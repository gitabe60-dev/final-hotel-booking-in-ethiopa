-- Restore unique constraint (reverts to one account per method per hotel)
ALTER TABLE hotel_payment_methods
  ADD CONSTRAINT hotel_payment_methods_hotel_id_method_key UNIQUE (hotel_id, method);
