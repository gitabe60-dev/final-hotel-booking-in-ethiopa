// modules/hotels/routes.go
package hotels

import (
	"database/sql"

	"dallolbook/config"
	"dallolbook/middleware"

	"github.com/gin-gonic/gin"
)

func Register(rg *gin.RouterGroup, db *sql.DB, cfg *config.Config) {
	m := NewModel(db)
	h := NewHandler(m)

	g := rg.Group("/hotels")
	{
		g.GET("/featured",                         h.Featured)
		g.GET("/search",                           h.Search)
		g.GET("/:id",                              h.Show)
		g.GET("/:id/availability",                 h.Availability)
		g.GET("/:id/payment-methods",             h.PaymentMethods)
		g.GET("/:id/reviews",                      h.GetReviews)
		g.POST("/:id/reviews", middleware.AuthRequired(cfg), h.PostReview)
	}
}
