<?php

namespace App\Models;

use CodeIgniter\Model;

class PaymentModel extends Model
{
    protected $table         = 'payments';
    protected $primaryKey    = 'id';
    protected $useAutoIncrement = true;
    protected $returnType    = 'array';
    protected $useSoftDeletes = false;

    protected $allowedFields = [
        'booking_id', 'user_id', 'amount', 'currency',
        'method', 'status', 'transaction_id', 'gateway_ref', 'paid_at',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // ─── Create a payment record ─────────────────────────────────────────────

    public function createPayment(int $bookingId, int $userId, float $amount, string $method): int
    {
        $this->insert([
            'booking_id' => $bookingId,
            'user_id'    => $userId,
            'amount'     => $amount,
            'currency'   => 'ETB',
            'method'     => $method,
            'status'     => 'pending',
        ]);
        return (int)$this->getInsertID();
    }

    // ─── Mark payment as completed ───────────────────────────────────────────

    public function markCompleted(int $paymentId, string $transactionId = '', string $gatewayRef = ''): bool
    {
        return (bool)$this->update($paymentId, [
            'status'         => 'completed',
            'transaction_id' => $transactionId,
            'gateway_ref'    => $gatewayRef,
            'paid_at'        => date('Y-m-d H:i:s'),
        ]);
    }

    // ─── Mark payment as failed ──────────────────────────────────────────────

    public function markFailed(int $paymentId, string $reason = ''): bool
    {
        return (bool)$this->update($paymentId, [
            'status'     => 'failed',
            'gateway_ref'=> $reason,
        ]);
    }

    // ─── Get payment by booking ──────────────────────────────────────────────

    public function getByBooking(int $bookingId): ?array
    {
        return $this->where('booking_id', $bookingId)
                    ->orderBy('created_at', 'DESC')
                    ->first();
    }

    // ─── Get user payment history ────────────────────────────────────────────

    public function getUserPayments(int $userId): array
    {
        return $this->db->table('payments p')
            ->select('p.*, b.check_in, b.check_out, h.name AS hotel_name')
            ->join('bookings b', 'b.id = p.booking_id')
            ->join('hotels h',   'h.id = b.hotel_id')
            ->where('p.user_id', $userId)
            ->orderBy('p.created_at', 'DESC')
            ->get()
            ->getResultArray();
    }
}
