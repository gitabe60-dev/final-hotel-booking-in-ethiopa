// modules/payment/handler.go
package payment

import (
	"strconv"

	"dallolbook/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct{ model *Model }

func NewHandler(model *Model) *Handler { return &Handler{model: model} }

// POST /api/v1/payments/initiate
func (h *Handler) Initiate(c *gin.Context) {
	userID := c.GetInt("user_id")

	var body struct {
		BookingID int    `json:"booking_id"`
		Method    string `json:"method"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.BookingID == 0 {
		utils.BadRequest(c, "booking_id is required")
		return
	}

	price, method, found := h.model.GetBookingForUser(body.BookingID, userID)
	if !found {
		utils.NotFound(c, "Pending booking not found")
		return
	}
	if body.Method != "" {
		method = body.Method
	}

	id, err := h.model.Create(body.BookingID, userID, price, method)
	if err != nil {
		utils.ServerError(c, "Failed to initiate payment")
		return
	}

	// TODO: integrate Chapa / Telebirr / CBE-Birr gateway here.
	// Return a checkout_url once gateway is connected.
	utils.Created(c, "Payment initiated.", gin.H{
		"payment_id":   id,
		"amount":       price,
		"currency":     "ETB",
		"method":       method,
		"checkout_url": "", // filled by gateway
	})
}

// GET /api/v1/payments/:id/status
func (h *Handler) Status(c *gin.Context) {
	userID := c.GetInt("user_id")
	id, _ := strconv.Atoi(c.Param("id"))

	p, err := h.model.GetByID(id, userID)
	if err != nil || p == nil {
		utils.NotFound(c, "Payment not found")
		return
	}
	utils.Success(c, "Payment status.", p)
}

// POST /api/v1/payments/retry/:booking_id
func (h *Handler) Retry(c *gin.Context) {
	userID := c.GetInt("user_id")
	bookingID, _ := strconv.Atoi(c.Param("booking_id"))

	price, method, found := h.model.GetBookingForUser(bookingID, userID)
	if !found {
		utils.NotFound(c, "Pending booking not found")
		return
	}

	id, err := h.model.Create(bookingID, userID, price, method)
	if err != nil {
		utils.ServerError(c, "Failed to create retry payment")
		return
	}
	utils.Created(c, "Retry payment created.", gin.H{"payment_id": id, "amount": price})
}

// POST /api/v1/payments/:id/submit  (user uploads transaction proof)
func (h *Handler) Submit(c *gin.Context) {
	userID := c.GetInt("user_id")
	id, _ := strconv.Atoi(c.Param("id"))

	var body struct {
		TransactionID string `json:"transaction_id"`
		ScreenshotURL string `json:"screenshot_url"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.TransactionID == "" {
		utils.BadRequest(c, "transaction_id is required")
		return
	}

	if err := h.model.SubmitPayment(id, userID, body.TransactionID, body.ScreenshotURL); err != nil {
		utils.ServerError(c, "Failed to submit payment proof")
		return
	}
	utils.Success(c, "Payment submitted for verification.", nil)
}

// POST /api/v1/payments/webhook  (public — called by payment gateway)
func (h *Handler) Webhook(c *gin.Context) {
	var body struct {
		PaymentID     int    `json:"payment_id"`
		Status        string `json:"status"`
		TransactionID string `json:"transaction_id"`
		GatewayRef    string `json:"gateway_ref"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		utils.BadRequest(c, "Invalid webhook payload")
		return
	}

	if body.Status == "success" {
		p, _ := h.model.GetByBooking(body.PaymentID)
		if p != nil {
			h.model.MarkCompleted(p.ID, body.TransactionID, body.GatewayRef)
			h.model.ConfirmBooking(p.BookingID)
		}
	}
	utils.Success(c, "Webhook received.", nil)
}
