<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Manage Rooms</h4>
    <p class="text-muted small mb-0"><?= esc($hotel['name'] ?? '') ?> · <?= count($rooms) ?> room type<?= count($rooms)!==1?'s':'' ?></p>
  </div>
  <a href="/admin/manager/rooms/add" class="btn btn-primary rounded-pill fw-700 px-4">
    <i class="bi bi-plus-circle me-1"></i>Add Room
  </a>
</div>

<!-- Search -->
<div class="admin-card p-3 mb-4">
  <form action="/admin/manager/rooms" method="GET" class="d-flex gap-2">
    <div class="input-group" style="max-width:360px">
      <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
      <input type="text" name="q" class="form-control border-start-0" placeholder="Search room name or bed type..." value="<?= esc($search) ?>">
    </div>
    <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">Search</button>
    <?php if($search): ?><a href="/admin/manager/rooms" class="btn btn-outline-secondary rounded-3">Clear</a><?php endif; ?>
  </form>
</div>

<div class="admin-card p-0">
  <?php if(empty($rooms)): ?>
  <div class="text-center py-5">
    <i class="bi bi-door-open fs-1 text-muted d-block mb-2"></i>
    <h6 class="fw-700">No Rooms Added Yet</h6>
    <a href="/admin/manager/rooms/add" class="btn btn-primary rounded-pill fw-700 mt-2">Add First Room</a>
  </div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Room</th><th>Bed Type</th><th>Size</th><th>Max Guests</th><th>Price/Night</th><th>Features</th><th>Available</th><th>Actions</th></tr></thead>
      <tbody>
      <?php foreach($rooms as $r): ?>
      <tr>
        <td>
          <div class="d-flex align-items-center gap-2">
            <?php if($r['image_url']??''): ?>
            <img src="<?= esc($r['image_url']) ?>" style="width:44px;height:38px;object-fit:cover;border-radius:8px" alt="">
            <?php endif; ?>
            <span class="fw-700 small"><?= esc($r['name']) ?></span>
          </div>
        </td>
        <td class="small"><?= esc($r['bed_type']) ?></td>
        <td class="small"><?= $r['size_sqm'] ?>m²</td>
        <td class="small"><?= $r['max_guests'] ?></td>
        <td class="fw-700 text-primary small">ETB <?= number_format($r['price_per_night'],0) ?></td>
        <td class="small text-muted" style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= esc(str_replace('"','',trim($r['features']??'{}','{}'))) ?></td>
        <td>
          <form action="/admin/manager/rooms/<?= $r['id'] ?>/toggle" method="POST" class="d-inline">
            <?= csrf_field() ?>
            <button type="submit" class="btn btn-sm rounded-pill fw-700 <?= $r['is_available']?'btn-success':'btn-outline-secondary' ?>" style="font-size:.75rem">
              <?= $r['is_available']?'✓ Available':'✗ Unavailable' ?>
            </button>
          </form>
        </td>
        <td>
          <div class="d-flex gap-1">
            <a href="/admin/manager/rooms/<?= $r['id'] ?>/edit" class="btn btn-sm btn-outline-primary rounded-pill fw-700" style="font-size:.75rem"><i class="bi bi-pencil"></i> Edit</a>
            <form action="/admin/manager/rooms/<?= $r['id'] ?>/delete" method="POST" class="d-inline" onsubmit="return confirm('Delete this room permanently?')">
              <?= csrf_field() ?>
              <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill fw-700" style="font-size:.75rem"><i class="bi bi-trash"></i> Del</button>
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
