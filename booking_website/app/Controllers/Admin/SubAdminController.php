<?php

namespace App\Controllers\Admin;

class SubAdminController extends BaseAdminController
{
    private string $city = '';

    public function __construct()
    {
        parent::__construct();
        $this->city = $this->adminModel->getSubAdminCity($this->adminId) ?? '';
    }

    // ── Dashboard ─────────────────────────────────────────────────────────────
    public function dashboard()
    {
        $db   = \Config\Database::connect();
        $city = $this->city;

        $hotels   = $db->query('SELECT COUNT(*) AS cnt FROM hotels WHERE city = ? AND is_active=TRUE', [$city])->getRowArray();
        $bookings = $db->query("SELECT COUNT(*) AS cnt FROM bookings b JOIN hotels h ON b.hotel_id=h.id WHERE h.city=?", [$city])->getRowArray();
        $pending  = $db->query("SELECT COUNT(*) AS cnt FROM bookings b JOIN hotels h ON b.hotel_id=h.id WHERE h.city=? AND b.status='pending'", [$city])->getRowArray();
        $brokers  = $db->query("SELECT COUNT(*) AS cnt FROM brokers WHERE sub_admin_id=? AND status='active'", [$this->adminId])->getRowArray();
        $revenue  = $db->query("SELECT COALESCE(SUM(b.total_price),0) AS total FROM bookings b JOIN hotels h ON b.hotel_id=h.id WHERE h.city=? AND b.status IN ('confirmed','completed')", [$city])->getRowArray();

        $recentBookings = $db->query(
            "SELECT b.*, h.name AS hotel_name, u.first_name||' '||u.last_name AS guest_name
             FROM bookings b JOIN hotels h ON b.hotel_id=h.id JOIN users u ON b.user_id=u.id
             WHERE h.city = ? ORDER BY b.created_at DESC LIMIT 6",
            [$city]
        )->getResultArray();

        return view('admin/subadmin/dashboard', $this->viewData([
            'pageTitle'      => "Sub-Admin Dashboard — $city",
            'city'           => $city,
            'hotelCount'     => (int)$hotels['cnt'],
            'bookingCount'   => (int)$bookings['cnt'],
            'pendingCount'   => (int)$pending['cnt'],
            'brokerCount'    => (int)$brokers['cnt'],
            'revenue'        => (float)$revenue['total'],
            'recentBookings' => $recentBookings,
        ]));
    }

    // ── Hotels in city ────────────────────────────────────────────────────────
    public function hotels()
    {
        $search = $this->request->getGet('q') ?? '';
        $db     = \Config\Database::connect();
        $sql    = "SELECT h.*, COUNT(rt.id) AS room_count,
                          (SELECT image_url FROM hotel_images WHERE hotel_id=h.id AND is_primary=TRUE LIMIT 1) AS img
                   FROM hotels h LEFT JOIN room_types rt ON rt.hotel_id=h.id
                   WHERE h.city = ?";
        $binds  = [$this->city];
        if ($search) { $sql .= ' AND (h.name ILIKE ? OR h.address ILIKE ?)'; $binds[] = "%$search%"; $binds[] = "%$search%"; }
        $sql .= ' GROUP BY h.id ORDER BY h.name';
        $hotels = $db->query($sql, $binds)->getResultArray();

        return view('admin/subadmin/hotels', $this->viewData([
            'pageTitle' => "Hotels in {$this->city}",
            'hotels'    => $hotels,
            'city'      => $this->city,
            'search'    => $search,
        ]));
    }

