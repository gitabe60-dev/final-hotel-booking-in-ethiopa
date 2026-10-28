-- 000019_create_notifications.up.sql
CREATE TABLE IF NOT EXISTS notifications (
    id         SERIAL PRIMARY KEY,
    user_id    INT          REFERENCES users(id)       ON DELETE CASCADE,
    admin_id   INT          REFERENCES admin_users(id) ON DELETE CASCADE,
    type       VARCHAR(50)  NOT NULL,  -- booking_new | payment_approved | payment_rejected
    title      VARCHAR(255) NOT NULL,
    message    TEXT         NOT NULL,
    is_read    BOOLEAN      NOT NULL DEFAULT false,
    booking_id INT          REFERENCES bookings(id)    ON DELETE SET NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notif_user  ON notifications (user_id,  is_read);
CREATE INDEX IF NOT EXISTS idx_notif_admin ON notifications (admin_id, is_read);
