// modules/hotels/handler.go — HTTP handlers for hotel endpoints.
package hotels

import (
	"strconv"
	"time"

	"dallolbook/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct{ model *Model }

func NewHandler(model *Model) *Handler { return &Handler{model: model} }

// GET /api/v1/hotels/featured
func (h *Handler) Featured(c *gin.Context) {
	hotels, err := h.model.GetFeatured(10)
	if err != nil {
		utils.ServerError(c, "Failed to fetch featured hotels")
		return
	}
	utils.Success(c, "Featured hotels.", hotels)
}

// GET /api/v1/hotels/search?city=&name=&type=&min_price=&max_price=&min_rating=&sort=&dir=&limit=&offset=
func (h *Handler) Search(c *gin.Context) {
	city      := c.Query("city")
	name      := c.Query("name")
	hotelType := c.Query("type")
	sort      := c.Query("sort")
	dir       := c.Query("dir")

	minPrice, _ := strconv.ParseFloat(c.Query("min_price"), 64)
	maxPrice, _ := strconv.ParseFloat(c.Query("max_price"), 64)
	minRating, _ := strconv.ParseFloat(c.Query("min_rating"), 64)
	limit, _   := strconv.Atoi(c.Query("limit"))
	offset, _  := strconv.Atoi(c.Query("offset"))

	hotels, total, err := h.model.Search(city, name, hotelType, sort, dir, minPrice, maxPrice, minRating, limit, offset)
	if err != nil {
		utils.ServerError(c, "Search failed")
		return
	}
	utils.Success(c, "Search results.", gin.H{"hotels": hotels, "total": total})
}

// GET /api/v1/hotels/:id
func (h *Handler) Show(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		utils.BadRequest(c, "Invalid hotel ID")
		return
	}
	hotel, err := h.model.GetByID(id)
	if err != nil || hotel == nil {
		utils.NotFound(c, "Hotel not found")
		return
	}
	rooms, _ := h.model.GetRoomTypes(id)
	utils.Success(c, "Hotel detail.", gin.H{"hotel": hotel, "rooms": rooms})
}

// GET /api/v1/hotels/:id/reviews?limit=&offset=
func (h *Handler) GetReviews(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	reviews, total, err := h.model.GetReviews(id, limit, offset)
	if err != nil {
		utils.ServerError(c, "Failed to fetch reviews")
		return
	}
	utils.Success(c, "Reviews.", gin.H{"reviews": reviews, "total": total})
}

// GET /api/v1/hotels/:id/availability?check_in=YYYY-MM-DD&check_out=YYYY-MM-DD
func (h *Handler) Availability(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	checkIn := c.Query("check_in")
	checkOut := c.Query("check_out")
	if checkIn == "" || checkOut == "" {
		// Default: today + tomorrow
		today := time.Now()
		checkIn = today.Format("2006-01-02")
		checkOut = today.AddDate(0, 0, 1).Format("2006-01-02")
	}
	rooms, err := h.model.GetAvailableRooms(id, checkIn, checkOut)
	if err != nil {
		utils.ServerError(c, "Failed to check availability")
		return
	}
	utils.Success(c, "Available rooms.", gin.H{"rooms": rooms, "check_in": checkIn, "check_out": checkOut})
}

// GET /api/v1/hotels/:id/payment-methods  (public — no auth needed)
func (h *Handler) PaymentMethods(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	methods, err := h.model.GetPaymentMethods(id)
	if err != nil {
		utils.ServerError(c, "Failed to load payment methods")
		return
	}
	if methods == nil {
		methods = []PaymentMethod{}
	}
	utils.Success(c, "Payment methods.", methods)
}

// POST /api/v1/hotels/:id/reviews  (JWT protected)
func (h *Handler) PostReview(c *gin.Context) {
	hotelID, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")

	var body struct {
		Rating  float64 `json:"rating"`
		Comment string  `json:"comment"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.Rating < 1 || body.Rating > 5 || len(body.Comment) < 5 {
		utils.Unprocessable(c, "Rating (1-5) and comment (min 5 chars) are required")
		return
	}

	uid := userID.(int)
	if h.model.HasReviewed(hotelID, uid) {
		utils.Conflict(c, "You have already reviewed this hotel")
		return
	}

	if err := h.model.PostReview(hotelID, uid, body.Rating, body.Comment); err != nil {
		utils.ServerError(c, "Failed to post review")
		return
	}
	utils.Created(c, "Review posted successfully.", nil)
}
