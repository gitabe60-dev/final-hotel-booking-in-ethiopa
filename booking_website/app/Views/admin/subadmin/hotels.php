<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<style>
.hotel-row:hover{background:#f8f9ff}
.mgr-pill{display:inline-flex;align-items:center;gap:5px;background:#e9f7ef;color:#1a7a3f;border-radius:20px;padding:3px 10px;font-size:.75rem;font-weight:700}
.no-mgr-pill{display:inline-flex;align-items:center;gap:5px;background:#fff3cd;color:#856404;border-radius:20px;padding:3px 10px;font-size:.75rem;font-weight:700}
.broker-pill{display:inline-flex;align-items:center;gap:4px;background:#e8f4fd;color:#0066cc;border-radius:20px;padding:2px 8px;font-size:.7rem;font-weight:700}
</style>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Hotels in <span class="text-primary"><?= esc($city) ?></span></h4>
    <p class="text-muted small mb-0"><?= count($hotels) ?> hotel<?= count($hotels) !== 1 ? 's' : '' ?></p>
  </div>
  <a href="/admin/subadmin/hotels/add" class="btn btn-primary rounded-pill fw-700 px-4">
    <i class="bi bi-plus-circle me-1"></i>Add Hotel
  </a>
</div>

<div class="admin-card p-3 mb-4">
  <form action="/admin/subadmin/hotels" method="GET" class="d-flex gap-2 flex-wrap">
    <div class="input-group" style="max-width:360px">
      <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
      <input type="text" name="q" class="form-control border-start-0"
             placeholder="Search hotel name or address..." value="<?= esc($search) ?>">
    </div>
    <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">Search</button>
    <?php if($search): ?>
      <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary rounded-3">Clear</a>
    <?php endif; ?>
  </form>
</div>

<div class="admin-card p-0">
  <?php if(empty($hotels)): ?>
  <div class="text-center py-5">
    <i class="bi bi-building fs-1 text-muted d-block mb-2"></i>
    <h6 class="fw-700">No Hotels in <?= esc($city) ?></h6>
    <p class="text-muted small">Start by adding the first hotel for your city.</p>
    <a href="/admin/subadmin/hotels/add" class="btn btn-primary rounded-pill fw-700 mt-2 px-5">
      <i class="bi bi-plus-circle me-1"></i>Add First Hotel
    </a>
  </div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead>
        <tr>
          <th>Hotel</th>
          <th>Type</th>
          <th>Price/Night</th>
          <th>Rating</th>
          <th>Rooms</th>
          <th>Manager</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
      <?php foreach($hotels as $h):
        $isActive = ($h['is_active'] === 't' || $h['is_active'] === true);
      ?>
      <tr class="hotel-row">
        <td>
          <div class="d-flex align-items-center gap-2">
            <?php if(!empty($h['img'])): ?>
            <img src="<?= esc($h['img']) ?>"
                 style="width:48px;height:40px;object-fit:cover;border-radius:8px;flex-shrink:0" alt="">
            <?php else: ?>
            <div style="width:48px;height:40px;background:#e9ecef;border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0">
              <i class="bi bi-building text-muted"></i>
            </div>
            <?php endif; ?>
            <div>
              <div class="fw-700 small"><?= esc($h['name']) ?></div>
              <div class="text-muted" style="font-size:.72rem"><?= esc($h['address']) ?></div>
            </div>
          </div>
        </td>
        <td><span class="badge bg-light text-dark border small"><?= esc($h['type']) ?></span></td>
        <td class="fw-700 small text-primary">ETB <?= number_format((float)$h['price_per_night'], 0) ?></td>
        <td class="small">⭐ <?= number_format((float)$h['rating'], 1) ?></td>
        <td><span class="badge bg-primary rounded-pill"><?= (int)$h['room_count'] ?></span></td>
        <td>
          <?php if(!empty($h['manager_name'])): ?>
          <div>
            <span class="mgr-pill"><i class="bi bi-person-check-fill"></i><?= esc($h['manager_name']) ?></span>
            <?php if(!empty($h['broker_name'])): ?>
            <br><span class="broker-pill mt-1"><i class="bi bi-briefcase-fill"></i><?= esc($h['broker_name']) ?></span>
            <?php endif; ?>
            <div class="text-muted mt-1" style="font-size:.7rem"><?= esc($h['manager_email'] ?? '') ?></div>
          </div>
          <?php else: ?>
          <a href="/admin/subadmin/hotels/<?= $h['id'] ?>/assign-manager" class="no-mgr-pill text-decoration-none">
            <i class="bi bi-plus-circle"></i>Assign Manager
          </a>
          <?php endif; ?>
        </td>
        <td>
          <span class="<?= $isActive ? 'status-active' : 'status-inactive' ?>">
            <?= $isActive ? 'Active' : 'Inactive' ?>
          </span>
        </td>
        <td>
          <div class="d-flex gap-1 flex-wrap">
            <a href="/admin/subadmin/hotels/<?= $h['id'] ?>/rooms"
               class="btn btn-sm btn-outline-primary rounded-pill fw-700" style="font-size:.73rem"
               title="Manage Rooms">
              <i class="bi bi-door-open me-1"></i>Rooms
            </a>
            <a href="/admin/subadmin/hotels/<?= $h['id'] ?>/edit"
               class="btn btn-sm btn-outline-secondary rounded-pill fw-700" style="font-size:.73rem"
               title="Edit Hotel">
              <i class="bi bi-pencil me-1"></i>Edit
            </a>
            <a href="/admin/subadmin/hotels/<?= $h['id'] ?>/assign-manager"
               class="btn btn-sm btn-outline-success rounded-pill fw-700" style="font-size:.73rem"
               title="<?= !empty($h['manager_name']) ? 'Replace Manager' : 'Assign Manager' ?>">
              <i class="bi bi-person-check me-1"></i><?= !empty($h['manager_name']) ? 'Manager' : 'Assign' ?>
            </a>
            <form action="/admin/subadmin/hotels/<?= $h['id'] ?>/delete" method="POST" class="d-inline"
                  onsubmit="return confirm('Deactivate \'<?= addslashes($h['name']) ?>\'?')">
              <?= csrf_field() ?>
              <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill fw-700"
                      style="font-size:.73rem" title="Deactivate">
                <i class="bi bi-trash"></i>
              </button>
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
