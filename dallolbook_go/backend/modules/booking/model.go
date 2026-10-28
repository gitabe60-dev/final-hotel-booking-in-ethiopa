// modules/booking/model.go
package booking

import (
	"database/sql"
	"time"
)

type Booking struct {
	ID              int        `json:"id"`
	UserID          int        `json:"user_id"`
	HotelID         int        `json:"hotel_id"`
	HotelName       string     `json:"hotel_name"`
	HotelCity       string     `json:"hotel_city"`
	HotelImage      string     `json:"hotel_image"`
	RoomTypeID      *int       `json:"room_type_id"`
	RoomTypeName    *string    `json:"room_type_name"`
	CheckIn         string     `json:"check_in"`
	CheckOut        string     `json:"check_out"`
	Adults          int        `json:"adults"`
	Children        int        `json:"children"`
	Rooms           int        `json:"rooms"`
	TotalPrice      float64    `json:"total_price"`
	PaymentMethod   string     `json:"payment_method"`
	Status          string     `json:"status"`
	SpecialRequests *string    `json:"special_requests"`
	GuestFullName   string     `json:"guest_full_name"`
	GuestEmail      *string    `json:"guest_email"`
	GuestPhone      *string    `json:"guest_phone"`
	NationalIDFront *string    `json:"national_id_front"`
	NationalIDBack  *string    `json:"national_id_back"`
	CreatedAt       time.Time  `json:"created_at"`
}

type StatusCounts struct {
	Pending   int `json:"pending"`
	Confirmed int `json:"confirmed"`
	Cancelled int `json:"cancelled"`
	Completed int `json:"completed"`
}

type Model struct{ db *sql.DB }

func NewModel(db *sql.DB) *Model { return &Model{db: db} }

func (m *Model) GetUserBookings(userID int) ([]Booking, error) {
	rows, err := m.db.Query(`
		SELECT b.id,b.user_id,b.hotel_id,h.name,h.city,
		       COALESCE((SELECT image_url FROM hotel_images WHERE hotel_id=h.id ORDER BY sort_order LIMIT 1),''),
		       b.room_type_id,rt.name,
		       b.check_in::text,b.check_out::text,
		       b.adults,b.children,b.rooms,b.total_price,
		       b.payment_method,b.status,b.special_requests,
		       b.guest_full_name,b.guest_email,b.guest_phone,
		       b.national_id_front,b.national_id_back,b.created_at
		FROM bookings b
		JOIN hotels h ON h.id=b.hotel_id
		LEFT JOIN room_types rt ON rt.id=b.room_type_id
		WHERE b.user_id=$1 ORDER BY b.created_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return m.scan(rows)
}

func (m *Model) GetDetail(bookingID, userID int) (*Booking, error) {
	b := &Booking{}
	err := m.db.QueryRow(`
		SELECT b.id,b.user_id,b.hotel_id,h.name,h.city,
		       COALESCE((SELECT image_url FROM hotel_images WHERE hotel_id=h.id ORDER BY sort_order LIMIT 1),''),
		       b.room_type_id,rt.name,
		       b.check_in::text,b.check_out::text,
		       b.adults,b.children,b.rooms,b.total_price,
		       b.payment_method,b.status,b.special_requests,
		       b.guest_full_name,b.guest_email,b.guest_phone,
		       b.national_id_front,b.national_id_back,b.created_at
		FROM bookings b
		JOIN hotels h ON h.id=b.hotel_id
		LEFT JOIN room_types rt ON rt.id=b.room_type_id
		WHERE b.id=$1 AND b.user_id=$2`, bookingID, userID,
	).Scan(&b.ID, &b.UserID, &b.HotelID, &b.HotelName, &b.HotelCity, &b.HotelImage,
		&b.RoomTypeID, &b.RoomTypeName, &b.CheckIn, &b.CheckOut,
		&b.Adults, &b.Children, &b.Rooms, &b.TotalPrice,
		&b.PaymentMethod, &b.Status, &b.SpecialRequests,
		&b.GuestFullName, &b.GuestEmail, &b.GuestPhone,
		&b.NationalIDFront, &b.NationalIDBack, &b.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return b, err
}

func (m *Model) Create(b *Booking) (int, error) {
	var id int
	err := m.db.QueryRow(`
		INSERT INTO bookings
		  (user_id,hotel_id,room_type_id,check_in,check_out,adults,children,rooms,
		   total_price,payment_method,status,special_requests,
		   guest_full_name,guest_email,guest_phone,national_id_front,national_id_back)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,'pending',$11,$12,$13,$14,$15,$16)
		RETURNING id`,
		b.UserID, b.HotelID, b.RoomTypeID, b.CheckIn, b.CheckOut,
		b.Adults, b.Children, b.Rooms, b.TotalPrice, b.PaymentMethod, b.SpecialRequests,
		b.GuestFullName, b.GuestEmail, b.GuestPhone, b.NationalIDFront, b.NationalIDBack,
	).Scan(&id)
	return id, err
}

func (m *Model) Cancel(bookingID, userID int) (bool, error) {
	res, err := m.db.Exec(`
		UPDATE bookings SET status='cancelled'
		WHERE id=$1 AND user_id=$2 AND status IN ('pending','confirmed')`,
		bookingID, userID)
	if err != nil {
		return false, err
	}
	n, _ := res.RowsAffected()
	return n > 0, nil
}

func (m *Model) CountByStatus(userID int) (StatusCounts, error) {
	rows, err := m.db.Query(`SELECT status,COUNT(*) FROM bookings WHERE user_id=$1 GROUP BY status`, userID)
	if err != nil {
		return StatusCounts{}, err
	}
	defer rows.Close()
	var sc StatusCounts
	for rows.Next() {
		var s string
		var n int
		rows.Scan(&s, &n)
		switch s {
		case "pending":   sc.Pending = n
		case "confirmed": sc.Confirmed = n
		case "cancelled": sc.Cancelled = n
		case "completed": sc.Completed = n
		}
	}
	return sc, nil
}

func (m *Model) GetHotelPrice(hotelID int) (float64, bool) {
	var price float64
	var active bool
	m.db.QueryRow(`SELECT price_per_night,is_active FROM hotels WHERE id=$1`, hotelID).Scan(&price, &active)
	return price, active
}

// CreatePayment auto-creates a payment row when a booking is made.
func (m *Model) CreatePayment(bookingID, userID int, amount float64, method string) {
	m.db.Exec(`
		INSERT INTO payments (booking_id,user_id,amount,currency,method,status)
		VALUES ($1,$2,$3,'ETB',$4,'pending')`,
		bookingID, userID, amount, method)
}

func (m *Model) scan(rows *sql.Rows) ([]Booking, error) {
	var list []Booking
	for rows.Next() {
		var b Booking
		if err := rows.Scan(
			&b.ID, &b.UserID, &b.HotelID, &b.HotelName, &b.HotelCity, &b.HotelImage,
			&b.RoomTypeID, &b.RoomTypeName, &b.CheckIn, &b.CheckOut,
			&b.Adults, &b.Children, &b.Rooms, &b.TotalPrice,
			&b.PaymentMethod, &b.Status, &b.SpecialRequests,
			&b.GuestFullName, &b.GuestEmail, &b.GuestPhone,
			&b.NationalIDFront, &b.NationalIDBack, &b.CreatedAt,
		); err != nil {
			return nil, err
		}
		list = append(list, b)
	}
	return list, nil
}
