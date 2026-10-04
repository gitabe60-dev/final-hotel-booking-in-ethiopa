<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4">
  <div>
    <h4 class="fw-900 mb-0">Welcome, <?= esc(explode(' ', $admin['name'])[0]) ?>! 👑</h4>
    <p class="text-muted small mb-0">Full system overview — all cities, all hotels</p>
  </div>
  <a href="/admin/super/sub-admins/create" class="btn btn-primary rounded-pill fw-700 px-4">
    <i class="bi bi-person-plus me-1"></i>Add Sub-Admin
  </a>
</div>

<!-- Overview Stats -->
<div class="row g-3 mb-4">
  <?php
  $stats = [
    ['Sub-Admins',         $overview['sub_admins']??0,          'bi-person-badge-fill','#3b82f6','#1d4ed8'],
    ['Brokers',            $overview['brokers']??0,             'bi-people-fill',      '#10b981','#059669'],
    ['Hotel Managers',     $overview['hotel_managers']??0,      'bi-building-gear',    '#8b5cf6','#6d28d9'],
    ['Active Hotels',      $overview['active_hotels']??0,       'bi-building-fill',    '#f59e0b','#d97706'],
    ['Confirmed Bookings', $overview['confirmed_bookings']??0,  'bi-calendar-check',   '#06b6d4','#0891b2'],
    ['Pending Bookings',   $overview['pending_bookings']??0,    'bi-clock-fill',       '#ef4444','#dc2626'],
    ['Total Guests',       $overview['total_guests']??0,        'bi-people',           '#ec4899','#db2777'],
    ['Revenue (ETB)',      number_format($overview['total_revenue']??0,0),'bi-cash-coin','#14b8a6','#0d9488'],
  ];
  foreach($stats as [$label,$val,$icon,$bg,$dark]):
  ?>
  <div class="col-6 col-md-3">
    <div class="stat-box" style="background:linear-gradient(135deg,<?= $bg ?>,<?= $dark ?>)">
      <i class="bi <?= $icon ?> fs-2 mb-2 d-block opacity-75"></i>
      <div class="fw-900 fs-4"><?= $val ?></div>
      <div class="small opacity-75 fw-500"><?= $label ?></div>
    </div>
  </div>
  <?php endforeach; ?>
</div>

<!-- Sub-Admins quick list -->
<div class="row g-4 mb-4">
  <div class="col-lg-6">
    <div class="admin-card p-0">
      <div class="d-flex justify-content-between align-items-center p-3 border-bottom">
        <h6 class="fw-800 mb-0"><i class="bi bi-person-badge-fill me-2 text-primary"></i>Sub-Admins</h6>
        <a href="/admin/super/sub-admins" class="btn btn-sm btn-outline-primary rounded-pill fw-700">View All</a>
      </div>
      <div class="p-3">
        <?php if(empty($subAdmins)): ?>
        <p class="text-muted small text-center py-3">No sub-admins yet. <a href="/admin/super/sub-admins/create" class="text-primary">Add one</a></p>
        <?php else: ?>
        <?php foreach(array_slice($subAdmins,0,5) as $sa): ?>
        <div class="d-flex align-items-center gap-3 py-2 border-bottom">
          <div style="width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,#1a56db,#7c3aed);display:flex;align-items:center;justify-content:center;font-weight:800;color:#fff;font-size:.85rem">
            <?= strtoupper(substr($sa['full_name'],0,1)) ?>
          </div>
          <div class="flex-grow-1">
            <div class="fw-700 small"><?= esc($sa['full_name']) ?></div>
            <div class="text-muted" style="font-size:.75rem"><?= esc($sa['email']) ?></div>
          </div>
          <div class="d-flex flex-wrap gap-1">
            <?php foreach($sa['cities']??[] as $c): ?>
            <span class="badge rounded-pill" style="background:#dbeafe;color:#1e40af;font-size:.7rem"><?= esc($c) ?></span>
            <?php endforeach; ?>
          </div>
        </div>
        <?php endforeach; ?>
        <?php endif; ?>
      </div>
    </div>
  </div>

  <!-- Recent Bookings -->
  <div class="col-lg-6">
    <div class="admin-card p-0">
      <div class="d-flex justify-content-between align-items-center p-3 border-bottom">
        <h6 class="fw-800 mb-0"><i class="bi bi-calendar-check-fill me-2 text-success"></i>Recent Bookings</h6>
        <a href="/admin/super/bookings" class="btn btn-sm btn-outline-success rounded-pill fw-700">View All</a>
      </div>
      <div style="overflow-x:auto">
        <table class="admin-table">
          <thead><tr><th>Guest</th><th>Hotel</th><th>Status</th><th>ETB</th></tr></thead>
          <tbody>
          <?php foreach($recentBk as $b): ?>
          <tr>
            <td><div class="fw-600 small"><?= esc($b['guest_name']) ?></div></td>
            <td><div class="small"><?= esc($b['hotel_name']) ?></div><div class="text-muted" style="font-size:.73rem"><?= esc($b['hotel_city']) ?></div></td>
            <td><span class="bk-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
            <td class="fw-700 small"><?= number_format($b['total_price'],0) ?></td>
          </tr>
          <?php endforeach; ?>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
