<?php

namespace App\Controllers\Api;

use App\Models\HotelModel;
use App\Models\ReviewModel;
use App\Models\WishlistModel;

/**
 * Hotels API Controller
 *
 * GET  /api/v1/hotels/search          — search with filters
 * GET  /api/v1/hotels/featured        — featured hotels
 * GET  /api/v1/hotels/(:num)          — hotel detail
 * GET  /api/v1/hotels/(:num)/reviews  — hotel reviews
 * POST /api/v1/hotels/(:num)/reviews  — post review (JWT)
 */
class HotelController extends BaseApiController
{
    private HotelModel    $hotelModel;
    private ReviewModel   $reviewModel;
    private WishlistModel $wishlistModel;

    public function __construct()
    {
        $this->hotelModel    = new HotelModel();
        $this->reviewModel   = new ReviewModel();
        $this->wishlistModel = new WishlistModel();
    }

    // ─── Search hotels ────────────────────────────────────────────────────────

    public function search(): \CodeIgniter\HTTP\Response
    {
        $params = [
            'city'       => $this->request->getGet('city')       ?? '',
            'hotel_name' => $this->request->getGet('hotel_name') ?? '',
            'check_in'   => $this->request->getGet('check_in')   ?? '',
            'check_out'  => $this->request->getGet('check_out')  ?? '',
            'adults'     => $this->request->getGet('adults')     ?? 1,
            'children'   => $this->request->getGet('children')   ?? 0,
            'rooms'      => $this->request->getGet('rooms')      ?? 1,
            'min_price'  => $this->request->getGet('min_price'),
            'max_price'  => $this->request->getGet('max_price'),
            'min_rating' => $this->request->getGet('min_rating'),
            'type'       => $this->request->getGet('type'),
            'sort'       => $this->request->getGet('sort')       ?? 'rating',
            'dir'        => $this->request->getGet('dir')        ?? 'DESC',
            'limit'      => $this->request->getGet('limit')      ?? 12,
            'offset'     => $this->request->getGet('offset')     ?? 0,
        ];

        $hotels = $this->hotelModel->search($params);

        // Mark wishlisted if user is authenticated
        $userId = $this->authUserId();
        if ($userId) {
            $wishlisted = $this->wishlistModel->getWishlistedIds($userId);
            foreach ($hotels as &$h) {
                $h['is_wishlisted'] = in_array($h['id'], $wishlisted);
            }
            unset($h);
        }

        return api_success($hotels, count($hotels) . ' hotels found.');
    }

    // ─── Featured hotels ──────────────────────────────────────────────────────

    public function featured(): \CodeIgniter\HTTP\Response
    {
        $limit  = (int)($this->request->getGet('limit') ?? 10);
        $hotels = $this->hotelModel->getFeatured($limit);

        $userId = $this->authUserId();
        if ($userId) {
            $wishlisted = $this->wishlistModel->getWishlistedIds($userId);
            foreach ($hotels as &$h) {
                $h['is_wishlisted'] = in_array($h['id'], $wishlisted);
            }
            unset($h);
        }

        return api_success($hotels, 'Featured hotels.');
    }

    // ─── Hotel detail ─────────────────────────────────────────────────────────

    public function show(int $id): \CodeIgniter\HTTP\Response
    {
        $hotel = $this->hotelModel->getDetail($id);

        if (!$hotel) {
            return api_error('Hotel not found.', 404);
        }

        // Mark wishlisted
        $userId = $this->authUserId();
        if ($userId) {
            $hotel['is_wishlisted'] = $this->wishlistModel->isWishlisted($userId, $id);
        }

        return api_success($hotel, 'Hotel details.');
    }

    // ─── Reviews list ─────────────────────────────────────────────────────────

    public function reviews(int $hotelId): \CodeIgniter\HTTP\Response
    {
        $limit  = (int)($this->request->getGet('limit')  ?? 10);
        $offset = (int)($this->request->getGet('offset') ?? 0);

        $reviews = $this->reviewModel->getByHotel($hotelId, $limit, $offset);
        $summary = $this->reviewModel->getRatingSummary($hotelId);

        return api_success([
            'reviews' => $reviews,
            'summary' => $summary,
        ], 'Hotel reviews.');
    }

    // ─── Post a review (JWT required) ────────────────────────────────────────

    public function postReview(int $hotelId): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        // postReview — check hotel exists with raw SQL
        $hotel = $this->hotelModel->db->query(
            'SELECT id FROM hotels WHERE id = ? LIMIT 1', [$hotelId]
        )->getRowArray();
        if (!$hotel) return api_error('Hotel not found.', 404);

        if ($this->reviewModel->hasReviewed($hotelId, $userId)) {
            return api_error('You have already reviewed this hotel.', 409);
        }

        $data = $this->jsonBody();

        $err = $this->requireFields($data, ['rating', 'comment']);
        if ($err) return api_error($err, 422);

        $rating = (float)$data['rating'];
        if ($rating < 1 || $rating > 5) {
            return api_error('Rating must be between 1 and 5.', 422);
        }

        $reviewId = $this->reviewModel->insert([
            'hotel_id' => $hotelId,
            'user_id'  => $userId,
            'rating'   => $rating,
            'comment'  => trim($data['comment']),
        ]);

        if (!$reviewId) {
            return api_error('Failed to post review.', 500);
        }

        return api_success(['review_id' => $reviewId], 'Review posted successfully.', 201);
    }
}
