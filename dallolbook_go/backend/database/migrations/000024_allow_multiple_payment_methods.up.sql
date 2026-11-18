-- Allow hotel managers to add multiple accounts for the same payment method
-- (e.g. two Telebirr numbers or two CBE accounts for the same hotel).
ALTER TABLE hotel_payment_methods
  DROP CONSTRAINT IF EXISTS hotel_payment_methods_hotel_id_method_key;
