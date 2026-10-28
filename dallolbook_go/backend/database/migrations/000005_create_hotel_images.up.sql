-- 000005_create_hotel_images.up.sql
CREATE TABLE IF NOT EXISTS hotel_images (
    id         SERIAL PRIMARY KEY,
    hotel_id   INT     NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    image_url  TEXT    NOT NULL,
    sort_order INT     NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_hotel_images_hotel ON hotel_images (hotel_id, sort_order);
