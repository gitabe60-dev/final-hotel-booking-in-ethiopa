<?php

namespace App\Models;

/**
 * ExpertModel — Smart Hotel Recommendation Engine
 *
 * Scoring algorithm:
 *   1. Same city hotels with similar price range     → score +5
 *   2. High rating (>4.0) bonus                     → score +3
 *   3. Same hotel type                               → score +2
 *   4. Amenity match count                           → score +1 per match
 *   5. User booking history preference               → score +4
 *   6. Trending (high review count)                  → score +1
 */
class ExpertModel
{
    protected $db;

    public function __construct()
    {
        $this->db = \Config\Database::connect();
    }

    // ─── Get similar hotels for detail page ──────────────────────────────────

    public function getSimilar(array $hotel, int $limit = 3, ?int $userId = null): array
    {
        $hotelId = (int)$hotel['id'];
        $city    = $hotel['city'];
        $type    = $hotel['type'];
        $price   = (float)$hotel['price_per_night'];

        // Get all active hotels except the current one
        $candidates = $this->db->query(
            "SELECT h.*,
                    (SELECT image_url FROM hotel_images WHERE hotel_id=h.id AND is_primary=TRUE LIMIT 1) AS img
             FROM hotels h
             WHERE h.id != ? AND h.is_active = TRUE",
            [$hotelId]
        )->getResultArray();

        if (empty($candidates)) return [];

        // Get current hotel amenities for matching
        $myAmenities = $this->db->query(
            'SELECT amenity FROM hotel_amenities WHERE hotel_id = ?',
            [$hotelId]
        )->getResultArray();
        $myAmenities = array_column($myAmenities, 'amenity');

        // Get user booking history preferences
        $userPrefs = [];
        if ($userId) {
            $history = $this->db->query(
                "SELECT h.city, h.type, h.price_per_night
                 FROM bookings b JOIN hotels h ON b.hotel_id=h.id
                 WHERE b.user_id=? ORDER BY b.created_at DESC LIMIT 10",
                [$userId]
            )->getResultArray();
            foreach ($history as $h) {
                $userPrefs['cities'][] = $h['city'];
                $userPrefs['types'][]  = $h['type'];
                $userPrefs['avgPrice'] = (($userPrefs['avgPrice'] ?? $price) + $h['price_per_night']) / 2;
            }
        }

        // Score each candidate
        $scored = [];
        foreach ($candidates as $c) {
            $score = 0;
            $cPrice = (float)$c['price_per_night'];

            // 1. Same city
            if ($c['city'] === $city) $score += 5;

            // 2. Similar price (within 50% range)
            $priceDiff = abs($cPrice - $price) / max($price, 1);
            if ($priceDiff < 0.2)      $score += 4;
            elseif ($priceDiff < 0.5)  $score += 2;

            // 3. High rating
            if ((float)$c['rating'] >= 4.5) $score += 3;
            elseif ((float)$c['rating'] >= 4.0) $score += 2;
            elseif ((float)$c['rating'] >= 3.5) $score += 1;

            // 4. Same hotel type
            if ($c['type'] === $type) $score += 2;

            // 5. Amenity match
            if (!empty($myAmenities)) {
                $cAmenities = $this->db->query(
                    'SELECT amenity FROM hotel_amenities WHERE hotel_id = ?',
                    [$c['id']]
                )->getResultArray();
                $cAmenities = array_column($cAmenities, 'amenity');
                $matches = count(array_intersect($myAmenities, $cAmenities));
                $score += min($matches, 5);
            }

            // 6. User history preference
            if ($userId && !empty($userPrefs)) {
                if (in_array($c['city'], $userPrefs['cities'] ?? [])) $score += 4;
                if (in_array($c['type'], $userPrefs['types']  ?? [])) $score += 2;
                $avgPref = $userPrefs['avgPrice'] ?? $price;
                if (abs($cPrice - $avgPref) / max($avgPref, 1) < 0.3) $score += 2;
            }

            // 7. Trending (review count)
            $reviewCount = (int)$c['review_count'];
            if ($reviewCount > 500) $score += 2;
            elseif ($reviewCount > 200) $score += 1;

            $c['expert_score'] = $score;
            $c['rating']       = (float)$c['rating'];
            $c['price_per_night'] = (float)$c['price_per_night'];
            $c['is_featured']  = ($c['is_featured']==='t'||$c['is_featured']===true);
            $c['images']       = $c['img'] ? [$c['img']] : [];
            unset($c['img']);
            $scored[] = $c;
        }

        // Sort by score descending
        usort($scored, fn($a, $b) => $b['expert_score'] <=> $a['expert_score']);

        return array_slice($scored, 0, $limit);
    }

