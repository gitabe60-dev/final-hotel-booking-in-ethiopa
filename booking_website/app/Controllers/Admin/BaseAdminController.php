<?php

namespace App\Controllers\Admin;

use CodeIgniter\Controller;
use App\Models\AdminUserModel;
use App\Models\BrokerModel;
use App\Models\HotelManagerModel;

/**
 * BaseAdminController
 * All admin controllers extend this.
 * Provides session helpers, role check, and shared data.
 */
abstract class BaseAdminController extends Controller
{
    protected AdminUserModel   $adminModel;
    protected BrokerModel      $brokerModel;
    protected HotelManagerModel $managerModel;

    protected array $adminSession = [];
    protected int   $adminId      = 0;
    protected string $adminRole   = '';

    public function __construct()
    {
        $this->adminModel   = new AdminUserModel();
        $this->brokerModel  = new BrokerModel();
        $this->managerModel = new HotelManagerModel();

        $this->adminSession = session()->get('admin') ?? [];
        $this->adminId      = (int)($this->adminSession['id']   ?? 0);
        $this->adminRole    = $this->adminSession['role'] ?? '';
    }

    // ── Shared view data injected into every admin view ───────────────────────
    protected function viewData(array $extra = []): array
    {
        $unread = $this->adminId ? $this->brokerModel->countUnread($this->adminId) : 0;

        return array_merge([
            'admin'       => $this->adminSession,
            'adminId'     => $this->adminId,
            'adminRole'   => $this->adminRole,
            'unreadCount' => $unread,
        ], $extra);
    }

    // ── Require specific role or redirect ─────────────────────────────────────
    protected function requireRole(string ...$roles): ?bool
    {
        if (!in_array($this->adminRole, $roles)) {
            session()->setFlashdata('error', 'Access denied.');
            redirect()->to('/admin/dashboard')->send();
            return false;
        }
        return true;
    }

    // ── City scope for sub-admin ──────────────────────────────────────────────
    protected function getAdminCity(): ?string
    {
        return $this->adminModel->getSubAdminCity($this->adminId);
    }
}
