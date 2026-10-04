<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-900 mb-0">All Bookings</h4>
</div>

<div class="d-flex flex-wrap gap-2 mb-4">
  <?php foreach([''=>'All','pending'=>'Pending','confirmed'=>'Confirmed','completed'=>'Completed','cancelled'=>'Cancelled'] as $k=>$v): ?>
  <a href="/admin/super/bookings<?= $k?'?status='.$k:'' ?>"
     class="btn btn-sm rounded-pill fw-700 <?= $status===$k?'btn-primary':'btn-outline-secondary' ?>">
    <?= $v ?> <?php if(isset($counts[$k])): ?><span class="badge <?= $status===$k?'bg-white text-primary':'bg-secondary' ?> ms-1"><?= $counts[$k] ?></span><?php endif; ?>
  </a>
  <?php endforeach; ?>
</div>

<div class="admin-card p-0">
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>#</th><th>Guest</th><th>Hotel / City</th><th>Dates</th><th>Guests</th><th>Total</th><th>Payment</th><th>Status</th></tr></thead>
      <tbody>
      <?php foreach($bookings as $b): ?>
      <tr>
        <td class="small text-muted"><?= str_pad($b['id'],4,'0',STR_PAD_LEFT) ?></td>
        <td><div class="fw-700 small"><?= esc($b['guest_name']) ?></div><div class="text-muted" style="font-size:.73rem"><?= esc($b['guest_email']) ?></div></td>
        <td><div class="small fw-600"><?= esc($b['hotel_name']) ?></div><div class="text-muted" style="font-size:.73rem"><?= esc($b['city']) ?></div></td>
        <td class="small"><?= date('d M',strtotime($b['check_in'])) ?> → <?= date('d M Y',strtotime($b['check_out'])) ?></td>
        <td class="small"><?= $b['adults'] ?>A<?= $b['children']>0?'+'.$b['children'].'C':'' ?></td>
        <td class="fw-700 small text-primary">ETB <?= number_format($b['total_price'],0) ?></td>
        <td class="small text-capitalize"><?= str_replace('_',' ',$b['payment_method']) ?></td>
        <td><span class="bk-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>

<?= $this->endSection() ?>
