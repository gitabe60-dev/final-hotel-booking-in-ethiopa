<?php

namespace App\Controllers\Web;

use App\Models\UserModel;
use App\Models\BookingModel;
use App\Models\WishlistModel;
use CodeIgniter\Controller;

class DashboardController extends Controller
{
    private UserModel     $userModel;
    private BookingModel  $bookingModel;
    private WishlistModel $wishlistModel;

    public function __construct()
    {
        $this->userModel     = new UserModel();
        $this->bookingModel  = new BookingModel();
        $this->wishlistModel = new WishlistModel();
    }

    private function userId(): int { return (int)session()->get('user_id'); }

    public function index()
    {
        $userId  = $this->userId();
        $user    = $this->userModel->safeUser($this->userModel->findById($userId));
        $counts  = $this->bookingModel->countByStatus($userId);
        $recent  = array_slice($this->bookingModel->getUserBookings($userId), 0, 3);
        $wishlist = array_slice($this->wishlistModel->getUserWishlist($userId), 0, 4);

        return view('dashboard/index', [
            'user'      => $user,
            'counts'    => $counts,
            'recent'    => $recent,
            'wishlist'  => $wishlist,
            'pageTitle' => 'Dashboard — Dallol Booking',
            'active'    => 'dashboard',
        ]);
    }

    public function bookings()
    {
        $userId   = $this->userId();
        $filter   = $this->request->getGet('status') ?? 'all';
        $bookings = $this->bookingModel->getUserBookings($userId);

        if ($filter !== 'all') {
            $bookings = array_filter($bookings, fn($b) => $b['status'] === $filter);
        }

        return view('dashboard/bookings', [
            'bookings'  => array_values($bookings),
            'filter'    => $filter,
            'counts'    => $this->bookingModel->countByStatus($userId),
            'pageTitle' => 'My Bookings — Dallol Booking',
            'active'    => 'bookings',
        ]);
    }

    public function bookingDetail(int $id)
    {
        $userId  = $this->userId();
        $booking = $this->bookingModel->getDetail($id, $userId);

        if (!$booking) {
            return redirect()->to('/dashboard/bookings')->with('error', 'Booking not found.');
        }

        return view('dashboard/booking_detail', [
            'booking'   => $booking,
            'pageTitle' => 'Booking #' . $id . ' — Dallol Booking',
            'active'    => 'bookings',
        ]);
    }

    public function cancelBooking(int $id)
    {
        $userId  = $this->userId();
        $success = $this->bookingModel->cancelBooking($id, $userId);

        if ($success) {
            return redirect()->to('/dashboard/bookings')->with('success', 'Booking cancelled successfully.');
        }
        return redirect()->back()->with('error', 'Could not cancel this booking.');
    }

    public function wishlist()
    {
        $hotels = $this->wishlistModel->getUserWishlist($this->userId());

        return view('dashboard/wishlist', [
            'hotels'    => $hotels,
            'pageTitle' => 'My Wishlist — Dallol Booking',
            'active'    => 'wishlist',
        ]);
    }

    public function toggleWishlist()
    {
        $userId  = $this->userId();
        $hotelId = (int)$this->request->getPost('hotel_id');
        $result  = $this->wishlistModel->toggle($userId, $hotelId);

        if ($this->request->getHeaderLine('X-Requested-With') === 'XMLHttpRequest') {
            return $this->response->setJSON($result);
        }
        return redirect()->back();
    }

    public function profile()
    {
        $userId = $this->userId();
        $user   = $this->userModel->safeUser($this->userModel->findById($userId));
        return view('dashboard/profile', [
            'user'          => $user,
            'bookingCounts' => $this->bookingModel->countByStatus($userId),
            'counts'        => $this->bookingModel->countByStatus($userId),
            'pageTitle'     => 'My Profile — Dallol Booking',
            'active'        => 'profile',
        ]);
    }

    public function updateProfile()
    {
        $rules = [
            'first_name' => 'required|min_length[2]',
            'last_name'  => 'required|min_length[1]',
        ];

        if (!$this->validate($rules)) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        $this->userModel->updateProfile($this->userId(), [
            'first_name'  => $this->request->getPost('first_name'),
            'last_name'   => $this->request->getPost('last_name'),
            'phone'       => $this->request->getPost('phone'),
            'nationality' => $this->request->getPost('nationality'),
        ]);

        // Refresh session name
        session()->set('user_name',
            $this->request->getPost('first_name') . ' ' . $this->request->getPost('last_name')
        );

        return redirect()->back()->with('success', 'Profile updated successfully.');
    }
}
