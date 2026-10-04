<?php

namespace App\Controllers\Admin;

class HotelManagerController extends BaseAdminController
{
    private int    $hotelId  = 0;
    private ?array $hotel    = null;

    public function __construct()
    {
        parent::__construct();
        $this->hotelId = $this->managerModel->getHotelId($this->adminId) ?? 0;
        if ($this->hotelId) {
            $this->hotel = \Config\Database::connect()->query(
                'SELECT * FROM hotels WHERE id=? LIMIT 1', [$this->hotelId]
            )->getRowArray();
        }
    }

    // ── Dashboard ─────────────────────────────────────────────────────────────
    public function dashboard()
    {
        if (!$this->hotelId) return redirect()->to('/admin/login')->with('error', 'No hotel assigned to your account.');
        $db = \Config\Database::connect();

        $rooms     = $db->query('SELECT COUNT(*) AS cnt FROM room_types WHERE hotel_id=?', [$this->hotelId])->getRowArray();
        $avail     = $db->query("SELECT COUNT(*) AS cnt FROM room_types WHERE hotel_id=? AND is_available=TRUE", [$this->hotelId])->getRowArray();
        $bookings  = $db->query("SELECT COUNT(*) AS cnt FROM bookings WHERE hotel_id=?", [$this->hotelId])->getRowArray();
        $pending   = $db->query("SELECT COUNT(*) AS cnt FROM bookings WHERE hotel_id=? AND status='pending'", [$this->hotelId])->getRowArray();
        $revenue   = $db->query("SELECT COALESCE(SUM(total_price),0) AS total FROM bookings WHERE hotel_id=? AND status IN ('confirmed','completed')", [$this->hotelId])->getRowArray();

        $recentBk = $db->query(
            "SELECT b.*, u.first_name||' '||u.last_name AS guest_name, u.email AS guest_email
             FROM bookings b JOIN users u ON b.user_id=u.id
             WHERE b.hotel_id=? ORDER BY b.created_at DESC LIMIT 8",
            [$this->hotelId]
        )->getResultArray();

        $mgrDetail = $this->managerModel->getByAdminId($this->adminId);
        $unread    = $this->brokerModel->countUnread($this->adminId);

        return view('admin/manager/dashboard', $this->viewData([
            'pageTitle'  => "Hotel Manager — {$this->hotel['name']}",
            'hotel'      => $this->hotel,
            'mgrDetail'  => $mgrDetail,
            'roomCount'  => (int)$rooms['cnt'],
            'availCount' => (int)$avail['cnt'],
            'bkCount'    => (int)$bookings['cnt'],
            'pendingCount'=> (int)$pending['cnt'],
            'revenue'    => (float)$revenue['total'],
            'recentBk'   => $recentBk,
            'unread'     => $unread,
        ]));
    }

    // ── Rooms CRUD ────────────────────────────────────────────────────────────
    public function rooms()
    {
        $search = $this->request->getGet('q') ?? '';
        $rooms  = $this->managerModel->getRooms($this->hotelId, $search);
        foreach ($rooms as &$r) $r['is_available'] = ($r['is_available']==='t'||$r['is_available']===true);
        unset($r);

        return view('admin/manager/rooms', $this->viewData([
            'pageTitle' => "Rooms — {$this->hotel['name']}",
            'hotel'     => $this->hotel,
            'rooms'     => $rooms,
            'search'    => $search,
        ]));
    }

