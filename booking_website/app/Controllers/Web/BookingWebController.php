<?php

namespace App\Controllers\Web;

use App\Models\HotelModel;
use App\Models\BookingModel;
use App\Models\PaymentModel;
use CodeIgniter\Controller;

class BookingWebController extends Controller
{
    private HotelModel   $hotelModel;
    private BookingModel $bookingModel;
    private PaymentModel $paymentModel;

    public function __construct()
    {
        $this->hotelModel   = new HotelModel();
        $this->bookingModel = new BookingModel();
        $this->paymentModel = new PaymentModel();
    }

    private function userId(): int { return (int)session()->get('user_id'); }

    // ─── Submit booking (POST from hotel detail page) ─────────────────────────

    public function submit(int $hotelId)
    {
        // Must be logged in
        if (!$this->userId()) {
            session()->set('post_auth_redirect', "/hotels/$hotelId");
            return redirect()->to('/login')->with('error', 'Please login to complete your booking.');
        }

        // Load hotel with raw SQL (avoid boolean quoting)
        $hotel = \Config\Database::connect()->query(
            'SELECT * FROM hotels WHERE id = ? AND is_active = TRUE LIMIT 1',
            [$hotelId]
        )->getRowArray();

        if (!$hotel) {
            return redirect()->back()->with('error', 'Hotel not found or unavailable.');
        }

        $checkIn   = $this->request->getPost('check_in');
        $checkOut  = $this->request->getPost('check_out');
        $rooms     = max(1, (int)$this->request->getPost('rooms'));
        $adults    = max(1, (int)$this->request->getPost('adults'));
        $children  = max(0, (int)($this->request->getPost('children') ?? 0));
        $method    = $this->request->getPost('payment_method');
        $roomTypeId= $this->request->getPost('room_type_id') ?: null;
        $special   = $this->request->getPost('special_requests');

        // ── Validation ──────────────────────────────────────────────────────
        if (!$checkIn || !$checkOut) {
            return redirect()->back()->withInput()->with('error', 'Please select check-in and check-out dates.');
        }
        if (strtotime($checkOut) <= strtotime($checkIn)) {
            return redirect()->back()->withInput()->with('error', 'Check-out date must be after check-in.');
        }
        if (strtotime($checkIn) < strtotime(date('Y-m-d'))) {
            return redirect()->back()->withInput()->with('error', 'Check-in date cannot be in the past.');
        }

        $allowedMethods = ['card','bank_transfer','mobile_money','cash','telebirr','cbe_birr'];
        if (!in_array($method, $allowedMethods)) $method = 'telebirr';

        // ── Calculate price ──────────────────────────────────────────────────
        $nights    = max(1, (strtotime($checkOut) - strtotime($checkIn)) / 86400);
        $unitPrice = (float)$hotel['price_per_night'];

        // If a specific room type is selected, use its price
        if ($roomTypeId) {
            $rt = \Config\Database::connect()->query(
                'SELECT price_per_night FROM room_types WHERE id = ? AND hotel_id = ? AND is_available = TRUE LIMIT 1',
                [$roomTypeId, $hotelId]
            )->getRowArray();
            if ($rt) $unitPrice = (float)$rt['price_per_night'];
        }

        // If user passed a calculated_total from JS, use it (already validated server-side)
        $clientTotal = (float)($this->request->getPost('calculated_total') ?? 0);
        $serverTotal = $unitPrice * $nights * $rooms;
        // Use server-calculated total for security — client total is just a hint
        $totalPrice  = $serverTotal;

        // ── Create booking ───────────────────────────────────────────────────
        $bookingId = $this->bookingModel->createBooking([
            'user_id'          => $this->userId(),
            'hotel_id'         => $hotelId,
            'room_type_id'     => $roomTypeId,
            'check_in'         => $checkIn,
            'check_out'        => $checkOut,
            'adults'           => $adults,
            'children'         => $children,
            'rooms'            => $rooms,
            'total_price'      => $totalPrice,
            'payment_method'   => $method,
            'status'           => 'pending',
            'special_requests' => $special,
        ]);

        if (!$bookingId) {
            return redirect()->back()->with('error', 'Booking failed. Please try again.');
        }

        // ── Create payment record ────────────────────────────────────────────
        $this->paymentModel->createPayment($bookingId, $this->userId(), $totalPrice, $method);

        // ── Cash bookings auto-confirm ────────────────────────────────────────
        if ($method === 'cash') {
            $this->bookingModel->update($bookingId, ['status' => 'confirmed']);
            session()->set("pay_method_$bookingId", 'cash');
            return redirect()->to('/payment/' . $bookingId . '/success')
                ->with('success', '✅ Booking confirmed! Pay at hotel on arrival.');
        }

        // All other methods → go to payment method selection
        session()->set("pay_method_$bookingId", $method);
        return redirect()->to('/payment/' . $bookingId . '/summary')
            ->with('success', 'Booking created! Complete your payment to confirm.');
    }

    // ─── Confirmation page ────────────────────────────────────────────────────

    public function confirm(int $bookingId)
    {
        if (!$this->userId()) return redirect()->to('/login');

        $booking = $this->bookingModel->getDetail($bookingId, $this->userId());
        if (!$booking) return redirect()->to('/dashboard/bookings');

        $payment = $this->paymentModel->getByBooking($bookingId);

        return view('booking/confirm', [
            'booking'   => $booking,
            'payment'   => $payment,
            'pageTitle' => 'Booking ' . ucfirst($booking['status']) . ' — Dallol Booking',
        ]);
    }

    // ─── Payment page ─────────────────────────────────────────────────────────

    public function payment(int $bookingId)
    {
        if (!$this->userId()) return redirect()->to('/login');

        $booking = $this->bookingModel->getDetail($bookingId, $this->userId());
        if (!$booking) return redirect()->to('/dashboard/bookings');

        if ($booking['status'] === 'confirmed') {
            return redirect()->to('/booking/confirm/' . $bookingId)
                ->with('success', 'Your booking is already confirmed!');
        }

        $payment = $this->paymentModel->getByBooking($bookingId);

        return view('booking/payment', [
            'booking'   => $booking,
            'payment'   => $payment,
            'pageTitle' => 'Complete Payment — Dallol Booking',
        ]);
    }

    // ─── Process payment ──────────────────────────────────────────────────────

    public function processPayment(int $bookingId)
    {
        if (!$this->userId()) return redirect()->to('/login');

        $booking = $this->bookingModel->getDetail($bookingId, $this->userId());
        if (!$booking) return redirect()->to('/dashboard/bookings');

        if ($booking['status'] === 'confirmed') {
            return redirect()->to('/booking/confirm/' . $bookingId);
        }

        $payment = $this->paymentModel->getByBooking($bookingId);
        if ($payment) {
            $txId = 'TXN-' . strtoupper(bin2hex(random_bytes(6)));
            $this->paymentModel->markCompleted((int)$payment['id'], $txId);
            $this->bookingModel->update($bookingId, ['status' => 'confirmed']);
        }

        return redirect()->to('/booking/confirm/' . $bookingId)
            ->with('success', '🎉 Payment successful! Your booking is confirmed.');
    }
}
