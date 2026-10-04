<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4">Bookings for My Hotels</h4>

<div class="d-flex flex-wrap gap-2 mb-4">
  <?php foreach([''=>'All','pending'=>'Pending','confirmed'=>'Confirmed','completed'=>'Completed','cancelled'=>'Cancelled'] as $k=>$v): ?>
  <a href="/admin/broker/bookings<?= $k?'?status='.$k:'' ?>"
     class="btn btn-sm rounded-pill fw-700 <?= $status===$k?'btn-primary':'btn-outline-secondary' ?>"><?= $v ?></a>
  <?php endforeach; ?>
</div>

<div class="admin-card p-0">
  <?php if(empty($bookings)): ?>
  <div class="text-center py-5 text-muted"><i class="bi bi-calendar-x fs-1 d-block mb-2"></i><p>No bookings found.</p></div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>#</th><th>Guest</th><th>Hotel</th><th>Dates</th><th>Total</th><th>Status</th></tr></thead>
      <tbody>
      <?php foreach($bookings as $b): ?>
      <tr>
        <td class="text-muted small"><?= str_pad($b['id'],4,'0',STR_PAD_LEFT) ?></td>
        <td class="fw-700 small"><?= esc($b['guest_name']) ?></td>
        <td class="small fw-600"><?= esc($b['hotel_name']) ?></td>
        <td class="small"><?= date('d M',strtotime($b['check_in'])) ?> → <?= date('d M Y',strtotime($b['check_out'])) ?></td>
        <td class="fw-700 text-primary small">ETB <?= number_format($b['total_price'],0) ?></td>
        <td><span class="bk-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
