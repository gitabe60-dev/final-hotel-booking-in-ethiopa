// modules/wishlist/routes.go
package wishlist

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

	g := rg.Group("/wishlist", auth)
	{
		g.GET("",                h.Index)
		g.POST("",               h.Toggle)
		g.DELETE("/:hotel_id",   h.Remove)
	}
}
