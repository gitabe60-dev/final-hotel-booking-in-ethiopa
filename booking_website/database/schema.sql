-- =============================================================
--  Dallol Booking Platform  –  PostgreSQL Schema
--  Compatible with CodeIgniter 4 + Flutter mobile app models
-- =============================================================

-- Drop existing tables (in dependency order)
DROP TABLE IF EXISTS wishlist         CASCADE;
DROP TABLE IF EXISTS payments         CASCADE;
DROP TABLE IF EXISTS bookings         CASCADE;
DROP TABLE IF EXISTS reviews          CASCADE;
DROP TABLE IF EXISTS room_types       CASCADE;
DROP TABLE IF EXISTS hotel_amenities  CASCADE;
DROP TABLE IF EXISTS hotel_images     CASCADE;
DROP TABLE IF EXISTS hotels           CASCADE;
DROP TABLE IF EXISTS otp_codes        CASCADE;
DROP TABLE IF EXISTS refresh_tokens   CASCADE;
DROP TABLE IF EXISTS users            CASCADE;

-- ─────────────────────────────────────────────────────────────
--  USERS  (guests)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE users (
    id                SERIAL        PRIMARY KEY,
    first_name        VARCHAR(100)  NOT NULL,
    last_name         VARCHAR(100)  NOT NULL,
    email             VARCHAR(150)  UNIQUE,
    phone             VARCHAR(20)   UNIQUE,
    password_hash     VARCHAR(255),
    nationality       VARCHAR(80),
    avatar_url        TEXT,
    status            VARCHAR(20)   NOT NULL DEFAULT 'active'
                          CHECK (status IN ('active','suspended','unverified')),
    is_verified       BOOLEAN       NOT NULL DEFAULT FALSE,
    last_login        TIMESTAMPTZ,
    registered_date   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_phone ON users (phone);

-- ─────────────────────────────────────────────────────────────
--  OTP CODES
-- ─────────────────────────────────────────────────────────────
CREATE TABLE otp_codes (
    id          SERIAL       PRIMARY KEY,
    phone       VARCHAR(20)  NOT NULL,
    code        VARCHAR(6)   NOT NULL,
    purpose     VARCHAR(30)  NOT NULL DEFAULT 'login'
                    CHECK (purpose IN ('login','register','reset')),
    expires_at  TIMESTAMPTZ  NOT NULL,
    used        BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_otp_phone ON otp_codes (phone);

-- ─────────────────────────────────────────────────────────────
--  REFRESH TOKENS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE refresh_tokens (
    id          SERIAL       PRIMARY KEY,
    user_id     INT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       TEXT         NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ  NOT NULL,
    revoked     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rt_user ON refresh_tokens (user_id);

-- ─────────────────────────────────────────────────────────────
--  HOTELS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE hotels (
    id               SERIAL         PRIMARY KEY,
    name             VARCHAR(200)   NOT NULL,
    city             VARCHAR(100)   NOT NULL,
    address          TEXT           NOT NULL,
    description      TEXT,
    type             VARCHAR(50)    NOT NULL DEFAULT 'Hotel'
                         CHECK (type IN ('Hotel','Resort','Lodge','Guest House','Hostel','Boutique')),
    rating           NUMERIC(3,1)   NOT NULL DEFAULT 0.0
                         CHECK (rating >= 0 AND rating <= 5),
    review_count     INT            NOT NULL DEFAULT 0,
    price_per_night  NUMERIC(10,2)  NOT NULL DEFAULT 0,
    latitude         NUMERIC(10,6)  NOT NULL DEFAULT 0,
    longitude        NUMERIC(10,6)  NOT NULL DEFAULT 0,
    is_featured      BOOLEAN        NOT NULL DEFAULT FALSE,
    is_active        BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_hotels_city     ON hotels (city);
CREATE INDEX idx_hotels_featured ON hotels (is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_hotels_type     ON hotels (type);
CREATE INDEX idx_hotels_price    ON hotels (price_per_night);
CREATE INDEX idx_hotels_rating   ON hotels (rating);

-- ─────────────────────────────────────────────────────────────
--  HOTEL IMAGES
-- ─────────────────────────────────────────────────────────────
CREATE TABLE hotel_images (
    id          SERIAL   PRIMARY KEY,
    hotel_id    INT      NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    image_url   TEXT     NOT NULL,
    sort_order  INT      NOT NULL DEFAULT 0,
    is_primary  BOOLEAN  NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_hi_hotel ON hotel_images (hotel_id);

-- ─────────────────────────────────────────────────────────────
--  HOTEL AMENITIES
-- ─────────────────────────────────────────────────────────────
CREATE TABLE hotel_amenities (
    id        SERIAL       PRIMARY KEY,
    hotel_id  INT          NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    amenity   VARCHAR(100) NOT NULL
);

CREATE INDEX idx_ha_hotel ON hotel_amenities (hotel_id);

-- ─────────────────────────────────────────────────────────────
--  ROOM TYPES
-- ─────────────────────────────────────────────────────────────
CREATE TABLE room_types (
    id               SERIAL         PRIMARY KEY,
    hotel_id         INT            NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    name             VARCHAR(100)   NOT NULL,
    bed_type         VARCHAR(80)    NOT NULL,
    image_url        TEXT,
    price_per_night  NUMERIC(10,2)  NOT NULL,
    size_sqm         NUMERIC(6,1)   NOT NULL DEFAULT 0,
    max_guests       INT            NOT NULL DEFAULT 2,
    features         TEXT[],                          -- PostgreSQL array
    is_available     BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rt_hotel ON room_types (hotel_id);

-- ─────────────────────────────────────────────────────────────
--  REVIEWS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE reviews (
    id           SERIAL        PRIMARY KEY,
    hotel_id     INT           NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    user_id      INT           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating       NUMERIC(3,1)  NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment      TEXT          NOT NULL,
    images       TEXT[],
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    UNIQUE (hotel_id, user_id)
);

CREATE INDEX idx_reviews_hotel ON reviews (hotel_id);
CREATE INDEX idx_reviews_user  ON reviews (user_id);

-- ─────────────────────────────────────────────────────────────
--  BOOKINGS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE bookings (
    id               SERIAL         PRIMARY KEY,
    user_id          INT            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hotel_id         INT            NOT NULL REFERENCES hotels(id) ON DELETE RESTRICT,
    room_type_id     INT            REFERENCES room_types(id) ON DELETE SET NULL,
    check_in         DATE           NOT NULL,
    check_out        DATE           NOT NULL,
    adults           SMALLINT       NOT NULL DEFAULT 1 CHECK (adults >= 1),
    children         SMALLINT       NOT NULL DEFAULT 0 CHECK (children >= 0),
    rooms            SMALLINT       NOT NULL DEFAULT 1 CHECK (rooms >= 1),
    total_price      NUMERIC(12,2)  NOT NULL,
    payment_method   VARCHAR(50)    NOT NULL DEFAULT 'card'
                         CHECK (payment_method IN ('card','bank_transfer','mobile_money','cash','telebirr','cbe_birr')),
    status           VARCHAR(20)    NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','confirmed','cancelled','completed')),
    special_requests TEXT,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_dates CHECK (check_out > check_in)
);

CREATE INDEX idx_bookings_user   ON bookings (user_id);
CREATE INDEX idx_bookings_hotel  ON bookings (hotel_id);
CREATE INDEX idx_bookings_status ON bookings (status);
CREATE INDEX idx_bookings_dates  ON bookings (check_in, check_out);

-- ─────────────────────────────────────────────────────────────
--  PAYMENTS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE payments (
    id              SERIAL         PRIMARY KEY,
    booking_id      INT            NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    user_id         INT            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount          NUMERIC(12,2)  NOT NULL,
    currency        VARCHAR(10)    NOT NULL DEFAULT 'ETB',
    method          VARCHAR(50)    NOT NULL,
    status          VARCHAR(20)    NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending','completed','failed','refunded')),
    transaction_id  VARCHAR(200),
    gateway_ref     VARCHAR(200),
    paid_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_booking ON payments (booking_id);
CREATE INDEX idx_payments_user    ON payments (user_id);
CREATE INDEX idx_payments_status  ON payments (status);

-- ─────────────────────────────────────────────────────────────
--  WISHLIST
-- ─────────────────────────────────────────────────────────────
CREATE TABLE wishlist (
    id          SERIAL       PRIMARY KEY,
    user_id     INT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hotel_id    INT          NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, hotel_id)
);

CREATE INDEX idx_wishlist_user  ON wishlist (user_id);
CREATE INDEX idx_wishlist_hotel ON wishlist (hotel_id);

-- =============================================================
--  FUNCTIONS & TRIGGERS
-- =============================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER trg_hotels_updated_at
    BEFORE UPDATE ON hotels
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER trg_room_types_updated_at
    BEFORE UPDATE ON room_types
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER trg_bookings_updated_at
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER trg_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER trg_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- Auto-update hotel rating when a review is inserted/updated/deleted
CREATE OR REPLACE FUNCTION update_hotel_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE hotels
    SET
        rating       = (SELECT COALESCE(AVG(rating), 0) FROM reviews WHERE hotel_id = COALESCE(NEW.hotel_id, OLD.hotel_id)),
        review_count = (SELECT COUNT(*)                 FROM reviews WHERE hotel_id = COALESCE(NEW.hotel_id, OLD.hotel_id)),
        updated_at   = NOW()
    WHERE id = COALESCE(NEW.hotel_id, OLD.hotel_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_hotel_rating
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_hotel_rating();

-- =============================================================
--  SEED DATA  –  10 Ethiopian Hotels (mirrors Flutter sample)
-- =============================================================

INSERT INTO hotels (name, city, address, description, type, rating, review_count, price_per_night, latitude, longitude, is_featured) VALUES
('Sheraton Addis',          'Addis Ababa', 'Taitu St, Addis Ababa',           'Luxury 5-star hotel in the heart of Addis Ababa with world-class amenities and stunning views of the city.',       'Hotel',       4.8, 1240, 4500.00,  9.019200,  38.752500, TRUE),
('Haile Resort Hawassa',    'Hawassa',     'Lake Shore, Hawassa',              'Beautiful lakeside resort with stunning views of Lake Hawassa. Perfect for a relaxing getaway.',                   'Resort',      4.6,  876, 2800.00,  7.062100,  38.476800, TRUE),
('Kuriftu Resort Bahir Dar','Bahir Dar',   'Lake Tana Shore, Bahir Dar',       'Eco-resort on the shores of Lake Tana, gateway to the ancient island monasteries.',                                'Resort',      4.7,  654, 3200.00, 11.574200,  37.361400, TRUE),
('Goha Hotel Gondar',       'Gondar',      'Gondar Hill, Gondar',              'Historic hotel with panoramic views of Gondar and the Royal Enclosure UNESCO heritage site.',                      'Hotel',       4.3,  432, 1800.00, 12.603000,  37.452100, TRUE),
('Axum Hotel',              'Mekelle',     'Central Mekelle, Tigray',          'Comfortable hotel in Mekelle offering easy access to the historic Tigray region.',                                 'Hotel',       4.2,  310, 1600.00, 13.496700,  39.475300, FALSE),
('Adama Guest Villa',       'Adama',       'Adama Town Centre',                'Cozy villa-style guesthouse close to the hot springs of Sodere.',                                                  'Guest House', 4.0,  215, 1200.00,  8.540000,  39.270000, FALSE),
('Jimma Hilltop Lodge',     'Jimma',       'Jimma Hills, Oromia',              'Scenic lodge in the birthplace of coffee, Jimma. Explore the lush coffee forests.',                                'Lodge',       4.1,  180, 1400.00,  7.666700,  36.833300, FALSE),
('Harar Jugol Boutique',    'Harar',       'Inside the Jugol Walls, Harar',    'Authentic boutique hotel inside the ancient walled city of Harar, a UNESCO World Heritage Site.',                 'Hotel',       4.5,  298, 2200.00,  9.311900,  42.119400, FALSE),
('Arba Minch Lakeview Resort','Arba Minch','Lake Abaya Shore, Arba Minch',     'Stunning resort overlooking Lake Abaya and Chamo. Gateway to Nechisar National Park.',                            'Resort',      4.4,  340, 2600.00,  6.033300,  37.550000, FALSE),
('Addis Skylight Hotel',    'Addis Ababa', 'Bole Road, Addis Ababa',           'Premium hotel near Bole International Airport with rooftop pool and panoramic views of Addis Ababa.',             'Hotel',       4.5,  920, 3800.00,  8.980600,  38.757800, TRUE);

-- Hotel images
INSERT INTO hotel_images (hotel_id, image_url, sort_order, is_primary) VALUES
(1, 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 0, TRUE),
(1, 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800', 1, FALSE),
(1, 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800', 2, FALSE),
(2, 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 0, TRUE),
(2, 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800', 1, FALSE),
(2, 'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=800', 2, FALSE),
(3, 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',   0, TRUE),
(3, 'https://images.unsplash.com/photo-1455587734955-081b22074882?w=800', 1, FALSE),
(3, 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',   2, FALSE),
(4, 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',   0, TRUE),
(4, 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 1, FALSE),
(5, 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800', 0, TRUE),
(5, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800', 1, FALSE),
(6, 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800', 0, TRUE),
(6, 'https://images.unsplash.com/photo-1631049421450-348ccd7f8949?w=800', 1, FALSE),
(7, 'https://images.unsplash.com/photo-1521401830884-6c03c1c87ebb?w=800', 0, TRUE),
(7, 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800', 1, FALSE),
(8, 'https://images.unsplash.com/photo-1601918774516-5c7fe187b2a1?w=800', 0, TRUE),
(8, 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800', 1, FALSE),
(9, 'https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=800', 0, TRUE),
(9, 'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800',   1, FALSE),
(10,'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 0, TRUE),
(10,'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800', 1, FALSE),
(10,'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 2, FALSE);

-- Hotel amenities
INSERT INTO hotel_amenities (hotel_id, amenity) VALUES
(1,'Free WiFi'),(1,'Pool'),(1,'Gym'),(1,'Restaurant'),(1,'Spa'),(1,'Parking'),
(2,'Free WiFi'),(2,'Pool'),(2,'Restaurant'),(2,'Parking'),(2,'Boat Tours'),
(3,'Free WiFi'),(3,'Pool'),(3,'Spa'),(3,'Restaurant'),(3,'Boat Tours'),(3,'Gym'),
(4,'Free WiFi'),(4,'Restaurant'),(4,'Parking'),(4,'Pool'),(4,'Bar'),
(5,'Free WiFi'),(5,'Restaurant'),(5,'Parking'),(5,'Air Conditioning'),
(6,'Free WiFi'),(6,'Parking'),(6,'Restaurant'),(6,'Garden'),
(7,'Free WiFi'),(7,'Restaurant'),(7,'Coffee Tours'),(7,'Garden'),(7,'Parking'),
(8,'Free WiFi'),(8,'Rooftop Terrace'),(8,'Local Tours'),(8,'Breakfast'),
(9,'Free WiFi'),(9,'Pool'),(9,'Restaurant'),(9,'Boat Tours'),(9,'Parking'),
(10,'Free WiFi'),(10,'Pool'),(10,'Gym'),(10,'Spa'),(10,'Restaurant'),(10,'Bar'),(10,'Airport Shuttle');

-- Room types for hotel 1 (Sheraton Addis) as example
INSERT INTO room_types (hotel_id, name, bed_type, image_url, price_per_night, size_sqm, max_guests, features, is_available) VALUES
(1, 'Standard Room',    'Queen Bed',         'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600', 4500.00, 22, 2, ARRAY['Free WiFi','Air Conditioning','TV','En-suite Bathroom'], TRUE),
(1, 'Deluxe Room',      'King Bed',          'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=600', 6300.00, 32, 2, ARRAY['Free WiFi','City View','Mini Bar','Bathtub','Balcony'],   TRUE),
(1, 'Twin Room',        'Twin Beds',         'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=600', 4950.00, 26, 2, ARRAY['Free WiFi','Air Conditioning','Work Desk','TV'],           TRUE),
(1, 'Family Suite',     'King + Bunk Beds',  'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=600', 8550.00, 48, 4, ARRAY['Free WiFi','Living Area','Kitchenette','Two Bathrooms','Kids Corner'], TRUE),
(1, 'Executive Suite',  'King Bed',          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=600',11250.00, 68, 2, ARRAY['Free WiFi','Panoramic View','Private Lounge','Jacuzzi','Butler Service','Premium Bar'], TRUE),
(1, 'Penthouse',        'Super King Bed',    'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600',  18000.00,120, 4, ARRAY['Free WiFi','Private Terrace','Private Pool','Chef Service','Limousine Transfer','Spa Access'], FALSE);

-- =============================================================
--  VIEWS  (useful for admin dashboard)
-- =============================================================

CREATE OR REPLACE VIEW v_hotel_summary AS
SELECT
    h.id,
    h.name,
    h.city,
    h.type,
    h.rating,
    h.review_count,
    h.price_per_night,
    h.is_featured,
    h.is_active,
    (SELECT image_url FROM hotel_images WHERE hotel_id = h.id AND is_primary = TRUE LIMIT 1) AS primary_image,
    (SELECT COUNT(*) FROM bookings b WHERE b.hotel_id = h.id AND b.status != 'cancelled') AS total_bookings
FROM hotels h;

CREATE OR REPLACE VIEW v_booking_detail AS
SELECT
    b.id,
    b.user_id,
    u.first_name || ' ' || u.last_name  AS guest_name,
    u.email                              AS guest_email,
    u.phone                              AS guest_phone,
    b.hotel_id,
    h.name                               AS hotel_name,
    h.city                               AS hotel_city,
    (SELECT image_url FROM hotel_images WHERE hotel_id = h.id AND is_primary = TRUE LIMIT 1) AS hotel_image,
    b.room_type_id,
    rt.name                              AS room_type_name,
    b.check_in,
    b.check_out,
    (b.check_out - b.check_in)           AS nights,
    b.adults,
    b.children,
    b.rooms,
    b.total_price,
    b.payment_method,
    b.status,
    b.special_requests,
    b.created_at
FROM bookings b
JOIN users     u  ON b.user_id     = u.id
JOIN hotels    h  ON b.hotel_id    = h.id
LEFT JOIN room_types rt ON b.room_type_id = rt.id;
