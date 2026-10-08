<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Hotel Managers</h4>
    <p class="text-muted small mb-0"><?= count($managers) ?> manager<?= count($managers) !== 1 ? 's' : '' ?> in <?= esc($city) ?></p>
  </div>
  <a href="/admin/subadmin/hotels" class="btn btn-outline-primary rounded-pill fw-700 px-4">
    <i class="bi bi-building me-1"></i>View Hotels
  </a>
</div>

<?php if(empty($managers)): ?>
<div class="admin-card text-center py-5">
  <i class="bi bi-person-x fs-1 text-muted d-block mb-3"></i>
  <h6 class="fw-700">No Hotel Managers Yet</h6>
  <p class="text-muted small">Add a hotel and assign a manager to see them here.</p>
  <a href="/admin/subadmin/hotels/add" class="btn btn-primary rounded-pill fw-700 px-5 mt-2">
    <i class="bi bi-plus-circle me-1"></i>Add Hotel with Manager
  </a>
</div>
<?php else: ?>
<div class="row g-4">
  <?php foreach($managers as $m): ?>
  <div class="col-md-6 col-lg-4">
    <div class="admin-card p-4 h-100" style="border-radius:16px">
      <!-- Manager header -->
      <div class="d-flex align-items-center gap-3 mb-3">
        <div style="width:52px;height:52px;background:linear-gradient(135deg,#4f46e5,#7c3aed);border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0">
          <i class="bi bi-person-badge-fill text-white fs-4"></i>
        </div>
        <div class="flex-grow-1 min-width-0">
          <div class="fw-800 text-truncate"><?= esc($m['manager_name'] ?? 'Unknown') ?></div>
          <div class="text-muted small text-truncate"><?= esc($m['manager_email'] ?? '') ?></div>
          <?php if(!empty($m['manager_phone'])): ?>
          <div class="text-muted small"><?= esc($m['manager_phone']) ?></div>
          <?php endif; ?>
        </div>
      </div>

      <!-- Hotel info -->
      <div class="bg-light rounded-3 p-3 mb-3">
        <div class="d-flex align-items-center gap-2 mb-1">
          <i class="bi bi-building text-primary"></i>
          <span class="fw-700 small"><?= esc($m['hotel_name'] ?? '—') ?></span>
        </div>
        <div class="text-muted" style="font-size:.78rem"><?= esc($m['hotel_city'] ?? '') ?></div>
      </div>

      <!-- Broker info -->
      <?php if(!empty($m['broker_name'])): ?>
      <div class="d-flex align-items-center gap-2 mb-3">
        <i class="bi bi-briefcase text-info"></i>
        <span class="small">Broker: <strong><?= esc($m['broker_name']) ?></strong></span>
      </div>
      <?php endif; ?>

      <!-- Actions -->
      <div class="d-flex gap-2 flex-wrap mt-auto pt-2 border-top">
        <a href="/admin/subadmin/hotels/<?= $m['hotel_id'] ?>/assign-manager"
           class="btn btn-sm btn-outline-primary rounded-pill fw-700 flex-grow-1">
          <i class="bi bi-arrow-repeat me-1"></i>Replace
        </a>
        <a href="/admin/subadmin/hotels/<?= $m['hotel_id'] ?>/rooms"
           class="btn btn-sm btn-outline-secondary rounded-pill fw-700 flex-grow-1">
          <i class="bi bi-door-open me-1"></i>Rooms
        </a>
      </div>
    </div>
  </div>
  <?php endforeach; ?>
</div>
<?php endif; ?>

<?= $this->endSection() ?>
