<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php $admin['city'] = $city ?? ''; ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Dashboard — <span class="text-primary"><?= esc($city) ?></span> 🏙️</h4>
    <p class="text-muted small mb-0">Managing all hotels and operations in <?= esc($city) ?></p>
  </div>
  <div class="d-flex gap-2">
    <a href="/admin/subadmin/hotels/add" class="btn btn-primary rounded-pill fw-700 px-3"><i class="bi bi-building-add me-1"></i>Add Hotel</a>
    <a href="/admin/subadmin/brokers/create" class="btn btn-outline-primary rounded-pill fw-700 px-3"><i class="bi bi-person-plus me-1"></i>Add Broker</a>
  </div>
</div>

<div class="row g-3 mb-4">
  <?php
  $stats = [
    ['Hotels',           $hotelCount,   'bi-building-fill',     '#3b82f6','#1d4ed8'],
    ['Bookings',         $bookingCount, 'bi-calendar-check',    '#10b981','#059669'],
    ['Pending',          $pendingCount, 'bi-clock-fill',        '#f59e0b','#d97706'],
    ['Brokers',          $brokerCount,  'bi-people-fill',       '#8b5cf6','#6d28d9'],
    ['Revenue (ETB)',    number_format($revenue,0), 'bi-cash-coin', '#06b6d4','#0891b2'],
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

<div class="admin-card p-0">
  <div class="d-flex justify-content-between align-items-center p-3 border-bottom">
    <h6 class="fw-800 mb-0"><i class="bi bi-calendar-check-fill me-2 text-success"></i>Recent Bookings in <?= esc($city) ?></h6>
    <a href="/admin/subadmin/bookings" class="btn btn-sm btn-outline-success rounded-pill fw-700">View All</a>
  </div>
  <?php if(empty($recentBookings)): ?>
  <div class="text-center py-4 text-muted small">No bookings yet.</div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Guest</th><th>Hotel</th><th>Dates</th><th>Total</th><th>Status</th></tr></thead>
      <tbody>
      <?php foreach($recentBookings as $b): ?>
      <tr>
        <td class="fw-600 small"><?= esc($b['guest_name']) ?></td>
        <td class="small"><?= esc($b['hotel_name']) ?></td>
        <td class="small"><?= date('d M',strtotime($b['check_in'])) ?> → <?= date('d M Y',strtotime($b['check_out'])) ?></td>
        <td class="fw-700 small text-primary">ETB <?= number_format($b['total_price'],0) ?></td>
        <td><span class="bk-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
