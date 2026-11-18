// modules/auth/routes.go — registers all auth routes on the router group.
package auth

import (
	"database/sql"

	"dallolbook/config"
	"dallolbook/middleware"

	"github.com/gin-gonic/gin"
)

// Register wires auth routes onto the provided /api/v1 group.
func Register(rg *gin.RouterGroup, db *sql.DB, cfg *config.Config) {
	m := NewModel(db)
	h := NewHandler(m, cfg)

	auth := rg.Group("/auth")
	{
		auth.POST("/register",        h.Register)
		auth.POST("/login",           h.Login)
		auth.POST("/otp/send",        h.SendOTP)
		auth.POST("/otp/verify",      h.VerifyOTP)
		auth.POST("/forgot-password", h.ForgotPassword)
		auth.POST("/reset-password",  h.ResetPassword)

		// Protected
		auth.POST("/logout", middleware.AuthRequired(cfg), h.Logout)
	}
}