    // ── Add Hotel ─────────────────────────────────────────────────────────────
    public function addHotel()
    {
        if ($this->request->getMethod() === 'POST') {
            $d   = $this->request->getPost();
            $db  = \Config\Database::connect();
            $res = $db->query(
                "INSERT INTO hotels (name, city, address, description, type, price_per_night, latitude, longitude, is_active, is_featured)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE, FALSE) RETURNING id",
                [$d['name'], $this->city, $d['address'], $d['description'] ?? '', $d['type'] ?? 'Hotel',
                 (float)($d['price_per_night'] ?? 0), (float)($d['latitude'] ?? 0), (float)($d['longitude'] ?? 0)]
            )->getRowArray();
            $hotelId = (int)($res['id'] ?? 0);

            // Add primary image if provided
            if (!empty($d['image_url'])) {
                $db->query('INSERT INTO hotel_images (hotel_id, image_url, sort_order, is_primary) VALUES (?,?,0,TRUE)',
                    [$hotelId, $d['image_url']]);
            }
            return redirect()->to('/admin/subadmin/hotels')->with('success', 'Hotel added successfully.');
        }
        return view('admin/subadmin/hotel_form', $this->viewData([
            'pageTitle' => 'Add Hotel',
            'city'      => $this->city,
            'hotel'     => null,
            'hotelTypes'=> ['Hotel','Resort','Lodge','Guest House','Boutique'],
        ]));
    }

