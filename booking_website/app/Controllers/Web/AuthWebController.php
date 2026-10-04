<?php

namespace App\Controllers\Web;

use App\Models\UserModel;
use App\Models\OtpModel;
use CodeIgniter\Controller;

class AuthWebController extends Controller
{
    private UserModel $userModel;
    private OtpModel  $otpModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
        $this->otpModel  = new OtpModel();
    }

    // ─── Login page ───────────────────────────────────────────────────────────

    public function loginPage()
    {
        if (session()->get('user_id')) {
            return redirect()->to($this->afterAuthRedirect());
        }

        // Store redirect URL from query string (e.g. ?redirect=/hotels/1?check_in=...)
        $redirectUrl = $this->request->getGet('redirect');
        if ($redirectUrl) {
            session()->set('post_auth_redirect', $redirectUrl);
        }

        return view('auth/login', ['pageTitle' => 'Login — Dallol Booking']);
    }

    public function loginPost()
    {
        $rules = [
            'email'    => 'required|valid_email',
            'password' => 'required|min_length[6]',
        ];

        if (!$this->validate($rules)) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        $user = $this->userModel->findByEmail($this->request->getPost('email'));

        if (!$user || !$this->userModel->verifyPassword($this->request->getPost('password'), $user['password_hash'] ?? '')) {
            return redirect()->back()->withInput()->with('error', 'Invalid email or password.');
        }

        if ($user['status'] === 'suspended') {
            return redirect()->back()->with('error', 'Your account has been suspended.');
        }

        $this->userModel->updateLastLogin((int)$user['id']);
        $this->_setSession($user);

        $redirect = $this->_pullRedirect();
        return redirect()->to($redirect)->with('success', 'Welcome back, ' . $user['first_name'] . '!');
    }

    // ─── Register page ────────────────────────────────────────────────────────

    public function registerPage()
    {
        if (session()->get('user_id')) {
            return redirect()->to($this->afterAuthRedirect());
        }

        // Store redirect URL
        $redirectUrl = $this->request->getGet('redirect');
        if ($redirectUrl) {
            session()->set('post_auth_redirect', $redirectUrl);
        }

        return view('auth/register', ['pageTitle' => 'Create Account — Dallol Booking']);
    }

    public function registerPost()
    {
        $firstName = trim($this->request->getPost('first_name') ?? '');
        $lastName  = trim($this->request->getPost('last_name')  ?? '');
        $email     = strtolower(trim($this->request->getPost('email')    ?? ''));
        $phone     = trim($this->request->getPost('phone')    ?? '');
        $password  = $this->request->getPost('password')      ?? '';
        $confirm   = $this->request->getPost('confirm_password') ?? '';

        // ── Manual validation (no CI4 is_unique — we check DB ourselves) ──────
        $errors = [];

        if (strlen($firstName) < 2)
            $errors['first_name'] = 'First name must be at least 2 characters.';

        if (strlen($lastName) < 1)
            $errors['last_name'] = 'Last name is required.';

        if (!$email || !filter_var($email, FILTER_VALIDATE_EMAIL))
            $errors['email'] = 'Please enter a valid email address.';

        if (strlen($password) < 6)
            $errors['password'] = 'Password must be at least 6 characters.';

        if ($password !== $confirm)
            $errors['confirm_password'] = 'Passwords do not match.';

        if (!empty($errors)) {
            return redirect()->back()->withInput()->with('errors', $errors);
        }

        // ── Check email uniqueness manually ───────────────────────────────────
        if (!empty($email) && $this->userModel->findByEmail($email)) {
            return redirect()->back()->withInput()->with('error',
                'This email is already registered. <a href="/login" class="alert-link fw-700">Sign in instead</a>.');
        }

        // ── Clean phone: strip leading 0 and +251 prefix ──────────────────────
        if ($phone) {
            $phone = preg_replace('/\D/', '', $phone);  // digits only
            if (str_starts_with($phone, '251')) $phone = substr($phone, 3);
            if (str_starts_with($phone, '0'))   $phone = substr($phone, 1);
            $phone = strlen($phone) >= 9 ? '+251' . $phone : null;
        } else {
            $phone = null;
        }

        // ── Insert user via raw SQL ────────────────────────────────────────────
        $result = $this->userModel->createUser([
            'first_name'    => $firstName,
            'last_name'     => $lastName,
            'email'         => $email,
            'phone'         => $phone,
            'password_hash' => $this->userModel->hashPassword($password),
            'status'        => 'active',
            'is_verified'   => false,
        ]);

        if ($result === 'email_exists') {
            return redirect()->back()->withInput()->with('error',
                'This email is already registered. <a href="/login" class="alert-link fw-700">Sign in instead →</a>');
        }

        if ($result === 'phone_exists') {
            return redirect()->back()->withInput()->with('error',
                'This phone number is already registered. Try a different number or leave phone blank.');
        }

        if ($result === false || !is_int($result)) {
            return redirect()->back()->withInput()->with('error',
                'Could not create account right now. Please try again in a moment.');
        }

        $userId = $result;

        // ── Set session and redirect ───────────────────────────────────────────
        $user = $this->userModel->findById($userId);
        $this->_setSession($user);

        $redirect = $this->_pullRedirect();
        return redirect()->to($redirect)->with('success',
            'Welcome, ' . $user['first_name'] . '! Your account is ready — enjoy booking.');
    }

    // ─── OTP page ─────────────────────────────────────────────────────────────

    public function otpPage()
    {
        return view('auth/otp', ['pageTitle' => 'Phone Login — Dallol Booking']);
    }

    public function otpSend()
    {
        $phone = trim($this->request->getPost('phone') ?? '');
        if (!$phone) return redirect()->back()->with('error', 'Phone number is required.');

        $code = $this->otpModel->generate($phone, 'login');
        log_message('info', "Web OTP for $phone: $code");
        session()->set('otp_phone', $phone);

        $msg = ENVIRONMENT === 'development'
            ? "OTP sent to $phone. (Dev code: $code)"
            : "OTP sent to $phone.";

        return redirect()->to('/otp')->with('success', $msg);
    }

    public function otpVerify()
    {
        $phone = session()->get('otp_phone') ?? $this->request->getPost('phone');
        $code  = trim($this->request->getPost('otp') ?? '');

        if (!$phone || !$code) {
            return redirect()->back()->with('error', 'Phone and OTP are required.');
        }

        if (!$this->otpModel->verify($phone, $code, 'login')) {
            return redirect()->back()->with('error', 'Invalid or expired OTP. Please try again.');
        }

        $user = $this->userModel->findByPhone($phone);
        if (!$user) {
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
        }

        $this->_setSession($user);
        session()->remove('otp_phone');

        $redirect = $this->_pullRedirect();
        return redirect()->to($redirect)->with('success', 'Welcome back!');
    }

    // ─── Forgot password ──────────────────────────────────────────────────────

    public function forgotPage()
    {
        return view('auth/forgot', ['pageTitle' => 'Forgot Password — Dallol Booking']);
    }

    public function forgotPost()
    {
        $email = trim($this->request->getPost('email') ?? '');
        $user  = $this->userModel->findByEmail($email);

        if ($user && $user['phone']) {
            $code = $this->otpModel->generate($user['phone'], 'reset');
            log_message('info', "Reset OTP for {$user['phone']}: $code");
            session()->set('reset_phone', $user['phone']);
        }

        return redirect()->back()->with('success',
            'If this email is registered, a reset code was sent to the linked phone number.');
    }

    // ─── Logout ───────────────────────────────────────────────────────────────

    public function logout()
    {
        session()->destroy();
        return redirect()->to('/login')->with('success', 'You have been logged out.');
    }

    // ─── Private helpers ─────────────────────────────────────────────────────

    private function _setSession(array $user): void
    {
        session()->set([
            'user_id'    => (int)$user['id'],
            'user_name'  => trim($user['first_name'] . ' ' . $user['last_name']),
            'user_email' => $user['email'] ?? '',
            'user_phone' => $user['phone'] ?? '',
            'is_logged'  => true,
        ]);
    }

    private function afterAuthRedirect(): string
    {
        return $this->_pullRedirect();
    }

    /**
     * CI4 has no session()->pull(). Read + remove redirect URL from session.
     */
    private function _pullRedirect(): string
    {
        $url = session()->get('post_auth_redirect');
        session()->remove('post_auth_redirect');
        return $url ?: '/dashboard';
    }
}
