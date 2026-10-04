<?php

namespace App\Controllers\Api;

use App\Models\UserModel;
use App\Models\OtpModel;

/**
 * Auth API Controller
 *
 * POST /api/v1/auth/guest/register
 * POST /api/v1/auth/guest/login
 * POST /api/v1/auth/otp/send
 * POST /api/v1/auth/otp/verify
 * POST /api/v1/auth/refresh
 * POST /api/v1/auth/guest/forgot-password
 * POST /api/v1/auth/guest/reset-password
 * POST /api/v1/auth/logout          (jwt protected)
 */
class AuthController extends BaseApiController
{
    private UserModel $userModel;
    private OtpModel  $otpModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
        $this->otpModel  = new OtpModel();
    }

    // ─── Register ─────────────────────────────────────────────────────────────

    public function register(): \CodeIgniter\HTTP\Response
    {
        $data = $this->jsonBody();

        $err = $this->requireFields($data, ['first_name', 'last_name', 'password']);
        if ($err) return api_error($err, 422);

        // Must supply email OR phone
        if (empty($data['email']) && empty($data['phone'])) {
            return api_error('Email or phone number is required.', 422);
        }

        if (strlen($data['password']) < 6) {
            return api_error('Password must be at least 6 characters.', 422);
        }

        // Check duplicates
        if (!empty($data['email']) && $this->userModel->findByEmail($data['email'])) {
            return api_error('Email is already registered.', 409);
        }
        if (!empty($data['phone']) && $this->userModel->findByPhone($data['phone'])) {
            return api_error('Phone number is already registered.', 409);
        }

        $userId = $this->userModel->createUser([
            'first_name'    => trim($data['first_name']),
            'last_name'     => trim($data['last_name']),
            'email'         => $data['email'] ?? null,
            'phone'         => $data['phone'] ?? null,
            'password_hash' => $this->userModel->hashPassword($data['password']),
            'nationality'   => $data['nationality'] ?? null,
            'status'        => 'active',
            'is_verified'   => false,
        ]);

        if ($userId === 'email_exists') {
            return api_error('This email is already registered.', 409);
        }
        if ($userId === 'phone_exists') {
            return api_error('This phone number is already registered.', 409);
        }
        if ($userId === false || !is_int($userId)) {
            return api_error('Registration failed. Please try again.', 500);
        }

        $user  = $this->userModel->safeUser($this->userModel->findById($userId));
        $token = jwt_generate(['user_id' => (int)$userId, 'email' => $user['email'] ?? '']);
        $refresh = jwt_generate_refresh(['user_id' => (int)$userId]);

        return api_success($user, 'Registration successful.', 201, [
            'token'         => $token,
            'refresh_token' => $refresh,
        ]);
    }

    // ─── Email / Password Login ───────────────────────────────────────────────

    public function login(): \CodeIgniter\HTTP\Response
    {
        $data = $this->jsonBody();

        $err = $this->requireFields($data, ['email', 'password']);
        if ($err) return api_error($err, 422);

        $user = $this->userModel->findByEmail(trim($data['email']));

        if (!$user || !$this->userModel->verifyPassword($data['password'], $user['password_hash'] ?? '')) {
            return api_error('Invalid email or password.', 401);
        }

        if ($user['status'] === 'suspended') {
            return api_error('Your account has been suspended.', 403);
        }

        $this->userModel->updateLastLogin((int)$user['id']);

        $token   = jwt_generate(['user_id' => (int)$user['id'], 'email' => $user['email']]);
        $refresh = jwt_generate_refresh(['user_id' => (int)$user['id']]);
        $safe    = $this->userModel->safeUser($user);

        return api_success($safe, 'Login successful.', 200, [
            'token'         => $token,
            'refresh_token' => $refresh,
        ]);
    }

    // ─── Send OTP ─────────────────────────────────────────────────────────────

    public function sendOtp(): \CodeIgniter\HTTP\Response
    {
        $data = $this->jsonBody();

        $err = $this->requireFields($data, ['phone']);
        if ($err) return api_error($err, 422);

        $phone   = trim($data['phone']);
        $purpose = $data['purpose'] ?? 'login';

        if (!in_array($purpose, ['login', 'register', 'reset'])) {
            $purpose = 'login';
        }

        $code = $this->otpModel->generate($phone, $purpose);

        // In production: send $code via SMS gateway (Twilio, Africa's Talking, etc.)
        // For development: return code in response (remove in production!)
        $responseData = ['phone' => $phone];
        if (ENVIRONMENT === 'development') {
            $responseData['otp'] = $code; // REMOVE IN PRODUCTION
        }

        log_message('info', "OTP for $phone: $code");

        return api_success($responseData, 'OTP sent successfully.');
    }

    // ─── Verify OTP / Phone Login ─────────────────────────────────────────────

    public function verifyOtp(): \CodeIgniter\HTTP\Response
    {
        $data = $this->jsonBody();

        $err = $this->requireFields($data, ['phone', 'otp']);
        if ($err) return api_error($err, 422);

        $phone   = trim($data['phone']);
        $code    = trim($data['otp']);
        $purpose = $data['purpose'] ?? 'login';

        if (!$this->otpModel->verify($phone, $code, $purpose)) {
            return api_error('Invalid or expired OTP.', 401);
        }

        // Find or create user
        $user = $this->userModel->findByPhone($phone);

        if (!$user) {
            // Auto-register phone-only users
            $userId = $this->userModel->createUser([
                'first_name'    => 'User',
                'last_name'     => '',
                'phone'         => $phone,
                'password_hash' => $this->userModel->hashPassword(bin2hex(random_bytes(8))),
                'status'        => 'active',
                'is_verified'   => true,
            ]);
            $user = $userId ? $this->userModel->findById($userId) : null;
        } else {
            $this->userModel->markVerified((int)$user['id']);
            $this->userModel->updateLastLogin((int)$user['id']);
            $user = $this->userModel->findById((int)$user['id']);
        }

        $token   = jwt_generate(['user_id' => (int)$user['id'], 'phone' => $phone]);
        $refresh = jwt_generate_refresh(['user_id' => (int)$user['id']]);
        $safe    = $this->userModel->safeUser($user);

        return api_success($safe, 'OTP verified. Login successful.', 200, [
            'token'         => $token,
            'refresh_token' => $refresh,
        ]);
    }

    // ─── Refresh Token ────────────────────────────────────────────────────────

    public function refresh(): \CodeIgniter\HTTP\Response
    {
        $data = $this->jsonBody();

        if (empty($data['refresh_token'])) {
            return api_error('Refresh token is required.', 422);
        }

        $payload = jwt_decode($data['refresh_token']);

        if (!$payload || ($payload['type'] ?? '') !== 'refresh') {
            return api_error('Invalid or expired refresh token.', 401);
        }

        $userId = (int)($payload['user_id'] ?? 0);
        $user   = $this->userModel->findById($userId);

        if (!$user) {
            return api_error('User not found.', 404);
        }

        $token   = jwt_generate(['user_id' => $userId, 'email' => $user['email'] ?? '']);
        $refresh = jwt_generate_refresh(['user_id' => $userId]);

        return api_success(null, 'Token refreshed.', 200, [
            'token'         => $token,
            'refresh_token' => $refresh,
        ]);
    }

    // ─── Forgot Password ──────────────────────────────────────────────────────

    public function forgotPassword(): \CodeIgniter\HTTP\Response
    {
        $data = $this->jsonBody();

        if (empty($data['email']) && empty($data['phone'])) {
            return api_error('Email or phone is required.', 422);
        }

        $user = null;
        if (!empty($data['email'])) {
            $user = $this->userModel->findByEmail($data['email']);
        } elseif (!empty($data['phone'])) {
            $user = $this->userModel->findByPhone($data['phone']);
        }

        // Always return success to prevent user enumeration
        if (!$user) {
            return api_success(null, 'If the account exists, a reset code has been sent.');
        }

        // Generate OTP for password reset
        $phone = $user['phone'] ?? '';
        if ($phone) {
            $code = $this->otpModel->generate($phone, 'reset');
            log_message('info', "Password reset OTP for $phone: $code");
        }

        // In production: send email/SMS with reset link or OTP

        return api_success(null, 'If the account exists, a reset code has been sent.');
    }

    // ─── Reset Password ───────────────────────────────────────────────────────

    public function resetPassword(): \CodeIgniter\HTTP\Response
    {
        $data = $this->jsonBody();

        $err = $this->requireFields($data, ['phone', 'otp', 'password']);
        if ($err) return api_error($err, 422);

        if (strlen($data['password']) < 6) {
            return api_error('Password must be at least 6 characters.', 422);
        }

        if (!$this->otpModel->verify($data['phone'], $data['otp'], 'reset')) {
            return api_error('Invalid or expired OTP.', 401);
        }

        $user = $this->userModel->findByPhone($data['phone']);
        if (!$user) {
            return api_error('User not found.', 404);
        }

        $this->userModel->update((int)$user['id'], [
            'password_hash' => $this->userModel->hashPassword($data['password']),
        ]);

        return api_success(null, 'Password reset successfully. Please log in.');
    }

    // ─── Logout (JWT protected) ───────────────────────────────────────────────

    public function logout(): \CodeIgniter\HTTP\Response
    {
        // Stateless JWT — client discards token.
        // For refresh token revocation, delete from refresh_tokens table here.
        return api_success(null, 'Logged out successfully.');
    }
}
