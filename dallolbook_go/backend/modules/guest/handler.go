// modules/guest/handler.go
package guest

import (
	"dallolbook/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct{ model *Model }

func NewHandler(model *Model) *Handler { return &Handler{model: model} }

// GET /api/v1/guest/profile
func (h *Handler) Profile(c *gin.Context) {
	userID := c.GetInt("user_id")
	user, err := h.model.GetByID(userID)
	if err != nil || user == nil {
		utils.NotFound(c, "User not found")
		return
	}
	counts := h.model.BookingCounts(userID)
	utils.Success(c, "Profile retrieved.", gin.H{
		"user":           user,
		"booking_counts": counts,
	})
}

// PUT /api/v1/guest/profile
func (h *Handler) UpdateProfile(c *gin.Context) {
	userID := c.GetInt("user_id")
	var body struct {
		FirstName   string  `json:"first_name"`
		LastName    string  `json:"last_name"`
		Phone       *string `json:"phone"`
		Nationality *string `json:"nationality"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		utils.BadRequest(c, "Invalid request body")
		return
	}
	if body.FirstName == "" || body.LastName == "" {
		utils.Unprocessable(c, "First name and last name are required")
		return
	}
	if err := h.model.UpdateProfile(userID, body.FirstName, body.LastName, body.Phone, body.Nationality); err != nil {
		utils.ServerError(c, "Failed to update profile")
		return
	}
	user, _ := h.model.GetByID(userID)
	utils.Success(c, "Profile updated.", user)
}

// POST /api/v1/guest/change-password
func (h *Handler) ChangePassword(c *gin.Context) {
	userID := c.GetInt("user_id")
	var body struct {
		CurrentPassword string `json:"current_password"`
		NewPassword     string `json:"new_password"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.CurrentPassword == "" || body.NewPassword == "" {
		utils.Unprocessable(c, "current_password and new_password are required")
		return
	}
	if len(body.NewPassword) < 6 {
		utils.Unprocessable(c, "New password must be at least 6 characters")
		return
	}

	user, _ := h.model.GetByID(userID)
	if user == nil || !utils.CheckPassword(body.CurrentPassword, user.PasswordHash) {
		utils.Unauthorized(c, "Current password is incorrect")
		return
	}

	h.model.UpdatePassword(userID, body.NewPassword)
	utils.Success(c, "Password changed successfully.", nil)
}
