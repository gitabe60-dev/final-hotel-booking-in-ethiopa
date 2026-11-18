// modules/guest/routes.go
package guest

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

	g := rg.Group("/guest", auth)
	{
		g.GET("/profile",          h.Profile)
		g.PUT("/profile",          h.UpdateProfile)
		g.POST("/change-password", h.ChangePassword)
	}
}
