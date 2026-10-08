<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= esc($pageTitle ?? 'Dallol Booking') ?></title>
<meta name="description" content="Book hotels, resorts and lodges across Ethiopia with Dallol Booking.">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<link href="/assets/css/app.css" rel="stylesheet">
<?= $this->renderSection('head') ?>
</head>
<body>

<!-- PAGE LOADER -->
<div id="pageLoader" class="page-loader">
  <div class="text-center">
    <div class="loader-ring mb-3"></div>
    <div class="fw-700 text-primary">DallolBooking</div>
  </div>
</div>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark sticky-top">
  <div class="container">
    <a class="navbar-brand d-flex align-items-center gap-2" href="/">
      <span style="background:linear-gradient(135deg,#f59e0b,#ef4444);border-radius:10px;width:36px;height:36px;display:flex;align-items:center;justify-content:center;">
        <i class="bi bi-compass-fill text-white fs-5"></i>
      </span>
      <span class="fw-900">Dallol<span class="text-warning">Booking</span></span>
    </a>
    <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="mainNav">
      <ul class="navbar-nav me-auto ms-3 gap-1">
        <li class="nav-item"><a class="nav-link <?= (current_url(true)->getPath()==='/')?'active':'' ?>" href="/">Home</a></li>
        <li class="nav-item"><a class="nav-link <?= str_starts_with(uri_string(),'hotels')?'active':'' ?>" href="/hotels">Hotels</a></li>
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">Destinations</a>
          <ul class="dropdown-menu border-0 shadow-lg" style="border-radius:14px">
            <?php foreach(['Addis Ababa','Hawassa','Bahir Dar','Gondar','Harar','Jimma','Arba Minch','Adama'] as $c): ?>
            <li><a class="dropdown-item py-2" href="/hotels?city=<?= urlencode($c) ?>"><i class="bi bi-geo-alt-fill text-primary me-2"></i><?= $c ?></a></li>
            <?php endforeach; ?>
          </ul>
        </li>
      </ul>
      <ul class="navbar-nav ms-auto align-items-center gap-2">
        <?php if(session()->get('user_id')): ?>
        <li class="nav-item"><a class="nav-link" href="/dashboard/wishlist"><i class="bi bi-heart me-1"></i>Wishlist</a></li>
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle d-flex align-items-center gap-2" href="#" data-bs-toggle="dropdown">
            <span style="width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#ef4444);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.85rem;color:#fff">
              <?= strtoupper(substr(session()->get('user_name')??'U',0,1)) ?>
            </span>
            <span class="d-none d-lg-inline"><?= esc(explode(' ',session()->get('user_name')??'')[0]) ?></span>
          </a>
          <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg" style="border-radius:14px;min-width:200px">
            <li><div class="px-3 py-2 border-bottom"><div class="fw-600 small"><?= esc(session()->get('user_name')) ?></div><div class="text-muted" style="font-size:.75rem"><?= esc(session()->get('user_email')) ?></div></div></li>
            <li><a class="dropdown-item py-2" href="/dashboard"><i class="bi bi-grid-1x2 me-2 text-primary"></i>Dashboard</a></li>
            <li><a class="dropdown-item py-2" href="/dashboard/bookings"><i class="bi bi-calendar-check me-2 text-primary"></i>My Bookings</a></li>
            <li><a class="dropdown-item py-2" href="/dashboard/wishlist"><i class="bi bi-heart me-2 text-danger"></i>Wishlist</a></li>
            <li><a class="dropdown-item py-2" href="/dashboard/profile"><i class="bi bi-person me-2 text-primary"></i>Profile</a></li>
            <li><hr class="dropdown-divider my-1"></li>
            <li><a class="dropdown-item py-2 text-danger" href="/logout"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
          </ul>
        </li>
        <?php else: ?>
        <li class="nav-item"><a class="nav-link" href="/login">Sign In</a></li>
        <li class="nav-item"><a class="btn btn-warning fw-700 px-4 py-2" style="border-radius:50px" href="/register">Join Free</a></li>
        <?php endif; ?>
      </ul>
    </div>
  </div>
</nav>

