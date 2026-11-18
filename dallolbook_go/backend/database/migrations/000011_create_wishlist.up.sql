-- 000011_create_wishlist.up.sql
CREATE TABLE IF NOT EXISTS wishlist (
    id         SERIAL PRIMARY KEY,
    user_id    INT         NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    hotel_id   INT         NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, hotel_id)
);

CREATE INDEX IF NOT EXISTS idx_wishlist_user ON wishlist (user_id);
