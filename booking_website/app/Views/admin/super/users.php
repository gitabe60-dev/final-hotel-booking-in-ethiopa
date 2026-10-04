<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-900 mb-0">All Guests</h4>
</div>

<div class="admin-card p-3 mb-4">
  <form action="/admin/super/users" method="GET" class="d-flex gap-2">
    <div class="input-group" style="max-width:360px">
      <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
      <input type="text" name="q" class="form-control border-start-0" placeholder="Search name, email or phone..." value="<?= esc($search) ?>">
    </div>
    <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">Search</button>
    <?php if($search): ?><a href="/admin/super/users" class="btn btn-outline-secondary rounded-3">Clear</a><?php endif; ?>
  </form>
</div>

<div class="admin-card p-0">
  <div class="p-3 border-bottom fw-700"><?= count($users) ?> guest<?= count($users)!==1?'s':'' ?> found</div>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Guest</th><th>Email</th><th>Phone</th><th>Bookings</th><th>Status</th><th>Joined</th></tr></thead>
      <tbody>
      <?php foreach($users as $u): ?>
      <tr>
        <td>
          <div class="d-flex align-items-center gap-2">
            <div style="width:34px;height:34px;border-radius:50%;background:#eff6ff;display:flex;align-items:center;justify-content:center;font-weight:800;color:#1a56db;font-size:.85rem">
              <?= strtoupper(substr($u['first_name'],0,1)) ?>
            </div>
            <span class="fw-700 small"><?= esc($u['first_name'].' '.$u['last_name']) ?></span>
          </div>
        </td>
        <td class="small"><?= esc($u['email']??'-') ?></td>
        <td class="small"><?= esc($u['phone']??'-') ?></td>
        <td><span class="badge bg-primary rounded-pill"><?= $u['booking_count'] ?></span></td>
        <td><span class="<?= $u['status']==='active'?'status-active':'status-suspended' ?>"><?= ucfirst($u['status']) ?></span></td>
        <td class="small text-muted"><?= date('d M Y',strtotime($u['registered_date'])) ?></td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>

<?= $this->endSection() ?>
