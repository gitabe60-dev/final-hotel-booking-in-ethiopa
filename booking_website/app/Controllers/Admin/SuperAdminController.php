<?php

namespace App\Controllers\Admin;

use App\Models\HotelModel;
use App\Models\BookingModel;
use App\Models\UserModel;
use App\Models\CityModel;

class SuperAdminController extends BaseAdminController
{
    private HotelModel   $hotelModel;
    private BookingModel $bookingModel;
    private UserModel    $userModel;
    private CityModel    $cityModel;

    public function __construct()
    {
        parent::__construct();
        $this->hotelModel   = new HotelModel();
        $this->bookingModel = new BookingModel();
        $this->userModel    = new UserModel();
        $this->cityModel    = new CityModel();
    }

    // ── Dashboard ─────────────────────────────────────────────────────────────
    public function dashboard()
    {
        $overview   = $this->adminModel->getOverview();
        $subAdmins  = $this->adminModel->getSubAdminsWithCities();
        $recentBk   = $this->db()->query(
            "SELECT b.*, h.name AS hotel_name, h.city AS hotel_city,
                    u.first_name||' '||u.last_name AS guest_name
             FROM bookings b JOIN hotels h ON b.hotel_id=h.id JOIN users u ON b.user_id=u.id
             ORDER BY b.created_at DESC LIMIT 8"
        )->getResultArray();

        return view('admin/super/dashboard', $this->viewData([
            'pageTitle' => 'Super Admin Dashboard',
            'overview'  => $overview,
            'subAdmins' => $subAdmins,
            'recentBk'  => $recentBk,
        ]));
    }

    // ── Sub-Admin CRUD ────────────────────────────────────────────────────────
    public function subAdmins()
    {
        $search    = $this->request->getGet('q') ?? '';
        $subAdmins = $this->adminModel->getSubAdminsWithCities();
        if ($search) {
            $subAdmins = array_filter($subAdmins, fn($a) =>
                stripos($a['full_name'], $search) !== false ||
                stripos($a['email'],     $search) !== false
            );
        }
        return view('admin/super/sub_admins', $this->viewData([
            'pageTitle' => 'Manage Sub-Admins',
            'subAdmins' => array_values($subAdmins),
            'search'    => $search,
            'cities'    => $this->cities(),
        ]));
    }

    public function createSubAdmin()
    {
        if ($this->request->getMethod() === 'POST') {
            $data = $this->request->getPost();
            if (empty($data['full_name']) || empty($data['email']) || empty($data['password'])) {
                return redirect()->back()->withInput()->with('error', 'Name, email and password are required.');
            }
            if ($this->adminModel->findByEmail($data['email'])) {
                return redirect()->back()->withInput()->with('error', 'Email already exists.');
            }
            $data['role'] = 'sub_admin';
            $newId = $this->adminModel->createAdmin($data, $this->adminId);
            if ($newId && !empty($data['city'])) {
                $this->adminModel->assignCity($newId, $data['city'], $this->adminId);
            }
            return redirect()->to('/admin/super/sub-admins')->with('success', 'Sub-admin created successfully.');
        }
        return view('admin/super/create_sub_admin', $this->viewData([
            'pageTitle' => 'Create Sub-Admin',
            'cities'    => $this->cities(),
        ]));
    }

    public function editSubAdmin(int $id)
    {
        $admin = $this->db()->query('SELECT * FROM admin_users WHERE id = ? AND role = ?', [$id,'sub_admin'])->getRowArray();
        if (!$admin) return redirect()->to('/admin/super/sub-admins')->with('error', 'Sub-admin not found.');

        if ($this->request->getMethod() === 'POST') {
            $data = $this->request->getPost();
            $upd  = ['full_name' => $data['full_name'], 'email' => $data['email'], 'phone' => $data['phone'], 'status' => $data['status']];
            if (!empty($data['password'])) $upd['password_hash'] = $this->adminModel->hashPassword($data['password']);
            $this->adminModel->update($id, $upd);

            // Update city assignment
            $this->db()->query('DELETE FROM admin_city_assignments WHERE admin_id = ?', [$id]);
            if (!empty($data['city'])) $this->adminModel->assignCity($id, $data['city'], $this->adminId);

            return redirect()->to('/admin/super/sub-admins')->with('success', 'Sub-admin updated.');
        }

        $admin['cities'] = $this->adminModel->getCities($id);
        return view('admin/super/edit_sub_admin', $this->viewData([
            'pageTitle' => 'Edit Sub-Admin',
            'admin'     => $admin,
            'cities'    => $this->cities(),
        ]));
    }

