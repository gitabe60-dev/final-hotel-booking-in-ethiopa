<?php

namespace App\Models;

use CodeIgniter\Model;

class ReviewModel extends Model
{
    protected $table         = 'reviews';
    protected $primaryKey    = 'id';
    protected $useAutoIncrement = true;
    protected $returnType    = 'array';
    protected $useSoftDeletes = false;

    protected $allowedFields = [
        'hotel_id', 'user_id', 'rating', 'comment', 'images',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    protected $validationRules = [
        'hotel_id' => 'required|integer',
        'user_id'  => 'required|integer',
        'rating'   => 'required|numeric|greater_than_equal_to[1]|less_than_equal_to[5]',
        'comment'  => 'required|min_length[5]|max_length[2000]',
    ];

    // ─── Get reviews for a hotel with user info ──────────────────────────────

    public function getByHotel(int $hotelId, int $limit = 10, int $offset = 0): array
    {
        $rows = $this->db->table('reviews r')
            ->select("r.id, r.hotel_id, r.user_id, r.rating, r.comment,
                      r.images, r.created_at,
                      u.first_name || ' ' || u.last_name AS user_name,
                      u.avatar_url AS user_avatar")
            ->join('users u', 'r.user_id = u.id')
            ->where('r.hotel_id', $hotelId)
            ->orderBy('r.created_at', 'DESC')
            ->limit($limit, $offset)
            ->get()
            ->getResultArray();

        foreach ($rows as &$row) {
            $row['rating'] = (float)$row['rating'];
        }
        unset($row);

        return $rows;
    }

    // ─── Check if user already reviewed this hotel ───────────────────────────

    public function hasReviewed(int $hotelId, int $userId): bool
    {
        return $this->where('hotel_id', $hotelId)
                    ->where('user_id', $userId)
                    ->countAllResults() > 0;
    }

    // ─── Rating summary for a hotel ──────────────────────────────────────────

    public function getRatingSummary(int $hotelId): array
    {
        $result = $this->db->table('reviews')
            ->select('COUNT(*) AS total,
                      AVG(rating) AS average,
                      SUM(CASE WHEN rating >= 4.5 THEN 1 ELSE 0 END) AS five_star,
                      SUM(CASE WHEN rating >= 3.5 AND rating < 4.5 THEN 1 ELSE 0 END) AS four_star,
                      SUM(CASE WHEN rating >= 2.5 AND rating < 3.5 THEN 1 ELSE 0 END) AS three_star,
                      SUM(CASE WHEN rating >= 1.5 AND rating < 2.5 THEN 1 ELSE 0 END) AS two_star,
                      SUM(CASE WHEN rating < 1.5 THEN 1 ELSE 0 END) AS one_star')
            ->where('hotel_id', $hotelId)
            ->get()
            ->getRowArray();

        return [
            'total'     => (int)($result['total']     ?? 0),
            'average'   => round((float)($result['average'] ?? 0), 1),
            'five_star' => (int)($result['five_star']  ?? 0),
            'four_star' => (int)($result['four_star']  ?? 0),
            'three_star'=> (int)($result['three_star'] ?? 0),
            'two_star'  => (int)($result['two_star']   ?? 0),
            'one_star'  => (int)($result['one_star']   ?? 0),
        ];
    }
}
