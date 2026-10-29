// modules/admin/handler.go — handlers for all 4 admin roles.
package admin

import (
	"strconv"

	"dallolbook/config"
	"dallolbook/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	model *Model
	cfg   *config.Config
}

func NewHandler(model *Model, cfg *config.Config) *Handler {
	return &Handler{model: model, cfg: cfg}
}

// ─── Admin Auth ──────────────────────────────────────────────────────────────

// POST /api/admin/login
func (h *Handler) Login(c *gin.Context) {
	var body struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.Email == "" || body.Password == "" {
		utils.Unprocessable(c, "Email and password are required")
		return
	}

	admin, _ := h.model.FindAdminByEmail(body.Email)
	if admin == nil || !utils.CheckPassword(body.Password, admin.PasswordHash) {
		utils.Unauthorized(c, "Invalid email or password")
		return
	}
	if admin.Status != "active" {
		utils.Forbidden(c, "Your account is not active")
		return
	}

	h.model.UpdateAdminLastLogin(admin.ID)
	token, _ := utils.GenerateToken(admin.ID, admin.Email, admin.Role, h.cfg.AdminJWTSecret, h.cfg.AdminJWTExpiryHours)

	utils.Success(c, "Login successful.", gin.H{
		"admin": gin.H{
			"id": admin.ID, "full_name": admin.FullName,
			"email": admin.Email, "role": admin.Role,
		},
		"token": token,
	})
}

// GET /api/admin/profile
func (h *Handler) Profile(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	admin, _ := h.model.FindAdminByID(adminID)
	if admin == nil {
		utils.NotFound(c, "Admin not found")
		return
	}
	utils.Success(c, "Profile.", gin.H{
		"id": admin.ID, "full_name": admin.FullName, "email": admin.Email,
		"phone": admin.Phone, "role": admin.Role, "status": admin.Status,
		"unread_messages": h.model.CountUnread(adminID),
	})
}

// PUT /api/admin/profile
func (h *Handler) UpdateProfile(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	var body struct {
		FullName string  `json:"full_name"`
		Phone    *string `json:"phone"`
	}
	c.ShouldBindJSON(&body)
	h.model.UpdateAdminProfile(adminID, body.FullName, body.Phone)
	utils.Success(c, "Profile updated.", nil)
}

// POST /api/admin/change-password
func (h *Handler) ChangePassword(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	var body struct {
		CurrentPassword string `json:"current_password"`
		NewPassword     string `json:"new_password"`
	}
	c.ShouldBindJSON(&body)

	admin, _ := h.model.FindAdminByID(adminID)
	if admin == nil || !utils.CheckPassword(body.CurrentPassword, admin.PasswordHash) {
		utils.Unauthorized(c, "Current password is incorrect")
		return
	}
	if len(body.NewPassword) < 6 {
		utils.Unprocessable(c, "New password must be at least 6 characters")
		return
	}
	h.model.UpdateAdminPassword(adminID, body.NewPassword)
	utils.Success(c, "Password changed.", nil)
}

// ─── Super Admin ─────────────────────────────────────────────────────────────

// GET /api/admin/super/dashboard
func (h *Handler) SuperDashboard(c *gin.Context) {
	overview := h.model.GetOverview()
	bookings, _ := h.model.GetBookings("", "", 8)
	utils.Success(c, "Super admin dashboard.", gin.H{
		"overview": overview,
		"recent_bookings": bookings,
	})
}

// GET /api/admin/super/sub-admins
func (h *Handler) SubAdmins(c *gin.Context) {
	list, _ := h.model.GetSubAdmins()
	utils.Success(c, "Sub-admins.", list)
}

