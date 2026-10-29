// modules/hotels/model.go — DB queries for hotels, images, amenities, rooms, reviews.
package hotels

import (
	"database/sql"
	"fmt"
	"strings"
	"time"
)

type Hotel struct {
	ID             int       `json:"id"`
	Name           string    `json:"name"`
	City           string    `json:"city"`
	Address        string    `json:"address"`
	Description    *string   `json:"description"`
	Type           string    `json:"type"`
	Rating         float64   `json:"rating"`
	ReviewCount    int       `json:"review_count"`
	PricePerNight  float64   `json:"price_per_night"`
	Latitude       float64   `json:"latitude"`
	Longitude      float64   `json:"longitude"`
	IsFeatured     bool      `json:"is_featured"`
	IsActive       bool      `json:"is_active"`
	CreatedAt      time.Time `json:"created_at"`
	Images         []string  `json:"images"`
	Amenities      []string  `json:"amenities"`
	IsWishlisted   bool      `json:"is_wishlisted"`
}

type RoomType struct {
	ID            int      `json:"id"`
	HotelID       int      `json:"hotel_id"`
	Name          string   `json:"name"`
	BedType       string   `json:"bed_type"`
	ImageURL      *string  `json:"image_url"`
	PricePerNight float64  `json:"price_per_night"`
	SizeSqm       float64  `json:"size_sqm"`
	MaxGuests     int      `json:"max_guests"`
	Features      []string `json:"features"`
	IsAvailable   bool     `json:"is_available"`
	RoomStatus    string   `json:"room_status"`
}

type Review struct {
	ID        int       `json:"id"`
	UserID    int       `json:"user_id"`
	UserName  string    `json:"user_name"`
	AvatarURL *string   `json:"avatar_url"`
	Rating    float64   `json:"rating"`
	Comment   string    `json:"comment"`
	CreatedAt time.Time `json:"created_at"`
}

type Model struct{ db *sql.DB }

func NewModel(db *sql.DB) *Model { return &Model{db: db} }

