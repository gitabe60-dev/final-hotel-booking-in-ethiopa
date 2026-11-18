// modules/booking/routes.go
package booking

import (
	"database/sql"

	"dallolbook/config"
	"dallolbook/middleware"

	"github.com/gin-gonic/gin"
)

func Register(rg *gin.RouterGroup, db *sql.DB, cfg *config.Config) {
	m := NewModel(db)
	h := NewHandler(m, db)
	auth := middleware.AuthRequired(cfg)

	g := rg.Group("/bookings", auth)
	{
		g.GET("",           h.Index)
		g.POST("",          h.Create)
		g.GET("/:id",       h.Show)
		g.POST("/:id/cancel", h.Cancel)
	}
}
