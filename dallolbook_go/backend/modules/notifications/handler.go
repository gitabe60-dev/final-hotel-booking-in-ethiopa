// modules/notifications/handler.go — notification HTTP handlers.
package notifications

import (
	"strconv"

	"dallolbook/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct{ model *Model }

func NewHandler(model *Model) *Handler { return &Handler{model: model} }

// GET /api/v1/notifications  — for regular users
func (h *Handler) ListUser(c *gin.Context) {
	userID := c.GetInt("user_id")
	list, _ := h.model.ForUser(userID)
	unread := h.model.CountUnreadUser(userID)
	utils.Success(c, "Notifications.", gin.H{"notifications": list, "unread": unread})
}

// POST /api/v1/notifications/:id/read
func (h *Handler) ReadUser(c *gin.Context) {
	userID := c.GetInt("user_id")
	id, _ := strconv.Atoi(c.Param("id"))
	h.model.MarkRead(id, userID, false)
	utils.Success(c, "Marked as read.", nil)
}

// POST /api/v1/notifications/read-all
func (h *Handler) ReadAllUser(c *gin.Context) {
	userID := c.GetInt("user_id")
	h.model.MarkAllRead(userID, false)
	utils.Success(c, "All notifications marked as read.", nil)
}

// GET /api/admin/manager/notifications  — for hotel manager
func (h *Handler) ListAdmin(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	list, _ := h.model.ForAdmin(adminID)
	unread := h.model.CountUnreadAdmin(adminID)
	utils.Success(c, "Notifications.", gin.H{"notifications": list, "unread": unread})
}

// POST /api/admin/manager/notifications/:id/read
func (h *Handler) ReadAdmin(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	id, _ := strconv.Atoi(c.Param("id"))
	h.model.MarkRead(id, adminID, true)
	utils.Success(c, "Marked as read.", nil)
}

// POST /api/admin/manager/notifications/read-all
func (h *Handler) ReadAllAdmin(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	h.model.MarkAllRead(adminID, true)
	utils.Success(c, "All notifications marked as read.", nil)
}
