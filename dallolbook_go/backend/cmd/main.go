// cmd/main.go — application entry point. Wires all modules together.
package main

import (
	"log"

	"dallolbook/config"
	"dallolbook/database"
	"dallolbook/modules/admin"
	"dallolbook/modules/auth"
	"dallolbook/modules/booking"
	"dallolbook/modules/guest"
	"dallolbook/modules/hotels"
	"dallolbook/modules/notifications"
	"dallolbook/modules/payment"
	"dallolbook/modules/wishlist"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	// 1. Load config
	cfg := config.Load()

	// 2. Connect to PostgreSQL, run migrations, and seed initial data
	db := database.Connect(cfg)
	defer db.Close()
	database.RunSeeder(db)

	// 3. Set Gin mode
	if cfg.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 4. Create router
	r := gin.Default()

	// 5. CORS — allow React frontend
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{cfg.FrontendURL},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	// 6. Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "dallolbook-api"})
	})

	// 7. API v1 group
	v1 := r.Group("/api/v1")
	auth.Register(v1, db, cfg)
	hotels.Register(v1, db, cfg)
	booking.Register(v1, db, cfg)
	payment.Register(v1, db, cfg)
	wishlist.Register(v1, db, cfg)
	guest.Register(v1, db, cfg)
	notifications.RegisterUser(v1, db, cfg)

	// 8. Admin group (separate prefix)
	api := r.Group("/api")
	admin.Register(api, db, cfg)

	// Public cities endpoint (used by frontend search without auth)
	api.GET("/public/cities", func(c *gin.Context) {
		rows, err := db.Query(`SELECT id, name, region FROM cities WHERE is_active=true ORDER BY name`)
		if err != nil {
			c.JSON(500, gin.H{"success": false, "message": "Failed to load cities"})
			return
		}
		defer rows.Close()
		var cities []gin.H
		for rows.Next() {
			var id int
			var name, region string
			rows.Scan(&id, &name, &region)
			cities = append(cities, gin.H{"id": id, "name": name, "region": region})
		}
		if cities == nil {
			cities = []gin.H{}
		}
		c.JSON(200, gin.H{"success": true, "data": cities})
	})

	// 9. Start server
	addr := ":" + cfg.AppPort
	log.Printf("[server] DallolBook API running on http://localhost%s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("[server] Failed to start: %v", err)
	}
}
