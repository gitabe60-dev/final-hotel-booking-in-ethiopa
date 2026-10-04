<?php

namespace App\Models;

use CodeIgniter\Model;

/**
 * BrokerModel
 * Manages brokers table + broker_hotel_links + broker_messages
 */
class BrokerModel extends Model
{
    protected $table            = 'brokers';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = [
        'admin_id','sub_admin_id','city','commission_pct','status',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // ── Get full broker details ───────────────────────────────────────────────

    public function getAll(): array
    {
        return $this->db->query('SELECT * FROM v_broker_details ORDER BY city, broker_name')
                        ->getResultArray();
    }

    public function getByCity(string $city): array
    {
        return $this->db->query(
            'SELECT * FROM v_broker_details WHERE city = ? ORDER BY broker_name',
            [$city]
        )->getResultArray();
    }

    public function getBySubAdmin(int $subAdminId): array
    {
        return $this->db->query(
            'SELECT * FROM v_broker_details WHERE sub_admin_id = ? ORDER BY broker_name',
            [$subAdminId]
        )->getResultArray();
    }

    public function getByAdminId(int $adminId): ?array
    {
        return $this->db->query(
            'SELECT b.*, au.full_name AS broker_name, au.email, au.phone
             FROM brokers b
             JOIN admin_users au ON b.admin_id = au.id
             WHERE b.admin_id = ? LIMIT 1',
            [$adminId]
        )->getRowArray();
    }

    // ── Hotel links ───────────────────────────────────────────────────────────

    public function linkHotel(int $brokerId, int $hotelId): void
    {
        $this->db->query(
            'INSERT INTO broker_hotel_links (broker_id, hotel_id)
             VALUES (?, ?) ON CONFLICT (broker_id, hotel_id) DO NOTHING',
            [$brokerId, $hotelId]
        );
    }

    public function unlinkHotel(int $brokerId, int $hotelId): void
    {
        $this->db->query(
            'DELETE FROM broker_hotel_links WHERE broker_id = ? AND hotel_id = ?',
            [$brokerId, $hotelId]
        );
    }

    public function getLinkedHotels(int $brokerId): array
    {
        return $this->db->query(
            'SELECT h.*, bhl.created_at AS linked_at,
                    (SELECT image_url FROM hotel_images WHERE hotel_id = h.id AND is_primary = TRUE LIMIT 1) AS primary_image
             FROM broker_hotel_links bhl
             JOIN hotels h ON bhl.hotel_id = h.id
             WHERE bhl.broker_id = ?
             ORDER BY h.name',
            [$brokerId]
        )->getResultArray();
    }

    // ── Messages ──────────────────────────────────────────────────────────────

    public function sendMessage(int $fromAdmin, int $toAdmin, string $subject, string $body, ?int $hotelId = null, ?int $parentId = null): int
    {
        $sql = 'INSERT INTO broker_messages (from_admin, to_admin, hotel_id, subject, body, parent_id)
                VALUES (?, ?, ?, ?, ?, ?) RETURNING id';
        $row = $this->db->query($sql, [$fromAdmin, $toAdmin, $hotelId, $subject, $body, $parentId])->getRowArray();
        return (int)($row['id'] ?? 0);
    }

    public function getMessages(int $adminId): array
    {
        return $this->db->query(
            "SELECT bm.*,
                    af.full_name AS from_name,
                    af.role      AS from_role,
                    at.full_name AS to_name,
                    h.name       AS hotel_name
             FROM broker_messages bm
             JOIN admin_users af ON bm.from_admin = af.id
             JOIN admin_users at ON bm.to_admin   = at.id
             LEFT JOIN hotels h  ON bm.hotel_id   = h.id
             WHERE bm.to_admin = ? OR bm.from_admin = ?
             ORDER BY bm.created_at DESC",
            [$adminId, $adminId]
        )->getResultArray();
    }

    public function getInbox(int $adminId): array
    {
        return $this->db->query(
            "SELECT bm.*,
                    af.full_name AS from_name,
                    af.role      AS from_role,
                    h.name       AS hotel_name
             FROM broker_messages bm
             JOIN admin_users af ON bm.from_admin = af.id
             LEFT JOIN hotels h  ON bm.hotel_id   = h.id
             WHERE bm.to_admin = ?
             ORDER BY bm.created_at DESC",
            [$adminId]
        )->getResultArray();
    }

    public function getSent(int $adminId): array
    {
        return $this->db->query(
            "SELECT bm.*,
                    at.full_name AS to_name,
                    at.role      AS to_role,
                    h.name       AS hotel_name
             FROM broker_messages bm
             JOIN admin_users at ON bm.to_admin  = at.id
             LEFT JOIN hotels h  ON bm.hotel_id  = h.id
             WHERE bm.from_admin = ?
             ORDER BY bm.created_at DESC",
            [$adminId]
        )->getResultArray();
    }

    public function markRead(int $messageId, int $adminId): void
    {
        $this->db->query(
            'UPDATE broker_messages SET is_read = TRUE WHERE id = ? AND to_admin = ?',
            [$messageId, $adminId]
        );
    }

    public function countUnread(int $adminId): int
    {
        $r = $this->db->query(
            'SELECT COUNT(*) AS cnt FROM broker_messages WHERE to_admin = ? AND is_read = FALSE',
            [$adminId]
        )->getRowArray();
        return (int)($r['cnt'] ?? 0);
    }

    public function getMessage(int $id): ?array
    {
        return $this->db->query(
            "SELECT bm.*,
                    af.full_name AS from_name, af.role AS from_role, af.email AS from_email,
                    at.full_name AS to_name,   at.role AS to_role,
                    h.name AS hotel_name
             FROM broker_messages bm
             JOIN admin_users af ON bm.from_admin = af.id
             JOIN admin_users at ON bm.to_admin   = at.id
             LEFT JOIN hotels h  ON bm.hotel_id   = h.id
             WHERE bm.id = ? LIMIT 1",
            [$id]
        )->getRowArray();
    }
}
