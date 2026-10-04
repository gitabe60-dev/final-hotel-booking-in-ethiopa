<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Hotel Manager Dashboard 🏨</h4>
    <p class="text-muted small mb-0">Managing: <strong class="text-primary"><?= esc($hotel['name'] ?? '') ?></strong> · <?= esc($hotel['city'] ?? '') ?></p>
  </div>
  <div class="d-flex gap-2">
    <a href="/admin/manager/rooms/add"  class="btn btn-primary rounded-pill fw-700 btn-sm px-3"><i class="bi bi-plus-circle me-1"></i>Add Room</a>
    <a href="/admin/manager/inbox"      class="btn btn-outline-secondary rounded-pill fw-700 btn-sm px-3 position-relative">
      <i class="bi bi-inbox me-1"></i>Inbox
      <?php if($unread>0): ?><span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size:.65rem"><?= $unread ?></span><?php endif; ?>
    </a>
  </div>
</div>

<!-- Stats -->
<div class="row g-3 mb-4">
  <?php
  $stats = [
    ['Total Rooms',   $roomCount,    'bi-door-open-fill',    '#3b82f6','#1d4ed8'],
    ['Available',     $availCount,   'bi-check-circle-fill', '#10b981','#059669'],
    ['Total Bookings',$bkCount,      'bi-calendar-check',    '#8b5cf6','#6d28d9'],
    ['Pending',       $pendingCount, 'bi-clock-fill',        '#f59e0b','#d97706'],
    ['Revenue (ETB)', number_format($revenue,0),'bi-cash-coin','#06b6d4','#0891b2'],
  ];
  foreach($stats as [$label,$val,$icon,$bg,$dark]):
  ?>
  <div class="col-6 col-md-4 col-xl">
    <div class="stat-box" style="background:linear-gradient(135deg,<?= $bg ?>,<?= $dark ?>)">
      <i class="bi <?= $icon ?> fs-3 mb-2 d-block opacity-75"></i>
      <div class="fw-900 fs-4"><?= $val ?></div>
      <div class="small opacity-75 fw-500"><?= $label ?></div>
    </div>
  </div>
  <?php endforeach; ?>
</div>

<!-- Broker & Assignment Info -->
<?php if($mgrDetail): ?>
<div class="row g-4 mb-4">
  <div class="col-md-4">
    <div class="admin-card p-3">
      <div class="fw-800 small mb-3 text-muted text-uppercase" style="letter-spacing:.06em">My Broker</div>
      <?php if($mgrDetail['broker_name']??''): ?>
      <div class="d-flex align-items-center gap-2">
        <div style="width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,#10b981,#059669);display:flex;align-items:center;justify-content:center;font-weight:800;color:#fff">
          <?= strtoupper(substr($mgrDetail['broker_name'],0,1)) ?>
        </div>
        <div>
          <div class="fw-700 small"><?= esc($mgrDetail['broker_name']) ?></div>
          <div class="text-muted" style="font-size:.73rem">Your assigned broker</div>
        </div>
      </div>
      <a href="/admin/manager/inbox" class="btn btn-sm btn-outline-success rounded-pill fw-700 mt-3 w-100"><i class="bi bi-chat-dots me-1"></i>Send Message</a>
      <?php else: ?>
      <p class="text-muted small">No broker assigned yet.</p>
      <?php endif; ?>
    </div>
  </div>
  <div class="col-md-8">
    <div class="admin-card p-3">
      <div class="fw-800 small mb-3 text-muted text-uppercase" style="letter-spacing:.06em">Hotel Information</div>
      <div class="row g-2 small">
        <div class="col-6"><span class="text-muted">Name:</span> <span class="fw-700"><?= esc($hotel['name']) ?></span></div>
        <div class="col-6"><span class="text-muted">City:</span> <span class="fw-700"><?= esc($hotel['city']) ?></span></div>
        <div class="col-6"><span class="text-muted">Type:</span> <span class="fw-700"><?= esc($hotel['type']) ?></span></div>
        <div class="col-6"><span class="text-muted">Price:</span> <span class="fw-700 text-primary">ETB <?= number_format($hotel['price_per_night'],0) ?>/night</span></div>
        <div class="col-6"><span class="text-muted">Rating:</span> <span class="fw-700">⭐ <?= number_format($hotel['rating'],1) ?> (<?= number_format($hotel['review_count']) ?> reviews)</span></div>
      </div>
    </div>
  </div>
</div>
<?php endif; ?>

<!-- Recent Bookings -->
<div class="admin-card p-0">
  <div class="d-flex justify-content-between align-items-center p-3 border-bottom">
    <h6 class="fw-800 mb-0"><i class="bi bi-calendar-check-fill me-2 text-success"></i>Recent Bookings</h6>
    <a href="/admin/manager/bookings" class="btn btn-sm btn-outline-success rounded-pill fw-700">View All</a>
  </div>
  <?php if(empty($recentBk)): ?>
  <div class="text-center py-4 text-muted small">No bookings yet.</div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Guest</th><th>Email</th><th>Dates</th><th>Guests</th><th>Total</th><th>Status</th></tr></thead>
      <tbody>
      <?php foreach($recentBk as $b): ?>
      <tr>
        <td class="fw-700 small"><?= esc($b['guest_name']) ?></td>
        <td class="small text-muted"><?= esc($b['guest_email']) ?></td>
        <td class="small"><?= date('d M',strtotime($b['check_in'])) ?> → <?= date('d M Y',strtotime($b['check_out'])) ?></td>
        <td class="small"><?= $b['adults'] ?> adults</td>
        <td class="fw-700 text-primary small">ETB <?= number_format($b['total_price'],0) ?></td>
        <td><span class="bk-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
