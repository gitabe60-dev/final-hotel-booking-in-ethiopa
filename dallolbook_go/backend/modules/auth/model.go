// modules/auth/model.go — all DB queries for auth (users + otp_codes).
package auth

import (
	"database/sql"
	"time"

	"dallolbook/utils"
)

// User represents a row in the users table.
type User struct {
	ID             int        `json:"id"`
	FirstName      string     `json:"first_name"`
	LastName       string     `json:"last_name"`
	Email          *string    `json:"email"`
	Phone          *string    `json:"phone"`
	PasswordHash   string     `json:"-"`
	Nationality    *string    `json:"nationality"`
	AvatarURL      *string    `json:"avatar_url"`
	Status         string     `json:"status"`
	IsVerified     bool       `json:"is_verified"`
	LastLogin      *time.Time `json:"last_login"`
	RegisteredDate time.Time  `json:"registered_date"`
}

// SafeUser strips the password from a User for API responses.
func SafeUser(u User) map[string]any {
	return map[string]any{
		"id":              u.ID,
		"first_name":      u.FirstName,
		"last_name":       u.LastName,
		"email":           u.Email,
		"phone":           u.Phone,
		"nationality":     u.Nationality,
		"avatar_url":      u.AvatarURL,
		"status":          u.Status,
		"is_verified":     u.IsVerified,
		"last_login":      u.LastLogin,
		"registered_date": u.RegisteredDate,
	}
}

type Model struct{ db *sql.DB }

func NewModel(db *sql.DB) *Model { return &Model{db: db} }

// --- User queries ---

func (m *Model) FindByEmail(email string) (*User, error) {
	u := &User{}
	err := m.db.QueryRow(
		`SELECT id,first_name,last_name,email,phone,password_hash,nationality,
		        avatar_url,status,is_verified,last_login,registered_date
		 FROM users WHERE LOWER(email)=LOWER($1) LIMIT 1`, email,
	).Scan(&u.ID, &u.FirstName, &u.LastName, &u.Email, &u.Phone,
		&u.PasswordHash, &u.Nationality, &u.AvatarURL, &u.Status,
		&u.IsVerified, &u.LastLogin, &u.RegisteredDate)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return u, err
}

func (m *Model) FindByPhone(phone string) (*User, error) {
	u := &User{}
	err := m.db.QueryRow(
		`SELECT id,first_name,last_name,email,phone,password_hash,nationality,
		        avatar_url,status,is_verified,last_login,registered_date
		 FROM users WHERE phone=$1 LIMIT 1`, phone,
	).Scan(&u.ID, &u.FirstName, &u.LastName, &u.Email, &u.Phone,
		&u.PasswordHash, &u.Nationality, &u.AvatarURL, &u.Status,
		&u.IsVerified, &u.LastLogin, &u.RegisteredDate)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return u, err
}

func (m *Model) FindByID(id int) (*User, error) {
	u := &User{}
	err := m.db.QueryRow(
		`SELECT id,first_name,last_name,email,phone,password_hash,nationality,
		        avatar_url,status,is_verified,last_login,registered_date
		 FROM users WHERE id=$1 LIMIT 1`, id,
	).Scan(&u.ID, &u.FirstName, &u.LastName, &u.Email, &u.Phone,
		&u.PasswordHash, &u.Nationality, &u.AvatarURL, &u.Status,
		&u.IsVerified, &u.LastLogin, &u.RegisteredDate)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return u, err
}

func (m *Model) CreateUser(firstName, lastName string, email, phone, passwordPlain, nationality *string) (int, error) {
	var hash string
	var err error
	if passwordPlain != nil {
		hash, err = utils.HashPassword(*passwordPlain)
		if err != nil {
			return 0, err
		}
	}

	var id int
	err = m.db.QueryRow(
		`INSERT INTO users (first_name,last_name,email,phone,password_hash,nationality,status,is_verified)
		 VALUES ($1,$2,$3,$4,$5,$6,'active',false)
		 RETURNING id`,
		firstName, lastName, email, phone, hash, nationality,
	).Scan(&id)
	return id, err
}

func (m *Model) UpdateLastLogin(id int) {
	m.db.Exec(`UPDATE users SET last_login=NOW() WHERE id=$1`, id)
}

func (m *Model) MarkVerified(id int) {
	m.db.Exec(`UPDATE users SET is_verified=true, status='active' WHERE id=$1`, id)
}

func (m *Model) UpdatePassword(id int, newPasswordPlain string) error {
	hash, err := utils.HashPassword(newPasswordPlain)
	if err != nil {
		return err
	}
	_, err = m.db.Exec(`UPDATE users SET password_hash=$1 WHERE id=$2`, hash, id)
	return err
}

// --- OTP queries ---

// GenerateOTP creates a new OTP for phone+purpose (5-minute expiry).
func (m *Model) GenerateOTP(phone, purpose string) (string, error) {
	code, err := utils.GenerateOTP()
	if err != nil {
		return "", err
	}
	// Invalidate previous codes for this phone+purpose
	m.db.Exec(
		`UPDATE otp_codes SET used=true WHERE phone=$1 AND purpose=$2 AND used=false`,
		phone, purpose,
	)
	_, err = m.db.Exec(
		`INSERT INTO otp_codes (phone,code,purpose,expires_at) VALUES ($1,$2,$3,$4)`,
		phone, code, purpose, time.Now().Add(5*time.Minute),
	)
	return code, err
}

// VerifyOTP checks the code and marks it used. Returns true if valid.
func (m *Model) VerifyOTP(phone, code, purpose string) (bool, error) {
	var id int
	err := m.db.QueryRow(
		`SELECT id FROM otp_codes
		 WHERE phone=$1 AND code=$2 AND purpose=$3
		   AND used=false AND expires_at > NOW()
		 LIMIT 1`,
		phone, code, purpose,
	).Scan(&id)
	if err == sql.ErrNoRows {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	m.db.Exec(`UPDATE otp_codes SET used=true WHERE id=$1`, id)
	return true, nil
}
