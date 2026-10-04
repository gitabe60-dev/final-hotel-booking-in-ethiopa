<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php $admin['city'] = $city ?? ''; ?>
<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-900 mb-0">Brokers in <span class="text-primary"><?= esc($city) ?></span></h4>
  <a href="/admin/subadmin/brokers/create" class="btn btn-primary rounded-pill fw-700 px-4"><i class="bi bi-person-plus me-1"></i>Add Broker</a>
</div>

<div class="admin-card p-0">
  <?php if(empty($brokers)): ?>
  <div class="text-center py-5"><i class="bi bi-people fs-1 text-muted d-block mb-2"></i><h6 class="fw-700">No Brokers Yet</h6><a href="/admin/subadmin/brokers/create" class="btn btn-primary rounded-pill fw-700 mt-2">Create First Broker</a></div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Broker</th><th>Email</th><th>Phone</th><th>Hotels</th><th>Commission</th><th>Status</th><th>Actions</th></tr></thead>
      <tbody>
      <?php foreach($brokers as $b): ?>
      <tr>
        <td>
          <div class="d-flex align-items-center gap-2">
            <div style="width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#10b981,#059669);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.82rem;color:#fff">
              <?= strtoupper(substr($b['broker_name'],0,1)) ?>
            </div>
            <span class="fw-700 small"><?= esc($b['broker_name']) ?></span>
          </div>
        </td>
        <td class="small"><?= esc($b['broker_email']) ?></td>
        <td class="small"><?= esc($b['broker_phone']??'-') ?></td>
        <td><span class="badge bg-primary rounded-pill"><?= $b['hotel_count'] ?></span></td>
        <td class="small fw-700"><?= $b['commission_pct'] ?>%</td>
        <td><span class="status-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
        <td>
          <div class="d-flex gap-1">
            <a href="/admin/subadmin/brokers/<?= $b['admin_id'] ?>/edit" class="btn btn-sm btn-outline-primary rounded-pill fw-700" style="font-size:.75rem">Edit</a>
            <form action="/admin/subadmin/brokers/<?= $b['admin_id'] ?>/delete" method="POST" class="d-inline" onsubmit="return confirm('Deactivate broker?')">
              <?= csrf_field() ?>
              <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill fw-700" style="font-size:.75rem">Deactivate</button>
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
