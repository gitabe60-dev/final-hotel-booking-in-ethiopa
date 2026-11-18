-- 000023_extend_image_columns.up.sql
-- Clean up any old blob:// URLs that can't be displayed (replace with base64 going forward)
UPDATE bookings SET national_id_front = NULL WHERE national_id_front LIKE 'blob:%';
UPDATE bookings SET national_id_back  = NULL WHERE national_id_back  LIKE 'blob:%';
UPDATE payments SET screenshot_url    = NULL WHERE screenshot_url    LIKE 'blob:%';