// GetFeatured returns hotels where is_featured=true ordered by rating desc.
func (m *Model) GetFeatured(limit int) ([]Hotel, error) {
	rows, err := m.db.Query(
		`SELECT id,name,city,address,description,type,rating,review_count,
		        price_per_night,latitude,longitude,is_featured,is_active,created_at
		 FROM hotels WHERE is_featured=true AND is_active=true
		 ORDER BY rating DESC LIMIT $1`, limit,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return m.scanHotels(rows)
}

// Search applies dynamic filters and returns matching hotels.
func (m *Model) Search(city, name, hotelType, sort, dir string, minPrice, maxPrice, minRating float64, limit, offset int) ([]Hotel, int, error) {
	where := []string{"is_active=true"}
	args := []any{}
	i := 1

	if city != "" {
		where = append(where, fmt.Sprintf("LOWER(city)=LOWER($%d)", i))
		args = append(args, city); i++
	}
	if name != "" {
		where = append(where, fmt.Sprintf("name ILIKE $%d", i))
		args = append(args, "%"+name+"%"); i++
	}
	if hotelType != "" {
		where = append(where, fmt.Sprintf("type=$%d", i))
		args = append(args, hotelType); i++
	}
	if minPrice > 0 {
		where = append(where, fmt.Sprintf("price_per_night >= $%d", i))
		args = append(args, minPrice); i++
	}
	if maxPrice > 0 {
		where = append(where, fmt.Sprintf("price_per_night <= $%d", i))
		args = append(args, maxPrice); i++
	}
	if minRating > 0 {
		where = append(where, fmt.Sprintf("rating >= $%d", i))
		args = append(args, minRating); i++
	}

	whereClause := strings.Join(where, " AND ")

	// Count
	var total int
	m.db.QueryRow("SELECT COUNT(*) FROM hotels WHERE "+whereClause, args...).Scan(&total)

	// Validate sort
	allowedSort := map[string]bool{"rating": true, "price_per_night": true, "review_count": true, "name": true}
	if !allowedSort[sort] {
		sort = "rating"
	}
	if dir != "asc" {
		dir = "desc"
	}
	if limit <= 0 || limit > 50 {
		limit = 20
	}

	query := fmt.Sprintf(
		`SELECT id,name,city,address,description,type,rating,review_count,
		        price_per_night,latitude,longitude,is_featured,is_active,created_at
		 FROM hotels WHERE %s ORDER BY %s %s LIMIT $%d OFFSET $%d`,
		whereClause, sort, dir, i, i+1,
	)
	args = append(args, limit, offset)

	rows, err := m.db.Query(query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	hotels, err := m.scanHotels(rows)
	return hotels, total, err
}

// GetByID returns full hotel detail with images, amenities, rooms, and reviews.
func (m *Model) GetByID(id int) (*Hotel, error) {
	h := &Hotel{}
	err := m.db.QueryRow(
		`SELECT id,name,city,address,description,type,rating,review_count,
		        price_per_night,latitude,longitude,is_featured,is_active,created_at
		 FROM hotels WHERE id=$1 AND is_active=true`, id,
	).Scan(&h.ID, &h.Name, &h.City, &h.Address, &h.Description, &h.Type,
		&h.Rating, &h.ReviewCount, &h.PricePerNight, &h.Latitude, &h.Longitude,
		&h.IsFeatured, &h.IsActive, &h.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	h.Images, _ = m.GetImages(id)
	h.Amenities, _ = m.GetAmenities(id)
	return h, nil
}

// GetImages returns all image URLs for a hotel ordered by sort_order.
func (m *Model) GetImages(hotelID int) ([]string, error) {
	rows, err := m.db.Query(
		`SELECT image_url FROM hotel_images WHERE hotel_id=$1 ORDER BY sort_order ASC`, hotelID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var images []string
	for rows.Next() {
		var url string
		rows.Scan(&url)
		images = append(images, url)
	}
	return images, nil
}

// GetAmenities returns amenity strings for a hotel.
func (m *Model) GetAmenities(hotelID int) ([]string, error) {
	rows, err := m.db.Query(
		`SELECT amenity FROM hotel_amenities WHERE hotel_id=$1`, hotelID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var amenities []string
	for rows.Next() {
		var a string
		rows.Scan(&a)
		amenities = append(amenities, a)
	}
	return amenities, nil
}

// GetRoomTypes returns room types for a hotel.
func (m *Model) GetRoomTypes(hotelID int) ([]RoomType, error) {
	rows, err := m.db.Query(
		`SELECT id,hotel_id,name,bed_type,image_url,price_per_night,
		        size_sqm,max_guests,is_available,room_status
		 FROM room_types WHERE hotel_id=$1 ORDER BY price_per_night ASC`, hotelID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var rooms []RoomType
	for rows.Next() {
		var r RoomType
		rows.Scan(&r.ID, &r.HotelID, &r.Name, &r.BedType, &r.ImageURL,
			&r.PricePerNight, &r.SizeSqm, &r.MaxGuests, &r.IsAvailable, &r.RoomStatus)
		rooms = append(rooms, r)
	}
	return rooms, nil
}

// GetReviews returns paginated reviews for a hotel.
func (m *Model) GetReviews(hotelID, limit, offset int) ([]Review, int, error) {
	var total int
	m.db.QueryRow(`SELECT COUNT(*) FROM reviews WHERE hotel_id=$1`, hotelID).Scan(&total)

	rows, err := m.db.Query(
		`SELECT r.id,r.user_id,
		        CONCAT(u.first_name,' ',u.last_name),
		        u.avatar_url,r.rating,r.comment,r.created_at
		 FROM reviews r
		 JOIN users u ON u.id=r.user_id
		 WHERE r.hotel_id=$1
		 ORDER BY r.created_at DESC
		 LIMIT $2 OFFSET $3`, hotelID, limit, offset,
	)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()
	var reviews []Review
	for rows.Next() {
		var rv Review
		rows.Scan(&rv.ID, &rv.UserID, &rv.UserName, &rv.AvatarURL,
			&rv.Rating, &rv.Comment, &rv.CreatedAt)
		reviews = append(reviews, rv)
	}
	return reviews, total, nil
}

// PostReview inserts a review. Returns 409 if user already reviewed this hotel.
func (m *Model) PostReview(hotelID, userID int, rating float64, comment string) error {
	_, err := m.db.Exec(
		`INSERT INTO reviews (hotel_id,user_id,rating,comment) VALUES ($1,$2,$3,$4)`,
		hotelID, userID, rating, comment,
	)
	return err
}

// HasReviewed checks if a user has already reviewed a hotel.
func (m *Model) HasReviewed(hotelID, userID int) bool {
	var id int
	m.db.QueryRow(
		`SELECT id FROM reviews WHERE hotel_id=$1 AND user_id=$2 LIMIT 1`, hotelID, userID,
	).Scan(&id)
	return id > 0
}

// GetAvailableRooms returns room types that are not fully booked for the given date range.
// A room is considered unavailable if any confirmed/pending booking covers the requested period.
func (m *Model) GetAvailableRooms(hotelID int, checkIn, checkOut string) ([]RoomType, error) {
	rows, err := m.db.Query(`
		SELECT rt.id, rt.hotel_id, rt.name, rt.bed_type, rt.image_url,
		       rt.price_per_night, rt.size_sqm, rt.max_guests, rt.is_available, rt.room_status
		FROM room_types rt
		WHERE rt.hotel_id = $1
		  AND rt.room_status = 'available'
		  AND rt.id NOT IN (
		      SELECT DISTINCT b.room_type_id
		      FROM bookings b
		      WHERE b.room_type_id IS NOT NULL
		        AND b.hotel_id = $1
		        AND b.status IN ('pending','confirmed')
		        AND b.check_in < $3::date
		        AND b.check_out > $2::date
		  )
		ORDER BY rt.price_per_night ASC`, hotelID, checkIn, checkOut)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var rooms []RoomType
	for rows.Next() {
		var r RoomType
		rows.Scan(&r.ID, &r.HotelID, &r.Name, &r.BedType, &r.ImageURL,
			&r.PricePerNight, &r.SizeSqm, &r.MaxGuests, &r.IsAvailable, &r.RoomStatus)
		rooms = append(rooms, r)
	}
	return rooms, nil
}

// PaymentMethod represents a hotel's accepted payment method with account details.
type PaymentMethod struct {
	ID            int    `json:"id"`
	HotelID       int    `json:"hotel_id"`
	Method        string `json:"method"`
	AccountName   string `json:"account_name"`
	AccountNumber string `json:"account_number"`
	PhoneNumber   string `json:"phone_number"`
	Instructions  string `json:"instructions"`
	IsActive      bool   `json:"is_active"`
}

// GetPaymentMethods returns all active payment methods for a hotel.
func (m *Model) GetPaymentMethods(hotelID int) ([]PaymentMethod, error) {
	rows, err := m.db.Query(`
		SELECT id, hotel_id, method, account_name, account_number, phone_number, instructions, is_active
		FROM hotel_payment_methods
		WHERE hotel_id=$1 AND is_active=true
		ORDER BY
		  CASE method
		    WHEN 'telebirr'     THEN 1
		    WHEN 'cbe_birr'     THEN 2
		    WHEN 'chapa'        THEN 3
		    WHEN 'bank_transfer' THEN 4
		    WHEN 'awash_bank'   THEN 5
		    WHEN 'abyssinia'    THEN 6
		    WHEN 'card'         THEN 7
		    WHEN 'mobile_money' THEN 8
		    WHEN 'cash'         THEN 9
		    ELSE 99
		  END`, hotelID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var methods []PaymentMethod
	for rows.Next() {
		var pm PaymentMethod
		rows.Scan(&pm.ID, &pm.HotelID, &pm.Method, &pm.AccountName, &pm.AccountNumber, &pm.PhoneNumber, &pm.Instructions, &pm.IsActive)
		methods = append(methods, pm)
	}
	return methods, nil
}

func (m *Model) scanHotels(rows *sql.Rows) ([]Hotel, error) {
	var hotels []Hotel
	for rows.Next() {
		var h Hotel
		err := rows.Scan(&h.ID, &h.Name, &h.City, &h.Address, &h.Description, &h.Type,
			&h.Rating, &h.ReviewCount, &h.PricePerNight, &h.Latitude, &h.Longitude,
			&h.IsFeatured, &h.IsActive, &h.CreatedAt)
		if err != nil {
			return nil, err
		}
		h.Images, _ = m.GetImages(h.ID)
		h.Amenities, _ = m.GetAmenities(h.ID)
		hotels = append(hotels, h)
	}
	return hotels, nil
}
