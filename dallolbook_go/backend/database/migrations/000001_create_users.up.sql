-- 000001_create_users.up.sql
CREATE TABLE IF NOT EXISTS users (
    id               SERIAL PRIMARY KEY,
    first_name       VARCHAR(100)  NOT NULL,
    last_name        VARCHAR(100)  NOT NULL DEFAULT '',
    email            VARCHAR(255)  UNIQUE,
    phone            VARCHAR(30)   UNIQUE,
    password_hash    TEXT,
    nationality      VARCHAR(100),
    avatar_url       TEXT,
    status           VARCHAR(20)   NOT NULL DEFAULT 'active',
    is_verified      BOOLEAN       NOT NULL DEFAULT false,
    last_login       TIMESTAMPTZ,
    registered_date  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (LOWER(email));
CREATE INDEX IF NOT EXISTS idx_users_phone ON users (phone);
