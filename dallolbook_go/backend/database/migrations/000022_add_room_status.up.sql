-- 000022_add_room_status.up.sql
ALTER TABLE room_types ADD COLUMN IF NOT EXISTS room_status VARCHAR(30) NOT NULL DEFAULT 'available';
-- available | maintenance | unavailable

-- Migrate existing is_available values
UPDATE room_types SET room_status = 'maintenance' WHERE is_available = false;