    public function deleteSubAdmin(int $id)
    {
        $this->adminModel->update($id, ['status' => 'inactive']);
        return redirect()->to('/admin/super/sub-admins')->with('success', 'Sub-admin deactivated.');
    }

    // ── Assign City ───────────────────────────────────────────────────────────
    public function assignCity(int $adminId)
    {
        $city = $this->request->getPost('city');
        if ($city) $this->adminModel->assignCity($adminId, $city, $this->adminId);
        return redirect()->back()->with('success', "City '$city' assigned.");
    }

    public function revokeCity(int $adminId, string $city)
    {
        $this->adminModel->revokeCity($adminId, urldecode($city));
        return redirect()->back()->with('success', 'City assignment removed.');
    }

    // ── All Hotels ────────────────────────────────────────────────────────────
    public function hotels()
    {
        $search = $this->request->getGet('q') ?? '';
        $city   = $this->request->getGet('city') ?? '';
        $sql    = "SELECT h.*, COUNT(rt.id) AS room_count,
                          (SELECT image_url FROM hotel_images WHERE hotel_id=h.id AND is_primary=TRUE LIMIT 1) AS img
                   FROM hotels h LEFT JOIN room_types rt ON rt.hotel_id=h.id";
        $where  = []; $binds = [];
        if ($search) { $where[] = '(h.name ILIKE ? OR h.address ILIKE ?)'; $binds[] = "%$search%"; $binds[] = "%$search%"; }
        if ($city)   { $where[] = 'h.city = ?'; $binds[] = $city; }
        if ($where)  $sql .= ' WHERE ' . implode(' AND ', $where);
        $sql .= ' GROUP BY h.id ORDER BY h.city, h.name';
        $hotels = $this->db()->query($sql, $binds)->getResultArray();

        return view('admin/super/hotels', $this->viewData([
            'pageTitle' => 'All Hotels',
            'hotels'    => $hotels,
            'search'    => $search,
            'cityFilter'=> $city,
            'cities'    => $this->cities(),
        ]));
    }

    // ── All Bookings ──────────────────────────────────────────────────────────
    public function bookings()
    {
        $status = $this->request->getGet('status') ?? '';
        $sql    = "SELECT b.*, h.name AS hotel_name, h.city,
                          u.first_name||' '||u.last_name AS guest_name, u.email AS guest_email
                   FROM bookings b JOIN hotels h ON b.hotel_id=h.id JOIN users u ON b.user_id=u.id";
        $binds  = [];
        if ($status) { $sql .= ' WHERE b.status = ?'; $binds[] = $status; }
        $sql .= ' ORDER BY b.created_at DESC LIMIT 100';
        $bookings = $this->db()->query($sql, $binds)->getResultArray();
        $counts   = $this->db()->query(
            "SELECT status, COUNT(*) AS cnt FROM bookings GROUP BY status"
        )->getResultArray();
        $countMap = [];
        foreach ($counts as $c) $countMap[$c['status']] = $c['cnt'];

        return view('admin/super/bookings', $this->viewData([
            'pageTitle' => 'All Bookings',
            'bookings'  => $bookings,
            'counts'    => $countMap,
            'status'    => $status,
        ]));
    }