    // ── Edit Hotel ────────────────────────────────────────────────────────────
    public function editHotel(int $id)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT * FROM hotels WHERE id = ? AND city = ? LIMIT 1', [$id, $this->city])->getRowArray();
        if (!$hotel) return redirect()->to('/admin/subadmin/hotels')->with('error', 'Hotel not found.');

        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            $db->query(
                "UPDATE hotels SET name=?, address=?, description=?, type=?, price_per_night=?, latitude=?, longitude=?, updated_at=NOW() WHERE id=?",
                [$d['name'], $d['address'], $d['description']??'', $d['type']??'Hotel',
                 (float)($d['price_per_night']??0), (float)($d['latitude']??0), (float)($d['longitude']??0), $id]
            );
            if (!empty($d['image_url'])) {
                $db->query('UPDATE hotel_images SET image_url=? WHERE hotel_id=? AND is_primary=TRUE', [$d['image_url'], $id]);
                $rows = $db->query('SELECT id FROM hotel_images WHERE hotel_id=? AND is_primary=TRUE', [$id])->getResultArray();
                if (empty($rows)) $db->query('INSERT INTO hotel_images (hotel_id,image_url,sort_order,is_primary) VALUES (?,?,0,TRUE)', [$id,$d['image_url']]);
            }
            return redirect()->to('/admin/subadmin/hotels')->with('success', 'Hotel updated.');
        }

        $hotel['images'] = $db->query('SELECT image_url FROM hotel_images WHERE hotel_id=? ORDER BY sort_order', [$id])->getResultArray();
        return view('admin/subadmin/hotel_form', $this->viewData([
            'pageTitle' => 'Edit Hotel',
            'city'      => $this->city,
            'hotel'     => $hotel,
            'hotelTypes'=> ['Hotel','Resort','Lodge','Guest House','Boutique'],
        ]));
    }

    // ── Delete Hotel ──────────────────────────────────────────────────────────
    public function deleteHotel(int $id)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT id FROM hotels WHERE id=? AND city=?', [$id,$this->city])->getRowArray();
        if (!$hotel) return redirect()->to('/admin/subadmin/hotels')->with('error', 'Not found.');
        $db->query('UPDATE hotels SET is_active=FALSE WHERE id=?', [$id]);
        return redirect()->to('/admin/subadmin/hotels')->with('success', 'Hotel deactivated.');
    }

    // ── Rooms in a hotel ──────────────────────────────────────────────────────
    public function rooms(int $hotelId)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT * FROM hotels WHERE id=? AND city=?', [$hotelId,$this->city])->getRowArray();
        if (!$hotel) return redirect()->to('/admin/subadmin/hotels')->with('error', 'Not found.');

        $search = $this->request->getGet('q') ?? '';
        $rooms  = $this->managerModel->getRooms($hotelId, $search);
        foreach ($rooms as &$r) {
            $r['is_available'] = ($r['is_available'] === 't' || $r['is_available'] === true);
        }
        unset($r);

        return view('admin/subadmin/rooms', $this->viewData([
            'pageTitle' => "Rooms — {$hotel['name']}",
            'hotel'     => $hotel,
            'rooms'     => $rooms,
            'search'    => $search,
        ]));
    }

    // ── Add Room ──────────────────────────────────────────────────────────────
    public function addRoom(int $hotelId)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT * FROM hotels WHERE id=? AND city=?', [$hotelId,$this->city])->getRowArray();
        if (!$hotel) return redirect()->to('/admin/subadmin/hotels')->with('error', 'Not found.');

        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            if (empty($d['name']) || empty($d['bed_type']) || empty($d['price_per_night'])) {
                return redirect()->back()->withInput()->with('error', 'Name, bed type and price are required.');
            }
            $features = array_filter(array_map('trim', explode(',', $d['features'] ?? '')));
            $this->managerModel->addRoom([
                'hotel_id'        => $hotelId,
                'name'            => $d['name'],
                'bed_type'        => $d['bed_type'],
                'image_url'       => $d['image_url'] ?? null,
                'price_per_night' => $d['price_per_night'],
                'size_sqm'        => $d['size_sqm'] ?? 0,
                'max_guests'      => $d['max_guests'] ?? 2,
                'features'        => $features,
            ]);
            return redirect()->to("/admin/subadmin/hotels/$hotelId/rooms")->with('success', 'Room added successfully.');
        }
        return view('admin/subadmin/room_form', $this->viewData([
            'pageTitle' => 'Add Room',
            'hotel'     => $hotel,
            'room'      => null,
        ]));
    }

    // ── Edit Room ─────────────────────────────────────────────────────────────
    public function editRoom(int $hotelId, int $roomId)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT * FROM hotels WHERE id=? AND city=?', [$hotelId,$this->city])->getRowArray();
        $room  = $this->managerModel->getRoom($roomId);
        if (!$hotel || !$room) return redirect()->back()->with('error', 'Not found.');

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
            return redirect()->to("/admin/subadmin/hotels/$hotelId/rooms")->with('success', 'Room updated.');
        }

        // Parse features array
        $room['features_str'] = '';
        if (!empty($room['features'])) {
            $f = trim($room['features'], '{}');
            $room['features_str'] = str_replace('"', '', $f);
        }
        return view('admin/subadmin/room_form', $this->viewData([
            'pageTitle' => 'Edit Room',
            'hotel'     => $hotel,
            'room'      => $room,
        ]));
    }

    // ── Delete Room ───────────────────────────────────────────────────────────
    public function deleteRoom(int $hotelId, int $roomId)
    {
        $this->managerModel->deleteRoom($roomId);
        return redirect()->to("/admin/subadmin/hotels/$hotelId/rooms")->with('success', 'Room deleted.');
    }

    // ── Toggle room availability ──────────────────────────────────────────────
    public function toggleRoom(int $hotelId, int $roomId)
    {
        $this->managerModel->toggleRoomAvailability($roomId);
        return redirect()->to("/admin/subadmin/hotels/$hotelId/rooms")->with('success', 'Room availability updated.');
    }

    // ── Bookings in city ──────────────────────────────────────────────────────
    public function bookings()
    {
        $status = $this->request->getGet('status') ?? '';
        $db     = \Config\Database::connect();
        $sql    = "SELECT b.*, h.name AS hotel_name, u.first_name||' '||u.last_name AS guest_name, u.email AS guest_email
                   FROM bookings b JOIN hotels h ON b.hotel_id=h.id JOIN users u ON b.user_id=u.id
                   WHERE h.city = ?";
        $binds  = [$this->city];
        if ($status) { $sql .= ' AND b.status = ?'; $binds[] = $status; }
        $sql .= ' ORDER BY b.created_at DESC LIMIT 100';
        $bookings = $db->query($sql, $binds)->getResultArray();

        $countRow = $db->query(
            "SELECT
               SUM(CASE WHEN b.status='pending'   THEN 1 ELSE 0 END) AS pending,
               SUM(CASE WHEN b.status='confirmed' THEN 1 ELSE 0 END) AS confirmed,
               SUM(CASE WHEN b.status='cancelled' THEN 1 ELSE 0 END) AS cancelled,
               SUM(CASE WHEN b.status='completed' THEN 1 ELSE 0 END) AS completed,
               COUNT(*) AS total
             FROM bookings b JOIN hotels h ON b.hotel_id=h.id WHERE h.city=?",
            [$this->city]
        )->getRowArray();

        return view('admin/subadmin/bookings', $this->viewData([
            'pageTitle' => "Bookings — {$this->city}",
            'bookings'  => $bookings,
            'counts'    => $countRow,
            'status'    => $status,
            'city'      => $this->city,
        ]));
    }

    // ── Brokers management ────────────────────────────────────────────────────
    public function brokers()
    {
        $brokers = $this->brokerModel->getBySubAdmin($this->adminId);
        return view('admin/subadmin/brokers', $this->viewData([
            'pageTitle' => 'My Brokers',
            'brokers'   => $brokers,
            'city'      => $this->city,
        ]));
    }

    public function createBroker()
    {
        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            if (empty($d['full_name']) || empty($d['email']) || empty($d['password'])) {
                return redirect()->back()->withInput()->with('error', 'All fields are required.');
            }
            if ($this->adminModel->findByEmail($d['email'])) {
                return redirect()->back()->withInput()->with('error', 'Email already exists.');
            }
            $d['role'] = 'broker';
            $newId = $this->adminModel->createAdmin($d, $this->adminId);
            if ($newId) {
                \Config\Database::connect()->query(
                    'INSERT INTO brokers (admin_id, sub_admin_id, city, commission_pct) VALUES (?,?,?,?)',
                    [$newId, $this->adminId, $this->city, (float)($d['commission_pct'] ?? 0)]
                );
                return redirect()->to('/admin/subadmin/brokers')->with('success', 'Broker created successfully.');
            }
            return redirect()->back()->with('error', 'Failed to create broker.');
        }
        return view('admin/subadmin/broker_form', $this->viewData([
            'pageTitle' => 'Create Broker',
            'broker'    => null,
            'city'      => $this->city,
        ]));
    }

    public function editBroker(int $id)
    {
        $broker = $this->brokerModel->getByAdminId($id);
        if (!$broker || $broker['sub_admin_id'] != $this->adminId) {
            return redirect()->to('/admin/subadmin/brokers')->with('error', 'Not found.');
        }
        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            $this->adminModel->update($id, ['full_name'=>$d['full_name'],'phone'=>$d['phone'],'status'=>$d['status']]);
            \Config\Database::connect()->query('UPDATE brokers SET commission_pct=? WHERE admin_id=?', [(float)($d['commission_pct']??0), $id]);
            return redirect()->to('/admin/subadmin/brokers')->with('success', 'Broker updated.');
        }
        return view('admin/subadmin/broker_form', $this->viewData([
            'pageTitle' => 'Edit Broker',
            'broker'    => $broker,
            'city'      => $this->city,
        ]));
    }

    public function deleteBroker(int $id)
    {
        $this->adminModel->update($id, ['status' => 'inactive']);
        return redirect()->to('/admin/subadmin/brokers')->with('success', 'Broker deactivated.');
    }

    // ── Assign Hotel Manager ──────────────────────────────────────────────────
    public function assignManager(int $hotelId)
    {
        $db     = \Config\Database::connect();
        $hotel  = $db->query('SELECT id,name FROM hotels WHERE id=? AND city=?', [$hotelId,$this->city])->getRowArray();
        if (!$hotel) return redirect()->back()->with('error', 'Hotel not found.');

        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            if (empty($d['full_name']) || empty($d['email']) || empty($d['password'])) {
                return redirect()->back()->withInput()->with('error', 'All fields are required.');
            }
            $d['role'] = 'hotel_manager';
            $newId = $this->adminModel->createAdmin($d, $this->adminId);
            if ($newId) {
                $brokerId = !empty($d['broker_id']) ? (int)$d['broker_id'] : null;
                $this->managerModel->assignManager($newId, $hotelId, $brokerId, $this->adminId);
                if ($brokerId) {
                    $brokerRow = $db->query('SELECT id FROM brokers WHERE admin_id=?', [$brokerId])->getRowArray();
                    if ($brokerRow) $this->brokerModel->linkHotel($brokerRow['id'], $hotelId);
                }
            }
            return redirect()->to('/admin/subadmin/hotels')->with('success', 'Hotel manager assigned.');
        }

        $brokers = $this->brokerModel->getBySubAdmin($this->adminId);
        return view('admin/subadmin/assign_manager', $this->viewData([
            'pageTitle' => "Assign Manager — {$hotel['name']}",
            'hotel'     => $hotel,
            'brokers'   => $brokers,
        ]));
    }
}