// POST /api/admin/super/sub-admins
func (h *Handler) CreateSubAdmin(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	var body struct {
		FullName string `json:"full_name"`
		Email    string `json:"email"`
		Phone    string `json:"phone"`
		Password string `json:"password"`
		City     string `json:"city"`
	}
	c.ShouldBindJSON(&body)
	if body.FullName == "" || body.Email == "" || body.Password == "" {
		utils.Unprocessable(c, "full_name, email, password are required")
		return
	}
	id, err := h.model.CreateSubAdmin(body.FullName, body.Email, body.Phone, body.Password, adminID)
	if err != nil {
		utils.ServerError(c, "Failed to create sub-admin")
		return
	}
	if body.City != "" {
		h.model.AssignCity(id, body.City, adminID)
	}
	utils.Created(c, "Sub-admin created.", gin.H{"id": id})
}

// PUT /api/admin/super/sub-admins/:id
func (h *Handler) EditSubAdmin(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var body struct {
		FullName string `json:"full_name"`
		Email    string `json:"email"`
		Phone    string `json:"phone"`
		Status   string `json:"status"`
	}
	c.ShouldBindJSON(&body)
	h.model.UpdateSubAdmin(id, body.FullName, body.Email, body.Phone, body.Status)
	utils.Success(c, "Sub-admin updated.", nil)
}

// DELETE /api/admin/super/sub-admins/:id
func (h *Handler) DeleteSubAdmin(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	h.model.SoftDeleteAdmin(id)
	utils.Success(c, "Sub-admin deactivated.", nil)
}

// POST /api/admin/super/sub-admins/:id/assign-city
func (h *Handler) AssignCity(c *gin.Context) {
	adminID_param, _ := strconv.Atoi(c.Param("id"))
	callerID := c.GetInt("admin_id")
	var body struct{ City string `json:"city"` }
	c.ShouldBindJSON(&body)
	h.model.AssignCity(adminID_param, body.City, callerID)
	utils.Success(c, "City assigned.", nil)
}

// DELETE /api/admin/super/sub-admins/:id/revoke-city/:city
func (h *Handler) RevokeCity(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	city := c.Param("city")
	h.model.RevokeCity(id, city)
	utils.Success(c, "City revoked.", nil)
}

// GET /api/admin/super/hotels
func (h *Handler) SuperHotels(c *gin.Context) {
	hotels, _ := h.model.GetAllHotels("", c.Query("search"))
	utils.Success(c, "Hotels.", hotels)
}

// POST /api/admin/super/hotels
func (h *Handler) AddHotel(c *gin.Context) {
	var body struct {
		Name        string  `json:"name"`
		City        string  `json:"city"`
		Address     string  `json:"address"`
		Description string  `json:"description"`
		Type        string  `json:"type"`
		Price       float64 `json:"price_per_night"`
		Lat         float64 `json:"latitude"`
		Lng         float64 `json:"longitude"`
		IsFeatured  bool    `json:"is_featured"`
		ImageURL    string  `json:"image_url"`
	}
	c.ShouldBindJSON(&body)
	if body.Name == "" || body.City == "" {
		utils.Unprocessable(c, "name and city are required")
		return
	}
	id, err := h.model.CreateHotel(body.Name, body.City, body.Address, body.Description, body.Type, body.Price, body.Lat, body.Lng, body.IsFeatured)
	if err != nil {
		utils.ServerError(c, "Failed to create hotel")
		return
	}
	if body.ImageURL != "" {
		h.model.AddHotelImage(id, body.ImageURL, 0, true)
	}
	utils.Created(c, "Hotel created.", gin.H{"id": id})
}

// PUT /api/admin/super/hotels/:id
func (h *Handler) EditHotel(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var body struct {
		Name        string  `json:"name"`
		City        string  `json:"city"`
		Address     string  `json:"address"`
		Description string  `json:"description"`
		Type        string  `json:"type"`
		Price       float64 `json:"price_per_night"`
		IsActive    bool    `json:"is_active"`
	}
	c.ShouldBindJSON(&body)
	h.model.UpdateHotel(id, body.Name, body.City, body.Address, body.Description, body.Type, body.Price, body.IsActive)
	utils.Success(c, "Hotel updated.", nil)
}

