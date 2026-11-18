-- 000007_create_room_types.up.sql
CREATE TABLE IF NOT EXISTS room_types (
    id              SERIAL PRIMARY KEY,
    hotel_id        INT           NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    name            VARCHAR(100)  NOT NULL,
    bed_type        VARCHAR(50)   NOT NULL DEFAULT '',
    image_url       TEXT,
    price_per_night NUMERIC(12,2) NOT NULL DEFAULT 0,
    size_sqm        NUMERIC(8,2)  NOT NULL DEFAULT 0,
    max_guests      INT           NOT NULL DEFAULT 2,
    is_available    BOOLEAN       NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_room_types_hotel ON room_types (hotel_id);
