<?= $this->extend('layouts/dashboard') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <h4 class="fw-900 mb-0"><i class="bi bi-calendar-check-fill me-2 text-primary"></i>My Bookings</h4>
  <a href="/hotels" class="btn btn-primary rounded-pill px-4 fw-700"><i class="bi bi-plus me-1"></i>New Booking</a>
</div>

<!-- Filter tabs -->
<div class="d-flex flex-wrap gap-2 mb-4">
  <?php
  $tabs = ['all'=>'All','pending'=>'Pending','confirmed'=>'Confirmed','completed'=>'Completed','cancelled'=>'Cancelled'];
  $colors = ['all'=>'primary','pending'=>'warning','confirmed'=>'success','completed'=>'info','cancelled'=>'danger'];
  foreach($tabs as $k=>$v):
    $cnt = $k==='all' ? array_sum($counts??[]) : ($counts[$k]??0);
    $isActive = $filter===$k;
  ?>
  <a href="/dashboard/bookings?status=<?= $k ?>"
     class="btn btn-sm rounded-pill fw-700 <?= $isActive?'btn-'.$colors[$k]:'btn-outline-'.$colors[$k] ?>">
    <?= $v ?>
    <span class="badge rounded-pill ms-1 <?= $isActive?'bg-white text-'.$colors[$k]:'bg-'.$colors[$k].' text-white' ?>"><?= $cnt ?></span>
  </a>
  <?php endforeach; ?>
</div>

<?php if(empty($bookings)): ?>
<div class="card border-0 rounded-4 shadow">
  <div class="card-body text-center py-5">
    <div class="anim-float d-inline-block mb-3"><i class="bi bi-calendar-x" style="font-size:3.5rem;color:#94a3b8"></i></div>
    <h5 class="fw-800 mb-2">No <?= $filter!=='all'?ucfirst($filter):'' ?> Bookings</h5>
    <p class="text-muted small mb-4">Start exploring Ethiopia's amazing hotels.</p>
    <a href="/hotels" class="btn btn-primary rounded-pill px-5 fw-700">Find a Hotel</a>
  </div>
</div>
<?php else: ?>
<div class="d-flex flex-column gap-3">
<?php foreach($bookings as $b): ?>
<div class="booking-list-card">
  <div class="card-body p-3 p-md-4">
    <div class="row align-items-center g-3">
      <div class="col-auto">
        <img src="<?= esc($b['hotel_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=150') ?>"
             class="rounded-3" style="width:90px;height:80px;object-fit:cover" alt="">
      </div>
      <div class="col">
        <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
          <div>
            <h6 class="fw-800 mb-1"><?= esc($b['hotel_name']) ?></h6>
            <p class="text-muted small mb-1">
              <i class="bi bi-geo-alt-fill me-1 text-primary"></i><?= esc($b['hotel_city']) ?>
              <span class="mx-2">·</span>
              <i class="bi bi-calendar3 me-1"></i><?= date('d M',strtotime($b['check_in'])) ?> – <?= date('d M Y',strtotime($b['check_out'])) ?>
              <span class="mx-2">·</span>
              <?= (strtotime($b['check_out'])-strtotime($b['check_in']))/86400 ?> night<?= (strtotime($b['check_out'])-strtotime($b['check_in']))/86400>1?'s':'' ?>
            </p>
            <p class="text-muted small mb-0">
              <i class="bi bi-people me-1"></i><?= $b['adults'] ?> adult<?= $b['adults']>1?'s':'' ?><?= $b['children']>0?', '.$b['children'].' child':'' ?>
              <span class="mx-2">·</span>
              <i class="bi bi-door-closed me-1"></i><?= $b['rooms'] ?> room<?= $b['rooms']>1?'s':'' ?>
            </p>
          </div>
          <div class="text-end">
            <span class="status-badge status-<?= $b['status'] ?> d-block mb-2"><?= ucfirst($b['status']) ?></span>
            <div class="fw-900 text-primary" style="font-size:1.1rem">ETB <?= number_format($b['total_price'],0) ?></div>
          </div>
        </div>
      </div>
      <div class="col-auto d-flex flex-column gap-2">
        <a href="/dashboard/bookings/<?= $b['id'] ?>" class="btn btn-sm btn-outline-primary rounded-pill fw-700 px-3">Details</a>
        <?php if(in_array($b['status'],['pending','confirmed'])): ?>
        <form action="/dashboard/bookings/<?= $b['id'] ?>/cancel" method="POST">
          <?= csrf_field() ?>
          <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill fw-700 w-100"
                  data-confirm="Cancel this booking?">Cancel</button>
        </form>
        <?php endif; ?>
        <?php if($b['status']==='pending'): ?>
        <a href="/booking/payment/<?= $b['id'] ?>" class="btn btn-sm btn-warning rounded-pill fw-700 px-3">Pay Now</a>
        <?php endif; ?>
      </div>
    </div>
  </div>
</div>
<?php endforeach; ?>
</div>
<?php endif; ?>

<?= $this->endSection() ?>