// POST /api/admin/super/hotels/:id/toggle
func (h *Handler) ToggleHotel(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	h.model.ToggleHotel(id)
	utils.Success(c, "Hotel status toggled.", nil)
}

// GET /api/admin/super/bookings
func (h *Handler) SuperBookings(c *gin.Context) {
	bookings, _ := h.model.GetBookings("", c.Query("status"), 100)
	utils.Success(c, "Bookings.", bookings)
}

// GET /api/admin/super/users
func (h *Handler) Users(c *gin.Context) {
	guests, _ := h.model.GetGuests(c.Query("search"))
	utils.Success(c, "Users.", guests)
}

// GET /api/admin/super/brokers
func (h *Handler) SuperBrokers(c *gin.Context) {
	brokers, _ := h.model.GetBrokers(0)
	utils.Success(c, "Brokers.", brokers)
}

// GET /api/admin/super/managers
func (h *Handler) SuperManagers(c *gin.Context) {
	managers, _ := h.model.GetManagers(0)
	utils.Success(c, "Managers.", managers)
}

// GET /api/admin/super/cities
func (h *Handler) Cities(c *gin.Context) {
	cities, _ := h.model.GetCities()
	utils.Success(c, "Cities.", cities)
}

// POST /api/admin/super/cities
func (h *Handler) AddCity(c *gin.Context) {
	var body struct {
		Name   string `json:"name"`
		Region string `json:"region"`
	}
	c.ShouldBindJSON(&body)
	h.model.AddCity(body.Name, body.Region)
	utils.Created(c, "City added.", nil)
}

// DELETE /api/admin/super/cities/:id
func (h *Handler) DeleteCity(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	h.model.DeleteCity(id)
	utils.Success(c, "City deleted.", nil)
}

// ─── Sub Admin ───────────────────────────────────────────────────────────────

// GET /api/admin/subadmin/dashboard
func (h *Handler) SubDashboard(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	city := h.model.GetSubAdminCity(adminID)
	bookings, _ := h.model.GetBookings(city, "", 8)
	hotels, _ := h.model.GetAllHotels(city, "")
	managers, _ := h.model.GetManagers(adminID)
	brokers, _ := h.model.GetBrokers(adminID)
	utils.Success(c, "Sub-admin dashboard.", gin.H{
		"city": city, "hotels": hotels,
		"recent_bookings": bookings, "brokers": brokers,
		"managers": managers,
	})
}

// GET /api/admin/subadmin/hotels
func (h *Handler) SubHotels(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	city := h.model.GetSubAdminCity(adminID)
	hotels, _ := h.model.GetAllHotels(city, c.Query("search"))
	utils.Success(c, "Hotels.", hotels)
}

// POST /api/admin/subadmin/hotels  — sub-admin creates a hotel in their city
func (h *Handler) SubAddHotel(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	city := h.model.GetSubAdminCity(adminID)
	if city == "" {
		utils.Forbidden(c, "No city assigned to your account")
		return
	}
	var body struct {
		Name        string  `json:"name"`
		Address     string  `json:"address"`
		Description string  `json:"description"`
		Type        string  `json:"type"`
		Price       float64 `json:"price_per_night"`
		Lat         float64 `json:"latitude"`
		Lng         float64 `json:"longitude"`
		IsFeatured  bool    `json:"is_featured"`
		ImageURL    string  `json:"image_url"`
	}
	c.ShouldBindJSON(&body)
	if body.Name == "" {
		utils.Unprocessable(c, "Hotel name is required")
		return
	}
	id, err := h.model.CreateHotel(body.Name, city, body.Address, body.Description, body.Type, body.Price, body.Lat, body.Lng, body.IsFeatured)
	if err != nil {
		utils.ServerError(c, "Failed to create hotel")
		return
	}
	if body.ImageURL != "" {
		h.model.AddHotelImage(id, body.ImageURL, 0, true)
	}
	utils.Created(c, "Hotel created.", gin.H{"id": id})
}

