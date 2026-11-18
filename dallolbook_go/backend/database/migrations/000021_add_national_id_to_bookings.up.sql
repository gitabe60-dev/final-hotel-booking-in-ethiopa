-- 000021_add_national_id_to_bookings.up.sql
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS national_id_front TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS national_id_back  TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS guest_full_name   VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS guest_email       VARCHAR(255);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS guest_phone       VARCHAR(50);

-- Remove cash from all hotels
DELETE FROM hotel_payment_methods WHERE method = 'cash';
DELETE FROM hotel_payment_methods WHERE method = 'mobile_money';
DELETE FROM hotel_payment_methods WHERE method = 'card';

-- Add comprehensive Ethiopian bank options for all hotels that don't have them yet
INSERT INTO hotel_payment_methods (hotel_id, method, account_name, account_number, phone_number, instructions, is_active)
SELECT h.id, m.method, m.acct_name, m.acct_num, m.phone, m.instr, true
FROM hotels h
CROSS JOIN (VALUES
  ('awash_bank',   'Hotel Awash Bank',    '01320XXXXXXXXX', '', 'Awash International Bank — transfer and include Booking ID'),
  ('abyssinia',    'Hotel Abyssinia Bank','023560XXXXXXXX', '', 'Bank of Abyssinia — transfer and include Booking ID'),
  ('dashen',       'Hotel Dashen Bank',   '015040XXXXXXXX', '', 'Dashen Bank — transfer and include Booking ID'),
  ('oromia_coop',  'Hotel Oromia Bank',   '031040XXXXXXXX', '', 'Oromia International Bank — transfer and include Booking ID'),
  ('united',       'Hotel United Bank',   '047050XXXXXXXX', '', 'United Bank Ethiopia — transfer and include Booking ID'),
  ('nib',          'Hotel NIB Bank',      '034030XXXXXXXX', '', 'NIB International Bank — transfer and include Booking ID'),
  ('wegagen',      'Hotel Wegagen Bank',  '066060XXXXXXXX', '', 'Wegagen Bank — transfer and include Booking ID'),
  ('bunna',        'Hotel Bunna Bank',    '089070XXXXXXXX', '', 'Bunna International Bank — transfer and include Booking ID'),
  ('cooperative',  'Hotel Cooperative Bank','010030XXXXXXXX','','Cooperative Bank of Oromia — transfer and include Booking ID')
) AS m(method, acct_name, acct_num, phone, instr)
WHERE NOT EXISTS (
  SELECT 1 FROM hotel_payment_methods hpm
  WHERE hpm.hotel_id = h.id AND hpm.method = m.method
);