<!-- FLASH MESSAGES -->
<?php if(session()->getFlashdata('success')): ?>
<div class="alert alert-success alert-flash alert-dismissible fade show mb-0 rounded-0 text-center py-2" role="alert">
  <i class="bi bi-check-circle-fill me-2"></i><?= esc(session()->getFlashdata('success')) ?>
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<?php endif; ?>
<?php if(session()->getFlashdata('error')): ?>
<div class="alert alert-danger alert-flash alert-dismissible fade show mb-0 rounded-0 text-center py-2" role="alert">
  <i class="bi bi-exclamation-circle-fill me-2"></i><?= esc(session()->getFlashdata('error')) ?>
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<?php endif; ?>

<main><?= $this->renderSection('content') ?></main>

<!-- FOOTER -->
<footer class="footer pt-5 pb-3 mt-5">
  <div class="container">
    <div class="row g-4 mb-4">
      <div class="col-lg-4">
        <div class="footer-brand mb-3"><i class="bi bi-compass-fill text-warning me-2"></i>DallolBooking</div>
        <p class="small" style="color:#64748b;line-height:1.7">Discover and book the finest hotels, resorts, and lodges across Ethiopia. Your perfect stay is just a click away.</p>
        <div class="d-flex gap-2 mt-3">
          <a href="#" class="social-btn"><i class="bi bi-facebook"></i></a>
          <a href="#" class="social-btn"><i class="bi bi-telegram"></i></a>
          <a href="#" class="social-btn"><i class="bi bi-instagram"></i></a>
          <a href="#" class="social-btn"><i class="bi bi-twitter-x"></i></a>
        </div>
      </div>
      <div class="col-6 col-lg-2">
        <div class="fw-700 text-white mb-3 small text-uppercase" style="letter-spacing:.08em">Explore</div>
        <a href="/hotels" class="footer-link">All Hotels</a>
        <a href="/hotels?type=Resort" class="footer-link">Resorts</a>
        <a href="/hotels?type=Lodge" class="footer-link">Lodges</a>
        <a href="/hotels?sort=rating&dir=DESC" class="footer-link">Top Rated</a>
      </div>
      <div class="col-6 col-lg-2">
        <div class="fw-700 text-white mb-3 small text-uppercase" style="letter-spacing:.08em">Cities</div>
        <?php foreach(['Addis Ababa','Hawassa','Bahir Dar','Gondar','Harar'] as $c): ?>
        <a href="/hotels?city=<?= urlencode($c) ?>" class="footer-link"><?= $c ?></a>
        <?php endforeach; ?>
      </div>
      <div class="col-lg-4">
        <div class="fw-700 text-white mb-3 small text-uppercase" style="letter-spacing:.08em">Get The App</div>
        <p class="small mb-3" style="color:#64748b">Book hotels on the go with our mobile app</p>
        <div class="d-flex gap-2">
          <a href="#" class="btn btn-sm px-3 py-2 fw-600" style="background:rgba(255,255,255,.08);color:#fff;border-radius:10px"><i class="bi bi-apple me-1"></i>App Store</a>
          <a href="#" class="btn btn-sm px-3 py-2 fw-600" style="background:rgba(255,255,255,.08);color:#fff;border-radius:10px"><i class="bi bi-google-play me-1"></i>Google Play</a>
        </div>
        <div class="mt-3 small" style="color:#64748b">
          <div class="mb-1"><i class="bi bi-envelope me-2 text-warning"></i>support@dalloltech.com</div>
          <div><i class="bi bi-telephone me-2 text-warning"></i>+251 911 000 000</div>
        </div>
      </div>
    </div>
    <hr style="border-color:#1e293b">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2" style="font-size:.82rem;color:#475569">
      <span>&copy; <?= date('Y') ?> DallolBooking. All rights reserved.</span>
      <div class="d-flex gap-3">
        <a href="#" class="footer-link mb-0">Privacy Policy</a>
        <a href="#" class="footer-link mb-0">Terms of Service</a>
      </div>
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="/assets/js/app.js"></script>
<script src="/assets/js/dallol-validate.js"></script>
<?= $this->renderSection('scripts') ?>
</body>
</html>
