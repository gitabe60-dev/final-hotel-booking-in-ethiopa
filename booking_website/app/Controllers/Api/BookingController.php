<?php

namespace App\Controllers\Api;

use App\Models\BookingModel;
use App\Models\HotelModel;
use App\Models\PaymentModel;

/**
 * Bookings API Controller  (all routes JWT-protected)
 *
 * GET  /api/v1/bookings              — list user bookings
 * POST /api/v1/bookings              — create booking
 * GET  /api/v1/bookings/(:num)       — booking detail
 * POST /api/v1/bookings/(:num)/cancel — cancel booking
 */
class BookingController extends BaseApiController
{
    private BookingModel $bookingModel;
    private HotelModel   $hotelModel;
    private PaymentModel $paymentModel;

    public function __construct()
    {
        $this->bookingModel = new BookingModel();
        $this->hotelModel   = new HotelModel();
        $this->paymentModel = new PaymentModel();
    }

    // ─── List user bookings ───────────────────────────────────────────────────

    public function index(): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $bookings = $this->bookingModel->getUserBookings($userId);
        $counts   = $this->bookingModel->countByStatus($userId);

        return api_success([
            'bookings' => $bookings,
            'counts'   => $counts,
        ], count($bookings) . ' bookings found.');
    }

    // ─── Create booking ───────────────────────────────────────────────────────

    public function create(): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $data = $this->jsonBody();

        $err = $this->requireFields($data, [
            'hotel_id', 'check_in', 'check_out', 'adults', 'rooms', 'payment_method',
        ]);
        if ($err) return api_error($err, 422);

        $hotelId  = (int)$data['hotel_id'];
        $checkIn  = $data['check_in'];
        $checkOut = $data['check_out'];
        $rooms    = (int)$data['rooms'];

        // Validate dates
        if (strtotime($checkOut) <= strtotime($checkIn)) {
            return api_error('Check-out date must be after check-in date.', 422);
        }
        if (strtotime($checkIn) < strtotime(date('Y-m-d'))) {
            return api_error('Check-in date cannot be in the past.', 422);
        }

        // Validate hotel — use raw SQL to avoid CI4 Postgre bool quoting
        $hotel = $this->hotelModel->db->query(
            'SELECT * FROM hotels WHERE id = ? LIMIT 1', [$hotelId]
        )->getRowArray();
        $isActive = ($hotel['is_active'] ?? false);
        $isActive = ($isActive === 't' || $isActive === true || $isActive === 1 || $isActive === '1');
        if (!$hotel || !$isActive) {
            return api_error('Hotel not found or unavailable.', 404);
        }

        // Validate payment method
        $allowed = ['card', 'bank_transfer', 'mobile_money', 'cash', 'telebirr', 'cbe_birr'];
        if (!in_array($data['payment_method'], $allowed)) {
            return api_error('Invalid payment method.', 422);
        }

        // Calculate total price
        $nights     = (strtotime($checkOut) - strtotime($checkIn)) / 86400;
        $totalPrice = (float)$hotel['price_per_night'] * $nights * $rooms;

        // Build booking record
        $bookingData = [
            'user_id'         => $userId,
            'hotel_id'        => $hotelId,
            'room_type_id'    => $data['room_type_id'] ?? null,
            'check_in'        => $checkIn,
            'check_out'       => $checkOut,
            'adults'          => (int)($data['adults'] ?? 1),
            'children'        => (int)($data['children'] ?? 0),
            'rooms'           => $rooms,
            'total_price'     => $totalPrice,
            'payment_method'  => $data['payment_method'],
            'status'          => 'pending',
            'special_requests'=> $data['special_requests'] ?? null,
        ];

        $bookingId = $this->bookingModel->createBooking($bookingData);

        if (!$bookingId) {
            return api_error('Failed to create booking. Please try again.', 500);
        }

        // Create a payment record
        $this->paymentModel->createPayment($bookingId, $userId, $totalPrice, $data['payment_method']);

        // Get full booking detail
        $booking = $this->bookingModel->getDetail($bookingId, $userId);

        // Add hotel info for the mobile app
        $booking['hotel_name']  = $hotel['name'];
        $booking['hotel_city']  = $hotel['city'];
        // Get first image using raw SQL to avoid bool quoting
        $imgRow = $this->hotelModel->db->query(
            'SELECT image_url FROM hotel_images WHERE hotel_id = ? ORDER BY sort_order ASC LIMIT 1',
            [$hotelId]
        )->getRowArray();
        $booking['hotel_image'] = $imgRow['image_url'] ?? '';

        return api_success($booking, 'Booking created successfully.', 201);
    }

    // ─── Booking detail ───────────────────────────────────────────────────────

    public function show(int $id): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $booking = $this->bookingModel->getDetail($id, $userId);
        if (!$booking) {
            return api_error('Booking not found.', 404);
        }

        // Attach payment info
        $payment = $this->paymentModel->getByBooking($id);
        if ($payment) {
            $booking['payment'] = $payment;
        }

        return api_success($booking, 'Booking details.');
    }

    // ─── Cancel booking ───────────────────────────────────────────────────────

    public function cancel(int $id): \CodeIgniter\HTTP\Response
    {
        $userId = $this->authUserId();
        if (!$userId) return api_error('Unauthorized.', 401);

        $booking = $this->bookingModel->getDetail($id, $userId);
        if (!$booking) {
            return api_error('Booking not found.', 404);
        }

        if (!in_array($booking['status'], ['pending', 'confirmed'])) {
            return api_error('Only pending or confirmed bookings can be cancelled.', 400);
        }

        $success = $this->bookingModel->cancelBooking($id, $userId);
        if (!$success) {
            return api_error('Failed to cancel booking.', 500);
        }

        return api_success(['booking_id' => $id, 'status' => 'cancelled'], 'Booking cancelled successfully.');
    }
}
