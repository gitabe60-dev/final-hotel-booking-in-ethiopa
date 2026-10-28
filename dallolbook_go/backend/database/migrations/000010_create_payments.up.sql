-- 000010_create_payments.up.sql
CREATE TABLE IF NOT EXISTS payments (
    id             SERIAL PRIMARY KEY,
    booking_id     INT           NOT NULL REFERENCES bookings(id),
    user_id        INT           NOT NULL REFERENCES users(id),
    amount         NUMERIC(12,2) NOT NULL,
    currency       VARCHAR(10)   NOT NULL DEFAULT 'ETB',
    method         VARCHAR(30)   NOT NULL,
    status         VARCHAR(20)   NOT NULL DEFAULT 'pending',
    transaction_id TEXT,
    gateway_ref    TEXT,
    paid_at        TIMESTAMPTZ,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_booking ON payments (booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_user    ON payments (user_id);
