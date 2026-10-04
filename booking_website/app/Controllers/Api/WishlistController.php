<?php

namespace App\Controllers\Api;

use App\Models\WishlistModel;
use App\Models\HotelModel;

/**
 * Wishlist Controller  (JWT-protected)
 *
 * GET    /api/v1/wishlist              — get user's wishlist
 * POST   /api/v1/wishlist              — toggle hotel in wishlist
 * DELETE /api/v1/wishlist/(:num)       — remove a hotel from wishlist
 */
class WishlistController extends BaseApiController
{
    private WishlistModel $wishlistModel;
    private HotelModel    $hotelModel;

    public function __construct()
    {
        $this->wishlistModel = new WishlistModel();
        $this->hotelModel    = new HotelModel();
    }

    // ─── Get wishlist ─────────────────────────────────────────────────────────

    public function index(): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $hotels = $this->wishlistModel->getUserWishlist($userId);

        return api_success($hotels, count($hotels) . ' wishlist items.');
    }

    // ─── Toggle (add / remove) ────────────────────────────────────────────────

    public function toggle(): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $data = $this->jsonBody();

        if (empty($data['hotel_id'])) {
            return api_error('hotel_id is required.', 422);
        }

        $hotelId = (int)$data['hotel_id'];
        // Use raw SQL to avoid CI4 query builder integer key issue
        $hotel = $this->hotelModel->db->query(
            'SELECT id, name, is_active FROM hotels WHERE id = ? LIMIT 1',
            [$hotelId]
        )->getRowArray();

        if (!$hotel) {
            return api_error('Hotel not found.', 404);
        }

        $result = $this->wishlistModel->toggle($userId, $hotelId);

        $msg = $result['action'] === 'added'
            ? 'Hotel added to wishlist.'
            : 'Hotel removed from wishlist.';

        return api_success($result, $msg);
    }

    // ─── Remove by hotel ID ───────────────────────────────────────────────────

    public function remove(int $hotelId): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $existing = $this->wishlistModel
            ->where('user_id', $userId)
            ->where('hotel_id', $hotelId)
            ->first();

        if (!$existing) {
            return api_error('Hotel not in wishlist.', 404);
        }

        $this->wishlistModel->delete($existing['id']);

        return api_success(['hotel_id' => $hotelId, 'wishlisted' => false], 'Removed from wishlist.');
    }
}
