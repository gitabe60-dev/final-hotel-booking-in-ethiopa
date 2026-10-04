<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4">Hotel Managers</h4>

<div class="admin-card p-0">
  <?php if(empty($managers)): ?>
  <div class="text-center py-5"><i class="bi bi-building-gear fs-1 text-muted d-block mb-2"></i><p class="text-muted">No hotel managers assigned yet.</p></div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Manager</th><th>Hotel</th><th>City</th><th>Broker</th><th>Sub-Admin</th></tr></thead>
      <tbody>
      <?php foreach($managers as $m): ?>
      <tr>
        <td><div class="fw-700 small"><?= esc($m['manager_name']) ?></div><div class="text-muted" style="font-size:.73rem"><?= esc($m['manager_email']) ?></div></td>
        <td class="small fw-600"><?= esc($m['hotel_name']) ?></td>
        <td class="small"><?= esc($m['hotel_city']) ?></td>
        <td class="small"><?= esc($m['broker_name']??'Not assigned') ?></td>
        <td class="small"><?= esc($m['sub_admin_name']??'-') ?></td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