    // ── All Users ─────────────────────────────────────────────────────────────
    public function users()
    {
        $search = $this->request->getGet('q') ?? '';
        $sql    = "SELECT u.*, COUNT(b.id) AS booking_count
                   FROM users u LEFT JOIN bookings b ON b.user_id=u.id";
        $binds  = [];
        if ($search) {
            $sql   .= ' WHERE (u.email ILIKE ? OR u.first_name ILIKE ? OR u.phone ILIKE ?)';
            $binds  = ["%$search%", "%$search%", "%$search%"];
        }
        $sql .= ' GROUP BY u.id ORDER BY u.registered_date DESC LIMIT 100';
        $users = $this->db()->query($sql, $binds)->getResultArray();

        return view('admin/super/users', $this->viewData([
            'pageTitle' => 'All Guests',
            'users'     => $users,
            'search'    => $search,
        ]));
    }

    // ── All Brokers (view across cities) ─────────────────────────────────────
    public function brokers()
    {
        $brokers = $this->brokerModel->getAll();
        return view('admin/super/brokers', $this->viewData([
            'pageTitle' => 'All Brokers',
            'brokers'   => $brokers,
        ]));
    }

    // ── All Hotel Managers ────────────────────────────────────────────────────
    public function managers()
    {
        $managers = $this->managerModel->getAll();
        return view('admin/super/managers', $this->viewData([
            'pageTitle' => 'Hotel Managers',
            'managers'  => $managers,
        ]));
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private function db() { return \Config\Database::connect(); }
    private function cities(): array
    {
        return $this->cityModel->getNames();
    }

    // ── City management ───────────────────────────────────────────────────────

    public function citiesPage()
    {
        $cities = $this->cityModel->getAll();
        return view('admin/super/cities', $this->viewData([
            'pageTitle' => 'Manage Cities',
            'cities'    => $cities,
            'active'    => 'cities',
        ]));
    }

    public function addCity()
    {
        if ($this->request->getMethod() !== 'POST') {
            return redirect()->to('/admin/super/cities');
        }
        $name   = trim($this->request->getPost('city_name') ?? '');
        $region = trim($this->request->getPost('region')    ?? '');

        if (!$name) {
            return redirect()->back()->with('error', 'City name is required.');
        }
        $id = $this->cityModel->addCity($name, $region);
        if ($id) {
            return redirect()->to('/admin/super/cities')->with('success', "City '$name' added successfully.");
        }
        return redirect()->back()->with('error', 'Failed to add city.');
    }

    public function deleteCity(int $id)
    {
        $this->cityModel->deleteCity($id);
        return redirect()->to('/admin/super/cities')->with('success', 'City removed.');
    }

    // ── Add Hotel (super admin can add hotel for any city) ────────────────────

    public function addHotel()
    {
        $cities = $this->cityModel->getActive();
        if ($this->request->getMethod() === 'POST') {
            $d  = $this->request->getPost();
            $db = $this->db();

            if (empty($d['name']) || empty($d['city']) || empty($d['price_per_night'])) {
                return redirect()->back()->withInput()->with('error', 'Name, city and price are required.');
            }

            // Ensure the city exists in cities table
            $this->cityModel->addCity($d['city']);

            $res = $db->query(
                "INSERT INTO hotels (name, city, address, description, type, price_per_night,
                                     latitude, longitude, is_active, is_featured)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE, ?)
                 RETURNING id",
                [
                    trim($d['name']),
                    trim($d['city']),
                    trim($d['address'] ?? ''),
                    trim($d['description'] ?? ''),
                    $d['type'] ?? 'Hotel',
                    (float)($d['price_per_night']),
                    (float)($d['latitude']  ?? 0),
                    (float)($d['longitude'] ?? 0),
                    isset($d['is_featured']) ? 'TRUE' : 'FALSE',
                ]
            )->getRowArray();

            if (!$res) {
                return redirect()->back()->withInput()->with('error', 'Failed to add hotel.');
            }
            $hotelId = (int)$res['id'];

            // Add primary image
            if (!empty($d['image_url'])) {
                $db->query(
                    'INSERT INTO hotel_images (hotel_id, image_url, sort_order, is_primary) VALUES (?,?,0,TRUE)',
                    [$hotelId, $d['image_url']]
                );
            }

            // Add amenities
            if (!empty($d['amenities'])) {
                foreach (array_filter(array_map('trim', explode(',', $d['amenities']))) as $am) {
                    $db->query('INSERT INTO hotel_amenities (hotel_id, amenity) VALUES (?,?)', [$hotelId, $am]);
                }
            }

            return redirect()->to('/admin/super/hotels')
                ->with('success', "Hotel '{$d['name']}' added to {$d['city']} and is now live on the website!");
        }

