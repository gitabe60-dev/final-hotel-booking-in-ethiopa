// modules/booking/handler.go
package booking

import (
	"database/sql"
	"strconv"
	"time"

	"dallolbook/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	model *Model
	db    *sql.DB
}

func NewHandler(model *Model, db *sql.DB) *Handler { return &Handler{model: model, db: db} }

// GET /api/v1/bookings
func (h *Handler) Index(c *gin.Context) {
	userID := c.GetInt("user_id")
	bookings, err := h.model.GetUserBookings(userID)
	if err != nil {
		utils.ServerError(c, "Failed to fetch bookings")
		return
	}
	counts, _ := h.model.CountByStatus(userID)
	utils.Success(c, "Bookings retrieved.", gin.H{"bookings": bookings, "counts": counts})
}

// POST /api/v1/bookings
func (h *Handler) Create(c *gin.Context) {
	userID := c.GetInt("user_id")

	var body struct {
		HotelID         int     `json:"hotel_id"`
		RoomTypeID      *int    `json:"room_type_id"`
		CheckIn         string  `json:"check_in"`
		CheckOut        string  `json:"check_out"`
		Adults          int     `json:"adults"`
		Children        int     `json:"children"`
		Rooms           int     `json:"rooms"`
		PaymentMethod   string  `json:"payment_method"`
		SpecialRequests *string `json:"special_requests"`
		GuestFullName   string  `json:"guest_full_name"`
		GuestEmail      *string `json:"guest_email"`
		GuestPhone      *string `json:"guest_phone"`
		NationalIDFront *string `json:"national_id_front"`
		NationalIDBack  *string `json:"national_id_back"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		utils.BadRequest(c, "Invalid request body")
		return
	}

	// Validate required fields and constraints
	if body.HotelID == 0 || body.CheckIn == "" || body.CheckOut == "" ||
		body.Adults == 0 || body.Rooms == 0 || body.PaymentMethod == "" {
		utils.Unprocessable(c, "hotel_id, check_in, check_out, adults, rooms, payment_method are required")
		return
	}
	// Enforce maximum 2 rooms per booking
	if body.Rooms > 2 {
		utils.Unprocessable(c, "Maximum 2 rooms can be booked at a time")
		return
	}

	// Validate dates
	layout := "2006-01-02"
	inDate, err1 := time.Parse(layout, body.CheckIn)
	outDate, err2 := time.Parse(layout, body.CheckOut)
	if err1 != nil || err2 != nil {
		utils.Unprocessable(c, "Dates must be in YYYY-MM-DD format")
		return
	}
	if !outDate.After(inDate) {
		utils.Unprocessable(c, "Check-out date must be after check-in date")
		return
	}
	if inDate.Before(time.Now().Truncate(24 * time.Hour)) {
		utils.Unprocessable(c, "Check-in date cannot be in the past")
		return
	}

	// Validate payment method
	allowed := map[string]bool{
		"telebirr": true, "cbe_birr": true, "chapa": true,
		"bank_transfer": true, "awash_bank": true, "abyssinia": true,
		"dashen": true, "oromia_coop": true, "united": true,
		"nib": true, "wegagen": true, "bunna": true, "cooperative": true,
		"card": true, "mobile_money": true,
	}
	if !allowed[body.PaymentMethod] {
		utils.Unprocessable(c, "Invalid payment method")
		return
	}

	// Validate hotel
	price, active := h.model.GetHotelPrice(body.HotelID)
	if !active {
		utils.NotFound(c, "Hotel not found or unavailable")
		return
	}

	// Calculate total price: price × nights × rooms
	nights := outDate.Sub(inDate).Hours() / 24
	totalPrice := price * nights * float64(body.Rooms)

	b := &Booking{
		UserID:          userID,
		HotelID:         body.HotelID,
		RoomTypeID:      body.RoomTypeID,
		CheckIn:         body.CheckIn,
		CheckOut:        body.CheckOut,
		Adults:          body.Adults,
		Children:        body.Children,
		Rooms:           body.Rooms,
		TotalPrice:      totalPrice,
		PaymentMethod:   body.PaymentMethod,
		SpecialRequests: body.SpecialRequests,
		GuestFullName:   body.GuestFullName,
		GuestEmail:      body.GuestEmail,
		GuestPhone:      body.GuestPhone,
		NationalIDFront: body.NationalIDFront,
		NationalIDBack:  body.NationalIDBack,
	}

	id, err := h.model.Create(b)
	if err != nil {
		utils.ServerError(c, "Failed to create booking")
		return
	}

	// Auto-create payment record
	h.model.CreatePayment(id, userID, totalPrice, body.PaymentMethod)

	// Notify the hotel manager of the new booking (in-app notification)
	go h.notifyNewBooking(id, body.HotelID, userID, body.CheckIn, body.CheckOut, totalPrice)

	detail, _ := h.model.GetDetail(id, userID)
	utils.Created(c, "Booking created successfully.", detail)
}

// notifyNewBooking creates an in-app notification for the hotel manager.
func (h *Handler) notifyNewBooking(bookingID, hotelID, userID int, checkIn, checkOut string, total float64) {
	// Find the manager admin_id for this hotel
	var managerID int
	err := h.db.QueryRow(
		`SELECT admin_id FROM hotel_managers WHERE hotel_id=$1 LIMIT 1`, hotelID,
	).Scan(&managerID)
	if err != nil || managerID == 0 {
		return // no manager assigned, skip
	}

	// Get user name
	var firstName, lastName string
	h.db.QueryRow(`SELECT first_name, last_name FROM users WHERE id=$1`, userID).Scan(&firstName, &lastName)
	guestName := firstName + " " + lastName

	// Get hotel name
	var hotelName string
	h.db.QueryRow(`SELECT name FROM hotels WHERE id=$1`, hotelID).Scan(&hotelName)

	title := "New Booking Received"
	message := guestName + " booked " + hotelName + " for " + checkIn + " to " + checkOut +
		" (ETB " + strconv.FormatFloat(total, 'f', 0, 64) + "). Please verify the payment."

	h.db.Exec(`
		INSERT INTO notifications (admin_id, type, title, message, booking_id)
		VALUES ($1, 'booking_new', $2, $3, $4)`,
		managerID, title, message, bookingID)
}

// GET /api/v1/bookings/:id
func (h *Handler) Show(c *gin.Context) {
	userID := c.GetInt("user_id")
	id, _ := strconv.Atoi(c.Param("id"))

	booking, err := h.model.GetDetail(id, userID)
	if err != nil || booking == nil {
		utils.NotFound(c, "Booking not found")
		return
	}
	utils.Success(c, "Booking detail.", booking)
}

// POST /api/v1/bookings/:id/cancel
func (h *Handler) Cancel(c *gin.Context) {
	userID := c.GetInt("user_id")
	id, _ := strconv.Atoi(c.Param("id"))

	booking, _ := h.model.GetDetail(id, userID)
	if booking == nil {
		utils.NotFound(c, "Booking not found")
		return
	}
	if booking.Status != "pending" && booking.Status != "confirmed" {
		utils.BadRequest(c, "Only pending or confirmed bookings can be cancelled")
		return
	}

	ok, err := h.model.Cancel(id, userID)
	if err != nil || !ok {
		utils.ServerError(c, "Failed to cancel booking")
		return
	}
	utils.Success(c, "Booking cancelled successfully.", gin.H{"booking_id": id, "status": "cancelled"})
}
