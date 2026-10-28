// modules/guest/model.go
package guest

import (
	"database/sql"
	"time"

	"dallolbook/utils"
)

type User struct {
	ID          int        `json:"id"`
	FirstName   string     `json:"first_name"`
	LastName    string     `json:"last_name"`
	Email       *string    `json:"email"`
	Phone       *string    `json:"phone"`
	PasswordHash string   `json:"-"`
	Nationality *string    `json:"nationality"`
	AvatarURL   *string    `json:"avatar_url"`
	Status      string     `json:"status"`
	IsVerified  bool       `json:"is_verified"`
	LastLogin   *time.Time `json:"last_login"`
}

type Model struct{ db *sql.DB }

func NewModel(db *sql.DB) *Model { return &Model{db: db} }

func (m *Model) GetByID(id int) (*User, error) {
	u := &User{}
	err := m.db.QueryRow(`
		SELECT id,first_name,last_name,email,phone,password_hash,
		       nationality,avatar_url,status,is_verified,last_login
		FROM users WHERE id=$1`, id,
	).Scan(&u.ID, &u.FirstName, &u.LastName, &u.Email, &u.Phone,
		&u.PasswordHash, &u.Nationality, &u.AvatarURL, &u.Status, &u.IsVerified, &u.LastLogin)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return u, err
}

func (m *Model) UpdateProfile(id int, firstName, lastName string, phone, nationality *string) error {
	_, err := m.db.Exec(`
		UPDATE users SET first_name=$1,last_name=$2,phone=$3,nationality=$4
		WHERE id=$5`, firstName, lastName, phone, nationality, id)
	return err
}

func (m *Model) UpdatePassword(id int, newPass string) error {
	hash, err := utils.HashPassword(newPass)
	if err != nil {
		return err
	}
	_, err = m.db.Exec(`UPDATE users SET password_hash=$1 WHERE id=$2`, hash, id)
	return err
}

func (m *Model) BookingCounts(userID int) map[string]int {
	rows, _ := m.db.Query(`SELECT status,COUNT(*) FROM bookings WHERE user_id=$1 GROUP BY status`, userID)
	defer rows.Close()
	counts := map[string]int{"pending": 0, "confirmed": 0, "cancelled": 0, "completed": 0}
	for rows.Next() {
		var s string
		var n int
		rows.Scan(&s, &n)
		counts[s] = n
	}
	return counts
}
