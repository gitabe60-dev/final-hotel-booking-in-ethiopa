<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Sub-Admins Management</h4>
    <p class="text-muted small mb-0">Assign cities and manage sub-admin accounts</p>
  </div>
  <a href="/admin/super/sub-admins/create" class="btn btn-primary rounded-pill fw-700 px-4">
    <i class="bi bi-person-plus me-1"></i>Create Sub-Admin
  </a>
</div>

<!-- Search -->
<div class="admin-card p-3 mb-4">
  <form action="/admin/super/sub-admins" method="GET" class="d-flex gap-2">
    <div class="input-group search-admin flex-grow-1" style="max-width:360px">
      <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
      <input type="text" name="q" class="form-control border-start-0" placeholder="Search by name or email..." value="<?= esc($search) ?>">
    </div>
    <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">Search</button>
    <?php if($search): ?><a href="/admin/super/sub-admins" class="btn btn-outline-secondary rounded-3 fw-700">Clear</a><?php endif; ?>
  </form>
</div>

<div class="admin-card p-0">
  <div class="p-3 border-bottom"><span class="fw-700"><?= count($subAdmins) ?> Sub-Admin<?= count($subAdmins)!==1?'s':'' ?></span></div>
  <?php if(empty($subAdmins)): ?>
  <div class="text-center py-5">
    <i class="bi bi-person-badge fs-1 text-muted d-block mb-2"></i>
    <h6 class="fw-700">No Sub-Admins Yet</h6>
    <a href="/admin/super/sub-admins/create" class="btn btn-primary rounded-pill fw-700 mt-2">Create First Sub-Admin</a>
  </div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead>
        <tr><th>Name</th><th>Email</th><th>Phone</th><th>City / Cities</th><th>Status</th><th>Created</th><th>Actions</th></tr>
      </thead>
      <tbody>
      <?php foreach($subAdmins as $sa): ?>
      <tr>
        <td>
          <div class="d-flex align-items-center gap-2">
            <div style="width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#1a56db,#7c3aed);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.82rem;color:#fff">
              <?= strtoupper(substr($sa['full_name'],0,1)) ?>
            </div>
            <span class="fw-700 small"><?= esc($sa['full_name']) ?></span>
          </div>
        </td>
        <td class="small"><?= esc($sa['email']) ?></td>
        <td class="small"><?= esc($sa['phone']??'-') ?></td>
        <td>
          <div class="d-flex flex-wrap gap-1">
            <?php foreach($sa['cities']??[] as $c): ?>
            <div class="d-inline-flex align-items-center gap-1 badge rounded-pill" style="background:#dbeafe;color:#1e40af;font-size:.73rem">
              <?= esc($c) ?>
              <a href="/admin/super/sub-admins/<?= $sa['id'] ?>/revoke-city/<?= urlencode($c) ?>" class="text-danger ms-1" title="Revoke" onclick="return confirm('Remove city <?= esc($c) ?>?')">×</a>
            </div>
            <?php endforeach; ?>
            <!-- Assign city form — free text + datalist of Ethiopian cities -->
            <form action="/admin/super/sub-admins/<?= $sa['id'] ?>/assign-city" method="POST" class="d-inline-flex align-items-center gap-1 mt-1">
              <?= csrf_field() ?>
              <input type="text" name="city" list="ethiopian-cities-<?= $sa['id'] ?>"
                     class="form-control form-control-sm" placeholder="Type city name..."
                     style="font-size:.72rem;min-width:140px;border-radius:8px" required>
              <datalist id="ethiopian-cities-<?= $sa['id'] ?>">
                <?php
                $etCities = ['Addis Ababa','Dire Dawa','Mekelle','Gondar','Hawassa','Bahir Dar','Dessie',
                  'Jimma','Jijiga','Shashamane','Bishoftu','Sodo','Arba Minch','Hosaena','Harar',
                  'Dilla','Nekemte','Debre Birhan','Asella','Adama','Woldia','Debre Markos',
                  'Kombolcha','Arsi Negele','Ziway','Axum','Lalibela','Shire','Gambella',
                  'Assosa','Semera','Logia'];
                foreach($etCities as $ec): ?>
                <option value="<?= esc($ec) ?>">
                <?php endforeach; ?>
              </datalist>
              <button type="submit" class="btn btn-sm btn-primary rounded-pill fw-700" style="font-size:.72rem;padding:.2rem .8rem">
                <i class="bi bi-plus-lg"></i>
              </button>
            </form>
          </div>
        </td>
        <td><span class="status-<?= $sa['status'] ?>"><?= ucfirst($sa['status']) ?></span></td>
        <td class="small text-muted"><?= date('d M Y', strtotime($sa['created_at'])) ?></td>
        <td>
          <div class="d-flex gap-1">
            <a href="/admin/super/sub-admins/<?= $sa['id'] ?>/edit" class="btn btn-sm btn-outline-primary rounded-pill fw-700" style="font-size:.78rem">Edit</a>
            <form action="/admin/super/sub-admins/<?= $sa['id'] ?>/delete" method="POST" class="d-inline" onsubmit="return confirm('Deactivate this sub-admin?')">
              <?= csrf_field() ?>
              <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill fw-700" style="font-size:.78rem">Deactivate</button>
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
