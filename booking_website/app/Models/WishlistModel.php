<?php

namespace App\Models;

use CodeIgniter\Model;

class WishlistModel extends Model
{
    protected $table            = 'wishlist';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = ['user_id', 'hotel_id'];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = false;

    // ─── Get wishlist hotels for a user ──────────────────────────────────────

    public function getUserWishlist(int $userId): array
    {
        $sql = "
            SELECT h.*,
                   (SELECT image_url FROM hotel_images
                    WHERE hotel_id = h.id AND is_primary = TRUE LIMIT 1) AS primary_image,
                   w.created_at AS wishlisted_at
            FROM wishlist w
            JOIN hotels h ON w.hotel_id = h.id
            WHERE w.user_id = ?
              AND h.is_active = TRUE
            ORDER BY w.created_at DESC
        ";

        $rows = $this->db->query($sql, [$userId])->getResultArray();

        foreach ($rows as &$row) {
            $row['rating']          = (float)$row['rating'];
            $row['price_per_night'] = (float)$row['price_per_night'];
            $row['is_featured']     = ($row['is_featured'] === 't');
            $row['is_active']       = ($row['is_active']   === 't');
        }
        unset($row);

        return $rows;
    }

    // ─── Toggle wishlist ──────────────────────────────────────────────────────

    public function toggle(int $userId, int $hotelId): array
    {
        // Use raw SQL to avoid CI4 Postgre integer bind issue
        $existing = $this->db->query(
            'SELECT id FROM wishlist WHERE user_id = ? AND hotel_id = ? LIMIT 1',
            [$userId, $hotelId]
        )->getRowArray();

        if ($existing) {
            $this->db->query('DELETE FROM wishlist WHERE id = ?', [$existing['id']]);
            return ['action' => 'removed', 'wishlisted' => false];
        }

        $this->db->query(
            'INSERT INTO wishlist (user_id, hotel_id, created_at) VALUES (?, ?, NOW())',
            [$userId, $hotelId]
        );
        return ['action' => 'added', 'wishlisted' => true];
    }

    // ─── Check if hotel is wishlisted ─────────────────────────────────────────

    public function isWishlisted(int $userId, int $hotelId): bool
    {
        $row = $this->db->query(
            'SELECT id FROM wishlist WHERE user_id = ? AND hotel_id = ? LIMIT 1',
            [$userId, $hotelId]
        )->getRowArray();
        return !empty($row);
    }

    // ─── Get all wishlisted hotel IDs ─────────────────────────────────────────

    public function getWishlistedIds(int $userId): array
    {
        $rows = $this->db->query(
            'SELECT hotel_id FROM wishlist WHERE user_id = ?',
            [$userId]
        )->getResultArray();
        return array_map('intval', array_column($rows, 'hotel_id'));
    }
}
