-- 000013_create_admin_city_assignments.up.sql
CREATE TABLE IF NOT EXISTS admin_city_assignments (
    id          SERIAL PRIMARY KEY,
    admin_id    INT          NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,
    city        VARCHAR(100) NOT NULL,
    assigned_by INT                   REFERENCES admin_users(id),
    UNIQUE (admin_id, city)
);
