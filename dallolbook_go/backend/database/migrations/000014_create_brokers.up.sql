-- 000014_create_brokers.up.sql
CREATE TABLE IF NOT EXISTS brokers (
    id             SERIAL PRIMARY KEY,
    admin_id       INT           NOT NULL REFERENCES admin_users(id),
    sub_admin_id   INT                    REFERENCES admin_users(id),
    city           VARCHAR(100)  NOT NULL DEFAULT '',
    commission_pct NUMERIC(5,2)  NOT NULL DEFAULT 0,
    status         VARCHAR(20)   NOT NULL DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS broker_hotel_links (
    id        SERIAL PRIMARY KEY,
    broker_id INT NOT NULL REFERENCES brokers(id) ON DELETE CASCADE,
    hotel_id  INT NOT NULL REFERENCES hotels(id)  ON DELETE CASCADE,
    UNIQUE (broker_id, hotel_id)
);
