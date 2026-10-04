<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= esc($pageTitle ?? 'Dashboard — Dallol Booking') ?></title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<link href="/assets/css/app.css" rel="stylesheet">
</head>
<body style="background:#f8fafc">

<div id="pageLoader" class="page-loader"><div class="loader-ring"></div></div>

<!-- Top Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark" style="position:sticky;top:0;z-index:1000">
  <div class="container-fluid px-4">
    <a class="navbar-brand d-flex align-items-center gap-2" href="/">
      <span style="background:linear-gradient(135deg,#f59e0b,#ef4444);border-radius:10px;width:32px;height:32px;display:flex;align-items:center;justify-content:center">
        <i class="bi bi-compass-fill text-white"></i>
      </span>
      <span class="fw-900">Dallol<span class="text-warning">Booking</span></span>
    </a>
    <div class="ms-auto d-flex align-items-center gap-3">
      <a href="/hotels" class="text-white text-decoration-none small d-none d-md-flex align-items-center gap-1"><i class="bi bi-search"></i>Find Hotels</a>
      <div class="dropdown">
        <button class="btn btn-sm d-flex align-items-center gap-2" style="background:rgba(255,255,255,.1);color:#fff;border-radius:50px;padding:.4rem .9rem" data-bs-toggle="dropdown">
          <span style="width:28px;height:28px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#ef4444);display:flex;align-items:center;justify-content:center;font-weight:900;font-size:.75rem;color:#fff">
            <?= strtoupper(substr(session()->get('user_name')??'U',0,1)) ?>
          </span>
          <span class="d-none d-sm-inline small fw-600"><?= esc(explode(' ',session()->get('user_name')??'')[0]) ?></span>
          <i class="bi bi-chevron-down" style="font-size:.7rem"></i>
        </button>
        <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg" style="border-radius:14px">
          <li><a class="dropdown-item py-2" href="/dashboard/profile"><i class="bi bi-person me-2 text-primary"></i>Profile</a></li>
          <li><hr class="dropdown-divider my-1"></li>
          <li><a class="dropdown-item py-2 text-danger" href="/logout"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
        </ul>
      </div>
    </div>
  </div>
</nav>

<div class="d-flex">
  <!-- Sidebar -->
  <aside class="sidebar d-none d-md-flex flex-column" style="width:240px;flex-shrink:0;padding:1.5rem 1rem">
    <?php
    $links = [
      ['dashboard','bi-grid-1x2-fill','Dashboard','/dashboard'],
      ['bookings','bi-calendar-check-fill','My Bookings','/dashboard/bookings'],
      ['wishlist','bi-heart-fill','Wishlist','/dashboard/wishlist'],
      ['profile','bi-person-circle','Profile','/dashboard/profile'],
    ];
    foreach($links as [$key,$icon,$label,$href]):
    ?>
    <a href="<?= $href ?>" class="sidebar-link <?= ($active??'')===$key?'active':'' ?>">
      <i class="bi <?= $icon ?> sidebar-icon"></i><?= $label ?>
      <?php if($key==='bookings' && isset($counts)): ?>
      <?php $tot=array_sum($counts??[]); if($tot): ?><span class="ms-auto badge rounded-pill bg-primary" style="font-size:.7rem"><?= $tot ?></span><?php endif; ?>
      <?php endif; ?>
    </a>
    <?php endforeach; ?>
    <hr class="my-3">
    <a href="/hotels" class="sidebar-link"><i class="bi bi-search sidebar-icon"></i>Find Hotels</a>
    <a href="/logout" class="sidebar-link text-danger mt-auto"><i class="bi bi-box-arrow-right sidebar-icon"></i>Logout</a>
  </aside>

  <!-- Main -->
  <main class="flex-grow-1 p-4" style="min-height:calc(100vh - 56px)">
    <?php if(session()->getFlashdata('success')): ?>
    <div class="alert alert-success alert-flash alert-dismissible fade show rounded-3 mb-3" role="alert">
      <i class="bi bi-check-circle-fill me-2"></i><?= esc(session()->getFlashdata('success')) ?>
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>
    <?php if(session()->getFlashdata('error')): ?>
    <div class="alert alert-danger alert-flash alert-dismissible fade show rounded-3 mb-3" role="alert">
      <i class="bi bi-exclamation-circle-fill me-2"></i><?= esc(session()->getFlashdata('error')) ?>
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <?= $this->renderSection('content') ?>
  </main>
</div>

<!-- Mobile bottom nav -->
<nav class="d-md-none fixed-bottom border-top bg-white">
  <div class="d-flex">
    <?php foreach($links as [$key,$icon,$label,$href]): ?>
    <a href="<?= $href ?>" class="flex-fill text-center py-2 text-decoration-none <?= ($active??'')===$key?'text-primary fw-700':'text-muted' ?>" style="font-size:.7rem">
      <i class="bi <?= $icon ?> d-block fs-5"></i><?= $label ?>
    </a>
    <?php endforeach; ?>
  </div>
</nav>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="/assets/js/app.js"></script>
<?= $this->renderSection('scripts') ?>
</body>
</html>
