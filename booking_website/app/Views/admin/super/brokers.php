<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4">All Brokers</h4>

<div class="admin-card p-0">
  <?php if(empty($brokers)): ?>
  <div class="text-center py-5"><i class="bi bi-people fs-1 text-muted d-block mb-2"></i><p class="text-muted">No brokers yet. Sub-admins create brokers in their city.</p></div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Broker</th><th>City</th><th>Sub-Admin</th><th>Hotels</th><th>Commission</th><th>Status</th></tr></thead>
      <tbody>
      <?php foreach($brokers as $b): ?>
      <tr>
        <td><div class="fw-700 small"><?= esc($b['broker_name']) ?></div><div class="text-muted" style="font-size:.73rem"><?= esc($b['broker_email']) ?></div></td>
        <td class="small"><?= esc($b['city']) ?></td>
        <td class="small"><?= esc($b['sub_admin_name']) ?></td>
        <td><span class="badge bg-primary rounded-pill"><?= $b['hotel_count'] ?></span></td>
        <td class="small fw-700"><?= $b['commission_pct'] ?>%</td>
        <td><span class="status-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
