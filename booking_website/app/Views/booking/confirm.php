<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-7">

      <!-- Success / Pending Banner -->
      <div class="text-center mb-5 reveal">
        <div class="success-icon-wrap mb-3">
          <i class="bi <?= $booking['status']==='confirmed'?'bi-check-lg':'bi-clock' ?> text-white" style="font-size:2.5rem"></i>
        </div>
        <h2 class="fw-900 mb-2">
          <?= $booking['status']==='confirmed' ? '🎉 Booking Confirmed!' : '⏳ Booking Pending' ?>
        </h2>
        <p class="text-muted">
          <?php if($booking['status']==='confirmed'): ?>
            Your reservation at <strong><?= esc($booking['hotel_name']) ?></strong> is confirmed. We can't wait to host you!
          <?php else: ?>
            Your booking is created. Complete payment below to confirm your reservation.
          <?php endif; ?>
        </p>
      </div>

      <!-- Booking Reference -->
      <div class="text-center mb-4 reveal">
        <div class="d-inline-block px-5 py-3 rounded-4" style="background:linear-gradient(135deg,#eff6ff,#dbeafe);border:2px solid #bfdbfe">
          <div class="text-muted small fw-600 mb-1">Booking Reference</div>
          <div class="booking-ref">#<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?></div>
          <div class="text-muted small mt-1">Show this code at hotel check-in</div>
        </div>
      </div>

      <!-- Booking Details Card -->
      <div class="card border-0 rounded-4 shadow mb-4 reveal">
        <div class="card-body p-4">
          <div class="d-flex align-items-center gap-3 mb-4">
            <img src="<?= esc($booking['hotel_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200') ?>"
                 class="rounded-3" style="width:80px;height:70px;object-fit:cover" alt="">
            <div class="flex-grow-1">
              <h5 class="fw-800 mb-1"><?= esc($booking['hotel_name']) ?></h5>
              <p class="text-muted small mb-0"><i class="bi bi-geo-alt-fill me-1 text-primary"></i><?= esc($booking['hotel_city']) ?></p>
            </div>
            <span class="status-badge status-<?= $booking['status'] ?>"><?= ucfirst($booking['status']) ?></span>
          </div>

          <div class="row g-3 small">
            <div class="col-6">
              <div class="p-3 rounded-3" style="background:#f8fafc">
                <div class="text-muted mb-1">Check-In</div>
                <div class="fw-700"><?= date('D, d M Y',strtotime($booking['check_in'])) ?></div>
                <div class="text-muted" style="font-size:.75rem">From 2:00 PM</div>
              </div>
            </div>
            <div class="col-6">
              <div class="p-3 rounded-3" style="background:#f8fafc">
                <div class="text-muted mb-1">Check-Out</div>
                <div class="fw-700"><?= date('D, d M Y',strtotime($booking['check_out'])) ?></div>
                <div class="text-muted" style="font-size:.75rem">Until 12:00 PM</div>
              </div>
            </div>
            <div class="col-4">
              <div class="text-muted mb-1">Nights</div>
              <div class="fw-700"><?= (strtotime($booking['check_out'])-strtotime($booking['check_in']))/86400 ?></div>
            </div>
            <div class="col-4">
              <div class="text-muted mb-1">Guests</div>
              <div class="fw-700"><?= $booking['adults'] ?> adult<?= $booking['adults']>1?'s':'' ?><?= $booking['children']>0?', '.$booking['children'].' child':'' ?></div>
            </div>
            <div class="col-4">
              <div class="text-muted mb-1">Rooms</div>
              <div class="fw-700"><?= $booking['rooms'] ?></div>
            </div>
            <?php if(!empty($booking['room_type_name'])): ?>
            <div class="col-12">
              <div class="text-muted mb-1">Room Type</div>
              <div class="fw-700"><?= esc($booking['room_type_name']) ?></div>
            </div>
            <?php endif; ?>
            <div class="col-6">
              <div class="text-muted mb-1">Payment</div>
              <div class="fw-700 text-capitalize"><?= str_replace('_',' ',$booking['payment_method']) ?></div>
            </div>
            <div class="col-6">
              <div class="text-muted mb-1">Total Paid</div>
              <div class="fw-800 text-primary fs-5">ETB <?= number_format($booking['total_price'],0) ?></div>
            </div>
            <?php if(!empty($booking['special_requests'])): ?>
            <div class="col-12">
              <div class="text-muted mb-1">Special Requests</div>
              <div class="fw-600 small"><?= esc($booking['special_requests']) ?></div>
            </div>
            <?php endif; ?>
          </div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="d-flex flex-wrap gap-3 justify-content-center reveal">
        <?php if($booking['status']==='pending'): ?>
        <a href="/booking/payment/<?= $booking['id'] ?>" class="btn btn-primary px-5 py-3 rounded-pill fw-700">
          <i class="bi bi-credit-card me-2"></i>Complete Payment
        </a>
        <?php endif; ?>
        <a href="/dashboard/bookings" class="btn btn-outline-primary px-4 py-3 rounded-pill fw-700">
          <i class="bi bi-calendar-check me-2"></i>My Bookings
        </a>
        <a href="/hotels" class="btn btn-outline-secondary px-4 py-3 rounded-pill fw-700">
          <i class="bi bi-search me-2"></i>Find More Hotels
        </a>
      </div>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
