-- 000020_create_hotel_payment_methods.up.sql
CREATE TABLE IF NOT EXISTS hotel_payment_methods (
    id             SERIAL PRIMARY KEY,
    hotel_id       INT          NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    method         VARCHAR(50)  NOT NULL,  -- telebirr | cbe_birr | chapa | bank_transfer | cash | card | mobile_money
    account_name   VARCHAR(200) NOT NULL DEFAULT '',
    account_number VARCHAR(100) NOT NULL DEFAULT '',
    phone_number   VARCHAR(50)  NOT NULL DEFAULT '',
    instructions   TEXT         NOT NULL DEFAULT '',
    is_active      BOOLEAN      NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (hotel_id, method)
);

-- Seed default payment methods for all existing hotels
INSERT INTO hotel_payment_methods (hotel_id, method, account_name, account_number, instructions, is_active)
SELECT h.id, m.method, m.account_name, m.account_number, m.instructions, true
FROM hotels h
CROSS JOIN (VALUES
    ('telebirr',     'Hotel Telebirr',     '09XXXXXXXX', 'Send payment to the Telebirr number above'),
    ('cbe_birr',      'Hotel CBE Account',  '1000XXXXXXXX', 'Transfer to the CBE Birr account above'),
    ('chapa',         'Chapa Payment',      '',            'Pay online via Chapa gateway'),
    ('bank_transfer', 'Bank Transfer',      '1000XXXXXXXX', 'Transfer to the bank account above'),
    ('cash',          'Cash on Arrival',    '',            'Pay cash at hotel reception on arrival')
) AS m(method, account_name, account_number, instructions)
WHERE NOT EXISTS (
    SELECT 1 FROM hotel_payment_methods hpm WHERE hpm.hotel_id = h.id AND hpm.method = m.method
);
