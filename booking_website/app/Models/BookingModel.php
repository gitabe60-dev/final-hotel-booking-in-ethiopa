<?php

namespace App\Models;

use CodeIgniter\Model;

class BookingModel extends Model
{
    protected $table            = 'bookings';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = [
        'user_id','hotel_id','room_type_id',
        'check_in','check_out',
        'adults','children','rooms',
        'total_price','payment_method',
        'status','special_requests',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // ─── User booking list ───────────────────────────────────────────────────

    public function getUserBookings(int $userId): array
    {
        // Raw SQL — avoid query builder quoting PostgreSQL booleans
        $sql = "
            SELECT b.*,
                   h.name  AS hotel_name,
                   h.city  AS hotel_city,
                   (SELECT image_url FROM hotel_images
                    WHERE hotel_id = h.id AND is_primary = TRUE
                    LIMIT 1) AS hotel_image
            FROM bookings b
            JOIN hotels h ON b.hotel_id = h.id
            WHERE b.user_id = ?
            ORDER BY b.created_at DESC
        ";

        $rows = $this->db->query($sql, [$userId])->getResultArray();
        return $this->castBookings($rows);
    }

    // ─── Single booking detail ───────────────────────────────────────────────

    public function getDetail(int $bookingId, int $userId): ?array
    {
        $sql = "
            SELECT b.*,
                   h.name    AS hotel_name,
                   h.city    AS hotel_city,
                   h.address AS hotel_address,
                   h.type    AS hotel_type,
                   h.id      AS hotel_id_ref,
                   (SELECT image_url FROM hotel_images
                    WHERE hotel_id = h.id AND is_primary = TRUE
                    LIMIT 1) AS hotel_image,
                   rt.name      AS room_type_name,
                   rt.bed_type  AS bed_type,
                   rt.image_url AS room_image
            FROM bookings b
            JOIN hotels h         ON b.hotel_id    = h.id
            LEFT JOIN room_types rt ON rt.id        = b.room_type_id
            WHERE b.id = ?
              AND b.user_id = ?
            LIMIT 1
        ";

        $row = $this->db->query($sql, [$bookingId, $userId])->getRowArray();
        return $row ? $this->castBooking($row) : null;
    }

    // ─── Create booking ──────────────────────────────────────────────────────

    public function createBooking(array $data): int|false
    {
        unset($data['price_per_night']);

        $this->insert($data);
        $id = $this->getInsertID();
        return $id ? (int)$id : false;
    }

    // ─── Cancel booking ───────────────────────────────────────────────────────

    public function cancelBooking(int $bookingId, int $userId): bool
    {
        $booking = $this->where('id', $bookingId)
                        ->where('user_id', $userId)
                        ->first();

        if (!$booking) return false;
        if (!in_array($booking['status'], ['pending','confirmed'])) return false;

        return (bool)$this->update($bookingId, ['status' => 'cancelled']);
    }

    // ─── Availability check ──────────────────────────────────────────────────

    public function isAvailable(int $hotelId, string $checkIn, string $checkOut, int $rooms): bool
    {
        $sql = "
            SELECT COALESCE(SUM(rooms), 0) AS booked
            FROM bookings
            WHERE hotel_id = ?
              AND status IN ('pending','confirmed')
              AND check_in  < ?
              AND check_out > ?
        ";
        $res = $this->db->query($sql, [$hotelId, $checkOut, $checkIn])->getRowArray();
        $booked = (int)($res['booked'] ?? 0);

        $total = (int)$this->db->query(
            "SELECT COUNT(*) AS cnt FROM room_types WHERE hotel_id = ? AND is_available = TRUE",
            [$hotelId]
        )->getRowArray()['cnt'] ?? 0;

        return $total === 0 || ($booked + $rooms) <= $total;
    }

    // ─── Count by status for a user ──────────────────────────────────────────

    public function countByStatus(int $userId): array
    {
        $rows = $this->db->query(
            "SELECT status, COUNT(*) AS total FROM bookings WHERE user_id = ? GROUP BY status",
            [$userId]
        )->getResultArray();

        $counts = ['pending'=>0,'confirmed'=>0,'cancelled'=>0,'completed'=>0];
        foreach ($rows as $r) {
            $counts[$r['status']] = (int)$r['total'];
        }
        return $counts;
    }

    // ─── Casting helpers ─────────────────────────────────────────────────────

    private function castBooking(array $b): array
    {
        $b['total_price'] = (float)$b['total_price'];
        $b['adults']      = (int)$b['adults'];
        $b['children']    = (int)$b['children'];
        $b['rooms']       = (int)$b['rooms'];
        return $b;
    }

    private function castBookings(array $bookings): array
    {
        return array_map([$this,'castBooking'], $bookings);
    }
}
