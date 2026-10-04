<?php

namespace App\Models;

use CodeIgniter\Model;

class OtpModel extends Model
{
    protected $table         = 'otp_codes';
    protected $primaryKey    = 'id';
    protected $useAutoIncrement = true;
    protected $returnType    = 'array';
    protected $useSoftDeletes = false;

    protected $allowedFields = ['phone', 'code', 'purpose', 'expires_at', 'used'];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = false;

    // ─── Generate and store a 6-digit OTP ────────────────────────────────────

    public function generate(string $phone, string $purpose = 'login'): string
    {
        // Invalidate previous codes for this phone + purpose
        $this->where('phone', $phone)->where('purpose', $purpose)->set('used', true)->update();

        $code = str_pad((string)random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $this->insert([
            'phone'      => $phone,
            'code'       => $code,
            'purpose'    => $purpose,
            'expires_at' => date('Y-m-d H:i:s', time() + 300), // 5 minutes
            'used'       => false,
        ]);

        return $code;
    }

    // ─── Verify OTP ──────────────────────────────────────────────────────────

    public function verify(string $phone, string $code, string $purpose = 'login'): bool
    {
        $record = $this->where('phone', $phone)
                       ->where('code', $code)
                       ->where('purpose', $purpose)
                       ->where('used', false)
                       ->where('expires_at >', date('Y-m-d H:i:s'))
                       ->orderBy('created_at', 'DESC')
                       ->first();

        if (!$record) return false;

        // Mark as used
        $this->update($record['id'], ['used' => true]);
        return true;
    }

    // ─── Clean up expired codes ───────────────────────────────────────────────

    public function cleanExpired(): int
    {
        $this->where('expires_at <', date('Y-m-d H:i:s'))->delete();
        return $this->db->affectedRows();
    }
}