// PUT /api/admin/subadmin/hotels/:id  — sub-admin edits a hotel
func (h *Handler) SubEditHotel(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var body struct {
		Name        string  `json:"name"`
		Address     string  `json:"address"`
		Description string  `json:"description"`
		Type        string  `json:"type"`
		Price       float64 `json:"price_per_night"`
		IsActive    bool    `json:"is_active"`
		ImageURL    string  `json:"image_url"`
	}
	c.ShouldBindJSON(&body)
	// Preserve city (don't let sub-admin change city)
	adminID := c.GetInt("admin_id")
	city := h.model.GetSubAdminCity(adminID)
	h.model.UpdateHotel(id, body.Name, city, body.Address, body.Description, body.Type, body.Price, body.IsActive)
	if body.ImageURL != "" {
		h.model.AddHotelImage(id, body.ImageURL, 0, true)
	}
	utils.Success(c, "Hotel updated.", nil)
}

// POST /api/admin/subadmin/hotels/:id/toggle
func (h *Handler) SubToggleHotel(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	h.model.ToggleHotel(id)
	utils.Success(c, "Hotel status toggled.", nil)
}

// GET /api/admin/subadmin/hotels/:id/rooms
func (h *Handler) Rooms(c *gin.Context) {
	hotelID, _ := strconv.Atoi(c.Param("id"))
	rooms, _ := h.model.GetRooms(hotelID)
	utils.Success(c, "Rooms.", rooms)
}

// POST /api/admin/subadmin/hotels/:id/rooms
func (h *Handler) AddRoom(c *gin.Context) {
	hotelID, _ := strconv.Atoi(c.Param("id"))
	var body struct {
		Name       string  `json:"name"`
		BedType    string  `json:"bed_type"`
		Price      float64 `json:"price_per_night"`
		MaxGuests  int     `json:"max_guests"`
		ImageURL   string  `json:"image_url"`
		RoomStatus string  `json:"room_status"`
	}
	c.ShouldBindJSON(&body)
	id, err := h.model.CreateRoom(hotelID, body.Name, body.BedType, body.Price, body.MaxGuests, body.ImageURL, body.RoomStatus)
	if err != nil {
		utils.ServerError(c, "Failed to create room")
		return
	}
	utils.Created(c, "Room created.", gin.H{"id": id})
}

// PUT /api/admin/subadmin/hotels/:id/rooms/:rid
func (h *Handler) EditRoom(c *gin.Context) {
	rid, _ := strconv.Atoi(c.Param("rid"))
	var body struct {
		Name      string  `json:"name"`
		BedType   string  `json:"bed_type"`
		Price     float64 `json:"price_per_night"`
		MaxGuests int     `json:"max_guests"`
	}
	c.ShouldBindJSON(&body)
	h.model.UpdateRoom(rid, body.Name, body.BedType, body.Price, body.MaxGuests)
	utils.Success(c, "Room updated.", nil)
}

// DELETE /api/admin/subadmin/hotels/:id/rooms/:rid
func (h *Handler) DeleteRoom(c *gin.Context) {
	rid, _ := strconv.Atoi(c.Param("rid"))
	h.model.DeleteRoom(rid)
	utils.Success(c, "Room deleted.", nil)
}

// POST /api/admin/subadmin/hotels/:id/rooms/:rid/toggle
func (h *Handler) ToggleRoom(c *gin.Context) {
	rid, _ := strconv.Atoi(c.Param("rid"))
	h.model.ToggleRoom(rid)
	utils.Success(c, "Room availability toggled.", nil)
}

