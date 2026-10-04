<?= $this->extend('layouts/dashboard') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Welcome back, <?= esc($user['first_name']) ?>! 👋</h4>
    <p class="text-muted small mb-0">Here's your travel overview</p>
  </div>
  <a href="/hotels" class="btn btn-primary rounded-pill px-4 fw-700"><i class="bi bi-search me-2"></i>Find Hotels</a>
</div>

<!-- Stats -->
<div class="row g-3 mb-4">
  <?php
  $stats = [
    ['Total Bookings',array_sum($counts),'bi-calendar-check','#eff6ff','#1a56db','#dbeafe'],
    ['Confirmed',    $counts['confirmed']??0,'bi-check-circle','#f0fdf4','#16a34a','#dcfce7'],
    ['Pending',      $counts['pending']??0,'bi-clock','#fef9c3','#d97706','#fde68a'],
    ['Completed',    $counts['completed']??0,'bi-trophy','#f5f3ff','#7c3aed','#ede9fe'],
  ];
  foreach($stats as $i=>[$label,$val,$icon,$bg,$color,$bg2]):
  ?>
  <div class="col-6 col-xl-3 reveal" style="animation-delay:<?= $i*.08 ?>s">
    <div class="stat-card" style="background:<?= $bg ?>">
      <div style="position:absolute;top:-15px;right:-15px;width:70px;height:70px;border-radius:50%;background:<?= $color ?>;opacity:.07"></div>
      <div class="d-flex align-items-center gap-3">
        <div class="stat-icon" style="background:<?= $bg2 ?>;color:<?= $color ?>">
          <i class="bi <?= $icon ?>"></i>
        </div>
        <div>
          <div class="h3 fw-900 mb-0" style="color:<?= $color ?>"><?= $val ?></div>
          <div class="small text-muted fw-500"><?= $label ?></div>
        </div>
      </div>
    </div>
  </div>
  <?php endforeach; ?>
</div>

<!-- Recent Bookings -->
<div class="card border-0 rounded-4 shadow mb-4 reveal">
  <div class="card-header bg-white border-0 pt-3 px-4 d-flex justify-content-between align-items-center">
    <h6 class="fw-800 mb-0"><i class="bi bi-clock-history me-2 text-primary"></i>Recent Bookings</h6>
    <a href="/dashboard/bookings" class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-700">View All</a>
  </div>
  <div class="card-body p-0">
    <?php if(empty($recent)): ?>
    <div class="text-center py-5">
      <i class="bi bi-calendar-x fs-1 text-muted d-block mb-2"></i>
      <p class="text-muted small">No bookings yet. <a href="/hotels" class="text-primary fw-700">Start exploring!</a></p>
    </div>
    <?php else: ?>
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-light">
          <tr class="small text-muted">
            <th class="px-4">Hotel</th><th>Dates</th><th>Guests</th><th>Amount</th><th>Status</th><th></th>
          </tr>
        </thead>
        <tbody>
        <?php foreach($recent as $b): ?>
        <tr>
          <td class="px-4">
            <div class="d-flex align-items-center gap-2">
              <img src="<?= esc($b['hotel_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=80') ?>"
                   class="rounded-2" style="width:44px;height:40px;object-fit:cover" alt="">
              <div>
                <div class="fw-700 small"><?= esc($b['hotel_name']) ?></div>
                <div class="text-muted" style="font-size:.75rem"><?= esc($b['hotel_city']) ?></div>
              </div>
            </div>
          </td>
          <td class="small"><?= date('d M',strtotime($b['check_in'])) ?> → <?= date('d M Y',strtotime($b['check_out'])) ?></td>
          <td class="small"><?= $b['adults'] ?> adult<?= $b['adults']>1?'s':'' ?></td>
          <td class="small fw-700 text-primary">ETB <?= number_format($b['total_price'],0) ?></td>
          <td><span class="status-badge status-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
          <td><a href="/dashboard/bookings/<?= $b['id'] ?>" class="btn btn-sm btn-outline-primary rounded-pill px-3 fw-700">View</a></td>
        </tr>
        <?php endforeach; ?>
        </tbody>
      </table>
    </div>
    <?php endif; ?>
  </div>
</div>

<!-- Wishlist Preview -->
<?php if(!empty($wishlist)): ?>
<div class="card border-0 rounded-4 shadow reveal">
  <div class="card-header bg-white border-0 pt-3 px-4 d-flex justify-content-between align-items-center">
    <h6 class="fw-800 mb-0"><i class="bi bi-heart-fill me-2 text-danger"></i>My Wishlist</h6>
    <a href="/dashboard/wishlist" class="btn btn-outline-danger btn-sm rounded-pill px-3 fw-700">View All</a>
  </div>
  <div class="card-body">
    <div class="row g-3">
      <?php foreach($wishlist as $h): ?>
      <div class="col-6 col-md-3">
        <a href="/hotels/<?= $h['id'] ?>" class="text-decoration-none">
          <div class="dest-card rounded-3" style="height:120px">
            <img src="<?= esc($h['primary_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400') ?>" alt="<?= esc($h['name']) ?>" loading="lazy">
            <div class="dest-card-overlay rounded-3">
              <div>
                <div class="text-white fw-700 small"><?= esc($h['name']) ?></div>
                <div class="text-white-50" style="font-size:.72rem">ETB <?= number_format($h['price_per_night'],0) ?>/night</div>
              </div>
            </div>
          </div>
        </a>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
</div>
<?php endif; ?>

<?= $this->endSection() ?>
