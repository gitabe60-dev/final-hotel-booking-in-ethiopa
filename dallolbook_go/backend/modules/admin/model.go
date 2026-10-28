// modules/admin/model.go — all DB queries for admin panel (all 4 roles).
package admin

import (
	"database/sql"
	"strconv"
	"time"

	"dallolbook/utils"
)

type AdminUser struct {
	ID           int        `json:"id"`
	FullName     string     `json:"full_name"`
	Email        string     `json:"email"`
	Phone        *string    `json:"phone"`
	PasswordHash string     `json:"-"`
	Role         string     `json:"role"`
	Status       string     `json:"status"`
	AvatarURL    *string    `json:"avatar_url"`
	LastLogin    *time.Time `json:"last_login"`
	CreatedAt    time.Time  `json:"created_at"`
}

type Hotel struct {
	ID            int     `json:"id"`
	Name          string  `json:"name"`
	City          string  `json:"city"`
	Type          string  `json:"type"`
	Rating        float64 `json:"rating"`
	PricePerNight float64 `json:"price_per_night"`
	IsActive      bool    `json:"is_active"`
	Image         string  `json:"image"`
}

type RoomType struct {
	ID            int     `json:"id"`
	HotelID       int     `json:"hotel_id"`
	Name          string  `json:"name"`
	BedType       string  `json:"bed_type"`
	PricePerNight float64 `json:"price_per_night"`
	MaxGuests     int     `json:"max_guests"`
	IsAvailable   bool    `json:"is_available"`
}

type Message struct {
	ID        int       `json:"id"`
	FromAdmin int       `json:"from_admin"`
	FromName  string    `json:"from_name"`
	ToAdmin   int       `json:"to_admin"`
	ToName    string    `json:"to_name"`
	Subject   string    `json:"subject"`
	Body      string    `json:"body"`
	IsRead    bool      `json:"is_read"`
	HotelID   *int      `json:"hotel_id"`
	ParentID  *int      `json:"parent_id"`
	CreatedAt time.Time `json:"created_at"`
}

type Overview struct {
	SubAdmins        int     `json:"sub_admins"`
	Brokers          int     `json:"brokers"`
	HotelManagers    int     `json:"hotel_managers"`
	ActiveHotels     int     `json:"active_hotels"`
	ConfirmedBookings int    `json:"confirmed_bookings"`
	PendingBookings  int     `json:"pending_bookings"`
	TotalGuests      int     `json:"total_guests"`
	TotalRevenue     float64 `json:"total_revenue"`
}

type Model struct{ db *sql.DB }

func NewModel(db *sql.DB) *Model { return &Model{db: db} }

// ─── Admin Auth ──────────────────────────────────────────────────────────────

