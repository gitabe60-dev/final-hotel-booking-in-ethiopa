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

	// 5. CORS — allow React frontend + Flutter web on any localhost port
	r.Use(cors.New(cors.Config{
		AllowOriginFunc: func(origin string) bool {
			// Allow all origins in development — mobile apps, any browser, any IP
			if len(origin) == 0 { return true } // mobile apps (no Origin header)
			// Allow any localhost port (web dev server: 5173, 8080, 3000, etc.)
			if len(origin) >= 16 && (origin[:16] == "http://localhost" ||
				origin[:16] == "http://127.0.0.1") { return true }
			if len(origin) >= 17 && origin[:17] == "https://localhost" { return true }
			// Allow any LAN IP for real phones (10.x.x.x, 192.168.x.x, 172.x.x.x)
			if len(origin) >= 10 && origin[:10] == "http://10." { return true }
			if len(origin) >= 18 && origin[:18] == "http://192.168." { return true }
			if len(origin) >= 11 && origin[:11] == "http://172." { return true }
			// Allow configured frontend URL
			if origin == cfg.FrontendURL { return true }
			// Allow file:// for Flutter web in some environments
			if len(origin) >= 7 && origin[:7] == "file://" { return true }
			return false
		},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "Accept", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length", "Content-Type"},
		AllowCredentials: false,
		MaxAge:           12 * 3600,
	}))

	// 6. Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "hotel-booking-api"})
	})

	// Global OPTIONS handler — required for browser CORS preflight requests
	// The browser sends OPTIONS before every cross-origin request.
	// Without this, the browser gets 404 and shows a blank white screen.
	r.OPTIONS("/*path", func(c *gin.Context) {
		c.Status(204)
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
	log.Printf("[server] Hotel Booking API running on http://localhost%s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("[server] Failed to start: %v", err)
	}
}
