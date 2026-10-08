<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= esc($pageTitle ?? 'Admin Panel') ?> — DallolBooking</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<style>
:root{--admin-primary:#1a56db;--admin-dark:#0f172a;--admin-sidebar:#1e293b;--admin-hover:#334155;--radius:12px}
*{font-family:'Inter',sans-serif;box-sizing:border-box}
body{background:#f1f5f9;margin:0}
/* Sidebar */
.admin-sidebar{width:240px;min-height:100vh;background:var(--admin-sidebar);position:fixed;top:0;left:0;z-index:100;display:flex;flex-direction:column;transition:.3s}
.admin-sidebar .brand{padding:1.25rem 1.5rem;border-bottom:1px solid rgba(255,255,255,.08);display:flex;align-items:center;gap:10px}
.admin-sidebar .brand-icon{width:36px;height:36px;border-radius:10px;background:linear-gradient(135deg,#f59e0b,#ef4444);display:flex;align-items:center;justify-content:center}
.admin-sidebar .brand-text{font-weight:900;font-size:1.1rem;color:#fff}
.admin-sidebar .brand-role{font-size:.7rem;color:#64748b;text-transform:uppercase;letter-spacing:.08em}
.sidebar-nav{padding:1rem .75rem;flex:1;overflow-y:auto}
.sidebar-section{font-size:.68rem;font-weight:700;color:#475569;text-transform:uppercase;letter-spacing:.1em;padding:.75rem .75rem .25rem;margin-top:.5rem}
.sidebar-link{display:flex;align-items:center;gap:10px;padding:.65rem .9rem;border-radius:10px;color:#94a3b8;text-decoration:none;font-size:.88rem;font-weight:500;transition:.2s;margin-bottom:2px;position:relative}
.sidebar-link:hover{background:var(--admin-hover);color:#fff}
.sidebar-link.active{background:var(--admin-primary);color:#fff;box-shadow:0 4px 12px rgba(26,86,219,.35)}
.sidebar-link .badge-dot{position:absolute;top:8px;right:10px;background:#ef4444;color:#fff;border-radius:50px;font-size:.65rem;padding:.15rem .45rem;font-weight:700}
/* Top bar */
.admin-topbar{margin-left:240px;height:60px;background:#fff;border-bottom:1px solid #e2e8f0;display:flex;align-items:center;justify-content:space-between;padding:0 1.5rem;position:sticky;top:0;z-index:99}
.admin-topbar .page-title{font-weight:800;font-size:1.1rem;color:#0f172a}
/* Main content */
.admin-main{margin-left:240px;padding:1.5rem;min-height:calc(100vh - 60px)}
/* Cards */
.admin-card{background:#fff;border-radius:var(--radius);border:none;box-shadow:0 1px 3px rgba(0,0,0,.06);transition:.25s}
.admin-card:hover{box-shadow:0 4px 16px rgba(0,0,0,.1)}
/* Stat cards */
.stat-box{border-radius:var(--radius);padding:1.25rem;color:#fff;position:relative;overflow:hidden}
.stat-box::after{content:'';position:absolute;top:-20px;right:-20px;width:80px;height:80px;border-radius:50%;background:rgba(255,255,255,.12)}
/* Tables */
.admin-table{width:100%;border-collapse:separate;border-spacing:0}
.admin-table th{background:#f8fafc;font-size:.78rem;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:#64748b;padding:.75rem 1rem;border-bottom:2px solid #e2e8f0}
.admin-table td{padding:.75rem 1rem;border-bottom:1px solid #f1f5f9;font-size:.88rem;vertical-align:middle}
.admin-table tr:last-child td{border-bottom:none}
.admin-table tbody tr:hover{background:#f8fafc}
/* Badges */
.role-badge{padding:.3em .75em;border-radius:50px;font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.05em}
.role-super{background:#fef3c7;color:#92400e}
.role-sub{background:#dbeafe;color:#1e40af}
.role-broker{background:#f0fdf4;color:#166534}
.role-manager{background:#fdf4ff;color:#6b21a8}
.status-active{background:#dcfce7;color:#15803d;padding:.25em .65em;border-radius:50px;font-size:.75rem;font-weight:700}
.status-suspended{background:#fee2e2;color:#b91c1c;padding:.25em .65em;border-radius:50px;font-size:.75rem;font-weight:700}
.status-inactive{background:#f1f5f9;color:#64748b;padding:.25em .65em;border-radius:50px;font-size:.75rem;font-weight:700}
/* Booking status */
.bk-pending{background:#fef9c3;color:#a16207;padding:.25em .7em;border-radius:50px;font-size:.73rem;font-weight:700}
.bk-confirmed{background:#dcfce7;color:#15803d;padding:.25em .7em;border-radius:50px;font-size:.73rem;font-weight:700}
.bk-cancelled{background:#fee2e2;color:#b91c1c;padding:.25em .7em;border-radius:50px;font-size:.73rem;font-weight:700}
.bk-completed{background:#e0e7ff;color:#3730a3;padding:.25em .7em;border-radius:50px;font-size:.73rem;font-weight:700}
/* Forms */
.admin-form-card{background:#fff;border-radius:var(--radius);padding:1.75rem;box-shadow:0 1px 3px rgba(0,0,0,.06)}
.form-label{font-weight:600;font-size:.85rem;color:#374151}
.form-control,.form-select{border:2px solid #e2e8f0;border-radius:8px;font-size:.9rem;transition:.2s}
.form-control:focus,.form-select:focus{border-color:var(--admin-primary);box-shadow:0 0 0 3px rgba(26,86,219,.1)}
/* Alert flash */
.alert-flash{border-radius:10px;font-size:.88rem;font-weight:500}
/* Responsive */
@media(max-width:768px){.admin-sidebar{transform:translateX(-100%)}.admin-topbar,.admin-main{margin-left:0}}
/* Search bar */
.search-admin{max-width:300px}
/* Avatar */
.admin-avatar{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#1a56db,#7c3aed);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.85rem;color:#fff}
</style>
</head>
<body>

<!-- SIDEBAR -->
<aside class="admin-sidebar">
  <div class="brand">
    <div class="brand-icon"><i class="bi bi-compass-fill text-white"></i></div>
    <div>
      <div class="brand-text">Dallol<span style="color:#f59e0b">Admin</span></div>
      <div class="brand-role"><?= esc(str_replace('_',' ',($admin['role'] ?? ''))) ?></div>
    </div>
  </div>

  <nav class="sidebar-nav">
    <?php
    $role = $admin['role'] ?? '';
    $active = $active ?? '';

    // ─── SUPER ADMIN MENU ────────────────────────────────────────────
    if ($role === 'super_admin'):
    ?>
    <div class="sidebar-section">Overview</div>
    <a href="/admin/super/dashboard"    class="sidebar-link <?= $active==='dashboard'?'active':'' ?>"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>

    <div class="sidebar-section">Management</div>
    <a href="/admin/super/sub-admins"   class="sidebar-link <?= $active==='sub_admins'?'active':'' ?>"><i class="bi bi-person-badge-fill"></i> Sub-Admins</a>
    <a href="/admin/super/brokers"      class="sidebar-link <?= $active==='brokers'?'active':'' ?>"><i class="bi bi-people-fill"></i> Brokers</a>
    <a href="/admin/super/managers"     class="sidebar-link <?= $active==='managers'?'active':'' ?>"><i class="bi bi-building-gear"></i> Hotel Managers</a>

    <div class="sidebar-section">Data</div>
    <a href="/admin/super/hotels"       class="sidebar-link <?= $active==='hotels'?'active':'' ?>"><i class="bi bi-building-fill"></i> All Hotels</a>
    <a href="/admin/super/bookings"     class="sidebar-link <?= $active==='bookings'?'active':'' ?>"><i class="bi bi-calendar-check-fill"></i> All Bookings</a>
    <a href="/admin/super/users"        class="sidebar-link <?= $active==='users'?'active':'' ?>"><i class="bi bi-person-lines-fill"></i> All Guests</a>

    <?php
    // ─── SUB ADMIN MENU ───────────────────────────────────────────────
    elseif ($role === 'sub_admin'):
    ?>
    <div class="sidebar-section">City: <?= esc($admin['city'] ?? '') ?></div>
    <a href="/admin/subadmin/dashboard"    class="sidebar-link <?= $active==='dashboard'?'active':'' ?>"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>

    <div class="sidebar-section">Hotels</div>
    <a href="/admin/subadmin/hotels"       class="sidebar-link <?= $active==='hotels'?'active':'' ?>"><i class="bi bi-building-fill"></i> Manage Hotels</a>

    <div class="sidebar-section">People</div>
    <a href="/admin/subadmin/brokers"      class="sidebar-link <?= $active==='brokers'?'active':'' ?>"><i class="bi bi-people-fill"></i> Brokers</a>

    <div class="sidebar-section">Activity</div>
    <a href="/admin/subadmin/bookings"     class="sidebar-link <?= $active==='bookings'?'active':'' ?>"><i class="bi bi-calendar-check-fill"></i> Bookings</a>

    <?php
    // ─── BROKER MENU ─────────────────────────────────────────────────
    elseif ($role === 'broker'):
    ?>
    <div class="sidebar-section">Overview</div>
    <a href="/admin/broker/dashboard"   class="sidebar-link <?= $active==='dashboard'?'active':'' ?>"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>
    <a href="/admin/broker/hotels"      class="sidebar-link <?= $active==='hotels'?'active':'' ?>"><i class="bi bi-building-fill"></i> My Hotels</a>
    <a href="/admin/broker/bookings"    class="sidebar-link <?= $active==='bookings'?'active':'' ?>"><i class="bi bi-calendar-check-fill"></i> Bookings</a>

    <div class="sidebar-section">Messages</div>
    <a href="/admin/broker/inbox"       class="sidebar-link <?= $active==='inbox'?'active':'' ?>">
      <i class="bi bi-inbox-fill"></i> Inbox
      <?php if(($unreadCount??0)>0): ?><span class="badge-dot"><?= $unreadCount ?></span><?php endif; ?>
    </a>
    <a href="/admin/broker/sent"        class="sidebar-link <?= $active==='sent'?'active':'' ?>"><i class="bi bi-send-fill"></i> Sent</a>
    <a href="/admin/broker/compose"     class="sidebar-link <?= $active==='compose'?'active':'' ?>"><i class="bi bi-pencil-square"></i> Compose</a>

    <?php
    // ─── HOTEL MANAGER MENU ───────────────────────────────────────────
    elseif ($role === 'hotel_manager'):
    ?>
    <div class="sidebar-section">Hotel</div>
    <a href="/admin/manager/dashboard"  class="sidebar-link <?= $active==='dashboard'?'active':'' ?>"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>
    <a href="/admin/manager/hotel-info" class="sidebar-link <?= $active==='hotel_info'?'active':'' ?>"><i class="bi bi-info-circle-fill"></i> Hotel Info</a>

    <div class="sidebar-section">Rooms</div>
    <a href="/admin/manager/rooms"      class="sidebar-link <?= $active==='rooms'?'active':'' ?>"><i class="bi bi-door-open-fill"></i> Manage Rooms</a>
    <a href="/admin/manager/rooms/add"  class="sidebar-link <?= $active==='add_room'?'active':'' ?>"><i class="bi bi-plus-circle-fill"></i> Add Room</a>

    <div class="sidebar-section">Bookings</div>
    <a href="/admin/manager/bookings"   class="sidebar-link <?= $active==='bookings'?'active':'' ?>"><i class="bi bi-calendar-check-fill"></i> Bookings</a>

    <div class="sidebar-section">Messages</div>
    <a href="/admin/manager/inbox"      class="sidebar-link <?= $active==='inbox'?'active':'' ?>">
      <i class="bi bi-inbox-fill"></i> Inbox
      <?php if(($unreadCount??0)>0): ?><span class="badge-dot"><?= $unreadCount ?></span><?php endif; ?>
    </a>

    <?php endif; ?>

    <div class="sidebar-section">Account</div>
    <a href="/admin/profile"            class="sidebar-link"><i class="bi bi-person-circle"></i> Profile</a>
    <a href="/admin/logout"             class="sidebar-link text-danger"><i class="bi bi-box-arrow-right"></i> Logout</a>
  </nav>
</aside>

<!-- TOP BAR -->
<header class="admin-topbar">
  <div class="d-flex align-items-center gap-3">
    <button class="btn btn-sm d-md-none" onclick="document.querySelector('.admin-sidebar').style.transform='translateX(0)'"><i class="bi bi-list fs-5"></i></button>
    <span class="page-title"><?= esc($pageTitle ?? '') ?></span>
  </div>
  <div class="d-flex align-items-center gap-3">
    <!-- Unread badge -->
    <?php if(($unreadCount??0)>0): ?>
    <a href="/admin/<?= $role==='broker'?'broker':($role==='hotel_manager'?'manager':'') ?>/inbox" class="btn btn-sm position-relative" style="background:#fee2e2;color:#b91c1c;border-radius:50px">
      <i class="bi bi-envelope-fill"></i>
      <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size:.65rem"><?= $unreadCount ?></span>
    </a>
    <?php endif; ?>
    <a href="/" target="_blank" class="btn btn-sm btn-outline-secondary rounded-pill"><i class="bi bi-globe me-1"></i>Website</a>
    <div class="dropdown">
      <button class="btn btn-sm d-flex align-items-center gap-2 rounded-pill" style="background:#f1f5f9" data-bs-toggle="dropdown">
        <div class="admin-avatar"><?= strtoupper(substr($admin['name'] ?? 'A', 0, 1)) ?></div>
        <span class="small fw-600 d-none d-sm-inline"><?= esc(explode(' ', $admin['name'] ?? 'Admin')[0]) ?></span>
      </button>
      <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg" style="border-radius:12px">
        <li><div class="px-3 py-2 border-bottom"><div class="fw-700 small"><?= esc($admin['name'] ?? '') ?></div><div class="text-muted" style="font-size:.75rem"><?= esc($admin['email'] ?? '') ?></div></div></li>
        <li><a class="dropdown-item py-2" href="/admin/profile"><i class="bi bi-person me-2 text-primary"></i>Profile</a></li>
        <li><a class="dropdown-item py-2" href="/admin/change-password"><i class="bi bi-key me-2 text-warning"></i>Change Password</a></li>
        <li><hr class="dropdown-divider my-1"></li>
        <li><a class="dropdown-item py-2 text-danger" href="/admin/logout"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
      </ul>
    </div>
  </div>
</header>

<!-- MAIN CONTENT -->
<main class="admin-main">
  <?php if(session()->getFlashdata('success')): ?>
  <div class="alert alert-success alert-flash alert-dismissible fade show mb-3" role="alert">
    <i class="bi bi-check-circle-fill me-2"></i><?= esc(session()->getFlashdata('success')) ?>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <?php endif; ?>
  <?php if(session()->getFlashdata('error')): ?>
  <div class="alert alert-danger alert-flash alert-dismissible fade show mb-3" role="alert">
    <i class="bi bi-exclamation-circle-fill me-2"></i><?= esc(session()->getFlashdata('error')) ?>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <?php endif; ?>

  <?= $this->renderSection('content') ?>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="/assets/js/dallol-validate.js"></script>
<?= $this->renderSection('scripts') ?>
</body>
</html>
