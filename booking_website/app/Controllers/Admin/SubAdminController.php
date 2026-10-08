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
        $managers = $db->query("SELECT COUNT(*) AS cnt FROM hotel_managers hm JOIN hotels h ON hm.hotel_id=h.id WHERE h.city=? AND hm.sub_admin_id=?", [$city, $this->adminId])->getRowArray();
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
            'managerCount'   => (int)$managers['cnt'],
            'revenue'        => (float)$revenue['total'],
            'recentBookings' => $recentBookings,
        ]));
    }

    // ── Hotels in city ────────────────────────────────────────────────────────
    public function hotels()
    {
        $search = $this->request->getGet('q') ?? '';
        $db     = \Config\Database::connect();

        // Include manager info + broker info per hotel
        $sql = "SELECT h.*,
                       COUNT(DISTINCT rt.id) AS room_count,
                       (SELECT image_url FROM hotel_images WHERE hotel_id=h.id AND is_primary=TRUE LIMIT 1) AS img,
                       mgr_au.full_name  AS manager_name,
                       mgr_au.email      AS manager_email,
                       mgr_au.phone      AS manager_phone,
                       brk_au.full_name  AS broker_name,
                       hm.id             AS hm_id
                FROM hotels h
                LEFT JOIN room_types rt ON rt.hotel_id=h.id
                LEFT JOIN hotel_managers hm ON hm.hotel_id=h.id
                LEFT JOIN admin_users mgr_au ON mgr_au.id=hm.admin_id
                LEFT JOIN brokers bk ON bk.id=hm.broker_id
                LEFT JOIN admin_users brk_au ON brk_au.id=bk.admin_id
                WHERE h.city = ?";
        $binds = [$this->city];
        if ($search) {
            $sql   .= ' AND (h.name ILIKE ? OR h.address ILIKE ?)';
            $binds[] = "%$search%";
            $binds[] = "%$search%";
        }
        $sql .= ' GROUP BY h.id, mgr_au.full_name, mgr_au.email, mgr_au.phone, brk_au.full_name, hm.id ORDER BY h.name';
        $hotels = $db->query($sql, $binds)->getResultArray();

        return view('admin/subadmin/hotels', $this->viewData([
            'pageTitle' => "Hotels in {$this->city}",
            'hotels'    => $hotels,
            'city'      => $this->city,
            'search'    => $search,
        ]));
    }

    // ── Add Hotel (with optional inline manager registration) ─────────────────
    public function addHotel()
    {
        $db      = \Config\Database::connect();
        $brokers = $this->brokerModel->getBySubAdmin($this->adminId);

        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();

            // ── 1. Validate hotel required fields ──────────────────────────
            if (empty($d['name']) || empty($d['address']) || empty($d['price_per_night'])) {
                return redirect()->back()->withInput()->with('error', 'Hotel name, address and price are required.');
            }

            // ── 2. Validate manager fields if provided ─────────────────────
            $hasManager = !empty($d['mgr_name']) || !empty($d['mgr_email']) || !empty($d['mgr_password']);
            if ($hasManager) {
                if (empty($d['mgr_name']) || empty($d['mgr_email']) || empty($d['mgr_password'])) {
                    return redirect()->back()->withInput()->with('error', 'Manager name, email and password are all required.');
                }
                if (strlen($d['mgr_password']) < 6) {
                    return redirect()->back()->withInput()->with('error', 'Manager password must be at least 6 characters.');
                }
                if ($this->adminModel->findByEmail($d['mgr_email'])) {
                    return redirect()->back()->withInput()->with('error', 'Manager email already exists. Use a different email.');
                }
            }

            // ── 3. Insert hotel ────────────────────────────────────────────
            $lat = $d['latitude']  !== '' && $d['latitude']  !== null ? (float)$d['latitude']  : 0.0;
            $lng = $d['longitude'] !== '' && $d['longitude'] !== null ? (float)$d['longitude'] : 0.0;
            // Clamp to valid geographic range (avoids NUMERIC(12,8) overflow)
            $lat = max(-90.0,  min(90.0,  $lat));
            $lng = max(-180.0, min(180.0, $lng));

            $res = $db->query(
                "INSERT INTO hotels (name, city, address, description, type, price_per_night, latitude, longitude, is_active, is_featured)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE, FALSE) RETURNING id",
                [
                    $d['name'], $this->city, $d['address'],
                    $d['description'] ?? '',
                    $d['type']        ?? 'Hotel',
                    (float)($d['price_per_night'] ?? 0),
                    $lat,
                    $lng,
                ]
            )->getRowArray();
            $hotelId = (int)($res['id'] ?? 0);

            if (!$hotelId) {
                return redirect()->back()->withInput()->with('error', 'Failed to create hotel. Please try again.');
            }

            // ── 4. Add primary image ───────────────────────────────────────
            if (!empty($d['image_url'])) {
                $db->query(
                    'INSERT INTO hotel_images (hotel_id, image_url, sort_order, is_primary) VALUES (?,?,0,TRUE)',
                    [$hotelId, $d['image_url']]
                );
            }

            // ── 5. Add amenities ───────────────────────────────────────────
            if (!empty($d['amenities'])) {
                foreach (array_filter(array_map('trim', explode(',', $d['amenities']))) as $a) {
                    $db->query('INSERT INTO hotel_amenities (hotel_id, amenity) VALUES (?,?)', [$hotelId, $a]);
                }
            }

            // ── 6. Create hotel manager account ───────────────────────────
            if ($hasManager) {
                $mgrId = $this->adminModel->createAdmin([
                    'full_name' => trim($d['mgr_name']),
                    'email'     => trim($d['mgr_email']),
                    'phone'     => $d['mgr_phone'] ?? null,
                    'password'  => $d['mgr_password'],
                    'role'      => 'hotel_manager',
                ], $this->adminId);

                if ($mgrId) {
                    $brokerId  = !empty($d['broker_id']) ? (int)$d['broker_id'] : null;
                    $this->managerModel->assignManager($mgrId, $hotelId, $brokerId, $this->adminId);

                    // Link broker ↔ hotel
                    if ($brokerId) {
                        $brokerRow = $db->query('SELECT id FROM brokers WHERE admin_id=? LIMIT 1', [$brokerId])->getRowArray();
                        if ($brokerRow) $this->brokerModel->linkHotel((int)$brokerRow['id'], $hotelId);
                    }

                    return redirect()->to('/admin/subadmin/hotels')
                        ->with('success', "Hotel '{$d['name']}' added and manager '{$d['mgr_name']}' registered. Login: {$d['mgr_email']}");
                }
            }

            return redirect()->to('/admin/subadmin/hotels')->with('success', "Hotel '{$d['name']}' added successfully.");
        }

        return view('admin/subadmin/hotel_form', $this->viewData([
            'pageTitle'  => 'Add Hotel',
            'city'       => $this->city,
            'hotel'      => null,
            'manager'    => null,
            'hotelTypes' => ['Hotel','Resort','Lodge','Guest House','Boutique','Hostel'],
            'brokers'    => $brokers,
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

            $lat = $d['latitude']  !== '' && $d['latitude']  !== null ? (float)$d['latitude']  : 0.0;
            $lng = $d['longitude'] !== '' && $d['longitude'] !== null ? (float)$d['longitude'] : 0.0;
            $lat = max(-90.0,  min(90.0,  $lat));
            $lng = max(-180.0, min(180.0, $lng));

            $db->query(
                "UPDATE hotels SET name=?, address=?, description=?, type=?, price_per_night=?, latitude=?, longitude=?, updated_at=NOW() WHERE id=?",
                [
                    $d['name'], $d['address'], $d['description'] ?? '',
                    $d['type'] ?? 'Hotel',
                    (float)($d['price_per_night'] ?? 0),
                    $lat,
                    $lng,
                    $id,
                ]
            );

            // Update primary image
            if (!empty($d['image_url'])) {
                $existing = $db->query('SELECT id FROM hotel_images WHERE hotel_id=? AND is_primary=TRUE', [$id])->getRowArray();
                if ($existing) {
                    $db->query('UPDATE hotel_images SET image_url=? WHERE hotel_id=? AND is_primary=TRUE', [$d['image_url'], $id]);
                } else {
                    $db->query('INSERT INTO hotel_images (hotel_id,image_url,sort_order,is_primary) VALUES (?,?,0,TRUE)', [$id, $d['image_url']]);
                }
            }

            return redirect()->to('/admin/subadmin/hotels')->with('success', 'Hotel updated successfully.');
        }

        $hotel['images']   = $db->query('SELECT image_url FROM hotel_images WHERE hotel_id=? ORDER BY sort_order', [$id])->getResultArray();
        $hotel['amenities']= $db->query('SELECT amenity FROM hotel_amenities WHERE hotel_id=? ORDER BY id', [$id])->getResultArray();
        $manager           = $db->query(
            "SELECT au.*, hm.broker_id, hm.id AS hm_id
             FROM hotel_managers hm
             JOIN admin_users au ON au.id=hm.admin_id
             WHERE hm.hotel_id=? LIMIT 1", [$id]
        )->getRowArray();
        $brokers = $this->brokerModel->getBySubAdmin($this->adminId);

        return view('admin/subadmin/hotel_form', $this->viewData([
            'pageTitle'  => 'Edit Hotel — ' . esc($hotel['name']),
            'city'       => $this->city,
            'hotel'      => $hotel,
            'manager'    => $manager,
            'hotelTypes' => ['Hotel','Resort','Lodge','Guest House','Boutique','Hostel'],
            'brokers'    => $brokers,
        ]));
    }

    // ── Delete Hotel ──────────────────────────────────────────────────────────
    public function deleteHotel(int $id)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT id FROM hotels WHERE id=? AND city=?', [$id, $this->city])->getRowArray();
        if (!$hotel) return redirect()->to('/admin/subadmin/hotels')->with('error', 'Not found.');
        $db->query('UPDATE hotels SET is_active=FALSE WHERE id=?', [$id]);
        return redirect()->to('/admin/subadmin/hotels')->with('success', 'Hotel deactivated.');
    }

    // ── Rooms in a hotel ──────────────────────────────────────────────────────
    public function rooms(int $hotelId)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT * FROM hotels WHERE id=? AND city=?', [$hotelId, $this->city])->getRowArray();
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
        $hotel = $db->query('SELECT * FROM hotels WHERE id=? AND city=?', [$hotelId, $this->city])->getRowArray();
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
                'size_sqm'        => $d['size_sqm']   ?? 0,
                'max_guests'      => $d['max_guests']  ?? 2,
                'features'        => $features,
            ]);
            return redirect()->to("/admin/subadmin/hotels/$hotelId/rooms")->with('success', 'Room added.');
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
        $hotel = $db->query('SELECT * FROM hotels WHERE id=? AND city=?', [$hotelId, $this->city])->getRowArray();
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
                'size_sqm'        => $d['size_sqm']   ?? 0,
                'max_guests'      => $d['max_guests']  ?? 2,
                'features'        => $features,
                'is_available'    => isset($d['is_available']),
            ]);
            return redirect()->to("/admin/subadmin/hotels/$hotelId/rooms")->with('success', 'Room updated.');
        }

        $room['features_str'] = '';
        if (!empty($room['features'])) {
            $room['features_str'] = str_replace('"', '', trim($room['features'], '{}'));
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

    // ── Managers list ─────────────────────────────────────────────────────────
    public function managers()
    {
        $managers = $this->managerModel->getBySubAdmin($this->adminId);
        return view('admin/subadmin/managers', $this->viewData([
            'pageTitle' => "Hotel Managers — {$this->city}",
            'managers'  => $managers,
            'city'      => $this->city,
        ]));
    }

    // ── Assign/Replace Hotel Manager ──────────────────────────────────────────
    public function assignManager(int $hotelId)
    {
        $db    = \Config\Database::connect();
        $hotel = $db->query('SELECT id,name FROM hotels WHERE id=? AND city=?', [$hotelId, $this->city])->getRowArray();
        if (!$hotel) return redirect()->back()->with('error', 'Hotel not found.');

        // Load existing manager for this hotel (if any)
        $existing = $db->query(
            "SELECT au.*, hm.broker_id, hm.id AS hm_id
             FROM hotel_managers hm
             JOIN admin_users au ON au.id=hm.admin_id
             WHERE hm.hotel_id=? LIMIT 1", [$hotelId]
        )->getRowArray();

        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();

            // Decide: create new OR reassign existing admin_user
            $mgrId = null;
            if (!empty($d['existing_manager_id'])) {
                // Reassign an existing manager
                $mgrId = (int)$d['existing_manager_id'];
            } else {
                // Create new manager account
                if (empty($d['full_name']) || empty($d['email']) || empty($d['password'])) {
                    return redirect()->back()->withInput()->with('error', 'Full name, email and password are required.');
                }
                if (strlen($d['password']) < 6) {
                    return redirect()->back()->withInput()->with('error', 'Password must be at least 6 characters.');
                }
                if ($this->adminModel->findByEmail($d['email'])) {
                    return redirect()->back()->withInput()->with('error', 'Email already exists.');
                }
                $mgrId = $this->adminModel->createAdmin([
                    'full_name' => trim($d['full_name']),
                    'email'     => trim($d['email']),
                    'phone'     => $d['phone'] ?? null,
                    'password'  => $d['password'],
                    'role'      => 'hotel_manager',
                ], $this->adminId);
            }

            if ($mgrId) {
                $brokerId  = !empty($d['broker_id']) ? (int)$d['broker_id'] : null;
                $this->managerModel->assignManager($mgrId, $hotelId, $brokerId, $this->adminId);
                if ($brokerId) {
                    $brokerRow = $db->query('SELECT id FROM brokers WHERE admin_id=? LIMIT 1', [$brokerId])->getRowArray();
                    if ($brokerRow) $this->brokerModel->linkHotel((int)$brokerRow['id'], $hotelId);
                }
                return redirect()->to('/admin/subadmin/hotels')
                    ->with('success', 'Hotel manager assigned to ' . esc($hotel['name']) . '.');
            }
            return redirect()->back()->with('error', 'Failed to assign manager.');
        }

        // Load all existing managers this sub-admin created (to allow reassignment)
        $allManagers = $db->query(
            "SELECT au.id, au.full_name, au.email
             FROM admin_users au
             JOIN hotel_managers hm ON hm.admin_id=au.id
             WHERE hm.sub_admin_id=? AND au.role='hotel_manager' AND au.status='active'
             ORDER BY au.full_name",
            [$this->adminId]
        )->getResultArray();

        $brokers = $this->brokerModel->getBySubAdmin($this->adminId);

        return view('admin/subadmin/assign_manager', $this->viewData([
            'pageTitle'   => "Assign Manager — {$hotel['name']}",
            'hotel'       => $hotel,
            'existing'    => $existing,
            'allManagers' => $allManagers,
            'brokers'     => $brokers,
            'city'        => $this->city,
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
            $newId = $this->adminModel->createAdmin(array_merge($d, ['role' => 'broker']), $this->adminId);
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
            $this->adminModel->update($id, ['full_name' => $d['full_name'], 'phone' => $d['phone'], 'status' => $d['status']]);
            \Config\Database::connect()->query(
                'UPDATE brokers SET commission_pct=? WHERE admin_id=?',
                [(float)($d['commission_pct'] ?? 0), $id]
            );
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
}
