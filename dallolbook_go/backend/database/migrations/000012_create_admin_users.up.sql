-- 000012_create_admin_users.up.sql
CREATE TABLE IF NOT EXISTS admin_users (
    id            SERIAL PRIMARY KEY,
    full_name     VARCHAR(255) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone         VARCHAR(30),
    password_hash TEXT         NOT NULL,
    role          VARCHAR(30)  NOT NULL,
    status        VARCHAR(20)  NOT NULL DEFAULT 'active',
    avatar_url    TEXT,
    last_login    TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by    INT                   REFERENCES admin_users(id)
);

CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users (LOWER(email));
CREATE INDEX IF NOT EXISTS idx_admin_users_role  ON admin_users (role);
