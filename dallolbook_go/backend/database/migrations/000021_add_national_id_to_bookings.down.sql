-- 000021_add_national_id_to_bookings.down.sql
ALTER TABLE bookings DROP COLUMN IF EXISTS national_id_front;
ALTER TABLE bookings DROP COLUMN IF EXISTS national_id_back;
ALTER TABLE bookings DROP COLUMN IF EXISTS guest_full_name;
ALTER TABLE bookings DROP COLUMN IF EXISTS guest_email;
ALTER TABLE bookings DROP COLUMN IF EXISTS guest_phone;
