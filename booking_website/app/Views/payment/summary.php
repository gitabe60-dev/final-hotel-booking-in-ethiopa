<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-9">

      <?= view('payment/_steps', ['step' => $step, 'bookingId' => $booking['id']]) ?>

      <div class="text-center mb-4">
        <h3 class="fw-900 mb-1">Review Your Booking</h3>
        <p class="text-muted">Confirm everything is correct, then pay</p>
      </div>

      <div class="row g-4">

        <!-- ── Left: Full Booking Details ────────────────────────────── -->
        <div class="col-lg-7">
          <div class="card border-0 rounded-4 shadow-sm mb-4">
            <div class="card-body p-4">

              <!-- Hotel -->
              <div class="d-flex gap-3 mb-4 pb-4 border-bottom">
                <img src="<?= esc($booking['hotel_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400') ?>"
                     class="rounded-3 flex-shrink-0" style="width:90px;height:80px;object-fit:cover" alt="">
                <div class="flex-grow-1">
                  <h5 class="fw-800 mb-1"><?= esc($booking['hotel_name']) ?></h5>
                  <div class="text-muted small mb-1">
                    <i class="bi bi-geo-alt-fill me-1 text-primary"></i><?= esc($booking['hotel_city']) ?>
                  </div>
                  <?php if(!empty($booking['room_type_name'])): ?>
                  <span class="badge rounded-pill" style="background:#eff6ff;color:#1a56db;font-size:.75rem">
                    <i class="bi bi-door-open me-1"></i><?= esc($booking['room_type_name']) ?>
                  </span>
                  <?php endif; ?>
                </div>
              </div>

              <!-- Dates -->
              <div class="row g-3 mb-4">
                <div class="col-6">
                  <div class="p-3 rounded-3" style="background:#f8fafc;border:1px solid #e2e8f0">
                    <div class="text-muted small fw-600 mb-1"><i class="bi bi-calendar-event me-1"></i>Check-In</div>
                    <div class="fw-800"><?= date('D, d M Y', strtotime($booking['check_in'])) ?></div>
                    <div class="text-muted" style="font-size:.75rem">From 2:00 PM</div>
                  </div>
                </div>
                <div class="col-6">
                  <div class="p-3 rounded-3" style="background:#f8fafc;border:1px solid #e2e8f0">
                    <div class="text-muted small fw-600 mb-1"><i class="bi bi-calendar2-check me-1"></i>Check-Out</div>
                    <div class="fw-800"><?= date('D, d M Y', strtotime($booking['check_out'])) ?></div>
                    <div class="text-muted" style="font-size:.75rem">Until 12:00 PM</div>
                  </div>
                </div>
              </div>

              <!-- Guests & Rooms -->
              <div class="row g-2 mb-4 pb-4 border-bottom">
                <div class="col-4 text-center">
                  <div class="fw-900 fs-4 text-primary"><?= $nights ?></div>
                  <div class="text-muted small">Night<?= $nights>1?'s':'' ?></div>
                </div>
                <div class="col-4 text-center">
                  <div class="fw-900 fs-4 text-primary"><?= $booking['adults'] ?></div>
                  <div class="text-muted small">Adult<?= $booking['adults']>1?'s':'' ?></div>
                </div>
                <div class="col-4 text-center">
                  <div class="fw-900 fs-4 text-primary"><?= $booking['rooms'] ?></div>
                  <div class="text-muted small">Room<?= $booking['rooms']>1?'s':'' ?></div>
                </div>
              </div>

              <!-- Booking ref -->
              <div class="d-flex justify-content-between align-items-center mb-3">
                <span class="text-muted small fw-600">Booking Reference</span>
                <span class="fw-800 text-primary">#<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?></span>
              </div>
              <?php if(!empty($booking['special_requests'])): ?>
              <div class="p-2 rounded-3 small" style="background:#f8fafc">
                <span class="text-muted fw-600">Special Requests: </span><?= esc($booking['special_requests']) ?>
              </div>
              <?php endif; ?>
            </div>
          </div>

          <!-- Payment method selected -->
          <div class="card border-0 rounded-4 shadow-sm mb-4" style="border:2px solid #1a56db !important">
            <div class="card-body p-3 d-flex align-items-center gap-3">
              <div class="rounded-circle d-flex align-items-center justify-content-center"
                   style="width:50px;height:50px;background:<?= esc($methodInfo['color']) ?>;font-size:1.5rem;flex-shrink:0">
                <?= $methodInfo['icon'] ?>
              </div>
              <div class="flex-grow-1">
                <div class="fw-700"><?= esc($methodInfo['name']) ?></div>
                <div class="text-muted small">
                  <?php
                  $typeLabels = ['mobile'=>'Mobile payment','bank'=>'Bank transfer','card'=>'Card payment','cash'=>'Pay on arrival'];
                  echo $typeLabels[$methodInfo['type']] ?? 'Payment';
                  ?>
                </div>
              </div>
              <a href="/payment/<?= $booking['id'] ?>/method" class="btn btn-outline-secondary btn-sm rounded-pill fw-700">
                Change
              </a>
            </div>
          </div>
        </div>

        <!-- ── Right: Price Breakdown + Pay Now ──────────────────────── -->
        <div class="col-lg-5">
          <div class="card border-0 rounded-4 shadow-sm sticky-top" style="top:80px">
            <div class="card-header rounded-top-4 border-0 py-3"
                 style="background:linear-gradient(135deg,#1a56db,#7c3aed)">
              <h6 class="fw-800 text-white mb-0">Price Breakdown</h6>
            </div>
            <div class="card-body p-4">

              <!-- Line items -->
              <?php
              $unitPrice = $booking['total_price'] / max(1, $nights * $booking['rooms']);
              ?>
              <div class="d-flex justify-content-between small mb-2 text-muted">
                <span>ETB <?= number_format($unitPrice, 0) ?> × <?= $nights ?> nights</span>
                <span>ETB <?= number_format($unitPrice * $nights, 0) ?></span>
              </div>
              <div class="d-flex justify-content-between small mb-2 text-muted">
                <span>× <?= $booking['rooms'] ?> room<?= $booking['rooms']>1?'s':'' ?></span>
                <span>ETB <?= number_format($booking['total_price'], 0) ?></span>
              </div>
              <div class="d-flex justify-content-between small mb-2 text-muted">
                <span>Taxes & fees</span>
                <span class="text-success fw-600">Included</span>
              </div>
              <div class="d-flex justify-content-between small mb-2 text-muted">
                <span>Service fee</span>
                <span class="text-success fw-600">Free</span>
              </div>
              <hr>
              <div class="d-flex justify-content-between fw-900 mb-4">
                <span class="fs-5">Total</span>
                <span class="fs-5 text-primary">ETB <?= number_format($booking['total_price'], 0) ?></span>
              </div>

              <!-- PAY NOW button -->
              <?php
              $type = $methodInfo['type'];
              $nextUrl = match(true) {
                  $type === 'card'   => "/payment/{$booking['id']}/card",
                  $type === 'cash'   => "/payment/{$booking['id']}/process",
                  default            => "/payment/{$booking['id']}/bank",
              };
              ?>

              <?php if($type === 'cash'): ?>
              <form action="<?= $nextUrl ?>" method="POST">
                <?= csrf_field() ?>
                <button type="submit" class="btn w-100 py-3 fw-800 rounded-3 fs-5"
                        style="background:linear-gradient(135deg,#10b981,#059669);color:#fff">
                  <i class="bi bi-calendar-check me-2 fs-4"></i>Confirm Booking (Pay at Hotel)
                </button>
              </form>
              <?php else: ?>
              <a href="<?= $nextUrl ?>" class="btn w-100 py-3 fw-800 rounded-3 fs-5 d-block text-center"
                 style="background:linear-gradient(135deg,#1a56db,#7c3aed);color:#fff;text-decoration:none">
                <span style="font-size:1.4rem"><?= $methodInfo['icon'] ?></span>
                <span class="ms-2">Pay ETB <?= number_format($booking['total_price'], 0) ?></span>
                <div style="font-size:.78rem;font-weight:500;opacity:.9">via <?= esc($methodInfo['name']) ?></div>
              </a>
              <?php endif; ?>

              <!-- Security note -->
              <div class="mt-3 p-2 rounded-3 d-flex align-items-center gap-2 small"
                   style="background:#f0fdf4;border:1px solid #bbf7d0">
                <i class="bi bi-shield-fill-check text-success fs-5"></i>
                <span class="text-success fw-600">Secure 256-bit SSL encrypted payment</span>
              </div>

              <!-- Policies -->
              <div class="mt-3 small text-muted">
                <div class="d-flex gap-2 mb-1"><i class="bi bi-check-circle text-success"></i><span>Free cancellation before check-in</span></div>
                <div class="d-flex gap-2 mb-1"><i class="bi bi-check-circle text-success"></i><span>Instant booking confirmation</span></div>
                <div class="d-flex gap-2"><i class="bi bi-check-circle text-success"></i><span>24/7 customer support</span></div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</div>

<?= $this->endSection() ?>
