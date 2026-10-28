// modules/notifications/routes.go — notification route registration.
package notifications

import (
	"database/sql"

	"dallolbook/config"
	"dallolbook/middleware"

	"github.com/gin-gonic/gin"
)

// RegisterUser registers user-facing notification routes under /api/v1.
func RegisterUser(rg *gin.RouterGroup, db *sql.DB, cfg *config.Config) {
	m := NewModel(db)
	h := NewHandler(m)
	auth := middleware.AuthRequired(cfg)

	g := rg.Group("/notifications", auth)
	{
		g.GET("",            h.ListUser)
		g.POST("/:id/read",  h.ReadUser)
		g.POST("/read-all",  h.ReadAllUser)
	}
}

// RegisterAdmin registers admin-facing notification routes under /api/admin/manager.
func RegisterAdmin(rg *gin.RouterGroup, db *sql.DB, cfg *config.Config) {
	m := NewModel(db)
	h := NewHandler(m)

	g := rg.Group("/notifications")
	{
		g.GET("",           h.ListAdmin)
		g.POST("/:id/read", h.ReadAdmin)
		g.POST("/read-all", h.ReadAllAdmin)
	}
}
