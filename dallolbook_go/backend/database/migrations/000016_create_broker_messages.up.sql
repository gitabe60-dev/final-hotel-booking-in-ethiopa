-- 000016_create_broker_messages.up.sql
CREATE TABLE IF NOT EXISTS broker_messages (
    id         SERIAL PRIMARY KEY,
    from_admin INT          NOT NULL REFERENCES admin_users(id),
    to_admin   INT          NOT NULL REFERENCES admin_users(id),
    subject    VARCHAR(255) NOT NULL DEFAULT '',
    body       TEXT         NOT NULL DEFAULT '',
    is_read    BOOLEAN      NOT NULL DEFAULT false,
    hotel_id   INT                   REFERENCES hotels(id),
    parent_id  INT                   REFERENCES broker_messages(id),
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_broker_messages_to   ON broker_messages (to_admin, is_read);
CREATE INDEX IF NOT EXISTS idx_broker_messages_from ON broker_messages (from_admin);
