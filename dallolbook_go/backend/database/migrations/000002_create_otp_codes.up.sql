-- 000002_create_otp_codes.up.sql
CREATE TABLE IF NOT EXISTS otp_codes (
    id         SERIAL PRIMARY KEY,
    phone      VARCHAR(30)  NOT NULL,
    code       VARCHAR(6)   NOT NULL,
    purpose    VARCHAR(30)  NOT NULL,
    used       BOOLEAN      NOT NULL DEFAULT false,
    expires_at TIMESTAMPTZ  NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_otp_phone_purpose ON otp_codes (phone, purpose, used);
