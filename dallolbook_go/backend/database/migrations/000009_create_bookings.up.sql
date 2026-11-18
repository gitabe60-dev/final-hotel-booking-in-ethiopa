-- 000009_create_bookings.up.sql
CREATE TABLE IF NOT EXISTS bookings (
    id               SERIAL PRIMARY KEY,
    user_id          INT           NOT NULL REFERENCES users(id),
    hotel_id         INT           NOT NULL REFERENCES hotels(id),
    room_type_id     INT                    REFERENCES room_types(id),
    check_in         DATE          NOT NULL,
    check_out        DATE          NOT NULL,
    adults           INT           NOT NULL DEFAULT 1,
    children         INT           NOT NULL DEFAULT 0,
    rooms            INT           NOT NULL DEFAULT 1,
    total_price      NUMERIC(12,2) NOT NULL DEFAULT 0,
    payment_method   VARCHAR(30)   NOT NULL,
    status           VARCHAR(20)   NOT NULL DEFAULT 'pending',
    special_requests TEXT,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_user   ON bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_hotel  ON bookings (hotel_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings (status);
