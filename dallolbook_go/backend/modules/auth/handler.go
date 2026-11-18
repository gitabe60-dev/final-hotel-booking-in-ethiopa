// modules/auth/handler.go — HTTP handlers for all auth endpoints.
package auth

import (
	"log"

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

// POST /api/v1/auth/register
func (h *Handler) Register(c *gin.Context) {
	var body struct {
		FirstName   string  `json:"first_name"`
		LastName    string  `json:"last_name"`
		Email       *string `json:"email"`
		Phone       *string `json:"phone"`
		Password    string  `json:"password"`
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
	if body.Email == nil && body.Phone == nil {
		utils.Unprocessable(c, "Email or phone number is required")
		return
	}
	if len(body.Password) < 6 {
		utils.Unprocessable(c, "Password must be at least 6 characters")
		return
	}

	// Check duplicates
	if body.Email != nil {
		existing, _ := h.model.FindByEmail(*body.Email)
		if existing != nil {
			utils.Conflict(c, "Email is already registered")
			return
		}
	}
	if body.Phone != nil {
		existing, _ := h.model.FindByPhone(*body.Phone)
		if existing != nil {
			utils.Conflict(c, "Phone number is already registered")
			return
		}
	}

	id, err := h.model.CreateUser(body.FirstName, body.LastName, body.Email, body.Phone, &body.Password, body.Nationality)
	if err != nil {
		log.Printf("[auth] CreateUser error: %v", err)
		utils.ServerError(c, "Registration failed. Please try again.")
		return
	}

	user, _ := h.model.FindByID(id)
	token, _ := utils.GenerateToken(id, emailStr(user), "user", h.cfg.JWTSecret, h.cfg.JWTExpiryHours)

	utils.Created(c, "Registration successful.", gin.H{
		"user":  SafeUser(*user),
		"token": token,
	})
}

// POST /api/v1/auth/login
func (h *Handler) Login(c *gin.Context) {
	var body struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.Email == "" || body.Password == "" {
		utils.Unprocessable(c, "Email and password are required")
		return
	}

	user, _ := h.model.FindByEmail(body.Email)
	if user == nil || !utils.CheckPassword(body.Password, user.PasswordHash) {
		utils.Unauthorized(c, "Invalid email or password")
		return
	}
	if user.Status == "suspended" {
		utils.Forbidden(c, "Your account has been suspended")
		return
	}

	h.model.UpdateLastLogin(user.ID)
	token, _ := utils.GenerateToken(user.ID, emailStr(user), "user", h.cfg.JWTSecret, h.cfg.JWTExpiryHours)

	utils.Success(c, "Login successful.", gin.H{
		"user":  SafeUser(*user),
		"token": token,
	})
}

// POST /api/v1/auth/otp/send
func (h *Handler) SendOTP(c *gin.Context) {
	var body struct {
		Phone   string `json:"phone"`
		Purpose string `json:"purpose"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.Phone == "" {
		utils.Unprocessable(c, "Phone number is required")
		return
	}
	if body.Purpose == "" {
		body.Purpose = "login"
	}

	code, err := h.model.GenerateOTP(body.Phone, body.Purpose)
	if err != nil {
		utils.ServerError(c, "Failed to generate OTP")
		return
	}

	log.Printf("[OTP] %s → %s", body.Phone, code)

	resp := gin.H{"phone": body.Phone}
	if h.cfg.AppEnv == "development" {
		resp["otp"] = code // remove in production
	}
	utils.Success(c, "OTP sent successfully.", resp)
}

// POST /api/v1/auth/otp/verify
func (h *Handler) VerifyOTP(c *gin.Context) {
	var body struct {
		Phone   string `json:"phone"`
		OTP     string `json:"otp"`
		Purpose string `json:"purpose"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.Phone == "" || body.OTP == "" {
		utils.Unprocessable(c, "Phone and OTP are required")
		return
	}
	if body.Purpose == "" {
		body.Purpose = "login"
	}

	valid, err := h.model.VerifyOTP(body.Phone, body.OTP, body.Purpose)
	if err != nil || !valid {
		utils.Unauthorized(c, "Invalid or expired OTP")
		return
	}

	user, _ := h.model.FindByPhone(body.Phone)
	if user == nil {
		// Auto-register phone-only user
		dummy := "User"
		id, _ := h.model.CreateUser(dummy, "", nil, &body.Phone, nil, nil)
		user, _ = h.model.FindByID(id)
	}
	h.model.MarkVerified(user.ID)
	h.model.UpdateLastLogin(user.ID)

	token, _ := utils.GenerateToken(user.ID, emailStr(user), "user", h.cfg.JWTSecret, h.cfg.JWTExpiryHours)
	utils.Success(c, "OTP verified. Login successful.", gin.H{
		"user":  SafeUser(*user),
		"token": token,
	})
}

// POST /api/v1/auth/forgot-password
func (h *Handler) ForgotPassword(c *gin.Context) {
	var body struct {
		Email *string `json:"email"`
		Phone *string `json:"phone"`
	}
	c.ShouldBindJSON(&body)

	if body.Email == nil && body.Phone == nil {
		utils.Unprocessable(c, "Email or phone is required")
		return
	}

	var user *User
	if body.Phone != nil {
		user, _ = h.model.FindByPhone(*body.Phone)
		if user != nil {
			code, _ := h.model.GenerateOTP(*body.Phone, "reset")
			log.Printf("[OTP-reset] %s → %s", *body.Phone, code)
		}
	}
	// Always return success to prevent user enumeration
	utils.Success(c, "If the account exists, a reset code has been sent.", nil)
}

// POST /api/v1/auth/reset-password
func (h *Handler) ResetPassword(c *gin.Context) {
	var body struct {
		Phone    string `json:"phone"`
		OTP      string `json:"otp"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.Phone == "" || body.OTP == "" || body.Password == "" {
		utils.Unprocessable(c, "Phone, OTP and new password are required")
		return
	}
	if len(body.Password) < 6 {
		utils.Unprocessable(c, "Password must be at least 6 characters")
		return
	}

	valid, _ := h.model.VerifyOTP(body.Phone, body.OTP, "reset")
	if !valid {
		utils.Unauthorized(c, "Invalid or expired OTP")
		return
	}

	user, _ := h.model.FindByPhone(body.Phone)
	if user == nil {
		utils.NotFound(c, "User not found")
		return
	}
	h.model.UpdatePassword(user.ID, body.Password)
	utils.Success(c, "Password reset successfully.", nil)
}

// POST /api/v1/auth/logout  (JWT protected — stateless, client discards token)
func (h *Handler) Logout(c *gin.Context) {
	utils.Success(c, "Logged out successfully.", nil)
}

// --- helpers ---
func emailStr(u *User) string {
	if u == nil || u.Email == nil {
		return ""
	}
	return *u.Email
}