        return view('admin/super/add_hotel', $this->viewData([
            'pageTitle'  => 'Add New Hotel',
            'cities'     => $cities,
            'hotelTypes' => ['Hotel','Resort','Lodge','Guest House','Boutique','Hostel'],
            'active'     => 'hotels',
        ]));
    }

    // ── Edit Hotel ────────────────────────────────────────────────────────────

    public function editHotel(int $id)
    {
        $db    = $this->db();
        $hotel = $db->query('SELECT * FROM hotels WHERE id=? LIMIT 1', [$id])->getRowArray();
        if (!$hotel) return redirect()->to('/admin/super/hotels')->with('error', 'Hotel not found.');

        $cities = $this->cityModel->getActive();

        if ($this->request->getMethod() === 'POST') {
            $d = $this->request->getPost();
            if (!empty($d['city'])) $this->cityModel->addCity($d['city']);

            $db->query(
                "UPDATE hotels SET name=?, city=?, address=?, description=?, type=?,
                 price_per_night=?, latitude=?, longitude=?,
                 is_featured=?, updated_at=NOW() WHERE id=?",
                [
                    $d['name'], $d['city'], $d['address']??'', $d['description']??'',
                    $d['type']??'Hotel', (float)($d['price_per_night']??0),
                    (float)($d['latitude']??0), (float)($d['longitude']??0),
                    isset($d['is_featured']) ? 'TRUE' : 'FALSE', $id,
                ]
            );
            if (!empty($d['image_url'])) {
                $db->query('UPDATE hotel_images SET image_url=? WHERE hotel_id=? AND is_primary=TRUE', [$d['image_url'],$id]);
                $has = $db->query('SELECT id FROM hotel_images WHERE hotel_id=? AND is_primary=TRUE LIMIT 1', [$id])->getRowArray();
                if (!$has) $db->query('INSERT INTO hotel_images (hotel_id,image_url,sort_order,is_primary) VALUES (?,?,0,TRUE)', [$id,$d['image_url']]);
            }
            return redirect()->to('/admin/super/hotels')->with('success', 'Hotel updated.');
        }

        $hotel['img'] = $db->query('SELECT image_url FROM hotel_images WHERE hotel_id=? AND is_primary=TRUE LIMIT 1', [$id])->getRowArray()['image_url'] ?? '';
        return view('admin/super/add_hotel', $this->viewData([
            'pageTitle'  => 'Edit Hotel: '.esc($hotel['name']),
            'cities'     => $cities,
            'hotelTypes' => ['Hotel','Resort','Lodge','Guest House','Boutique','Hostel'],
            'hotel'      => $hotel,
            'active'     => 'hotels',
        ]));
    }

    // ── Toggle hotel active/featured ──────────────────────────────────────────

    public function toggleHotel(int $id)
    {
        $db    = $this->db();
        $hotel = $db->query('SELECT is_active FROM hotels WHERE id=? LIMIT 1', [$id])->getRowArray();
        if (!$hotel) return redirect()->back()->with('error', 'Not found.');
        $new = ($hotel['is_active']==='t'||$hotel['is_active']===true) ? 'FALSE' : 'TRUE';
        $db->query("UPDATE hotels SET is_active=$new, updated_at=NOW() WHERE id=?", [$id]);
        return redirect()->back()->with('success', 'Hotel status updated.');
    }
}
