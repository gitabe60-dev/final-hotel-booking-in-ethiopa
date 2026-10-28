// utils/otp.go — 6-digit OTP generation and email delivery.
package utils

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"net/smtp"

	"dallolbook/config"
)

// GenerateOTP returns a random zero-padded 6-digit string.
func GenerateOTP() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1_000_000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

// SendOTPEmail sends the OTP code to the given address via SMTP.
func SendOTPEmail(cfg *config.Config, toEmail, otp string) error {
	auth := smtp.PlainAuth("", cfg.SMTPUser, cfg.SMTPPassword, cfg.SMTPHost)

	msg := fmt.Sprintf(
		"From: %s\r\nTo: %s\r\nSubject: Your DallolBook OTP Code\r\n\r\n"+
			"Your one-time password is: %s\r\n\r\nThis code expires in 5 minutes.\r\nDo not share it with anyone.",
		cfg.SMTPFrom, toEmail, otp,
	)

	return smtp.SendMail(
		fmt.Sprintf("%s:%d", cfg.SMTPHost, cfg.SMTPPort),
		auth, cfg.SMTPFrom, []string{toEmail}, []byte(msg),
	)
}

// SendEmailNotification sends a generic email notification (e.g. payment status).
func SendEmailNotification(cfg *config.Config, toEmail, subject, body string) error {
	if toEmail == "" || cfg.SMTPUser == "" {
		return nil // silently skip if email not configured
	}
	auth := smtp.PlainAuth("", cfg.SMTPUser, cfg.SMTPPassword, cfg.SMTPHost)
	msg := fmt.Sprintf(
		"From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n%s",
		cfg.SMTPFrom, toEmail, subject, body,
	)
	return smtp.SendMail(
		fmt.Sprintf("%s:%d", cfg.SMTPHost, cfg.SMTPPort),
		auth, cfg.SMTPFrom, []string{toEmail}, []byte(msg),
	)
}
