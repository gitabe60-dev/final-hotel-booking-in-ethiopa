<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

/**
 * AdminFilter — role-based access control for /admin/* routes
 *
 * Usage in routes:
 *   ['filter' => 'admin']               – any admin role
 *   ['filter' => 'admin:super_admin']   – super admin only
 *   ['filter' => 'admin:sub_admin']     – sub admin only
 *   ['filter' => 'admin:broker']        – broker only
 *   ['filter' => 'admin:hotel_manager'] – hotel manager only
 */
class AdminFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null): mixed
    {
        $adminSession = session()->get('admin');

        // Not logged in → redirect to admin login
        if (!$adminSession || empty($adminSession['id'])) {
            session()->setFlashdata('error', 'Please log in to access the admin panel.');
            return redirect()->to('/admin/login');
        }

        // Role check if a specific role is required
        if (!empty($arguments)) {
            $allowedRoles = is_array($arguments) ? $arguments : explode(',', $arguments[0] ?? '');
            $allowedRoles = array_map('trim', $allowedRoles);

            if (!in_array($adminSession['role'], $allowedRoles)) {
                session()->setFlashdata('error', 'Access denied. Insufficient permissions.');
                return redirect()->to('/admin/dashboard');
            }
        }

        return null;
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null): mixed
    {
        return null;
    }
}