// POST /api/admin/manager/rooms/:rid/status — set room status (available/maintenance/unavailable)
func (h *Handler) SetRoomStatus(c *gin.Context) {
	rid, _ := strconv.Atoi(c.Param("rid"))
	var body struct{ Status string `json:"status"` }
	c.ShouldBindJSON(&body)
	allowed := map[string]bool{"available": true, "maintenance": true, "unavailable": true}
	if !allowed[body.Status] {
		utils.BadRequest(c, "Status must be: available, maintenance, or unavailable")
		return
	}
	if err := h.model.SetRoomStatus(rid, body.Status); err != nil {
		utils.ServerError(c, "Failed to update room status")
		return
	}
	utils.Success(c, "Room status updated.", nil)
}

// GET /api/admin/subadmin/bookings
func (h *Handler) SubBookings(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	city := h.model.GetSubAdminCity(adminID)
	bookings, _ := h.model.GetBookings(city, c.Query("status"), 100)
	utils.Success(c, "Bookings.", bookings)
}

// GET /api/admin/subadmin/brokers
func (h *Handler) SubBrokers(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	brokers, _ := h.model.GetBrokers(adminID)
	utils.Success(c, "Brokers.", brokers)
}

// POST /api/admin/subadmin/brokers
func (h *Handler) CreateBroker(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	var body struct {
		FullName      string  `json:"full_name"`
		Email         string  `json:"email"`
		Phone         string  `json:"phone"`
		Password      string  `json:"password"`
		City          string  `json:"city"`
		CommissionPct float64 `json:"commission_pct"`
	}
	c.ShouldBindJSON(&body)
	id, err := h.model.CreateBroker(body.FullName, body.Email, body.Phone, body.Password, body.City, body.CommissionPct, adminID, adminID)
	if err != nil {
		utils.ServerError(c, "Failed to create broker")
		return
	}
	utils.Created(c, "Broker created.", gin.H{"id": id})
}

// GET /api/admin/subadmin/managers
func (h *Handler) SubManagers(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	managers, _ := h.model.GetManagers(adminID)
	utils.Success(c, "Managers.", managers)
}

// ─── Broker ──────────────────────────────────────────────────────────────────

// GET /api/admin/broker/dashboard
func (h *Handler) BrokerDashboard(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	unread := h.model.CountUnread(adminID)
	inbox, _ := h.model.GetInbox(adminID)
	utils.Success(c, "Broker dashboard.", gin.H{
		"unread_messages": unread,
		"inbox":           inbox,
	})
}

// GET /api/admin/broker/bookings
func (h *Handler) BrokerBookings(c *gin.Context) {
	bookings, _ := h.model.GetBookings("", c.Query("status"), 100)
	utils.Success(c, "Bookings.", bookings)
}

// GET /api/admin/broker/inbox
func (h *Handler) Inbox(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	msgs, _ := h.model.GetInbox(adminID)
	utils.Success(c, "Inbox.", msgs)
}

// GET /api/admin/broker/sent
func (h *Handler) Sent(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	msgs, _ := h.model.GetSent(adminID)
	utils.Success(c, "Sent messages.", msgs)
}

// GET /api/admin/broker/messages/:id
func (h *Handler) ViewMessage(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	id, _ := strconv.Atoi(c.Param("id"))
	msg, _ := h.model.GetMessage(id, adminID)
	if msg == nil {
		utils.NotFound(c, "Message not found")
		return
	}
	utils.Success(c, "Message.", msg)
}

// POST /api/admin/broker/messages
func (h *Handler) SendMessage(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	var body struct {
		ToAdmin  int     `json:"to_admin"`
		Subject  string  `json:"subject"`
		Body     string  `json:"body"`
		HotelID  *int    `json:"hotel_id"`
		ParentID *int    `json:"parent_id"`
	}
	c.ShouldBindJSON(&body)
	id, err := h.model.SendMessage(adminID, body.ToAdmin, body.Subject, body.Body, body.HotelID, body.ParentID)
	if err != nil {
		utils.ServerError(c, "Failed to send message")
		return
	}
	utils.Created(c, "Message sent.", gin.H{"id": id})
}

