-- 000017_create_admin_overview_view.up.sql
CREATE OR REPLACE VIEW v_admin_overview AS
SELECT
    (SELECT COUNT(*) FROM admin_users WHERE role = 'sub_admin'      AND status = 'active')::INT  AS sub_admins,
    (SELECT COUNT(*) FROM admin_users WHERE role = 'broker'         AND status = 'active')::INT  AS brokers,
    (SELECT COUNT(*) FROM admin_users WHERE role = 'hotel_manager'  AND status = 'active')::INT  AS hotel_managers,
    (SELECT COUNT(*) FROM hotels     WHERE is_active = true)::INT                                AS active_hotels,
    (SELECT COUNT(*) FROM bookings   WHERE status = 'confirmed')::INT                            AS confirmed_bookings,
    (SELECT COUNT(*) FROM bookings   WHERE status = 'pending')::INT                              AS pending_bookings,
    (SELECT COUNT(*) FROM users)::INT                                                            AS total_guests,
    COALESCE((SELECT SUM(amount) FROM payments WHERE status = 'completed'), 0)::NUMERIC          AS total_revenue;
