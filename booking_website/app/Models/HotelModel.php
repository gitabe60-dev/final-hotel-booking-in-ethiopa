<?php

namespace App\Models;

use CodeIgniter\Model;

class HotelModel extends Model
{
    protected $table            = 'hotels';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = [
        'name', 'city', 'address', 'description', 'type',
        'rating', 'review_count', 'price_per_night',
        'latitude', 'longitude', 'is_featured', 'is_active',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // ─── Find hotel by ID (raw SQL — bypasses CI4 Postgre bool quoting) ────────

    public function findById(int $id): ?array
    {
        $row = $this->db->query('SELECT * FROM hotels WHERE id = ? LIMIT 1', [$id])->getRowArray();
        if (!$row) return null;
        $row['is_active']   = $this->pgBool($row['is_active']   ?? false);
        $row['is_featured'] = $this->pgBool($row['is_featured'] ?? false);
        $row['rating']          = (float)($row['rating']          ?? 0);
        $row['price_per_night'] = (float)($row['price_per_night'] ?? 0);
        return $row;
    }

    // ─── Search hotels with filters ──────────────────────────────────────────

    public function search(array $params): array
    {
        // Build raw SQL to avoid CI4 Postgre driver quoting booleans
        $conditions = ['h.is_active = TRUE'];
        $binds      = [];

        if (!empty($params['city'])) {
            $conditions[] = 'h.city ILIKE :city:';
            $binds['city'] = '%' . $params['city'] . '%';
        }
        if (!empty($params['hotel_name'])) {
            $conditions[] = 'h.name ILIKE :hotel_name:';
            $binds['hotel_name'] = '%' . $params['hotel_name'] . '%';
        }
        if (!empty($params['min_price'])) {
            $conditions[] = 'h.price_per_night >= :min_price:';
            $binds['min_price'] = (float)$params['min_price'];
        }
        if (!empty($params['max_price'])) {
            $conditions[] = 'h.price_per_night <= :max_price:';
            $binds['max_price'] = (float)$params['max_price'];
        }
        if (!empty($params['min_rating'])) {
            $conditions[] = 'h.rating >= :min_rating:';
            $binds['min_rating'] = (float)$params['min_rating'];
        }
        if (!empty($params['type']) && $params['type'] !== 'All') {
            $conditions[] = 'h.type = :type:';
            $binds['type'] = $params['type'];
        }

        $where  = implode(' AND ', $conditions);
        $sort   = in_array($params['sort'] ?? '', ['rating','price_per_night','review_count','name'])
                    ? $params['sort'] : 'rating';
        $dir    = strtoupper($params['dir'] ?? 'DESC') === 'ASC' ? 'ASC' : 'DESC';
        $limit  = min((int)($params['limit']  ?? 12), 50);
        $offset = (int)($params['offset'] ?? 0);

        $sql = "
            SELECT h.*,
                   (SELECT image_url FROM hotel_images
                    WHERE hotel_id = h.id AND is_primary = TRUE
                    LIMIT 1) AS primary_image
            FROM hotels h
            WHERE {$where}
            ORDER BY h.{$sort} {$dir}
            LIMIT {$limit} OFFSET {$offset}
        ";

        $results = $this->db->query($sql, $binds)->getResultArray();
        return $this->attachDetails($results);
    }

    // ─── Featured hotels ─────────────────────────────────────────────────────

    public function getFeatured(int $limit = 10): array
    {
        $sql = "
            SELECT h.*,
                   (SELECT image_url FROM hotel_images
                    WHERE hotel_id = h.id AND is_primary = TRUE
                    LIMIT 1) AS primary_image
            FROM hotels h
            WHERE h.is_featured = TRUE
              AND h.is_active   = TRUE
            ORDER BY h.rating DESC
            LIMIT {$limit}
        ";

        $results = $this->db->query($sql)->getResultArray();
        return $this->attachDetails($results);
    }

    // ─── Hotel detail ─────────────────────────────────────────────────────────

    public function getDetail(int $id, string $checkIn = '', string $checkOut = ''): ?array
    {
        $sql  = 'SELECT * FROM hotels WHERE id = ? LIMIT 1';
        $hotel = $this->db->query($sql, [$id])->getRowArray();

        if (!$hotel) return null;

        $hotel['is_active']   = $this->pgBool($hotel['is_active']);
        $hotel['is_featured'] = $this->pgBool($hotel['is_featured']);

        if (!$hotel['is_active']) return null;

        $hotel['images']     = $this->getImages($id);
        $hotel['amenities']  = $this->getAmenities($id);
        $hotel['room_types'] = $this->getRoomTypes($id, $checkIn, $checkOut);
        $hotel['reviews']    = $this->getReviews($id, 5);

        return $hotel;
    }

    // ─── Images ──────────────────────────────────────────────────────────────

    public function getImages(int $hotelId): array
    {
        $rows = $this->db->query(
            'SELECT image_url FROM hotel_images WHERE hotel_id = ? ORDER BY sort_order ASC',
            [$hotelId]
        )->getResultArray();

        return array_column($rows, 'image_url');
    }

    // ─── Amenities ───────────────────────────────────────────────────────────

    public function getAmenities(int $hotelId): array
    {
        $rows = $this->db->query(
            'SELECT amenity FROM hotel_amenities WHERE hotel_id = ?',
            [$hotelId]
        )->getResultArray();

        return array_column($rows, 'amenity');
    }

    // ─── Room types (with availability check for dates) ─────────────────────

    public function getRoomTypes(int $hotelId, string $checkIn = '', string $checkOut = ''): array
    {
        $rows = $this->db->query(
            'SELECT * FROM room_types WHERE hotel_id = ? ORDER BY price_per_night ASC',
            [$hotelId]
        )->getResultArray();

        foreach ($rows as &$row) {
            $row['features']        = $this->pgArrayToPhp($row['features'] ?? '{}');
            $row['price_per_night'] = (float)$row['price_per_night'];
            $row['size_sqm']        = (float)$row['size_sqm'];
            $row['max_guests']      = (int)$row['max_guests'];
            $row['is_available']    = $this->pgBool($row['is_available']);

            // Check if booked for the requested dates
            if ($row['is_available'] && $checkIn && $checkOut) {
                $booked = $this->db->query(
                    "SELECT COUNT(*) AS cnt FROM bookings
                     WHERE room_type_id = ?
                       AND status IN ('pending','confirmed')
                       AND check_in  < ?
                       AND check_out > ?",
                    [$row['id'], $checkOut, $checkIn]
                )->getRowArray();

                if ((int)($booked['cnt'] ?? 0) > 0) {
                    $row['is_available']     = false;
                    $row['unavailable_reason'] = 'Occupied for selected dates';
                }
            }
        }
        unset($row);

        return $rows;
    }

    // ─── Reviews ─────────────────────────────────────────────────────────────

    public function getReviews(int $hotelId, int $limit = 10, int $offset = 0): array
    {
        $sql = "
            SELECT r.*,
                   u.first_name || ' ' || u.last_name AS user_name,
                   u.avatar_url AS user_avatar
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            WHERE r.hotel_id = ?
            ORDER BY r.created_at DESC
            LIMIT ? OFFSET ?
        ";

        return $this->db->query($sql, [$hotelId, $limit, $offset])->getResultArray();
    }

    // ─── Attach images + amenities to list of hotels ─────────────────────────

    private function attachDetails(array $hotels): array
    {
        if (empty($hotels)) return [];

        // Build comma-separated IDs safely (no query builder whereIn)
        $ids = implode(',', array_map('intval', array_column($hotels, 'id')));
        if (empty($ids)) return $hotels;

        $allImages = $this->db->query(
            "SELECT hotel_id, image_url FROM hotel_images WHERE hotel_id IN ($ids) ORDER BY sort_order ASC"
        )->getResultArray();

        $allAmenities = $this->db->query(
            "SELECT hotel_id, amenity FROM hotel_amenities WHERE hotel_id IN ($ids)"
        )->getResultArray();

        $imagesByHotel    = [];
        $amenitiesByHotel = [];
        foreach ($allImages    as $r) { $imagesByHotel[$r['hotel_id']][]    = $r['image_url']; }
        foreach ($allAmenities as $r) { $amenitiesByHotel[$r['hotel_id']][] = $r['amenity'];   }

        foreach ($hotels as &$hotel) {
            $hid = (int)$hotel['id'];
            $pri = $hotel['primary_image'] ?? '';

            $hotel['images']          = $imagesByHotel[$hid]    ?? ($pri ? [$pri] : []);
            $hotel['amenities']       = $amenitiesByHotel[$hid] ?? [];
            $hotel['rating']          = (float)$hotel['rating'];
            $hotel['price_per_night'] = (float)$hotel['price_per_night'];
            $hotel['is_featured']     = $this->pgBool($hotel['is_featured'] ?? false);
            $hotel['is_active']       = $this->pgBool($hotel['is_active']   ?? true);
            $hotel['is_wishlisted']   = false;
            unset($hotel['primary_image']);
        }
        unset($hotel);

        return $hotels;
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    /** PostgreSQL returns booleans as 't' / 'f' strings */
    private function pgBool(mixed $val): bool
    {
        if (is_bool($val)) return $val;
        return $val === 't' || $val === true || $val === '1' || $val === 1;
    }

    /** PostgreSQL array string "{a,b,c}" → PHP array */
    private function pgArrayToPhp(?string $pg): array
    {
        if (!$pg || $pg === '{}') return [];
        $inner = trim($pg, '{}');
        if ($inner === '') return [];
        preg_match_all('/"((?:[^"\\\\]|\\\\.)*)"|([^,]+)/', $inner, $m);
        return array_map(fn($s) => trim($s, '"'), $m[0]);
    }
}
