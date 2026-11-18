-- 000004_create_hotels.up.sql
CREATE TABLE IF NOT EXISTS hotels (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(255)  NOT NULL,
    city            VARCHAR(100)  NOT NULL,
    address         TEXT          NOT NULL DEFAULT '',
    description     TEXT,
    type            VARCHAR(50)   NOT NULL DEFAULT 'hotel',
    rating          NUMERIC(3,2)  NOT NULL DEFAULT 0,
    review_count    INT           NOT NULL DEFAULT 0,
    price_per_night NUMERIC(12,2) NOT NULL DEFAULT 0,
    latitude        DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude       DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_featured     BOOLEAN       NOT NULL DEFAULT false,
    is_active       BOOLEAN       NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hotels_city     ON hotels (LOWER(city));
CREATE INDEX IF NOT EXISTS idx_hotels_featured ON hotels (is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_hotels_active   ON hotels (is_active)   WHERE is_active   = true;