    // ─── Personalized homepage recommendations ────────────────────────────────

    public function getPersonalized(int $userId, int $limit = 4): array
    {
        // Get user's booking history
        $history = $this->db->query(
            "SELECT h.city, h.type, AVG(h.price_per_night) AS avg_price
             FROM bookings b JOIN hotels h ON b.hotel_id=h.id
             WHERE b.user_id=? GROUP BY h.city, h.type ORDER BY COUNT(*) DESC LIMIT 5",
            [$userId]
        )->getResultArray();

        if (empty($history)) return [];

        $cities = array_column($history, 'city');
        $types  = array_column($history, 'type');
        $avgPrice = (float)(array_sum(array_column($history, 'avg_price')) / count($history));

        $cityList = implode(',', array_fill(0, count($cities), '?'));
        $results = $this->db->query(
            "SELECT h.*,
                    (SELECT image_url FROM hotel_images WHERE hotel_id=h.id AND is_primary=TRUE LIMIT 1) AS primary_image
             FROM hotels h
             WHERE h.city IN ($cityList)
               AND h.is_active = TRUE
             ORDER BY h.rating DESC
             LIMIT ?",
            array_merge($cities, [$limit])
        )->getResultArray();

        foreach ($results as &$r) {
            $r['rating']          = (float)$r['rating'];
            $r['price_per_night'] = (float)$r['price_per_night'];
            $r['images']          = $r['primary_image'] ? [$r['primary_image']] : [];
            $r['is_featured']     = ($r['is_featured']==='t'||$r['is_featured']===true);
            unset($r['primary_image']);
        }
        unset($r);

        return $results;
    }

    // ─── Get trending hotels (most booked recently) ───────────────────────────

    public function getTrending(int $limit = 6): array
    {
        $results = $this->db->query(
            "SELECT h.*, COUNT(b.id) AS booking_count,
                    (SELECT image_url FROM hotel_images WHERE hotel_id=h.id AND is_primary=TRUE LIMIT 1) AS primary_image
             FROM hotels h
             LEFT JOIN bookings b ON b.hotel_id=h.id
               AND b.created_at > NOW() - INTERVAL '30 days'
             WHERE h.is_active = TRUE
             GROUP BY h.id
             ORDER BY booking_count DESC, h.rating DESC
             LIMIT ?",
            [$limit]
        )->getResultArray();

        foreach ($results as &$r) {
            $r['rating']          = (float)$r['rating'];
            $r['price_per_night'] = (float)$r['price_per_night'];
            $r['images']          = $r['primary_image'] ? [$r['primary_image']] : [];
            $r['is_featured']     = ($r['is_featured']==='t'||$r['is_featured']===true);
            unset($r['primary_image']);
        }
        unset($r);

        return $results;
    }

    // ─── Smart price suggestion for a hotel search ───────────────────────────

    public function getPriceSuggestion(string $city): array
    {
        $row = $this->db->query(
            "SELECT MIN(price_per_night) AS min_price,
                    MAX(price_per_night) AS max_price,
                    AVG(price_per_night) AS avg_price,
                    COUNT(*) AS hotel_count
             FROM hotels WHERE city = ? AND is_active = TRUE",
            [$city]
        )->getRowArray();

        return [
            'min'   => (float)($row['min_price'] ?? 0),
            'max'   => (float)($row['max_price'] ?? 0),
            'avg'   => round((float)($row['avg_price'] ?? 0)),
            'count' => (int)($row['hotel_count'] ?? 0),
        ];
    }

    // ─── Get best value hotels (high rating, low price ratio) ─────────────────

    public function getBestValue(string $city = '', int $limit = 4): array
    {
        $where = $city ? 'WHERE h.city = ? AND h.is_active=TRUE' : 'WHERE h.is_active=TRUE';
        $binds = $city ? [$city, $limit] : [$limit];

        $results = $this->db->query(
            "SELECT h.*,
                    (h.rating / NULLIF(h.price_per_night, 0) * 1000) AS value_score,
                    (SELECT image_url FROM hotel_images WHERE hotel_id=h.id AND is_primary=TRUE LIMIT 1) AS primary_image
             FROM hotels h
             $where
             ORDER BY value_score DESC
             LIMIT ?",
            $binds
        )->getResultArray();

        foreach ($results as &$r) {
            $r['rating']          = (float)$r['rating'];
            $r['price_per_night'] = (float)$r['price_per_night'];
            $r['images']          = $r['primary_image'] ? [$r['primary_image']] : [];
            $r['is_featured']     = ($r['is_featured']==='t'||$r['is_featured']===true);
            unset($r['primary_image']);
        }
        unset($r);

        return $results;
    }
}
