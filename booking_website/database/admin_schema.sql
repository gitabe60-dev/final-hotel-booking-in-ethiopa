-- =============================================================
--  Dallol Booking — Admin Hierarchy Schema
--  Roles: super_admin > sub_admin > broker > hotel_manager
-- =============================================================

-- ─── ADMIN USERS ─────────────────────────────────────────────
DROP TABLE IF EXISTS broker_messages     CASCADE;
DROP TABLE IF EXISTS broker_hotel_links  CASCADE;
DROP TABLE IF EXISTS hotel_managers      CASCADE;
DROP TABLE IF EXISTS brokers             CASCADE;
DROP TABLE IF EXISTS admin_city_assignments CASCADE;
DROP TABLE IF EXISTS admin_users         CASCADE;

CREATE TABLE admin_users (
    id            SERIAL        PRIMARY KEY,
    full_name     VARCHAR(150)  NOT NULL,
    email         VARCHAR(150)  NOT NULL UNIQUE,
    phone         VARCHAR(20),
    password_hash VARCHAR(255)  NOT NULL,
    role          VARCHAR(30)   NOT NULL
                      CHECK (role IN ('super_admin','sub_admin','broker','hotel_manager')),
    status        VARCHAR(20)   NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active','suspended','inactive')),
    avatar_url    TEXT,
    last_login    TIMESTAMPTZ,
    created_by    INT           REFERENCES admin_users(id) ON DELETE SET NULL,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_au_role   ON admin_users (role);
CREATE INDEX idx_au_email  ON admin_users (email);
CREATE INDEX idx_au_status ON admin_users (status);

-- ─── CITY ASSIGNMENTS (sub_admin ↔ city) ─────────────────────
CREATE TABLE admin_city_assignments (
    id           SERIAL       PRIMARY KEY,
    admin_id     INT          NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,
    city         VARCHAR(100) NOT NULL,
    assigned_by  INT          REFERENCES admin_users(id) ON DELETE SET NULL,
    assigned_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (admin_id, city)
);

CREATE INDEX idx_aca_admin ON admin_city_assignments (admin_id);
CREATE INDEX idx_aca_city  ON admin_city_assignments (city);

-- ─── BROKERS (linked to sub_admin + city) ────────────────────
CREATE TABLE brokers (
    id            SERIAL       PRIMARY KEY,
    admin_id      INT          NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,
    sub_admin_id  INT          NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,
    city          VARCHAR(100) NOT NULL,
    commission_pct NUMERIC(5,2) NOT NULL DEFAULT 0.00,
    status        VARCHAR(20)  NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active','suspended','inactive')),
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_brokers_admin     ON brokers (admin_id);
CREATE INDEX idx_brokers_subadmin  ON brokers (sub_admin_id);
CREATE INDEX idx_brokers_city      ON brokers (city);

-- ─── HOTEL MANAGERS (linked to a specific hotel) ─────────────
CREATE TABLE hotel_managers (
    id           SERIAL  PRIMARY KEY,
    admin_id     INT     NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,
    hotel_id     INT     NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    broker_id    INT     REFERENCES brokers(id) ON DELETE SET NULL,
    sub_admin_id INT     REFERENCES admin_users(id) ON DELETE SET NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (hotel_id)  -- one manager per hotel
);

CREATE INDEX idx_hm_admin   ON hotel_managers (admin_id);
CREATE INDEX idx_hm_hotel   ON hotel_managers (hotel_id);
CREATE INDEX idx_hm_broker  ON hotel_managers (broker_id);

-- ─── BROKER ↔ HOTEL LINKS (broker manages multiple hotels) ───
CREATE TABLE broker_hotel_links (
    id         SERIAL  PRIMARY KEY,
    broker_id  INT     NOT NULL REFERENCES brokers(id) ON DELETE CASCADE,
    hotel_id   INT     NOT NULL REFERENCES hotels(id)  ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (broker_id, hotel_id)
);

-- ─── BROKER MESSAGES (sub_admin ↔ broker ↔ hotel_manager) ────
CREATE TABLE broker_messages (
    id           SERIAL        PRIMARY KEY,
    from_admin   INT           NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,
    to_admin     INT           NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,
    hotel_id     INT           REFERENCES hotels(id) ON DELETE SET NULL,
    subject      VARCHAR(200)  NOT NULL,
    body         TEXT          NOT NULL,
    is_read      BOOLEAN       NOT NULL DEFAULT FALSE,
    parent_id    INT           REFERENCES broker_messages(id) ON DELETE SET NULL,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bm_from   ON broker_messages (from_admin);
CREATE INDEX idx_bm_to     ON broker_messages (to_admin);
CREATE INDEX idx_bm_hotel  ON broker_messages (hotel_id);

-- ─── TRIGGER: updated_at ─────────────────────────────────────
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname='trg_admin_users_updated_at') THEN
    CREATE TRIGGER trg_admin_users_updated_at
      BEFORE UPDATE ON admin_users FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
  END IF;
END $$;

-- ─── SEED: Super Admin ────────────────────────────────────────
-- Password: Admin@1234  (bcrypt)
INSERT INTO admin_users (full_name, email, phone, password_hash, role, status)
VALUES (
    'Super Admin',
    'superadmin@dalloltech.com',
    '+251911000001',
    '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGiHMkLf3vPn.wqMtjQF4l.yEeS',
    'super_admin',
    'active'
) ON CONFLICT (email) DO NOTHING;

-- =============================================================
--  VIEWS useful for admin dashboards
-- =============================================================
CREATE OR REPLACE VIEW v_admin_overview AS
SELECT
    (SELECT COUNT(*) FROM admin_users WHERE role = 'sub_admin'    AND status='active') AS sub_admins,
    (SELECT COUNT(*) FROM admin_users WHERE role = 'broker'        AND status='active') AS brokers,
    (SELECT COUNT(*) FROM admin_users WHERE role = 'hotel_manager' AND status='active') AS hotel_managers,
    (SELECT COUNT(*) FROM hotels         WHERE is_active = TRUE)                         AS active_hotels,
    (SELECT COUNT(*) FROM bookings        WHERE status   = 'confirmed')                  AS confirmed_bookings,
    (SELECT COUNT(*) FROM bookings        WHERE status   = 'pending')                    AS pending_bookings,
    (SELECT COUNT(*) FROM users)                                                          AS total_guests,
    (SELECT COALESCE(SUM(total_price),0) FROM bookings WHERE status IN ('confirmed','completed')) AS total_revenue;

CREATE OR REPLACE VIEW v_broker_details AS
SELECT
    b.id,
    b.city,
    b.commission_pct,
    b.status,
    au_broker.id       AS admin_id,
    au_broker.full_name AS broker_name,
    au_broker.email     AS broker_email,
    au_broker.phone     AS broker_phone,
    au_sub.id          AS sub_admin_id,
    au_sub.full_name   AS sub_admin_name,
    (SELECT COUNT(*) FROM broker_hotel_links bhl WHERE bhl.broker_id = b.id) AS hotel_count,
    (SELECT COUNT(*) FROM broker_messages bm WHERE bm.from_admin = b.admin_id OR bm.to_admin = b.admin_id) AS message_count
FROM brokers b
JOIN admin_users au_broker ON b.admin_id     = au_broker.id
JOIN admin_users au_sub    ON b.sub_admin_id = au_sub.id;

CREATE OR REPLACE VIEW v_hotel_manager_details AS
SELECT
    hm.id,
    hm.hotel_id,
    h.name  AS hotel_name,
    h.city  AS hotel_city,
    au.id   AS admin_id,
    au.full_name AS manager_name,
    au.email     AS manager_email,
    au.phone     AS manager_phone,
    b.id         AS broker_id,
    au_b.full_name AS broker_name,
    hm.sub_admin_id,
    au_s.full_name AS sub_admin_name
FROM hotel_managers hm
JOIN hotels     h   ON hm.hotel_id   = h.id
JOIN admin_users au  ON hm.admin_id  = au.id
LEFT JOIN brokers b  ON hm.broker_id = b.id
LEFT JOIN admin_users au_b ON b.admin_id   = au_b.id
LEFT JOIN admin_users au_s ON hm.sub_admin_id = au_s.id;
