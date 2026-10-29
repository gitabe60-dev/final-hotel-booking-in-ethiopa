-- 000022_add_room_status.down.sql
ALTER TABLE room_types DROP COLUMN IF EXISTS room_status;
