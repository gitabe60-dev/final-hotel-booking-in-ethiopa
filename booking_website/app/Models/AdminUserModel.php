<?php

namespace App\Models;

use CodeIgniter\Model;

/**
 * AdminUserModel
 * Handles all admin_users CRUD for every role:
 *   super_admin | sub_admin | broker | hotel_manager
 */
class AdminUserModel extends Model
{
    protected $table            = 'admin_users';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = [
        'full_name','email','phone','password_hash',
        'role','status','avatar_url','last_login','created_by',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // ── Finders ──────────────────────────────────────────────────────────────

    public function findByEmail(string $email): ?array
    {
        return $this->db->query(
            'SELECT * FROM admin_users WHERE email = ? LIMIT 1', [$email]
        )->getRowArray();
    }

    public function findByRole(string $role, string $status = 'active'): array
    {
        return $this->db->query(
            'SELECT * FROM admin_users WHERE role = ? AND status = ? ORDER BY full_name ASC',
            [$role, $status]
        )->getResultArray();
    }

    public function findAllAdmins(): array
    {
        return $this->db->query(
            "SELECT a.*, c.full_name AS created_by_name
             FROM admin_users a
             LEFT JOIN admin_users c ON a.created_by = c.id
             ORDER BY a.role, a.full_name"
        )->getResultArray();
    }

    // ── Password ─────────────────────────────────────────────────────────────

    public function hashPassword(string $plain): string
    {
        return password_hash($plain, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    public function verifyPassword(string $plain, string $hash): bool
    {
        return password_verify($plain, $hash);
    }

    // ── Create admin (any role) ───────────────────────────────────────────────

    public function createAdmin(array $data, int $createdBy): int|false
    {
        $id = $this->insert([
            'full_name'     => trim($data['full_name']),
            'email'         => trim($data['email']),
            'phone'         => $data['phone'] ?? null,
            'password_hash' => $this->hashPassword($data['password']),
            'role'          => $data['role'],
            'status'        => 'active',
            'created_by'    => $createdBy,
        ]);
        return $id ? (int)$this->getInsertID() : false;
    }

    // ── Update last login ─────────────────────────────────────────────────────

    public function updateLastLogin(int $id): void
    {
        $this->db->query(
            'UPDATE admin_users SET last_login = NOW() WHERE id = ?', [$id]
        );
    }

    // ── Safe (no password) ───────────────────────────────────────────────────

    public function safe(array $admin): array
    {
        unset($admin['password_hash']);
        return $admin;
    }

    // ── Sub-admin city assignments ────────────────────────────────────────────

    public function assignCity(int $adminId, string $city, int $assignedBy): bool
    {
        $this->db->query(
            'INSERT INTO admin_city_assignments (admin_id, city, assigned_by)
             VALUES (?, ?, ?)
             ON CONFLICT (admin_id, city) DO NOTHING',
            [$adminId, $city, $assignedBy]
        );
        return true;
    }

    public function revokeCity(int $adminId, string $city): bool
    {
        $this->db->query(
            'DELETE FROM admin_city_assignments WHERE admin_id = ? AND city = ?',
            [$adminId, $city]
        );
        return true;
    }

    public function getCities(int $adminId): array
    {
        $rows = $this->db->query(
            'SELECT city FROM admin_city_assignments WHERE admin_id = ? ORDER BY city',
            [$adminId]
        )->getResultArray();
        return array_column($rows, 'city');
    }

    public function getSubAdminCity(int $adminId): ?string
    {
        $row = $this->db->query(
            'SELECT city FROM admin_city_assignments WHERE admin_id = ? LIMIT 1',
            [$adminId]
        )->getRowArray();
        return $row['city'] ?? null;
    }

    // ── Sub-admins with their cities ──────────────────────────────────────────

    public function getSubAdminsWithCities(): array
    {
        $admins = $this->findByRole('sub_admin', 'active');
        foreach ($admins as &$a) {
            $a['cities'] = $this->getCities($a['id']);
        }
        unset($a);
        return $admins;
    }

    // ── Stats for overview ────────────────────────────────────────────────────

    public function getOverview(): array
    {
        return $this->db->query('SELECT * FROM v_admin_overview')->getRowArray() ?? [];
    }
}
