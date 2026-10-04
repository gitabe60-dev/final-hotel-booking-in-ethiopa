<?php

namespace App\Models;

use CodeIgniter\Model;

/**
 * UserModel
 *
 * All DB writes for boolean columns use raw SQL to avoid
 * CI4's PostgreSQL driver quoting TRUE/FALSE as strings.
 */
class UserModel extends Model
{
    protected $table            = 'users';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = [
        'first_name','last_name','email','phone',
        'password_hash','nationality','avatar_url',
        'status','last_login','registered_date',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'registered_date';
    protected $updatedField  = 'updated_at';
    protected $skipValidation = true;

    // ─── Create user (fully raw SQL) ─────────────────────────────────────────

    /**
     * Returns:
     *   int    — new user ID on success
     *   'email_exists'  — email already registered
     *   'phone_exists'  — phone already registered
     *   false  — unexpected DB error
     */
    public function createUser(array $data): int|string|false
    {
        $email      = !empty($data['email'])  ? strtolower(trim($data['email'])) : null;
        $phone      = !empty($data['phone'])  ? trim($data['phone'])             : null;
        $isVerified = !empty($data['is_verified']) ? 'TRUE' : 'FALSE';
        $status     = $data['status']       ?? 'active';
        $nationality= $data['nationality']  ?? null;

        // ── Check email uniqueness ────────────────────────────────────────────
        if ($email) {
            $exists = $this->db->query(
                'SELECT id FROM users WHERE LOWER(email) = LOWER(?) LIMIT 1',
                [$email]
            )->getRowArray();
            if ($exists) return 'email_exists';
        }

        // ── Check phone uniqueness ────────────────────────────────────────────
        if ($phone) {
            $exists = $this->db->query(
                'SELECT id FROM users WHERE phone = ? LIMIT 1',
                [$phone]
            )->getRowArray();
            if ($exists) return 'phone_exists';
        }

        // ── Insert ────────────────────────────────────────────────────────────
        try {
            $row = $this->db->query(
                "INSERT INTO users
                   (first_name, last_name, email, phone, password_hash, nationality, status, is_verified)
                 VALUES (?, ?, ?, ?, ?, ?, ?, $isVerified)
                 RETURNING id",
                [
                    trim($data['first_name']),
                    trim($data['last_name']),
                    $email,
                    $phone,
                    $data['password_hash'],
                    $nationality,
                    $status,
                ]
            )->getRowArray();

            if ($row && isset($row['id'])) {
                return (int)$row['id'];
            }

            // Log the DB error for debugging
            $error = $this->db->error();
            log_message('error', 'UserModel::createUser DB error: ' . json_encode($error));
            return false;

        } catch (\Throwable $e) {
            log_message('error', 'UserModel::createUser exception: ' . $e->getMessage());
            return false;
        }
    }

    // ─── Finders ─────────────────────────────────────────────────────────────

    public function findById(int $id): ?array
    {
        return $this->db->query(
            'SELECT * FROM users WHERE id = ? LIMIT 1', [$id]
        )->getRowArray() ?: null;
    }

    public function findByEmail(string $email): ?array
    {
        return $this->db->query(
            'SELECT * FROM users WHERE LOWER(email) = LOWER(?) LIMIT 1', [$email]
        )->getRowArray() ?: null;
    }

    public function findByPhone(string $phone): ?array
    {
        return $this->db->query(
            'SELECT * FROM users WHERE phone = ? LIMIT 1', [$phone]
        )->getRowArray() ?: null;
    }

    public function find($id = null)
    {
        if ($id === null) return null;
        return $this->findById((int)$id);
    }

    // ─── Password ─────────────────────────────────────────────────────────────

    public function hashPassword(string $plain): string
    {
        return password_hash($plain, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    public function verifyPassword(string $plain, string $hash): bool
    {
        return password_verify($plain, $hash);
    }

    // ─── Profile update ───────────────────────────────────────────────────────

    public function updateProfile(int $userId, array $data): bool
    {
        $allowed = ['first_name','last_name','phone','nationality','avatar_url'];
        $sets = []; $binds = [];
        foreach ($allowed as $col) {
            if (array_key_exists($col, $data)) {
                $sets[]  = "$col = ?";
                $binds[] = $data[$col];
            }
        }
        if (empty($sets)) return false;
        $binds[] = $userId;
        $this->db->query(
            'UPDATE users SET ' . implode(', ', $sets) . ', updated_at = NOW() WHERE id = ?',
            $binds
        );
        return true;
    }

    // ─── Mark verified ────────────────────────────────────────────────────────

    public function markVerified(int $userId): bool
    {
        $this->db->query(
            "UPDATE users SET is_verified = TRUE, status = 'active', updated_at = NOW() WHERE id = ?",
            [$userId]
        );
        return true;
    }

    public function updateLastLogin(int $userId): bool
    {
        $this->db->query(
            'UPDATE users SET last_login = NOW() WHERE id = ?', [$userId]
        );
        return true;
    }

    // ─── Safe user (no password hash) ────────────────────────────────────────

    public function safeUser(array $user): array
    {
        unset($user['password_hash']);
        return $user;
    }
}