// ─── Hotel Manager ────────────────────────────────────────────────────────────

// GET /api/admin/manager/dashboard
func (h *Handler) ManagerDashboard(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	hotelID := h.model.GetManagerHotelID(adminID)
	rooms, _ := h.model.GetRooms(hotelID)
	bookings, _ := h.model.GetBookings("", "", 8)
	unread := h.model.CountUnread(adminID)
	utils.Success(c, "Manager dashboard.", gin.H{
		"hotel_id": hotelID, "rooms": rooms,
		"recent_bookings": bookings, "unread_messages": unread,
	})
}

// GET /api/admin/manager/rooms
func (h *Handler) ManagerRooms(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	hotelID := h.model.GetManagerHotelID(adminID)
	rooms, _ := h.model.GetRooms(hotelID)
	utils.Success(c, "Rooms.", rooms)
}

// GET /api/admin/manager/bookings
func (h *Handler) ManagerBookings(c *gin.Context) {
	bookings, _ := h.model.GetBookings("", c.Query("status"), 100)
	utils.Success(c, "Bookings.", bookings)
}

// POST /api/admin/manager/bookings/:id/status
func (h *Handler) UpdateBookingStatus(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var body struct{ Status string `json:"status"` }
	c.ShouldBindJSON(&body)
	allowed := map[string]bool{"confirmed": true, "cancelled": true, "completed": true}
	if !allowed[body.Status] {
		utils.BadRequest(c, "Invalid status. Use: confirmed, cancelled, completed")
		return
	}
	h.model.UpdateBookingStatus(id, body.Status)
	utils.Success(c, "Booking status updated.", nil)
}

// ─── Sub Admin: Create Manager ───────────────────────────────────────────────

