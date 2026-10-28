// modules/payment/routes.go
package payment

import (
	"database/sql"

	"dallolbook/config"
	"dallolbook/middleware"

	"github.com/gin-gonic/gin"
)

func Register(rg *gin.RouterGroup, db *sql.DB, cfg *config.Config) {
	m := NewModel(db)
	h := NewHandler(m)
	auth := middleware.AuthRequired(cfg)

	g := rg.Group("/payments")
	{
		g.POST("/initiate",            auth, h.Initiate)
		g.GET("/:id/status",           auth, h.Status)
		g.POST("/:id/submit",          auth, h.Submit)
		g.POST("/retry/:booking_id",   auth, h.Retry)
		g.POST("/webhook",                   h.Webhook) // public
	}
}
