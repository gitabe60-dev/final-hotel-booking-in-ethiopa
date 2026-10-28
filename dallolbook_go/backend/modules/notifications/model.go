// modules/notifications/model.go — notification DB queries.
package notifications

import (
	"database/sql"
	"time"
)

type Notification struct {
	ID        int       `json:"id"`
	UserID    *int      `json:"user_id"`
	AdminID   *int      `json:"admin_id"`
	Type      string    `json:"type"`
	Title     string    `json:"title"`
	Message   string    `json:"message"`
	IsRead    bool      `json:"is_read"`
	BookingID *int      `json:"booking_id"`
	CreatedAt time.Time `json:"created_at"`
}

type Model struct{ db *sql.DB }

func NewModel(db *sql.DB) *Model { return &Model{db: db} }

// Create inserts a notification row.
func (m *Model) Create(userID, adminID *int, nType, title, message string, bookingID *int) error {
	_, err := m.db.Exec(`
		INSERT INTO notifications (user_id, admin_id, type, title, message, booking_id)
		VALUES ($1, $2, $3, $4, $5, $6)`,
		userID, adminID, nType, title, message, bookingID)
	return err
}

// ForUser returns all notifications for a user, newest first.
func (m *Model) ForUser(userID int) ([]Notification, error) {
	rows, err := m.db.Query(`
		SELECT id, user_id, admin_id, type, title, message, is_read, booking_id, created_at
		FROM notifications WHERE user_id=$1 ORDER BY created_at DESC LIMIT 50`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanRows(rows)
}

// ForAdmin returns all notifications for an admin (hotel manager), newest first.
func (m *Model) ForAdmin(adminID int) ([]Notification, error) {
	rows, err := m.db.Query(`
		SELECT id, user_id, admin_id, type, title, message, is_read, booking_id, created_at
		FROM notifications WHERE admin_id=$1 ORDER BY created_at DESC LIMIT 50`, adminID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanRows(rows)
}

// CountUnreadUser counts unread notifications for a user.
func (m *Model) CountUnreadUser(userID int) int {
	var n int
	m.db.QueryRow(`SELECT COUNT(*) FROM notifications WHERE user_id=$1 AND is_read=false`, userID).Scan(&n)
	return n
}

// CountUnreadAdmin counts unread notifications for an admin.
func (m *Model) CountUnreadAdmin(adminID int) int {
	var n int
	m.db.QueryRow(`SELECT COUNT(*) FROM notifications WHERE admin_id=$1 AND is_read=false`, adminID).Scan(&n)
	return n
}

// MarkRead sets is_read=true for one notification (scoped to user or admin).
func (m *Model) MarkRead(id int, userID int, isAdmin bool) error {
	if isAdmin {
		_, err := m.db.Exec(`UPDATE notifications SET is_read=true WHERE id=$1 AND admin_id=$2`, id, userID)
		return err
	}
	_, err := m.db.Exec(`UPDATE notifications SET is_read=true WHERE id=$1 AND user_id=$2`, id, userID)
	return err
}

// MarkAllRead marks all unread notifications as read for a user or admin.
func (m *Model) MarkAllRead(userID int, isAdmin bool) error {
	if isAdmin {
		_, err := m.db.Exec(`UPDATE notifications SET is_read=true WHERE admin_id=$1 AND is_read=false`, userID)
		return err
	}
	_, err := m.db.Exec(`UPDATE notifications SET is_read=true WHERE user_id=$1 AND is_read=false`, userID)
	return err
}

func scanRows(rows *sql.Rows) ([]Notification, error) {
	var list []Notification
	for rows.Next() {
		var n Notification
		if err := rows.Scan(&n.ID, &n.UserID, &n.AdminID, &n.Type, &n.Title,
			&n.Message, &n.IsRead, &n.BookingID, &n.CreatedAt); err != nil {
			return nil, err
		}
		list = append(list, n)
	}
	return list, nil
}
