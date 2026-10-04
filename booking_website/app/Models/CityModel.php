<?php

namespace App\Models;

use CodeIgniter\Model;

/**
 * CityModel
 * All city data comes from the cities table — fully dynamic.
 * Super admin can add/delete cities; they instantly appear in search dropdowns.
 */
class CityModel extends Model
{
    protected $table         = 'cities';
    protected $primaryKey    = 'id';
    protected $returnType    = 'array';
    protected $allowedFields = ['name','region','is_active'];
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = false;
    protected $skipValidation = true;

    // ── All active cities (for dropdowns) ────────────────────────────────────

    public function getActive(): array
    {
        return $this->db->query(
            "SELECT id, name, region FROM cities WHERE is_active=TRUE ORDER BY name ASC"
        )->getResultArray();
    }

    // ── Cities that actually have hotels ─────────────────────────────────────

    public function getWithHotels(): array
    {
        return $this->db->query(
            "SELECT c.id, c.name, c.region, COUNT(h.id) AS hotel_count
             FROM cities c
             JOIN hotels h ON LOWER(h.city) = LOWER(c.name) AND h.is_active=TRUE
             WHERE c.is_active=TRUE
             GROUP BY c.id, c.name, c.region
             ORDER BY hotel_count DESC, c.name ASC"
        )->getResultArray();
    }

    // ── All cities for admin panel ────────────────────────────────────────────

    public function getAll(): array
    {
        return $this->db->query(
            "SELECT c.*, COUNT(h.id) AS hotel_count
             FROM cities c
             LEFT JOIN hotels h ON LOWER(h.city)=LOWER(c.name) AND h.is_active=TRUE
             GROUP BY c.id
             ORDER BY c.name ASC"
        )->getResultArray();
    }

    // ── Add city ──────────────────────────────────────────────────────────────

    public function addCity(string $name, string $region = ''): int|false
    {
        $name = trim($name);
        if (!$name) return false;

        // Check duplicate (case-insensitive)
        $exists = $this->db->query(
            'SELECT id FROM cities WHERE LOWER(name)=LOWER(?) LIMIT 1', [$name]
        )->getRowArray();

        if ($exists) {
            // Re-activate if inactive
            $this->db->query(
                'UPDATE cities SET is_active=TRUE WHERE id=?', [(int)$exists['id']]
            );
            return (int)$exists['id'];
        }

        $row = $this->db->query(
            'INSERT INTO cities (name, region) VALUES (?,?) RETURNING id',
            [$name, $region]
        )->getRowArray();

        return $row ? (int)$row['id'] : false;
    }

    // ── Delete / deactivate city ──────────────────────────────────────────────

    public function deleteCity(int $id): bool
    {
        // Check if any hotels exist
        $city = $this->db->query('SELECT name FROM cities WHERE id=? LIMIT 1', [$id])->getRowArray();
        if (!$city) return false;

        $hotels = $this->db->query(
            'SELECT COUNT(*) AS cnt FROM hotels WHERE city=? AND is_active=TRUE',
            [$city['name']]
        )->getRowArray();

        if ((int)($hotels['cnt'] ?? 0) > 0) {
            // Soft-delete only
            $this->db->query('UPDATE cities SET is_active=FALSE WHERE id=?', [$id]);
        } else {
            $this->db->query('DELETE FROM cities WHERE id=?', [$id]);
        }
        return true;
    }

    // ── Names only (for fast lookup) ──────────────────────────────────────────

    public function getNames(): array
    {
        $rows = $this->db->query(
            "SELECT name FROM cities WHERE is_active=TRUE ORDER BY name ASC"
        )->getResultArray();
        return array_column($rows, 'name');
    }
}
