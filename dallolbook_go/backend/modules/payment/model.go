// modules/payment/model.go
package payment

import (
	"database/sql"
	"time"
)

type Payment struct {
	ID            int        `json:"id"`
	BookingID     int        `json:"booking_id"`
	UserID        int        `json:"user_id"`
	Amount        float64    `json:"amount"`
	Currency      string     `json:"currency"`
	Method        string     `json:"method"`
	Status        string     `json:"status"`
	TransactionID *string    `json:"transaction_id"`
	GatewayRef    *string    `json:"gateway_ref"`
	ScreenshotURL *string    `json:"screenshot_url"`
	PaidAt        *time.Time `json:"paid_at"`
	CreatedAt     time.Time  `json:"created_at"`
}

type Model struct{ db *sql.DB }

func NewModel(db *sql.DB) *Model { return &Model{db: db} }

func (m *Model) GetByID(id, userID int) (*Payment, error) {
	p := &Payment{}
	err := m.db.QueryRow(`
		SELECT id,booking_id,user_id,amount,currency,method,status,
		       transaction_id,gateway_ref,screenshot_url,paid_at,created_at
		FROM payments WHERE id=$1 AND user_id=$2`, id, userID,
	).Scan(&p.ID, &p.BookingID, &p.UserID, &p.Amount, &p.Currency, &p.Method,
		&p.Status, &p.TransactionID, &p.GatewayRef, &p.ScreenshotURL, &p.PaidAt, &p.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return p, err
}

func (m *Model) GetByBooking(bookingID int) (*Payment, error) {
	p := &Payment{}
	err := m.db.QueryRow(`
		SELECT id,booking_id,user_id,amount,currency,method,status,
		       transaction_id,gateway_ref,screenshot_url,paid_at,created_at
		FROM payments WHERE booking_id=$1 ORDER BY created_at DESC LIMIT 1`, bookingID,
	).Scan(&p.ID, &p.BookingID, &p.UserID, &p.Amount, &p.Currency, &p.Method,
		&p.Status, &p.TransactionID, &p.GatewayRef, &p.ScreenshotURL, &p.PaidAt, &p.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return p, err
}

func (m *Model) Create(bookingID, userID int, amount float64, method string) (int, error) {
	var id int
	err := m.db.QueryRow(`
		INSERT INTO payments (booking_id,user_id,amount,currency,method,status)
		VALUES ($1,$2,$3,'ETB',$4,'pending') RETURNING id`,
		bookingID, userID, amount, method,
	).Scan(&id)
	return id, err
}

func (m *Model) MarkCompleted(id int, txID, gwRef string) error {
	now := time.Now()
	_, err := m.db.Exec(`
		UPDATE payments SET status='completed',transaction_id=$1,gateway_ref=$2,paid_at=$3
		WHERE id=$4`, txID, gwRef, now, id)
	return err
}

func (m *Model) MarkFailed(id int, reason string) error {
	_, err := m.db.Exec(`
		UPDATE payments SET status='failed',gateway_ref=$1 WHERE id=$2`, reason, id)
	return err
}

// SubmitPayment lets the user submit transaction proof (transaction_id + screenshot_url)
// for a pending payment. Sets status to 'submitted' (awaiting manager verification).
func (m *Model) SubmitPayment(paymentID, userID int, transactionID, screenshotURL string) error {
	_, err := m.db.Exec(`
		UPDATE payments
		SET transaction_id=$1, screenshot_url=$2, status='submitted'
		WHERE id=$3 AND user_id=$4 AND status='pending'`,
		transactionID, screenshotURL, paymentID, userID)
	return err
}

// ConfirmBooking sets booking status to confirmed after payment.
func (m *Model) ConfirmBooking(bookingID int) error {
	_, err := m.db.Exec(`UPDATE bookings SET status='confirmed' WHERE id=$1`, bookingID)
	return err
}

// GetBookingForUser checks ownership.
func (m *Model) GetBookingForUser(bookingID, userID int) (float64, string, bool) {
	var price float64
	var method string
	var found bool
	m.db.QueryRow(`
		SELECT total_price,payment_method FROM bookings
		WHERE id=$1 AND user_id=$2 AND status='pending'`, bookingID, userID,
	).Scan(&price, &method)
	found = price > 0
	return price, method, found
}
