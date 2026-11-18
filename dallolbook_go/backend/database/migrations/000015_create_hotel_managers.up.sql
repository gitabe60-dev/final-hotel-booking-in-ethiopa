-- 000015_create_hotel_managers.up.sql
CREATE TABLE IF NOT EXISTS hotel_managers (
    id           SERIAL PRIMARY KEY,
    admin_id     INT NOT NULL REFERENCES admin_users(id),
    hotel_id     INT NOT NULL REFERENCES hotels(id),
    sub_admin_id INT          REFERENCES admin_users(id)
);

CREATE INDEX IF NOT EXISTS idx_hotel_managers_admin ON hotel_managers (admin_id);
CREATE INDEX IF NOT EXISTS idx_hotel_managers_hotel ON hotel_managers (hotel_id);
