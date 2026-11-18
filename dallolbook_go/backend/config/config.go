// config/config.go — loads all env vars into one typed struct.
// Every package imports this — never call os.Getenv directly elsewhere.
package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	AppPort string
	AppEnv  string

	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string

	JWTSecret      string
	JWTExpiryHours int

	AdminJWTSecret      string
	AdminJWTExpiryHours int

	SMTPHost     string
	SMTPPort     int
	SMTPUser     string
	SMTPPassword string
	SMTPFrom     string

	ChapaSecretKey string
	ChapaBaseURL   string

	FrontendURL string
}

func Load() *Config {
	if err := godotenv.Load(); err != nil {
		log.Println("[config] no .env file, reading OS environment")
	}

	jwtExpiry, _   := strconv.Atoi(env("JWT_EXPIRY_HOURS", "24"))
	adminExpiry, _ := strconv.Atoi(env("ADMIN_JWT_EXPIRY_HOURS", "8"))
	smtpPort, _    := strconv.Atoi(env("SMTP_PORT", "587"))

	return &Config{
		AppPort: env("APP_PORT", "8080"),
		AppEnv:  env("APP_ENV", "development"),

		DBHost:     env("DB_HOST", "127.0.0.1"),
		DBPort:     env("DB_PORT", "5432"),
		DBUser:     env("DB_USER", "postgres"),
		DBPassword: env("DB_PASSWORD", ""),
		DBName:     env("DB_NAME", "dallolbook"),
		DBSSLMode:  env("DB_SSLMODE", "disable"),

		JWTSecret:      env("JWT_SECRET", "change-me"),
		JWTExpiryHours: jwtExpiry,

		AdminJWTSecret:      env("ADMIN_JWT_SECRET", "admin-change-me"),
		AdminJWTExpiryHours: adminExpiry,

		SMTPHost:     env("SMTP_HOST", "smtp.gmail.com"),
		SMTPPort:     smtpPort,
		SMTPUser:     env("SMTP_USER", ""),
		SMTPPassword: env("SMTP_PASSWORD", ""),
		SMTPFrom:     env("SMTP_FROM", "noreply@dallolbook.com"),

		ChapaSecretKey: env("CHAPA_SECRET_KEY", ""),
		ChapaBaseURL:   env("CHAPA_BASE_URL", "https://api.chapa.co/v1"),

		FrontendURL: env("FRONTEND_URL", "http://localhost:5173"),
	}
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
