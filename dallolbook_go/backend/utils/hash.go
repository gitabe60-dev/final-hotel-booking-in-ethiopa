// utils/hash.go — bcrypt password hashing.
package utils

import "golang.org/x/crypto/bcrypt"

// HashPassword hashes a plain-text password with bcrypt cost 12.
func HashPassword(password string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	return string(b), err
}

// CheckPassword compares a plain password to a stored bcrypt hash.
func CheckPassword(plain, hash string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(plain)) == nil
}
