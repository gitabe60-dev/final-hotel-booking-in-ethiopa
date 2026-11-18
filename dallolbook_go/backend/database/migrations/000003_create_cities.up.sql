-- 000003_create_cities.up.sql
CREATE TABLE IF NOT EXISTS cities (
    id        SERIAL PRIMARY KEY,
    name      VARCHAR(100) NOT NULL UNIQUE,
    region    VARCHAR(100) NOT NULL DEFAULT '',
    is_active BOOLEAN      NOT NULL DEFAULT true
);