// POST /api/admin/subadmin/managers
func (h *Handler) CreateManager(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	var body struct {
		FullName string `json:"full_name"`
		Email    string `json:"email"`
		Phone    string `json:"phone"`
		Password string `json:"password"`
		HotelID  int    `json:"hotel_id"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.Email == "" || body.Password == "" || body.HotelID == 0 {
		utils.BadRequest(c, "full_name, email, password, hotel_id are required")
		return
	}
	id, err := h.model.CreateManager(body.FullName, body.Email, body.Phone, body.Password, body.HotelID, adminID)
	if err != nil {
		utils.ServerError(c, "Failed to create hotel manager")
		return
	}
	utils.Created(c, "Hotel manager created.", gin.H{"id": id})
}

// DELETE /api/admin/subadmin/managers/:id
func (h *Handler) DeleteManager(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := h.model.DeleteManager(id); err != nil {
		utils.ServerError(c, "Failed to delete manager")
		return
	}
	utils.Success(c, "Manager removed.", nil)
}

// ─── Sub Admin: Hotel Payment Methods ─────────────────────────────────────────

// GET /api/admin/subadmin/hotels/:id/payment-methods
func (h *Handler) HotelPaymentMethods(c *gin.Context) {
	hotelID, _ := strconv.Atoi(c.Param("id"))
	methods, _ := h.model.GetHotelPaymentMethods(hotelID)
	utils.Success(c, "Payment methods.", methods)
}

// POST /api/admin/subadmin/hotels/:id/payment-methods
func (h *Handler) AddPaymentMethod(c *gin.Context) {
	hotelID, _ := strconv.Atoi(c.Param("id"))
	var body struct {
		Method        string `json:"method"`
		AccountName   string `json:"account_name"`
		AccountNumber string `json:"account_number"`
		PhoneNumber   string `json:"phone_number"`
		Instructions  string `json:"instructions"`
	}
	c.ShouldBindJSON(&body)
	if body.Method == "" {
		utils.BadRequest(c, "Payment method is required")
		return
	}
	id, err := h.model.AddPaymentMethod(hotelID, body.Method, body.AccountName, body.AccountNumber, body.PhoneNumber, body.Instructions)
	if err != nil {
		utils.ServerError(c, "Failed to add payment method (may already exist)")
		return
	}
	utils.Created(c, "Payment method added.", gin.H{"id": id})
}

// PUT /api/admin/subadmin/payment-methods/:id
func (h *Handler) UpdatePaymentMethod(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var body struct {
		AccountName   string `json:"account_name"`
		AccountNumber string `json:"account_number"`
		PhoneNumber   string `json:"phone_number"`
		Instructions  string `json:"instructions"`
		IsActive      bool   `json:"is_active"`
	}
	c.ShouldBindJSON(&body)
	h.model.UpdatePaymentMethod(id, body.AccountName, body.AccountNumber, body.PhoneNumber, body.Instructions, body.IsActive)
	utils.Success(c, "Payment method updated.", nil)
}

// ─── Hotel Manager: Payment Verification ──────────────────────────────────────

// GET /api/admin/manager/payments
func (h *Handler) ManagerPayments(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	hotelID := h.model.GetManagerHotelID(adminID)
	payments, err := h.model.GetManagerPayments(hotelID)
	if err != nil {
		utils.ServerError(c, "Failed to load payments")
		return
	}
	utils.Success(c, "Payments.", payments)
}

// POST /api/admin/manager/payments/:id/verify
func (h *Handler) VerifyPayment(c *gin.Context) {
	adminID := c.GetInt("admin_id")
	paymentID, _ := strconv.Atoi(c.Param("id"))
	var body struct {
		Status string `json:"status"` // "approved" or "rejected"
	}
	c.ShouldBindJSON(&body)

	var dbStatus string
	switch body.Status {
	case "approved":
		dbStatus = "completed"
	case "rejected":
		dbStatus = "failed"
	default:
		utils.BadRequest(c, "status must be 'approved' or 'rejected'")
		return
	}

	if err := h.model.VerifyPayment(paymentID, adminID, dbStatus); err != nil {
		utils.ServerError(c, "Failed to verify payment")
		return
	}

	// Send email notification + in-app notification to the user
	go func() {
		email, guestName, bookingInfo := h.model.GetPaymentUserEmail(paymentID)
		var nType, nTitle, nMessage string
		if body.Status == "approved" {
			nType = "payment_approved"
			nTitle = "Payment Approved!"
			nMessage = "Your payment for " + bookingInfo + " has been approved. Your booking is confirmed!"
		} else {
			nType = "payment_rejected"
			nTitle = "Payment Rejected"
			nMessage = "Your payment for " + bookingInfo + " was rejected. Please try a different payment method or contact the hotel."
		}

		// In-app notification
		var userID int
		h.model.db.QueryRow(`SELECT user_id FROM payments WHERE id=$1`, paymentID).Scan(&userID)
		var bookingID int
		h.model.db.QueryRow(`SELECT booking_id FROM payments WHERE id=$1`, paymentID).Scan(&bookingID)
		h.model.db.Exec(`
			INSERT INTO notifications (user_id, type, title, message, booking_id)
			VALUES ($1, $2, $3, $4, $5)`,
			userID, nType, nTitle, nMessage, bookingID)

		// Email notification
		if email != "" {
			subject := "DallolBook Payment Update"
			var msg string
			if body.Status == "approved" {
				msg = "Dear " + guestName + ",\n\nYour payment for booking " + bookingInfo + " has been APPROVED. Your booking is now confirmed!\n\nThank you for choosing DallolBook."
			} else {
				msg = "Dear " + guestName + ",\n\nYour payment for booking " + bookingInfo + " has been REJECTED. Please contact the hotel for more information or try a different payment method.\n\nThank you for choosing DallolBook."
			}
			utils.SendEmailNotification(h.cfg, email, subject, msg)
		}
	}()

	utils.Success(c, "Payment "+body.Status+".", nil)
}
