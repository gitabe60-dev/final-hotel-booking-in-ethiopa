-- 000018_add_payment_screenshot.up.sql
ALTER TABLE payments ADD COLUMN IF NOT EXISTS screenshot_url TEXT;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS verified_by INT REFERENCES admin_users(id);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;
