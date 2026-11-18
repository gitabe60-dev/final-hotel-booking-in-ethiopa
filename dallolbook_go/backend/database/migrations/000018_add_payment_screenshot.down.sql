-- 000018_add_payment_screenshot.down.sql
ALTER TABLE payments DROP COLUMN IF EXISTS screenshot_url;
ALTER TABLE payments DROP COLUMN IF EXISTS verified_by;
ALTER TABLE payments DROP COLUMN IF EXISTS verified_at;
