// database/seeder.go — runs seed.sql once if the cities table is empty.
package database

import (
	"database/sql"
	_ "embed"
	"log"
)

//go:embed seed.sql
var seedSQL string

// RunSeeder executes seed.sql when the database has no city rows yet.
// It is idempotent: subsequent runs are no-ops because seed.sql uses
// ON CONFLICT DO NOTHING for set-based data.
func RunSeeder(db *sql.DB) {
	var count int
	db.QueryRow(`SELECT COUNT(*) FROM cities`).Scan(&count)
	if count > 0 {
		log.Printf("[seeder] already seeded (%d cities present), skipping", count)
		return
	}

	log.Println("[seeder] seeding initial data…")
	if _, err := db.Exec(seedSQL); err != nil {
		log.Fatalf("[seeder] failed: %v", err)
	}
	log.Println("[seeder] done — cities, hotels, room types, amenities, images, super admin inserted")
}
