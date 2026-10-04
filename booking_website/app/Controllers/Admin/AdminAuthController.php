<?php

namespace App\Controllers\Admin;

use CodeIgniter\Controller;
use App\Models\AdminUserModel;

class AdminAuthController extends Controller
{
    private AdminUserModel $adminModel;

    public function __construct()
    {
        $this->adminModel = new AdminUserModel();
    }

    // ── Login Page ────────────────────────────────────────────────────────────
    public function loginPage()
    {
        if (session()->get('admin')) {
            return redirect()->to('/admin/dashboard');
        }
        return view('admin/shared/login', ['pageTitle' => 'Admin Login — Dallol Booking']);
    }

    // ── Login POST ────────────────────────────────────────────────────────────
    public function loginPost()
    {
        $email    = trim($this->request->getPost('email') ?? '');
        $password = $this->request->getPost('password') ?? '';

        if (!$email || !$password) {
            return redirect()->back()->withInput()->with('error', 'Email and password are required.');
        }

        $admin = $this->adminModel->findByEmail($email);

        if (!$admin || !$this->adminModel->verifyPassword($password, $admin['password_hash'])) {
            return redirect()->back()->withInput()->with('error', 'Invalid email or password.');
        }

        if ($admin['status'] !== 'active') {
            return redirect()->back()->with('error', 'Your account is suspended or inactive.');
        }

        $this->adminModel->updateLastLogin((int)$admin['id']);

        session()->set('admin', [
            'id'        => (int)$admin['id'],
            'name'      => $admin['full_name'],
            'email'     => $admin['email'],
            'role'      => $admin['role'],
            'avatar'    => $admin['avatar_url'] ?? null,
        ]);

        // Redirect based on role
        return redirect()->to($this->dashboardUrl($admin['role']));
    }

    // ── Logout ────────────────────────────────────────────────────────────────
    public function logout()
    {
        session()->remove('admin');
        return redirect()->to('/admin/login')->with('success', 'Logged out successfully.');
    }

    // ── Dashboard redirect ────────────────────────────────────────────────────
    public function dashboard()
    {
        $admin = session()->get('admin');
        if (!$admin) return redirect()->to('/admin/login');
        return redirect()->to($this->dashboardUrl($admin['role']));
    }

    // ── Change Password ───────────────────────────────────────────────────────
    public function changePassword()
    {
        $admin = session()->get('admin');
        if (!$admin) return redirect()->to('/admin/login');

        if ($this->request->getMethod() === 'POST') {
            $current = $this->request->getPost('current_password');
            $new     = $this->request->getPost('new_password');
            $confirm = $this->request->getPost('confirm_password');

            $adminRecord = $this->adminModel->findByEmail($admin['email']);

            if (!$this->adminModel->verifyPassword($current, $adminRecord['password_hash'])) {
                return redirect()->back()->with('error', 'Current password is incorrect.');
            }
            if ($new !== $confirm) {
                return redirect()->back()->with('error', 'New passwords do not match.');
            }
            if (strlen($new) < 6) {
                return redirect()->back()->with('error', 'Password must be at least 6 characters.');
            }

            $this->adminModel->update((int)$admin['id'], [
                'password_hash' => $this->adminModel->hashPassword($new),
            ]);

            return redirect()->back()->with('success', 'Password changed successfully.');
        }

        return view('admin/shared/change_password', [
            'admin'     => $admin,
            'pageTitle' => 'Change Password',
        ]);
    }

    // ── Profile update ────────────────────────────────────────────────────────
    public function updateProfile()
    {
        $admin = session()->get('admin');
        if (!$admin) return redirect()->to('/admin/login');

        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            $this->adminModel->update((int)$admin['id'], [
                'full_name' => $d['full_name'],
                'phone'     => $d['phone'] ?? null,
            ]);
            session()->set('admin', array_merge($admin, ['name' => $d['full_name']]));
            return redirect()->back()->with('success', 'Profile updated.');
        }

        $adminRecord = $this->adminModel->find((int)$admin['id']);
        return view('admin/shared/profile', [
            'admin'      => $adminRecord,
            'pageTitle'  => 'My Profile',
        ]);
    }

    // ── Role → URL ────────────────────────────────────────────────────────────
    private function dashboardUrl(string $role): string
    {
        return match($role) {
            'super_admin'   => '/admin/super/dashboard',
            'sub_admin'     => '/admin/subadmin/dashboard',
            'broker'        => '/admin/broker/dashboard',
            'hotel_manager' => '/admin/manager/dashboard',
            default         => '/admin/login',
        };
    }
}
