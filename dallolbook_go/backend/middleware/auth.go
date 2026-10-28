// middleware/auth.go — JWT authentication and role-based access control.
package middleware

import (
	"strings"

	"dallolbook/config"
	"dallolbook/utils"

	"github.com/gin-gonic/gin"
)

// AuthRequired validates the user JWT and injects claims into gin context.
func AuthRequired(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		token := extractBearer(c)
		if token == "" {
			utils.Unauthorized(c, "Authorization header required")
			c.Abort()
			return
		}
		claims, err := utils.ValidateToken(token, cfg.JWTSecret)
		if err != nil {
			utils.Unauthorized(c, "Invalid or expired token")
			c.Abort()
			return
		}
		c.Set("user_id", claims.UserID)
		c.Set("email", claims.Email)
		c.Set("role", claims.Role)
		c.Next()
	}
}

// AdminRequired validates the admin JWT.
func AdminRequired(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		token := extractBearer(c)
		if token == "" {
			utils.Unauthorized(c, "Authorization header required")
			c.Abort()
			return
		}
		claims, err := utils.ValidateToken(token, cfg.AdminJWTSecret)
		if err != nil {
			utils.Unauthorized(c, "Invalid or expired admin token")
			c.Abort()
			return
		}
		c.Set("admin_id", claims.UserID)
		c.Set("email", claims.Email)
		c.Set("role", claims.Role)
		c.Next()
	}
}

// RoleRequired checks that the admin has one of the allowed roles.
// Must come after AdminRequired.
func RoleRequired(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		role, _ := c.Get("role")
		for _, r := range roles {
			if role == r {
				c.Next()
				return
			}
		}
		utils.Forbidden(c, "You do not have permission to access this resource")
		c.Abort()
	}
}

func extractBearer(c *gin.Context) string {
	h := c.GetHeader("Authorization")
	if h == "" {
		return ""
	}
	parts := strings.SplitN(h, " ", 2)
	if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
		return ""
	}
	return parts[1]
}
