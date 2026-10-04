<?php

namespace App\Controllers\Api;

use App\Models\UserModel;
use App\Models\BookingModel;

/**
 * Guest Profile Controller  (all routes JWT-protected)
 *
 * GET  /api/v1/guest/profile            — get profile
 * PUT  /api/v1/guest/profile            — update profile
 * POST /api/v1/guest/change-password    — change password
 */
class GuestController extends BaseApiController
{
    private UserModel    $userModel;
    private BookingModel $bookingModel;

    public function __construct()
    {
        $this->userModel    = new UserModel();
        $this->bookingModel = new BookingModel();
    }

    // ─── Get profile ──────────────────────────────────────────────────────────

    public function profile(): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $user = $this->userModel->findById($userId);
        if (!$user) return api_error('User not found.', 404);

        $safe   = $this->userModel->safeUser($user);
        $counts = $this->bookingModel->countByStatus($userId);
        $safe['booking_counts'] = $counts;

        return api_success($safe, 'Profile loaded.');
    }

    // ─── Update profile ───────────────────────────────────────────────────────

    public function updateProfile(): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $data = $this->jsonBody();

        $allowed = ['first_name', 'last_name', 'phone', 'nationality'];
        $updates = array_intersect_key($data, array_flip($allowed));

        if (empty($updates)) {
            return api_error('No valid fields to update.', 422);
        }

        // Check phone uniqueness if changing
        if (!empty($updates['phone'])) {
            $existing = $this->userModel->findByPhone($updates['phone']);
            if ($existing && (int)$existing['id'] !== $userId) {
                return api_error('Phone number already in use.', 409);
            }
        }

        $ok = $this->userModel->updateProfile($userId, $updates);
        if (!$ok) {
            return api_error('Failed to update profile.', 500);
        }

        $user = $this->userModel->safeUser($this->userModel->findById($userId));
        return api_success($user, 'Profile updated successfully.');
    }

    // ─── Change password ──────────────────────────────────────────────────────

    public function changePassword(): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $data = $this->jsonBody();

        $err = $this->requireFields($data, ['current_password', 'new_password']);
        if ($err) return api_error($err, 422);

        if (strlen($data['new_password']) < 6) {
            return api_error('New password must be at least 6 characters.', 422);
        }

        $user = $this->userModel->findById($userId);
        if (!$user) return api_error('User not found.', 404);

        if (!$this->userModel->verifyPassword($data['current_password'], $user['password_hash'] ?? '')) {
            return api_error('Current password is incorrect.', 401);
        }

        $this->userModel->update($userId, [
            'password_hash' => $this->userModel->hashPassword($data['new_password']),
        ]);

        return api_success(null, 'Password changed successfully.');
    }
}
