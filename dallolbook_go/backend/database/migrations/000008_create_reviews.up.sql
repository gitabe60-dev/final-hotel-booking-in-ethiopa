-- 000008_create_reviews.up.sql
CREATE TABLE IF NOT EXISTS reviews (
    id         SERIAL PRIMARY KEY,
    hotel_id   INT           NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    user_id    INT           NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    rating     NUMERIC(3,2)  NOT NULL,
    comment    TEXT          NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    UNIQUE (hotel_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_hotel ON reviews (hotel_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user  ON reviews (user_id);
