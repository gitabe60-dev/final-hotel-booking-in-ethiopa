-- 000006_create_hotel_amenities.up.sql
CREATE TABLE IF NOT EXISTS hotel_amenities (
    id       SERIAL PRIMARY KEY,
    hotel_id INT          NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    amenity  VARCHAR(100) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_hotel_amenities_hotel ON hotel_amenities (hotel_id);