    public function addRoom()
    {
        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            if (empty($d['name']) || empty($d['bed_type']) || empty($d['price_per_night'])) {
                return redirect()->back()->withInput()->with('error', 'Name, bed type and price are required.');
            }
            $features = array_filter(array_map('trim', explode(',', $d['features'] ?? '')));
            $this->managerModel->addRoom([
                'hotel_id'        => $this->hotelId,
                'name'            => $d['name'],
                'bed_type'        => $d['bed_type'],
                'image_url'       => $d['image_url'] ?? null,
                'price_per_night' => $d['price_per_night'],
                'size_sqm'        => $d['size_sqm'] ?? 0,
                'max_guests'      => $d['max_guests'] ?? 2,
                'features'        => $features,
            ]);
            return redirect()->to('/admin/manager/rooms')->with('success', 'Room added.');
        }
        return view('admin/manager/room_form', $this->viewData([
            'pageTitle' => 'Add Room',
            'hotel'     => $this->hotel,
            'room'      => null,
        ]));
    }

    public function editRoom(int $roomId)
    {
        $room = $this->managerModel->getRoom($roomId);
        if (!$room || (int)$room['hotel_id'] !== $this->hotelId) {
            return redirect()->to('/admin/manager/rooms')->with('error', 'Room not found.');
        }
        if ($this->request->getMethod() === 'POST') {
            $d        = $this->request->getPost();
            $features = array_filter(array_map('trim', explode(',', $d['features'] ?? '')));
            $this->managerModel->updateRoom($roomId, [
                'name'            => $d['name'],
                'bed_type'        => $d['bed_type'],
                'image_url'       => $d['image_url'] ?? null,
                'price_per_night' => $d['price_per_night'],
                'size_sqm'        => $d['size_sqm'] ?? 0,
                'max_guests'      => $d['max_guests'] ?? 2,
                'features'        => $features,
                'is_available'    => isset($d['is_available']),
            ]);
            return redirect()->to('/admin/manager/rooms')->with('success', 'Room updated.');
        }
        $room['features_str'] = !empty($room['features']) ? str_replace('"', '', trim($room['features'],'{}')) : '';
        return view('admin/manager/room_form', $this->viewData([
            'pageTitle' => 'Edit Room',
            'hotel'     => $this->hotel,
            'room'      => $room,
        ]));
    }

    public function deleteRoom(int $roomId)
    {
        $room = $this->managerModel->getRoom($roomId);
        if ($room && (int)$room['hotel_id'] === $this->hotelId) {
            $this->managerModel->deleteRoom($roomId);
            return redirect()->to('/admin/manager/rooms')->with('success', 'Room deleted.');
        }
        return redirect()->to('/admin/manager/rooms')->with('error', 'Not found.');
    }

    public function toggleRoom(int $roomId)
    {
        $this->managerModel->toggleRoomAvailability($roomId);
        return redirect()->to('/admin/manager/rooms')->with('success', 'Availability updated.');
    }

    // ── Bookings ──────────────────────────────────────────────────────────────
    public function bookings()
    {
        $status = $this->request->getGet('status') ?? '';
        $db     = \Config\Database::connect();
        $sql    = "SELECT b.*, u.first_name||' '||u.last_name AS guest_name, u.email AS guest_email,
                          u.phone AS guest_phone, rt.name AS room_type_name
                   FROM bookings b JOIN users u ON b.user_id=u.id
                   LEFT JOIN room_types rt ON b.room_type_id=rt.id
                   WHERE b.hotel_id=?";
        $binds  = [$this->hotelId];
        if ($status) { $sql .= ' AND b.status=?'; $binds[] = $status; }
        $sql .= ' ORDER BY b.created_at DESC LIMIT 100';
        $bookings = $db->query($sql, $binds)->getResultArray();

        return view('admin/manager/bookings', $this->viewData([
            'pageTitle' => 'Bookings',
            'hotel'     => $this->hotel,
            'bookings'  => $bookings,
            'status'    => $status,
        ]));
    }

    public function updateBookingStatus(int $bookingId)
    {
        $status = $this->request->getPost('status');
        $allowed = ['confirmed','cancelled','completed'];
        if (!in_array($status, $allowed)) return redirect()->back()->with('error', 'Invalid status.');
        \Config\Database::connect()->query(
            'UPDATE bookings SET status=?, updated_at=NOW() WHERE id=? AND hotel_id=?',
            [$status, $bookingId, $this->hotelId]
        );
        return redirect()->to('/admin/manager/bookings')->with('success', "Booking #$bookingId → $status");
    }

    // ── Messages ──────────────────────────────────────────────────────────────
    public function inbox()
    {
        $inbox = $this->brokerModel->getInbox($this->adminId);
        return view('admin/manager/inbox', $this->viewData([
            'pageTitle' => 'Inbox',
            'messages'  => $inbox,
            'unread'    => $this->brokerModel->countUnread($this->adminId),
        ]));
    }

    public function viewMessage(int $id)
    {
        $msg = $this->brokerModel->getMessage($id);
        if (!$msg) return redirect()->to('/admin/manager/inbox')->with('error', 'Not found.');
        $this->brokerModel->markRead($id, $this->adminId);
        return view('admin/manager/message', $this->viewData([
            'pageTitle' => 'Message: '.$msg['subject'],
            'msg'       => $msg,
        ]));
    }

    public function reply()
    {
        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            // Reply goes to my broker
            $mgrDetail = $this->managerModel->getByAdminId($this->adminId);
            $brokerRow = $mgrDetail ? \Config\Database::connect()->query(
                'SELECT admin_id FROM brokers WHERE id=? LIMIT 1', [$mgrDetail['broker_id'] ?? 0]
            )->getRowArray() : null;

            $toAdmin = !empty($d['to_admin']) ? (int)$d['to_admin'] : (int)($brokerRow['admin_id'] ?? 0);
            if (!$toAdmin) return redirect()->back()->with('error', 'No recipient.');

            $this->brokerModel->sendMessage(
                $this->adminId, $toAdmin,
                $d['subject'], $d['body'],
                !empty($d['hotel_id']) ? (int)$d['hotel_id'] : $this->hotelId,
                !empty($d['parent_id']) ? (int)$d['parent_id'] : null
            );
            return redirect()->to('/admin/manager/inbox')->with('success', 'Reply sent.');
        }
        return redirect()->to('/admin/manager/inbox');
    }

    // ── Hotel Info ────────────────────────────────────────────────────────────
    public function hotelInfo()
    {
        return view('admin/manager/hotel_info', $this->viewData([
            'pageTitle' => 'Hotel Information',
            'hotel'     => $this->hotel,
        ]));
    }
}
