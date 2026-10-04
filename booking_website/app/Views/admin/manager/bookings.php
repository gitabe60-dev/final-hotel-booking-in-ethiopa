<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4">Bookings — <?= esc($hotel['name'] ?? '') ?></h4>

<div class="d-flex flex-wrap gap-2 mb-4">
  <?php foreach([''=>'All','pending'=>'Pending','confirmed'=>'Confirmed','completed'=>'Completed','cancelled'=>'Cancelled'] as $k=>$v): ?>
  <a href="/admin/manager/bookings<?= $k?'?status='.$k:'' ?>"
     class="btn btn-sm rounded-pill fw-700 <?= $status===$k?'btn-primary':'btn-outline-secondary' ?>"><?= $v ?></a>
  <?php endforeach; ?>
</div>

<div class="admin-card p-0">
  <?php if(empty($bookings)): ?>
  <div class="text-center py-5 text-muted"><i class="bi bi-calendar-x fs-1 d-block mb-2"></i><p>No bookings found.</p></div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>#</th><th>Guest</th><th>Room Type</th><th>Check-In → Out</th><th>Guests</th><th>Total</th><th>Payment</th><th>Status</th><th>Action</th></tr></thead>
      <tbody>
      <?php foreach($bookings as $b): ?>
      <tr>
        <td class="text-muted small"><?= str_pad($b['id'],4,'0',STR_PAD_LEFT) ?></td>
        <td>
          <div class="fw-700 small"><?= esc($b['guest_name']) ?></div>
          <div class="text-muted" style="font-size:.73rem"><?= esc($b['guest_email']) ?></div>
          <?php if($b['guest_phone']??''): ?><div class="text-muted" style="font-size:.73rem"><?= esc($b['guest_phone']) ?></div><?php endif; ?>
        </td>
        <td class="small"><?= esc($b['room_type_name']??'Any') ?></td>
        <td class="small"><?= date('d M Y',strtotime($b['check_in'])) ?><br><?= date('d M Y',strtotime($b['check_out'])) ?></td>
        <td class="small"><?= $b['adults'] ?>A <?= $b['children']>0?$b['children'].'C':'' ?> · <?= $b['rooms'] ?>R</td>
        <td class="fw-700 text-primary small">ETB <?= number_format($b['total_price'],0) ?></td>
        <td class="small text-capitalize"><?= str_replace('_',' ',$b['payment_method']) ?></td>
        <td><span class="bk-<?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
        <td>
          <?php if(in_array($b['status'],['pending'])): ?>
          <form action="/admin/manager/bookings/<?= $b['id'] ?>/status" method="POST" class="d-flex gap-1">
            <?= csrf_field() ?>
            <button type="submit" name="status" value="confirmed" class="btn btn-sm btn-success rounded-pill fw-700" style="font-size:.72rem">Confirm</button>
            <button type="submit" name="status" value="cancelled" class="btn btn-sm btn-danger rounded-pill fw-700" style="font-size:.72rem">Cancel</button>
          </form>
          <?php elseif($b['status']==='confirmed'): ?>
          <form action="/admin/manager/bookings/<?= $b['id'] ?>/status" method="POST">
            <?= csrf_field() ?>
            <button type="submit" name="status" value="completed" class="btn btn-sm btn-info rounded-pill fw-700" style="font-size:.72rem">Complete</button>
          </form>
          <?php else: ?>
          <span class="text-muted small">—</span>
          <?php endif; ?>
        </td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
