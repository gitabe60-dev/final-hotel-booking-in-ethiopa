<?php

namespace App\Controllers\Api;

use App\Models\PaymentModel;
use App\Models\BookingModel;

/**
 * Payment Controller  (JWT-protected)
 *
 * POST /api/v1/payments/initiate      — initiate payment for a booking
 * GET  /api/v1/payments/(:num)/status — check payment status
 * POST /api/v1/payments/retry/(:num)  — retry a failed payment
 * POST /api/v1/payments/webhook       — payment gateway webhook (no auth)
 */
class PaymentController extends BaseApiController
{
    private PaymentModel $paymentModel;
    private BookingModel $bookingModel;

    public function __construct()
    {
        $this->paymentModel = new PaymentModel();
        $this->bookingModel = new BookingModel();
    }

    // ─── Initiate payment ─────────────────────────────────────────────────────

    public function initiate(): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $data = $this->jsonBody();
        $err  = $this->requireFields($data, ['booking_id', 'method']);
        if ($err) return api_error($err, 422);

        $bookingId = (int)$data['booking_id'];
        $booking   = $this->bookingModel->getDetail($bookingId, $userId);

        if (!$booking) return api_error('Booking not found.', 404);

        if ($booking['status'] === 'cancelled') {
            return api_error('Cannot pay for a cancelled booking.', 400);
        }

        // Check if already paid
        $existing = $this->paymentModel->getByBooking($bookingId);
        if ($existing && $existing['status'] === 'completed') {
            return api_success($existing, 'Booking is already paid.');
        }

        $paymentId = $this->paymentModel->createPayment(
            $bookingId,
            $userId,
            (float)$booking['total_price'],
            $data['method']
        );

        // In production: call Telebirr / Chapa / CBE Birr gateway here
        // Return redirect URL or payment reference
        $paymentData = [
            'payment_id'   => $paymentId,
            'booking_id'   => $bookingId,
            'amount'       => $booking['total_price'],
            'currency'     => 'ETB',
            'method'       => $data['method'],
            'status'       => 'pending',
            // 'redirect_url' => 'https://payment-gateway.com/pay/...',
        ];

        return api_success($paymentData, 'Payment initiated. Complete payment to confirm booking.', 201);
    }

    // ─── Payment status ───────────────────────────────────────────────────────

    public function status(int $paymentId): \CodeIgniter\HTTP\Response
    {
        $userId  = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $payment = $this->paymentModel->find($paymentId);
        if (!$payment || (int)$payment['user_id'] !== $userId) {
            return api_error('Payment not found.', 404);
        }

        return api_success($payment, 'Payment status.');
    }

    // ─── Retry failed payment ─────────────────────────────────────────────────

    public function retry(int $bookingId): \CodeIgniter\HTTP\Response
    {
        $userId  = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $booking = $this->bookingModel->getDetail($bookingId, $userId);
        if (!$booking) return api_error('Booking not found.', 404);

        if ($booking['status'] === 'cancelled') {
            return api_error('Cancelled bookings cannot be retried.', 400);
        }

        $existing = $this->paymentModel->getByBooking($bookingId);
        if ($existing && $existing['status'] === 'completed') {
            return api_success($existing, 'Booking already paid.');
        }

        // Create new payment attempt
        $paymentId = $this->paymentModel->createPayment(
            $bookingId,
            $userId,
            (float)$booking['total_price'],
            $existing['method'] ?? 'card'
        );

        return api_success(['payment_id' => $paymentId], 'Payment retry initiated.');
    }

    // ─── Webhook (no JWT — verified by gateway signature) ────────────────────

    public function webhook(): \CodeIgniter\HTTP\Response
    {
        $data = $this->jsonBody();

        // TODO: Verify webhook signature from your payment gateway
        $transactionId = $data['transaction_id'] ?? '';
        $gatewayRef    = $data['reference']       ?? '';
        $status        = $data['status']          ?? '';
        $bookingId     = (int)($data['booking_id'] ?? 0);

        if ($status === 'success' && $bookingId) {
            $payment = $this->paymentModel->getByBooking($bookingId);
            if ($payment) {
                $this->paymentModel->markCompleted((int)$payment['id'], $transactionId, $gatewayRef);
                // Confirm the booking
                $this->bookingModel->update($bookingId, ['status' => 'confirmed']);
            }
        }

        return api_success(null, 'Webhook received.');
    }
}
