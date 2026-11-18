// modules/wishlist/handler.go
package wishlist

import (
	"strconv"

	"dallolbook/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct{ model *Model }

func NewHandler(model *Model) *Handler { return &Handler{model: model} }

// GET /api/v1/wishlist
func (h *Handler) Index(c *gin.Context) {
	userID := c.GetInt("user_id")
	items, err := h.model.GetAll(userID)
	if err != nil {
		utils.ServerError(c, "Failed to fetch wishlist")
		return
	}
	utils.Success(c, "Wishlist retrieved.", items)
}

// POST /api/v1/wishlist  { hotel_id: int }
func (h *Handler) Toggle(c *gin.Context) {
	userID := c.GetInt("user_id")
	var body struct {
		HotelID int `json:"hotel_id"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.HotelID == 0 {
		utils.BadRequest(c, "hotel_id is required")
		return
	}

	action, err := h.model.Toggle(userID, body.HotelID)
	if err != nil {
		utils.ServerError(c, "Failed to update wishlist")
		return
	}
	utils.Success(c, "Wishlist updated.", gin.H{
		"action":      action,
		"wishlisted":  action == "added",
		"hotel_id":    body.HotelID,
	})
}

// DELETE /api/v1/wishlist/:hotel_id
func (h *Handler) Remove(c *gin.Context) {
	userID := c.GetInt("user_id")
	hotelID, _ := strconv.Atoi(c.Param("hotel_id"))

	if err := h.model.Remove(userID, hotelID); err != nil {
		utils.ServerError(c, "Failed to remove from wishlist")
		return
	}
	utils.Success(c, "Removed from wishlist.", nil)
}
