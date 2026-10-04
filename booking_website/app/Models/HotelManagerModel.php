<?php

namespace App\Models;

use CodeIgniter\Model;

/**
 * HotelManagerModel
 * Manages hotel_managers table — links admin_user to a specific hotel
 */
class HotelManagerModel extends Model
{
    protected $table            = 'hotel_managers';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = [
        'admin_id','hotel_id','broker_id','sub_admin_id',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // ── Get all with details ──────────────────────────────────────────────────

    public function getAll(): array
    {
        return $this->db->query(
            'SELECT * FROM v_hotel_manager_details ORDER BY hotel_city, hotel_name'
        )->getResultArray();
    }

    public function getByCity(string $city): array
    {
        return $this->db->query(
            'SELECT * FROM v_hotel_manager_details WHERE hotel_city = ? ORDER BY hotel_name',
            [$city]
        )->getResultArray();
    }

    public function getBySubAdmin(int $subAdminId): array
    {
        return $this->db->query(
            'SELECT * FROM v_hotel_manager_details WHERE sub_admin_id = ? ORDER BY hotel_name',
            [$subAdminId]
        )->getResultArray();
    }

    public function getByBroker(int $brokerId): array
    {
        return $this->db->query(
            'SELECT * FROM v_hotel_manager_details WHERE broker_id = ? ORDER BY hotel_name',
            [$brokerId]
        )->getResultArray();
    }

    public function getByAdminId(int $adminId): ?array
    {
        return $this->db->query(
            'SELECT * FROM v_hotel_manager_details WHERE admin_id = ? LIMIT 1',
            [$adminId]
        )->getRowArray();
    }

    public function getHotelId(int $adminId): ?int
    {
        $row = $this->db->query(
            'SELECT hotel_id FROM hotel_managers WHERE admin_id = ? LIMIT 1',
            [$adminId]
        )->getRowArray();
        return $row ? (int)$row['hotel_id'] : null;
    }

    // ── Assign manager to hotel ───────────────────────────────────────────────

    public function assignManager(int $adminId, int $hotelId, ?int $brokerId = null, ?int $subAdminId = null): bool
    {
        // Remove previous assignment for this hotel
        $this->db->query('DELETE FROM hotel_managers WHERE hotel_id = ?', [$hotelId]);

        $this->db->query(
            'INSERT INTO hotel_managers (admin_id, hotel_id, broker_id, sub_admin_id)
             VALUES (?, ?, ?, ?)',
            [$adminId, $hotelId, $brokerId, $subAdminId]
        );
        return true;
    }

    // ── Room management (for hotel managers & sub-admins) ────────────────────

    public function getRooms(int $hotelId, string $search = ''): array
    {
        if ($search) {
            return $this->db->query(
                "SELECT * FROM room_types
                 WHERE hotel_id = ? AND (name ILIKE ? OR bed_type ILIKE ?)
                 ORDER BY price_per_night",
                [$hotelId, "%$search%", "%$search%"]
            )->getResultArray();
        }
        return $this->db->query(
            'SELECT * FROM room_types WHERE hotel_id = ? ORDER BY price_per_night',
            [$hotelId]
        )->getResultArray();
    }

    public function getRoom(int $roomId): ?array
    {
        return $this->db->query(
            'SELECT * FROM room_types WHERE id = ? LIMIT 1',
            [$roomId]
        )->getRowArray();
    }

    public function addRoom(array $data): int
    {
        $features = isset($data['features']) && is_array($data['features'])
            ? '{' . implode(',', array_map(fn($f) => '"' . addslashes($f) . '"', $data['features'])) . '}'
            : '{}';

        $row = $this->db->query(
            'INSERT INTO room_types (hotel_id, name, bed_type, image_url, price_per_night, size_sqm, max_guests, features, is_available)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE) RETURNING id',
            [
                $data['hotel_id'],
                $data['name'],
                $data['bed_type'],
                $data['image_url'] ?? null,
                (float)$data['price_per_night'],
                (float)($data['size_sqm'] ?? 0),
                (int)($data['max_guests'] ?? 2),
                $features,
            ]
        )->getRowArray();
        return (int)($row['id'] ?? 0);
    }

    public function updateRoom(int $roomId, array $data): bool
    {
        $features = isset($data['features']) && is_array($data['features'])
            ? '{' . implode(',', array_map(fn($f) => '"' . addslashes($f) . '"', $data['features'])) . '}'
            : null;

        $sets  = [];
        $binds = [];

        foreach (['name','bed_type','image_url','price_per_night','size_sqm','max_guests'] as $col) {
            if (isset($data[$col])) { $sets[] = "$col = ?"; $binds[] = $data[$col]; }
        }
        if ($features !== null) { $sets[] = "features = ?"; $binds[] = $features; }
        if (isset($data['is_available'])) {
            $sets[] = 'is_available = ' . ($data['is_available'] ? 'TRUE' : 'FALSE');
        }
        if (empty($sets)) return false;

        $binds[] = $roomId;
        $this->db->query('UPDATE room_types SET ' . implode(', ', $sets) . ' WHERE id = ?', $binds);
        return true;
    }

    public function deleteRoom(int $roomId): bool
    {
        $this->db->query('DELETE FROM room_types WHERE id = ?', [$roomId]);
        return true;
    }

    public function toggleRoomAvailability(int $roomId): bool
    {
        $this->db->query(
            'UPDATE room_types SET is_available = NOT is_available WHERE id = ?',
            [$roomId]
        );
        return true;
    }
}
