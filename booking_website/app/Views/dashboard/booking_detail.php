<?= $this->extend('layouts/dashboard') ?>
<?= $this->section('content') ?>

<div class="d-flex align-items-center gap-3 mb-4 flex-wrap">
  <a href="/dashboard/bookings" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Back</a>
  <h4 class="fw-900 mb-0">Booking #<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?></h4>
  <span class="status-badge status-<?= $booking['status'] ?>"><?= ucfirst($booking['status']) ?></span>
</div>

<div class="row g-4">
  <div class="col-lg-7">
    <div class="card border-0 rounded-4 shadow mb-4 reveal">
      <div class="card-body p-4">
        <div class="d-flex gap-3 mb-4 pb-3 border-bottom">
          <img src="<?= esc($booking['hotel_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200') ?>"
               class="rounded-3" style="width:90px;height:80px;object-fit:cover" alt="">
          <div>
            <h5 class="fw-800 mb-1"><?= esc($booking['hotel_name']) ?></h5>
            <p class="text-muted small mb-1"><i class="bi bi-geo-alt-fill me-1 text-primary"></i><?= esc($booking['hotel_city']) ?></p>
            <?php if(!empty($booking['hotel_address'])): ?>
            <p class="text-muted small mb-0"><i class="bi bi-map me-1"></i><?= esc($booking['hotel_address']) ?></p>
            <?php endif; ?>
          </div>
        </div>
        <div class="row g-3 small">
          <div class="col-6"><div class="p-3 rounded-3 bg-light"><div class="text-muted mb-1">Check-In</div><div class="fw-700"><?= date('D, d M Y',strtotime($booking['check_in'])) ?></div><div class="text-muted" style="font-size:.75rem">From 2:00 PM</div></div></div>
          <div class="col-6"><div class="p-3 rounded-3 bg-light"><div class="text-muted mb-1">Check-Out</div><div class="fw-700"><?= date('D, d M Y',strtotime($booking['check_out'])) ?></div><div class="text-muted" style="font-size:.75rem">Until 12:00 PM</div></div></div>
          <div class="col-4"><div class="text-muted mb-1">Nights</div><div class="fw-700"><?= (strtotime($booking['check_out'])-strtotime($booking['check_in']))/86400 ?></div></div>
          <div class="col-4"><div class="text-muted mb-1">Guests</div><div class="fw-700"><?= $booking['adults'] ?> adult<?= $booking['adults']>1?'s':'' ?><?= $booking['children']>0?', '.$booking['children'].' child':'' ?></div></div>
          <div class="col-4"><div class="text-muted mb-1">Rooms</div><div class="fw-700"><?= $booking['rooms'] ?></div></div>
          <?php if(!empty($booking['room_type_name'])): ?>
          <div class="col-12"><div class="text-muted mb-1">Room Type</div><div class="fw-700"><?= esc($booking['room_type_name']) ?></div></div>
          <?php endif; ?>
          <?php if(!empty($booking['special_requests'])): ?>
          <div class="col-12"><div class="text-muted mb-1">Special Requests</div><div class="fw-600"><?= esc($booking['special_requests']) ?></div></div>
          <?php endif; ?>
        </div>
      </div>
    </div>

    <div class="d-flex gap-3 flex-wrap">
      <?php if(in_array($booking['status'],['pending','confirmed'])): ?>
      <form action="/dashboard/bookings/<?= $booking['id'] ?>/cancel" method="POST">
        <?= csrf_field() ?>
        <button type="submit" class="btn btn-outline-danger rounded-pill fw-700 px-4" data-confirm="Are you sure you want to cancel this booking?">
          <i class="bi bi-x-circle me-2"></i>Cancel Booking
        </button>
      </form>
      <?php endif; ?>
      <?php if($booking['status']==='pending'): ?>
      <a href="/booking/payment/<?= $booking['id'] ?>" class="btn btn-primary rounded-pill fw-700 px-4">
        <i class="bi bi-credit-card me-2"></i>Complete Payment
      </a>
      <?php endif; ?>
      <a href="/hotels/<?= $booking['hotel_id'] ?>" class="btn btn-outline-secondary rounded-pill fw-700 px-4">
        <i class="bi bi-building me-2"></i>View Hotel
      </a>
    </div>
  </div>

  <div class="col-lg-5">
    <div class="card border-0 rounded-4 shadow mb-4 reveal">
      <div class="card-header bg-white border-0 pt-3 px-4"><h6 class="fw-800 mb-0">Payment Summary</h6></div>
      <div class="card-body px-4">
        <div class="small">
          <div class="d-flex justify-content-between mb-2"><span class="text-muted">Payment Method</span><span class="fw-700 text-capitalize"><?= str_replace('_',' ',$booking['payment_method']) ?></span></div>
          <div class="d-flex justify-content-between mb-2"><span class="text-muted">Booked On</span><span class="fw-700"><?= date('d M Y H:i',strtotime($booking['created_at'])) ?></span></div>
        </div>
        <hr>
        <div class="d-flex justify-content-between fw-900">
          <span>Total Amount</span>
          <span class="text-primary fs-5">ETB <?= number_format($booking['total_price'],0) ?></span>
        </div>
      </div>
    </div>
    <div class="card border-0 rounded-4 text-center p-4 reveal" style="background:linear-gradient(135deg,#eff6ff,#dbeafe);border:2px solid #bfdbfe !important">
      <div class="text-muted small mb-1 fw-600">Booking Reference</div>
      <div class="booking-ref" style="font-size:1.8rem">#<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?></div>
      <div class="text-muted small mt-1">Show this at hotel check-in</div>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
