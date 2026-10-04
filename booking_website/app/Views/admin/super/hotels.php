<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-900 mb-0">All Hotels</h4>
  <div class="d-flex gap-2">
    <a href="/admin/super/cities" class="btn btn-outline-secondary rounded-pill fw-700 btn-sm px-3">
      <i class="bi bi-geo-alt me-1"></i>Manage Cities
    </a>
    <a href="/admin/super/hotels/add" class="btn btn-primary rounded-pill fw-700 btn-sm px-3">
      <i class="bi bi-plus-circle me-1"></i>Add Hotel
    </a>
  </div>
</div>

<div class="admin-card p-3 mb-4">
  <form action="/admin/super/hotels" method="GET" class="row g-2 align-items-center">
    <div class="col-md-4">
      <div class="input-group">
        <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
        <input type="text" name="q" class="form-control border-start-0" placeholder="Search hotel name..." value="<?= esc($search) ?>">
      </div>
    </div>
    <div class="col-md-3">
      <select name="city" class="form-select">
        <option value="">All Cities</option>
        <?php foreach($cities as $c): ?>
        <option value="<?= esc($c) ?>" <?= $cityFilter===$c?'selected':'' ?>><?= esc($c) ?></option>
        <?php endforeach; ?>
      </select>
    </div>
    <div class="col-auto">
      <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">Filter</button>
      <?php if($search||$cityFilter): ?><a href="/admin/super/hotels" class="btn btn-outline-secondary rounded-3 fw-700">Clear</a><?php endif; ?>
    </div>
  </form>
</div>

<div class="admin-card p-0">
  <div class="p-3 border-bottom fw-700"><?= count($hotels) ?> hotels found</div>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Hotel</th><th>City</th><th>Type</th><th>Price/Night</th><th>Rating</th><th>Rooms</th><th>Status</th><th>Actions</th></tr></thead>
      <tbody>
      <?php foreach($hotels as $h): ?>
      <tr>
        <td>
          <div class="d-flex align-items-center gap-2">
            <?php if($h['img']??''): ?>
            <img src="<?= esc($h['img']) ?>" style="width:40px;height:36px;object-fit:cover;border-radius:8px" alt="">
            <?php endif; ?>
            <span class="fw-700 small"><?= esc($h['name']) ?></span>
          </div>
        </td>
        <td class="small"><?= esc($h['city']) ?></td>
        <td><span class="badge bg-light text-dark border small"><?= esc($h['type']) ?></span></td>
        <td class="fw-700 small text-primary">ETB <?= number_format($h['price_per_night'],0) ?></td>
        <td class="small">⭐ <?= number_format($h['rating'],1) ?></td>
        <td class="small"><?= $h['room_count'] ?></td>
        <td><span class="<?= ($h['is_active']==='t'||$h['is_active']===true)?'status-active':'status-inactive' ?>"><?= ($h['is_active']==='t'||$h['is_active']===true)?'Active':'Inactive' ?></span></td>
        <td>
          <div class="d-flex gap-1">
            <a href="/hotels/<?= $h['id'] ?>" target="_blank" class="btn btn-sm btn-outline-primary rounded-pill" style="font-size:.75rem" title="View on website"><i class="bi bi-eye"></i></a>
            <a href="/admin/super/hotels/<?= $h['id'] ?>/edit" class="btn btn-sm btn-outline-secondary rounded-pill" style="font-size:.75rem" title="Edit"><i class="bi bi-pencil"></i></a>
            <form action="/admin/super/hotels/<?= $h['id'] ?>/toggle" method="POST" class="d-inline">
              <?= csrf_field() ?>
              <button type="submit" class="btn btn-sm rounded-pill <?= ($h['is_active']==='t'||$h['is_active']===true)?'btn-outline-danger':'btn-outline-success' ?>" style="font-size:.75rem"
                      title="<?= ($h['is_active']==='t'||$h['is_active']===true)?'Deactivate':'Activate' ?>">
                <i class="bi <?= ($h['is_active']==='t'||$h['is_active']===true)?'bi-toggle-on':'bi-toggle-off' ?>"></i>
              </button>
            </form>
          </div>
        </td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>

<?= $this->endSection() ?>
