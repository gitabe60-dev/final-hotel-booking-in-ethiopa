// database/db.go — opens PostgreSQL connection pool and runs migrations on startup.
package database

import (
	"database/sql"
	"fmt"
	"log"

	"dallolbook/config"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/lib/pq"
)

func Connect(cfg *config.Config) *sql.DB {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.DBHost, cfg.DBPort, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBSSLMode,
	)

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("[db] open failed: %v", err)
	}
	if err := db.Ping(); err != nil {
		log.Fatalf("[db] ping failed: %v", err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	log.Printf("[db] connected → host=%s db=%s", cfg.DBHost, cfg.DBName)

	RunMigrations(db, cfg.DBName)

	return db
}

// RunMigrations applies all pending up migrations from database/migrations/.
func RunMigrations(db *sql.DB, dbName string) {
	driver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		log.Fatalf("[migrate] driver init failed: %v", err)
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://database/migrations",
		dbName,
		driver,
	)
	if err != nil {
		log.Fatalf("[migrate] init failed: %v", err)
	}

	upErr := m.Up()
	if upErr != nil && upErr != migrate.ErrNoChange {
		log.Fatalf("[migrate] up failed: %v", upErr)
	}

	version, dirty, _ := m.Version()
	if upErr == migrate.ErrNoChange {
		log.Printf("[migrate] already at version %d, no changes", version)
	} else {
		log.Printf("[migrate] applied migrations → version=%d dirty=%v", version, dirty)
	}
}
