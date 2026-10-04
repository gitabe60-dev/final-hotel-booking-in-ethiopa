<?php

namespace App\Controllers\Admin;

class BrokerController extends BaseAdminController
{
    private ?array $brokerRecord = null;

    public function __construct()
    {
        parent::__construct();
        $this->brokerRecord = $this->brokerModel->getByAdminId($this->adminId);
    }

    // ── Dashboard ─────────────────────────────────────────────────────────────
    public function dashboard()
    {
        $br       = $this->brokerRecord;
        $hotels   = $br ? $this->brokerModel->getLinkedHotels($br['id'] ?? 0) : [];
        $managers = $br ? $this->managerModel->getByBroker($br['id'] ?? 0) : [];
        $unread   = $this->brokerModel->countUnread($this->adminId);
        $inbox    = array_slice($this->brokerModel->getInbox($this->adminId), 0, 5);

        $db = \Config\Database::connect();
        $revenue = $db->query(
            "SELECT COALESCE(SUM(b.total_price),0) AS total
             FROM bookings b
             JOIN broker_hotel_links bhl ON bhl.hotel_id = b.hotel_id
             WHERE bhl.broker_id = ? AND b.status IN ('confirmed','completed')",
            [$br['id'] ?? 0]
        )->getRowArray();

        return view('admin/broker/dashboard', $this->viewData([
            'pageTitle'  => 'Broker Dashboard',
            'broker'     => $br,
            'hotels'     => $hotels,
            'managers'   => $managers,
            'unread'     => $unread,
            'inbox'      => $inbox,
            'revenue'    => (float)($revenue['total'] ?? 0),
        ]));
    }

    // ── My Hotels ─────────────────────────────────────────────────────────────
    public function hotels()
    {
        $br     = $this->brokerRecord;
        $hotels = $br ? $this->brokerModel->getLinkedHotels($br['id'] ?? 0) : [];

        return view('admin/broker/hotels', $this->viewData([
            'pageTitle' => 'My Hotels',
            'hotels'    => $hotels,
            'broker'    => $br,
        ]));
    }

    // ── Hotel Rooms (view only) ───────────────────────────────────────────────
    public function rooms(int $hotelId)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT * FROM hotels WHERE id=? LIMIT 1', [$hotelId])->getRowArray();
        if (!$hotel) return redirect()->to('/admin/broker/hotels')->with('error', 'Hotel not found.');
        $rooms = $this->managerModel->getRooms($hotelId);
        foreach ($rooms as &$r) $r['is_available'] = ($r['is_available']==='t'||$r['is_available']===true);
        unset($r);

        return view('admin/broker/rooms', $this->viewData([
            'pageTitle' => "Rooms — {$hotel['name']}",
            'hotel'     => $hotel,
            'rooms'     => $rooms,
        ]));
    }

    // ── Bookings for my hotels ────────────────────────────────────────────────
    public function bookings()
    {
        $br     = $this->brokerRecord;
        $status = $this->request->getGet('status') ?? '';
        $db     = \Config\Database::connect();

        $sql   = "SELECT b.*, h.name AS hotel_name, u.first_name||' '||u.last_name AS guest_name
                  FROM bookings b
                  JOIN hotels h ON b.hotel_id = h.id
                  JOIN users u  ON b.user_id  = u.id
                  JOIN broker_hotel_links bhl ON bhl.hotel_id = b.hotel_id
                  WHERE bhl.broker_id = ?";
        $binds = [$br['id'] ?? 0];
        if ($status) { $sql .= ' AND b.status=?'; $binds[] = $status; }
        $sql .= ' ORDER BY b.created_at DESC LIMIT 100';
        $bookings = $db->query($sql, $binds)->getResultArray();

        return view('admin/broker/bookings', $this->viewData([
            'pageTitle' => 'Bookings',
            'bookings'  => $bookings,
            'status'    => $status,
        ]));
    }

    // ── Messages Inbox ────────────────────────────────────────────────────────
    public function inbox()
    {
        $inbox = $this->brokerModel->getInbox($this->adminId);
        return view('admin/broker/inbox', $this->viewData([
            'pageTitle' => 'Inbox',
            'messages'  => $inbox,
            'unread'    => $this->brokerModel->countUnread($this->adminId),
        ]));
    }

    public function viewMessage(int $id)
    {
        $msg = $this->brokerModel->getMessage($id);
        if (!$msg) return redirect()->to('/admin/broker/inbox')->with('error', 'Message not found.');
        $this->brokerModel->markRead($id, $this->adminId);
        return view('admin/broker/message', $this->viewData([
            'pageTitle' => 'Message: '.$msg['subject'],
            'msg'       => $msg,
        ]));
    }

    // ── Send Message ──────────────────────────────────────────────────────────
    public function sendMessage()
    {
        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            if (empty($d['to_admin']) || empty($d['subject']) || empty($d['body'])) {
                return redirect()->back()->withInput()->with('error', 'All fields required.');
            }
            $this->brokerModel->sendMessage(
                $this->adminId,
                (int)$d['to_admin'],
                $d['subject'],
                $d['body'],
                !empty($d['hotel_id']) ? (int)$d['hotel_id'] : null,
                !empty($d['parent_id']) ? (int)$d['parent_id'] : null
            );
            return redirect()->to('/admin/broker/inbox')->with('success', 'Message sent.');
        }

        // Get hotel managers I can contact
        $br       = $this->brokerRecord;
        $managers = $br ? $this->managerModel->getByBroker($br['id'] ?? 0) : [];
        $hotels   = $br ? $this->brokerModel->getLinkedHotels($br['id'] ?? 0) : [];

        return view('admin/broker/compose', $this->viewData([
            'pageTitle' => 'Compose Message',
            'managers'  => $managers,
            'hotels'    => $hotels,
        ]));
    }

    // ── Sent Messages ────────────────────────────────────────────────────────
    public function sent()
    {
        $sent = $this->brokerModel->getSent($this->adminId);
        return view('admin/broker/sent', $this->viewData([
            'pageTitle' => 'Sent Messages',
            'messages'  => $sent,
        ]));
    }
}
