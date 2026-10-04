<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php $admin['city'] = $city ?? ''; ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Hotels in <span class="text-primary"><?= esc($city) ?></span></h4>
    <p class="text-muted small mb-0"><?= count($hotels) ?> hotel<?= count($hotels)!==1?'s':'' ?></p>
  </div>
  <a href="/admin/subadmin/hotels/add" class="btn btn-primary rounded-pill fw-700 px-4">
    <i class="bi bi-plus-circle me-1"></i>Add Hotel
  </a>
</div>

<div class="admin-card p-3 mb-4">
  <form action="/admin/subadmin/hotels" method="GET" class="d-flex gap-2">
    <div class="input-group" style="max-width:360px">
      <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
      <input type="text" name="q" class="form-control border-start-0" placeholder="Search hotel name or address..." value="<?= esc($search) ?>">
    </div>
    <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">Search</button>
    <?php if($search): ?><a href="/admin/subadmin/hotels" class="btn btn-outline-secondary rounded-3">Clear</a><?php endif; ?>
  </form>
</div>

<div class="admin-card p-0">
  <?php if(empty($hotels)): ?>
  <div class="text-center py-5">
    <i class="bi bi-building fs-1 text-muted d-block mb-2"></i>
    <h6 class="fw-700">No Hotels in <?= esc($city) ?></h6>
    <a href="/admin/subadmin/hotels/add" class="btn btn-primary rounded-pill fw-700 mt-2">Add First Hotel</a>
  </div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Hotel</th><th>Type</th><th>Price/Night</th><th>Rating</th><th>Rooms</th><th>Status</th><th>Actions</th></tr></thead>
      <tbody>
      <?php foreach($hotels as $h): ?>
      <tr>
        <td>
          <div class="d-flex align-items-center gap-2">
            <?php if($h['img']??''): ?>
            <img src="<?= esc($h['img']) ?>" style="width:44px;height:38px;object-fit:cover;border-radius:8px" alt="">
            <?php endif; ?>
            <div>
              <div class="fw-700 small"><?= esc($h['name']) ?></div>
              <div class="text-muted" style="font-size:.73rem"><?= esc($h['address']) ?></div>
            </div>
          </div>
        </td>
        <td><span class="badge bg-light text-dark border small"><?= esc($h['type']) ?></span></td>
        <td class="fw-700 small text-primary">ETB <?= number_format($h['price_per_night'],0) ?></td>
        <td class="small">⭐ <?= number_format($h['rating'],1) ?></td>
        <td><span class="badge bg-primary rounded-pill"><?= $h['room_count'] ?></span></td>
        <td><span class="<?= ($h['is_active']==='t'||$h['is_active']===true)?'status-active':'status-inactive' ?>"><?= ($h['is_active']==='t'||$h['is_active']===true)?'Active':'Inactive' ?></span></td>
        <td>
          <div class="d-flex gap-1 flex-wrap">
            <a href="/admin/subadmin/hotels/<?= $h['id'] ?>/rooms" class="btn btn-sm btn-outline-primary rounded-pill fw-700" style="font-size:.75rem"><i class="bi bi-door-open me-1"></i>Rooms</a>
            <a href="/admin/subadmin/hotels/<?= $h['id'] ?>/edit" class="btn btn-sm btn-outline-secondary rounded-pill fw-700" style="font-size:.75rem"><i class="bi bi-pencil me-1"></i>Edit</a>
            <a href="/admin/subadmin/hotels/<?= $h['id'] ?>/assign-manager" class="btn btn-sm btn-outline-success rounded-pill fw-700" style="font-size:.75rem"><i class="bi bi-person-check me-1"></i>Assign</a>
            <form action="/admin/subadmin/hotels/<?= $h['id'] ?>/delete" method="POST" class="d-inline" onsubmit="return confirm('Deactivate this hotel?')">
              <?= csrf_field() ?>
              <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill fw-700" style="font-size:.75rem"><i class="bi bi-trash me-1"></i>Del</button>
            </form>
          </div>
        </td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
