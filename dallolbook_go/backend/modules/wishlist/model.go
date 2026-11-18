// modules/wishlist/model.go
package wishlist

import (
	"database/sql"
	"time"
)

type WishlistItem struct {
	ID        int       `json:"id"`
	HotelID   int       `json:"hotel_id"`
	HotelName string    `json:"hotel_name"`
	City      string    `json:"city"`
	Rating    float64   `json:"rating"`
	Price     float64   `json:"price_per_night"`
	Image     string    `json:"image"`
	AddedAt   time.Time `json:"added_at"`
}

type Model struct{ db *sql.DB }

func NewModel(db *sql.DB) *Model { return &Model{db: db} }

func (m *Model) GetAll(userID int) ([]WishlistItem, error) {
	rows, err := m.db.Query(`
		SELECT w.id,w.hotel_id,h.name,h.city,h.rating,h.price_per_night,
		       COALESCE((SELECT image_url FROM hotel_images WHERE hotel_id=h.id ORDER BY sort_order LIMIT 1),''),
		       w.created_at
		FROM wishlist w
		JOIN hotels h ON h.id=w.hotel_id
		WHERE w.user_id=$1 AND h.is_active=true
		ORDER BY w.created_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []WishlistItem
	for rows.Next() {
		var item WishlistItem
		rows.Scan(&item.ID, &item.HotelID, &item.HotelName, &item.City,
			&item.Rating, &item.Price, &item.Image, &item.AddedAt)
		list = append(list, item)
	}
	return list, nil
}

// Toggle adds or removes a hotel from the wishlist. Returns action + current state.
func (m *Model) Toggle(userID, hotelID int) (string, error) {
	var id int
	m.db.QueryRow(`SELECT id FROM wishlist WHERE user_id=$1 AND hotel_id=$2`, userID, hotelID).Scan(&id)
	if id > 0 {
		m.db.Exec(`DELETE FROM wishlist WHERE id=$1`, id)
		return "removed", nil
	}
	_, err := m.db.Exec(`INSERT INTO wishlist (user_id,hotel_id) VALUES ($1,$2)`, userID, hotelID)
	return "added", err
}

func (m *Model) Remove(userID, hotelID int) error {
	_, err := m.db.Exec(`DELETE FROM wishlist WHERE user_id=$1 AND hotel_id=$2`, userID, hotelID)
	return err
}