func (m *Model) FindAdminByEmail(email string) (*AdminUser, error) {
	a := &AdminUser{}
	err := m.db.QueryRow(`
		SELECT id,full_name,email,phone,password_hash,role,status,avatar_url,last_login,created_at
		FROM admin_users WHERE LOWER(email)=LOWER($1) LIMIT 1`, email,
	).Scan(&a.ID, &a.FullName, &a.Email, &a.Phone, &a.PasswordHash,
		&a.Role, &a.Status, &a.AvatarURL, &a.LastLogin, &a.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return a, err
}

func (m *Model) FindAdminByID(id int) (*AdminUser, error) {
	a := &AdminUser{}
	err := m.db.QueryRow(`
		SELECT id,full_name,email,phone,password_hash,role,status,avatar_url,last_login,created_at
		FROM admin_users WHERE id=$1`, id,
	).Scan(&a.ID, &a.FullName, &a.Email, &a.Phone, &a.PasswordHash,
		&a.Role, &a.Status, &a.AvatarURL, &a.LastLogin, &a.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return a, err
}

func (m *Model) UpdateAdminLastLogin(id int) {
	m.db.Exec(`UPDATE admin_users SET last_login=NOW() WHERE id=$1`, id)
}

func (m *Model) UpdateAdminPassword(id int, plain string) error {
	hash, err := utils.HashPassword(plain)
	if err != nil {
		return err
	}
	_, err = m.db.Exec(`UPDATE admin_users SET password_hash=$1 WHERE id=$2`, hash, id)
	return err
}

func (m *Model) UpdateAdminProfile(id int, fullName string, phone *string) error {
	_, err := m.db.Exec(`UPDATE admin_users SET full_name=$1,phone=$2 WHERE id=$3`, fullName, phone, id)
	return err
}

// ─── Super Admin ─────────────────────────────────────────────────────────────

func (m *Model) GetOverview() Overview {
	var o Overview
	m.db.QueryRow(`SELECT * FROM v_admin_overview`).Scan(
		&o.SubAdmins, &o.Brokers, &o.HotelManagers, &o.ActiveHotels,
		&o.ConfirmedBookings, &o.PendingBookings, &o.TotalGuests, &o.TotalRevenue,
	)
	return o
}

func (m *Model) GetSubAdmins() ([]AdminUser, error) {
	rows, err := m.db.Query(`
		SELECT id,full_name,email,phone,password_hash,role,status,avatar_url,last_login,created_at
		FROM admin_users WHERE role='sub_admin' ORDER BY created_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return m.scanAdmins(rows)
}

func (m *Model) CreateSubAdmin(fullName, email, phone, password string, createdBy int) (int, error) {
	hash, _ := utils.HashPassword(password)
	var id int
	err := m.db.QueryRow(`
		INSERT INTO admin_users (full_name,email,phone,password_hash,role,status,created_by)
		VALUES ($1,$2,$3,$4,'sub_admin','active',$5) RETURNING id`,
		fullName, email, phone, hash, createdBy,
	).Scan(&id)
	return id, err
}

func (m *Model) UpdateSubAdmin(id int, fullName, email, phone, status string) error {
	_, err := m.db.Exec(`
		UPDATE admin_users SET full_name=$1,email=$2,phone=$3,status=$4 WHERE id=$5`,
		fullName, email, phone, status, id)
	return err
}

func (m *Model) SoftDeleteAdmin(id int) error {
	_, err := m.db.Exec(`UPDATE admin_users SET status='inactive' WHERE id=$1`, id)
	return err
}

func (m *Model) AssignCity(adminID int, city string, assignedBy int) error {
	_, err := m.db.Exec(`
		INSERT INTO admin_city_assignments (admin_id,city,assigned_by)
		VALUES ($1,$2,$3) ON CONFLICT (admin_id,city) DO NOTHING`,
		adminID, city, assignedBy)
	return err
}

func (m *Model) RevokeCity(adminID int, city string) error {
	_, err := m.db.Exec(`DELETE FROM admin_city_assignments WHERE admin_id=$1 AND city=$2`, adminID, city)
	return err
}

func (m *Model) GetAdminCities(adminID int) []string {
	rows, _ := m.db.Query(`SELECT city FROM admin_city_assignments WHERE admin_id=$1`, adminID)
	defer rows.Close()
	var cities []string
	for rows.Next() {
		var c string
		rows.Scan(&c)
		cities = append(cities, c)
	}
	return cities
}

func (m *Model) GetSubAdminCity(adminID int) string {
	var city string
	m.db.QueryRow(`SELECT city FROM admin_city_assignments WHERE admin_id=$1 LIMIT 1`, adminID).Scan(&city)
	return city
}

// ─── Hotels (admin) ──────────────────────────────────────────────────────────

func (m *Model) GetAllHotels(city, search string) ([]Hotel, error) {
	q := `SELECT h.id,h.name,h.city,h.type,h.rating,h.price_per_night,h.is_active,
		         COALESCE((SELECT image_url FROM hotel_images WHERE hotel_id=h.id ORDER BY sort_order LIMIT 1),'')
		  FROM hotels h WHERE 1=1`
	args := []any{}
	i := 1
	if city != "" {
		q += ` AND LOWER(h.city)=LOWER($` + itoa(i) + `)`
		args = append(args, city); i++
	}
	if search != "" {
		q += ` AND h.name ILIKE $` + itoa(i)
		args = append(args, "%"+search+"%"); i++
	}
	q += ` ORDER BY h.created_at DESC`
	rows, err := m.db.Query(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var hotels []Hotel
	for rows.Next() {
		var h Hotel
		rows.Scan(&h.ID, &h.Name, &h.City, &h.Type, &h.Rating, &h.PricePerNight, &h.IsActive, &h.Image)
		hotels = append(hotels, h)
	}
	return hotels, nil
}

func (m *Model) CreateHotel(name, city, address, description, hotelType string, price, lat, lng float64, isFeatured bool) (int, error) {
	var id int
	err := m.db.QueryRow(`
		INSERT INTO hotels (name,city,address,description,type,price_per_night,latitude,longitude,is_featured,is_active)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,true) RETURNING id`,
		name, city, address, description, hotelType, price, lat, lng, isFeatured,
	).Scan(&id)
	return id, err
}

func (m *Model) UpdateHotel(id int, name, city, address, description, hotelType string, price float64, isActive bool) error {
	_, err := m.db.Exec(`
		UPDATE hotels SET name=$1,city=$2,address=$3,description=$4,type=$5,price_per_night=$6,is_active=$7
		WHERE id=$8`, name, city, address, description, hotelType, price, isActive, id)
	return err
}

func (m *Model) ToggleHotel(id int) error {
	_, err := m.db.Exec(`UPDATE hotels SET is_active = NOT is_active WHERE id=$1`, id)
	return err
}

func (m *Model) AddHotelImage(hotelID int, imageURL string, sortOrder int, isPrimary bool) error {
	_, err := m.db.Exec(`
		INSERT INTO hotel_images (hotel_id,image_url,sort_order,is_primary)
		VALUES ($1,$2,$3,$4)`, hotelID, imageURL, sortOrder, isPrimary)
	return err
}

// ─── Rooms ───────────────────────────────────────────────────────────────────

func (m *Model) GetRooms(hotelID int) ([]RoomType, error) {
	rows, err := m.db.Query(`
		SELECT id,hotel_id,name,bed_type,price_per_night,max_guests,is_available
		FROM room_types WHERE hotel_id=$1 ORDER BY price_per_night`, hotelID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var rooms []RoomType
	for rows.Next() {
		var r RoomType
		rows.Scan(&r.ID, &r.HotelID, &r.Name, &r.BedType, &r.PricePerNight, &r.MaxGuests, &r.IsAvailable)
		rooms = append(rooms, r)
	}
	return rooms, nil
}

func (m *Model) CreateRoom(hotelID int, name, bedType string, price float64, maxGuests int) (int, error) {
	var id int
	err := m.db.QueryRow(`
		INSERT INTO room_types (hotel_id,name,bed_type,price_per_night,max_guests,is_available)
		VALUES ($1,$2,$3,$4,$5,true) RETURNING id`,
		hotelID, name, bedType, price, maxGuests,
	).Scan(&id)
	return id, err
}

func (m *Model) UpdateRoom(id int, name, bedType string, price float64, maxGuests int) error {
	_, err := m.db.Exec(`
		UPDATE room_types SET name=$1,bed_type=$2,price_per_night=$3,max_guests=$4 WHERE id=$5`,
		name, bedType, price, maxGuests, id)
	return err
}

func (m *Model) DeleteRoom(id int) error {
	_, err := m.db.Exec(`DELETE FROM room_types WHERE id=$1`, id)
	return err
}

func (m *Model) ToggleRoom(id int) error {
	_, err := m.db.Exec(`UPDATE room_types SET is_available = NOT is_available WHERE id=$1`, id)
	return err
}

// ─── Bookings (admin view) ────────────────────────────────────────────────────

func (m *Model) GetBookings(city, status string, limit int) ([]map[string]any, error) {
	q := `SELECT b.id,b.user_id,u.first_name||' '||u.last_name,
		         b.hotel_id,h.name,h.city,
		         b.check_in::text,b.check_out::text,b.rooms,b.total_price,
		         b.payment_method,b.status,b.created_at
		  FROM bookings b
		  JOIN users u ON u.id=b.user_id
		  JOIN hotels h ON h.id=b.hotel_id
		  WHERE 1=1`
	args := []any{}
	i := 1
	if city != "" {
		q += ` AND LOWER(h.city)=LOWER($` + itoa(i) + `)`
		args = append(args, city); i++
	}
	if status != "" {
		q += ` AND b.status=$` + itoa(i)
		args = append(args, status); i++
	}
	q += ` ORDER BY b.created_at DESC LIMIT $` + itoa(i)
	args = append(args, limit)

	rows, err := m.db.Query(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var bookings []map[string]any
	for rows.Next() {
		var id, userID, hotelID, rooms int
		var guestName, hotelName, city2, checkIn, checkOut, method, bStatus string
		var total float64
		var createdAt time.Time
		rows.Scan(&id, &userID, &guestName, &hotelID, &hotelName, &city2,
			&checkIn, &checkOut, &rooms, &total, &method, &bStatus, &createdAt)
		bookings = append(bookings, map[string]any{
			"id": id, "user_id": userID, "guest_name": guestName,
			"hotel_id": hotelID, "hotel_name": hotelName, "city": city2,
			"check_in": checkIn, "check_out": checkOut, "rooms": rooms,
			"total_price": total, "payment_method": method, "status": bStatus,
			"created_at": createdAt,
		})
	}
	return bookings, nil
}

func (m *Model) UpdateBookingStatus(id int, status string) error {
	_, err := m.db.Exec(`UPDATE bookings SET status=$1 WHERE id=$2`, status, id)
	return err
}

// ─── Users ───────────────────────────────────────────────────────────────────

func (m *Model) GetGuests(search string) ([]map[string]any, error) {
	q := `SELECT u.id,u.first_name,u.last_name,u.email,u.phone,u.status,u.registered_date,
		         COUNT(b.id) as booking_count
		  FROM users u LEFT JOIN bookings b ON b.user_id=u.id
		  WHERE 1=1`
	args := []any{}
	if search != "" {
		q += ` AND (u.first_name ILIKE $1 OR u.last_name ILIKE $1 OR u.email ILIKE $1)`
		args = append(args, "%"+search+"%")
	}
	q += ` GROUP BY u.id ORDER BY u.registered_date DESC LIMIT 100`
	rows, err := m.db.Query(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var guests []map[string]any
	for rows.Next() {
		var id, count int
		var fname, lname, status string
		var email, phone *string
		var reg time.Time
		rows.Scan(&id, &fname, &lname, &email, &phone, &status, &reg, &count)
		guests = append(guests, map[string]any{
			"id": id, "first_name": fname, "last_name": lname,
			"email": email, "phone": phone, "status": status,
			"registered_date": reg, "booking_count": count,
		})
	}
	return guests, nil
}

// ─── Brokers ─────────────────────────────────────────────────────────────────

func (m *Model) GetBrokers(subAdminID int) ([]map[string]any, error) {
	q := `SELECT b.id,au.full_name,au.email,au.phone,b.city,b.commission_pct,b.status,
		         COUNT(bhl.hotel_id) as hotel_count
		  FROM brokers b
		  JOIN admin_users au ON au.id=b.admin_id
		  LEFT JOIN broker_hotel_links bhl ON bhl.broker_id=b.id
		  WHERE 1=1`
	args := []any{}
	if subAdminID > 0 {
		q += ` AND b.sub_admin_id=$1`
		args = append(args, subAdminID)
	}
	q += ` GROUP BY b.id,au.full_name,au.email,au.phone,b.city,b.commission_pct,b.status`
	rows, err := m.db.Query(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var brokers []map[string]any
	for rows.Next() {
		var id, hotelCount int
		var name, email, city, status string
		var phone *string
		var commission float64
		rows.Scan(&id, &name, &email, &phone, &city, &commission, &status, &hotelCount)
		brokers = append(brokers, map[string]any{
			"id": id, "full_name": name, "email": email, "phone": phone,
			"city": city, "commission_pct": commission, "status": status,
			"hotel_count": hotelCount,
		})
	}
	return brokers, nil
}

func (m *Model) CreateBroker(fullName, email, phone, password, city string, commission float64, subAdminID, createdBy int) (int, error) {
	hash, _ := utils.HashPassword(password)
	var adminID int
	err := m.db.QueryRow(`
		INSERT INTO admin_users (full_name,email,phone,password_hash,role,status,created_by)
		VALUES ($1,$2,$3,$4,'broker','active',$5) RETURNING id`,
		fullName, email, phone, hash, createdBy,
	).Scan(&adminID)
	if err != nil {
		return 0, err
	}
	var brokerID int
	err = m.db.QueryRow(`
		INSERT INTO brokers (admin_id,sub_admin_id,city,commission_pct,status)
		VALUES ($1,$2,$3,$4,'active') RETURNING id`,
		adminID, subAdminID, city, commission,
	).Scan(&brokerID)
	return brokerID, err
}

// ─── Managers ────────────────────────────────────────────────────────────────

func (m *Model) GetManagers(subAdminID int) ([]map[string]any, error) {
	q := `SELECT hm.id,au.full_name,au.email,au.phone,h.name,h.city,au.status
		  FROM hotel_managers hm
		  JOIN admin_users au ON au.id=hm.admin_id
		  JOIN hotels h ON h.id=hm.hotel_id
		  WHERE 1=1`
	args := []any{}
	if subAdminID > 0 {
		q += ` AND hm.sub_admin_id=$1`
		args = append(args, subAdminID)
	}
	rows, err := m.db.Query(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var managers []map[string]any
	for rows.Next() {
		var id int
		var name, email, hotelName, hotelCity, status string
		var phone *string
		rows.Scan(&id, &name, &email, &phone, &hotelName, &hotelCity, &status)
		managers = append(managers, map[string]any{
			"id": id, "full_name": name, "email": email, "phone": phone,
			"hotel_name": hotelName, "hotel_city": hotelCity, "status": status,
		})
	}
	return managers, nil
}

func (m *Model) GetManagerHotelID(adminID int) int {
	var hotelID int
	m.db.QueryRow(`SELECT hotel_id FROM hotel_managers WHERE admin_id=$1 LIMIT 1`, adminID).Scan(&hotelID)
	return hotelID
}

// UpdateRoomImage sets the image_url on a room type.
func (m *Model) UpdateRoomImage(roomID int, imageURL string) {
	m.db.Exec(`UPDATE room_types SET image_url=$1 WHERE id=$2`, imageURL, roomID)
}

// GetHotelPaymentMethods returns all payment methods for a hotel (admin view — includes inactive).
func (m *Model) GetHotelPaymentMethods(hotelID int) ([]map[string]any, error) {
	rows, err := m.db.Query(`
		SELECT id, hotel_id, method, account_name, account_number, phone_number, instructions, is_active
		FROM hotel_payment_methods WHERE hotel_id=$1 ORDER BY method`, hotelID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var methods []map[string]any
	for rows.Next() {
		var id, hotelId int
		var method, accountName, accountNumber, phoneNumber, instructions string
		var isActive bool
		rows.Scan(&id, &hotelId, &method, &accountName, &accountNumber, &phoneNumber, &instructions, &isActive)
		methods = append(methods, map[string]any{
			"id": id, "hotel_id": hotelId, "method": method,
			"account_name": accountName, "account_number": accountNumber,
			"phone_number": phoneNumber, "instructions": instructions, "is_active": isActive,
		})
	}
	return methods, nil
}

// UpdatePaymentMethod updates a hotel payment method's details.
func (m *Model) UpdatePaymentMethod(id int, accountName, accountNumber, phoneNumber, instructions string, isActive bool) error {
	_, err := m.db.Exec(`
		UPDATE hotel_payment_methods
		SET account_name=$1, account_number=$2, phone_number=$3, instructions=$4, is_active=$5
		WHERE id=$6`, accountName, accountNumber, phoneNumber, instructions, isActive, id)
	return err
}

// AddPaymentMethod adds a new payment method for a hotel.
func (m *Model) AddPaymentMethod(hotelID int, method, accountName, accountNumber, phoneNumber, instructions string) (int, error) {
	var id int
	err := m.db.QueryRow(`
		INSERT INTO hotel_payment_methods (hotel_id, method, account_name, account_number, phone_number, instructions)
		VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
		hotelID, method, accountName, accountNumber, phoneNumber, instructions).Scan(&id)
	return id, err
}

// GetPaymentUserEmail returns user email, name, and booking reference for notifications.
func (m *Model) GetPaymentUserEmail(paymentID int) (email, name, bookingInfo string) {
	m.db.QueryRow(`
		SELECT COALESCE(u.email,''), u.first_name||' '||u.last_name,
		       'ID #'||b.id::text||' ('||h.name||')'
		FROM payments p
		JOIN bookings b ON b.id=p.booking_id
		JOIN users u ON u.id=p.user_id
		JOIN hotels h ON h.id=b.hotel_id
		WHERE p.id=$1`, paymentID,
	).Scan(&email, &name, &bookingInfo)
	return
}

// ─── Messages ────────────────────────────────────────────────────────────────

func (m *Model) GetInbox(adminID int) ([]Message, error) {
	return m.getMessages(`WHERE m.to_admin=$1`, adminID)
}

func (m *Model) GetSent(adminID int) ([]Message, error) {
	return m.getMessages(`WHERE m.from_admin=$1`, adminID)
}

func (m *Model) GetMessage(id, adminID int) (*Message, error) {
	msgs, err := m.getMessages(`WHERE m.id=$1 AND (m.to_admin=$2 OR m.from_admin=$2)`, id, adminID)
	if err != nil || len(msgs) == 0 {
		return nil, err
	}
	m.db.Exec(`UPDATE broker_messages SET is_read=true WHERE id=$1 AND to_admin=$2`, id, adminID)
	return &msgs[0], nil
}

func (m *Model) SendMessage(fromAdmin, toAdmin int, subject, body string, hotelID, parentID *int) (int, error) {
	var id int
	err := m.db.QueryRow(`
		INSERT INTO broker_messages (from_admin,to_admin,subject,body,hotel_id,parent_id)
		VALUES ($1,$2,$3,$4,$5,$6) RETURNING id`,
		fromAdmin, toAdmin, subject, body, hotelID, parentID,
	).Scan(&id)
	return id, err
}

func (m *Model) CountUnread(adminID int) int {
	var n int
	m.db.QueryRow(`SELECT COUNT(*) FROM broker_messages WHERE to_admin=$1 AND is_read=false`, adminID).Scan(&n)
	return n
}

func (m *Model) getMessages(where string, args ...any) ([]Message, error) {
	rows, err := m.db.Query(`
		SELECT m.id,m.from_admin,af.full_name,m.to_admin,at2.full_name,
		       m.subject,m.body,m.is_read,m.hotel_id,m.parent_id,m.created_at
		FROM broker_messages m
		JOIN admin_users af  ON af.id=m.from_admin
		JOIN admin_users at2 ON at2.id=m.to_admin
		`+where+` ORDER BY m.created_at DESC`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var msgs []Message
	for rows.Next() {
		var msg Message
		rows.Scan(&msg.ID, &msg.FromAdmin, &msg.FromName, &msg.ToAdmin, &msg.ToName,
			&msg.Subject, &msg.Body, &msg.IsRead, &msg.HotelID, &msg.ParentID, &msg.CreatedAt)
		msgs = append(msgs, msg)
	}
	return msgs, nil
}

func (m *Model) scanAdmins(rows *sql.Rows) ([]AdminUser, error) {
	var list []AdminUser
	for rows.Next() {
		var a AdminUser
		rows.Scan(&a.ID, &a.FullName, &a.Email, &a.Phone, &a.PasswordHash,
			&a.Role, &a.Status, &a.AvatarURL, &a.LastLogin, &a.CreatedAt)
		list = append(list, a)
	}
	return list, nil
}

// ─── Cities ──────────────────────────────────────────────────────────────────

func (m *Model) GetCities() ([]map[string]any, error) {
	rows, err := m.db.Query(`
		SELECT c.id,c.name,c.region,c.is_active,COUNT(h.id) as hotel_count
		FROM cities c LEFT JOIN hotels h ON LOWER(h.city)=LOWER(c.name) AND h.is_active=true
		GROUP BY c.id ORDER BY c.name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var cities []map[string]any
	for rows.Next() {
		var id, count int
		var name, region string
		var active bool
		rows.Scan(&id, &name, &region, &active, &count)
		cities = append(cities, map[string]any{
			"id": id, "name": name, "region": region, "is_active": active, "hotel_count": count,
		})
	}
	return cities, nil
}

func (m *Model) AddCity(name, region string) error {
	_, err := m.db.Exec(`
		INSERT INTO cities (name,region,is_active) VALUES ($1,$2,true)
		ON CONFLICT DO NOTHING`, name, region)
	return err
}

func (m *Model) DeleteCity(id int) error {
	_, err := m.db.Exec(`DELETE FROM cities WHERE id=$1`, id)
	return err
}

// CreateManager creates an admin_users row (role=hotel_manager) and a hotel_managers link.
func (m *Model) CreateManager(fullName, email, phone, password string, hotelID, subAdminID int) (int, error) {
	hash, _ := utils.HashPassword(password)
	var adminID int
	err := m.db.QueryRow(`
		INSERT INTO admin_users (full_name,email,phone,password_hash,role,status,created_by)
		VALUES ($1,$2,$3,$4,'hotel_manager','active',$5) RETURNING id`,
		fullName, email, phone, hash, subAdminID,
	).Scan(&adminID)
	if err != nil {
		return 0, err
	}
	var managerID int
	err = m.db.QueryRow(`
		INSERT INTO hotel_managers (admin_id,hotel_id,sub_admin_id)
		VALUES ($1,$2,$3) RETURNING id`,
		adminID, hotelID, subAdminID,
	).Scan(&managerID)
	return managerID, err
}

func (m *Model) DeleteManager(id int) error {
	// id is the hotel_managers.id
	var adminID int
	m.db.QueryRow(`SELECT admin_id FROM hotel_managers WHERE id=$1`, id).Scan(&adminID)
	_, err := m.db.Exec(`DELETE FROM hotel_managers WHERE id=$1`, id)
	if err != nil {
		return err
	}
	_, err = m.db.Exec(`UPDATE admin_users SET status='inactive' WHERE id=$1`, adminID)
	return err
}

// GetManagerPayments returns all payments for bookings at the manager's hotel.
func (m *Model) GetManagerPayments(hotelID int) ([]map[string]any, error) {
	rows, err := m.db.Query(`
		SELECT p.id,p.booking_id,p.user_id,p.amount,p.currency,p.method,p.status,
		       p.transaction_id,p.screenshot_url,p.created_at,p.paid_at,
		       b.check_in::text,b.check_out::text,b.total_price,
		       b.adults,b.children,b.rooms,b.special_requests,
		       b.guest_full_name,b.guest_email,b.guest_phone,
		       b.national_id_front,b.national_id_back,
		       COALESCE(rt.name,'') AS room_type_name,
		       u.first_name||' '||u.last_name AS guest_name,
		       u.email AS user_email, u.phone AS user_phone
		FROM payments p
		JOIN bookings b ON b.id=p.booking_id
		JOIN users u ON u.id=p.user_id
		LEFT JOIN room_types rt ON rt.id=b.room_type_id
		WHERE b.hotel_id=$1
		ORDER BY p.created_at DESC`, hotelID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var payments []map[string]any
	for rows.Next() {
		var id, bookingID, userID, adults, children, rooms int
		var amount, totalPrice float64
		var currency, method, status, guestName string
		var checkIn, checkOut, roomTypeName string
		var txID, screenshot, paidAt, specialReqs *string
		var guestFullName, userEmail, userPhone string
		var guestEmail, guestPhone, natFront, natBack *string
		var createdAt time.Time
		rows.Scan(&id, &bookingID, &userID, &amount, &currency, &method, &status,
			&txID, &screenshot, &createdAt, &paidAt, &checkIn, &checkOut, &totalPrice,
			&adults, &children, &rooms, &specialReqs,
			&guestFullName, &guestEmail, &guestPhone,
			&natFront, &natBack, &roomTypeName,
			&guestName, &userEmail, &userPhone)
		payments = append(payments, map[string]any{
			"id": id, "booking_id": bookingID, "user_id": userID,
			"amount": amount, "currency": currency, "method": method, "status": status,
			"transaction_id": txID, "screenshot_url": screenshot,
			"created_at": createdAt, "paid_at": paidAt,
			"check_in": checkIn, "check_out": checkOut, "total_price": totalPrice,
			"adults": adults, "children": children, "rooms": rooms,
			"special_requests": specialReqs,
			"room_type_name":   roomTypeName,
			"guest_name":       guestName,
			"user_email":       userEmail,
			"user_phone":       userPhone,
			"guest_full_name":  guestFullName,
			"guest_email":      guestEmail,
			"guest_phone":      guestPhone,
			"national_id_front": natFront,
			"national_id_back":  natBack,
		})
	}
	return payments, nil
}

// VerifyPayment approves or rejects a payment. status = "completed" or "failed".
func (m *Model) VerifyPayment(paymentID, adminID int, status string) error {
	now := time.Now()
	if status == "completed" {
		_, err := m.db.Exec(`
			UPDATE payments SET status='completed',verified_by=$1,verified_at=$2,paid_at=$2
			WHERE id=$3`, adminID, now, paymentID)
		if err != nil {
			return err
		}
		// Confirm the booking
		var bookingID int
		m.db.QueryRow(`SELECT booking_id FROM payments WHERE id=$1`, paymentID).Scan(&bookingID)
		m.db.Exec(`UPDATE bookings SET status='confirmed' WHERE id=$1`, bookingID)
		return nil
	}
	_, err := m.db.Exec(`
		UPDATE payments SET status='failed',verified_by=$1,verified_at=$2
		WHERE id=$3`, adminID, now, paymentID)
	return err
}

func itoa(i int) string {
	return strconv.Itoa(i)
}
