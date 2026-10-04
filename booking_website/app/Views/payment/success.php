<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<?php $methods = \App\Controllers\Web\PaymentWebController::METHODS; ?>

<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-7">

      <?= view('payment/_steps', ['step' => 4, 'bookingId' => $booking['id']]) ?>

      <!-- ── Success Banner ─────────────────────────────────────────── -->
      <div class="text-center mb-4">
        <div class="success-icon-wrap mb-3 mx-auto" style="animation:bounceIn .8s ease">
          <i class="bi bi-check-lg text-white" style="font-size:2.5rem"></i>
        </div>
        <h2 class="fw-900 mb-2" style="color:#0f172a">🎉 Booking Confirmed!</h2>
        <p class="text-muted">
          Your stay at <strong><?= esc($booking['hotel_name']) ?></strong> is confirmed.
          We can't wait to host you!
        </p>
      </div>

      <!-- ── Booking Reference ─────────────────────────────────────── -->
      <div class="text-center mb-4 p-4 rounded-4"
           style="background:linear-gradient(135deg,#eff6ff,#dbeafe);border:2px dashed #3b82f6">
        <div class="text-muted small fw-700 mb-1 text-uppercase" style="letter-spacing:.1em">Booking Reference</div>
        <div class="fw-900 text-primary" style="font-size:2.4rem;letter-spacing:.15em;font-family:monospace">
          #<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?>
        </div>
        <div class="text-muted small mt-1">Show this code at hotel reception on check-in</div>
      </div>

      <!-- ── Booking Details Card ──────────────────────────────────── -->
      <div class="card border-0 rounded-4 shadow mb-4">
        <div class="card-body p-4">
          <!-- Hotel -->
          <div class="d-flex gap-3 mb-4 pb-4 border-bottom">
            <img src="<?= esc($booking['hotel_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400') ?>"
                 class="rounded-3 flex-shrink-0" style="width:80px;height:72px;object-fit:cover" alt="">
            <div class="flex-grow-1">
              <h5 class="fw-800 mb-1"><?= esc($booking['hotel_name']) ?></h5>
              <div class="text-muted small"><i class="bi bi-geo-alt-fill me-1 text-primary"></i><?= esc($booking['hotel_city']) ?></div>
            </div>
            <span class="status-badge status-confirmed align-self-start">Confirmed</span>
          </div>

          <!-- Dates + details -->
          <div class="row g-3 mb-3">
            <div class="col-6">
              <div class="p-3 rounded-3" style="background:#f8fafc">
                <div class="text-muted small fw-600 mb-1"><i class="bi bi-calendar-event me-1"></i>Check-In</div>
                <div class="fw-800"><?= date('D, d M Y', strtotime($booking['check_in'])) ?></div>
                <div class="text-muted small">2:00 PM</div>
              </div>
            </div>
            <div class="col-6">
              <div class="p-3 rounded-3" style="background:#f8fafc">
                <div class="text-muted small fw-600 mb-1"><i class="bi bi-calendar2-check me-1"></i>Check-Out</div>
                <div class="fw-800"><?= date('D, d M Y', strtotime($booking['check_out'])) ?></div>
                <div class="text-muted small">12:00 PM</div>
              </div>
            </div>
          </div>
          <div class="row g-2 small mb-3">
            <div class="col-4 text-center py-2 rounded-3" style="background:#f8fafc">
              <div class="fw-900 text-primary"><?= $nights ?></div>
              <div class="text-muted">Night<?= $nights>1?'s':'' ?></div>
            </div>
            <div class="col-4 text-center py-2 rounded-3" style="background:#f8fafc">
              <div class="fw-900 text-primary"><?= $booking['adults'] ?></div>
              <div class="text-muted">Guest<?= $booking['adults']>1?'s':'' ?></div>
            </div>
            <div class="col-4 text-center py-2 rounded-3" style="background:#f8fafc">
              <div class="fw-900 text-primary"><?= $booking['rooms'] ?></div>
              <div class="text-muted">Room<?= $booking['rooms']>1?'s':'' ?></div>
            </div>
          </div>
        </div>
      </div>

      <!-- ── Payment Receipt ───────────────────────────────────────── -->
      <?php if(!empty($receipt)): ?>
      <?php $mInfo = $methods[$receipt['method']] ?? ['icon'=>'💰','color'=>'#1a56db','name'=>'Payment']; ?>
      <div class="card border-0 rounded-4 shadow mb-4">
        <div class="card-header rounded-top-4 border-0 py-3 px-4"
             style="background:linear-gradient(135deg,<?= esc($mInfo['color']) ?>,<?= esc($mInfo['color']) ?>bb)">
          <div class="d-flex align-items-center gap-2 text-white">
            <span style="font-size:1.5rem"><?= $mInfo['icon'] ?></span>
            <span class="fw-800">Payment Receipt</span>
          </div>
        </div>
        <div class="card-body p-4">
          <div class="row g-2 small">
            <div class="col-6 text-muted">Payment Method</div>
            <div class="col-6 fw-700"><?= esc($receipt['method_name'] ?? '') ?></div>
            <div class="col-6 text-muted">Transaction ID</div>
            <div class="col-6 fw-700 font-monospace" style="font-size:.85rem"><?= esc($receipt['tx_id'] ?? '') ?></div>
            <div class="col-6 text-muted">Paid At</div>
            <div class="col-6 fw-700"><?= esc($receipt['paid_at'] ?? '') ?></div>
            <?php if(!empty($receipt['details'])): ?>
            <?php if(isset($receipt['details']['card_number'])): ?>
            <div class="col-6 text-muted">Card</div>
            <div class="col-6 fw-700 font-monospace"><?= esc($receipt['details']['card_number']) ?></div>
            <?php elseif(isset($receipt['details']['phone']) && $receipt['details']['phone']): ?>
            <div class="col-6 text-muted">Phone</div>
            <div class="col-6 fw-700">+251 <?= esc($receipt['details']['phone']) ?></div>
            <?php elseif(isset($receipt['details']['account']) && $receipt['details']['account']): ?>
            <div class="col-6 text-muted">Account</div>
            <div class="col-6 fw-700 font-monospace"><?= esc($receipt['details']['account']) ?></div>
            <?php endif; ?>
            <?php endif; ?>
            <div class="col-12"><hr class="my-1"></div>
            <div class="col-6 fw-800 fs-6">Amount Paid</div>
            <div class="col-6 fw-900 fs-6 text-primary">ETB <?= number_format($booking['total_price'], 0) ?></div>
          </div>
        </div>
      </div>
      <?php elseif($payment): ?>
      <div class="card border-0 rounded-4 shadow-sm mb-4">
        <div class="card-body p-4">
          <div class="d-flex justify-content-between fw-700 mb-2">
            <span>Payment Method</span>
            <span class="text-capitalize"><?= str_replace('_',' ',$booking['payment_method']) ?></span>
          </div>
          <div class="d-flex justify-content-between fw-800 fs-5">
            <span>Total Paid</span>
            <span class="text-primary">ETB <?= number_format($booking['total_price'], 0) ?></span>
          </div>
        </div>
      </div>
      <?php endif; ?>

      <!-- ── Action Buttons ────────────────────────────────────────── -->
      <div class="d-flex flex-wrap gap-3 justify-content-center mb-4">
        <a href="/dashboard/bookings/<?= $booking['id'] ?>" class="btn btn-primary rounded-pill fw-700 px-5 py-3">
          <i class="bi bi-calendar-check me-2"></i>View My Booking
        </a>
        <a href="/hotels" class="btn btn-outline-primary rounded-pill fw-700 px-4 py-3">
          <i class="bi bi-search me-2"></i>Find More Hotels
        </a>
      </div>

      <!-- ── What's next ───────────────────────────────────────────── -->
      <div class="card border-0 rounded-4" style="background:linear-gradient(135deg,#f0fdf4,#dcfce7);border:1px solid #bbf7d0!important">
        <div class="card-body p-4">
          <h6 class="fw-800 text-success mb-3"><i class="bi bi-info-circle me-2"></i>What happens next?</h6>
          <div class="d-flex flex-column gap-3 small">
            <div class="d-flex gap-3 align-items-start">
              <div class="rounded-circle text-white fw-800 d-flex align-items-center justify-content-center flex-shrink-0"
                   style="width:28px;height:28px;background:#10b981;font-size:.75rem">1</div>
              <div>
                <div class="fw-700">Confirmation Email</div>
                <div class="text-muted">A confirmation will be sent to <?= esc($booking['guest_email'] ?? session()->get('user_email')) ?></div>
              </div>
            </div>
            <div class="d-flex gap-3 align-items-start">
              <div class="rounded-circle text-white fw-800 d-flex align-items-center justify-content-center flex-shrink-0"
                   style="width:28px;height:28px;background:#10b981;font-size:.75rem">2</div>
              <div>
                <div class="fw-700">Check-In</div>
                <div class="text-muted">Show reference <strong>#<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?></strong> at hotel reception</div>
              </div>
            </div>
            <div class="d-flex gap-3 align-items-start">
              <div class="rounded-circle text-white fw-800 d-flex align-items-center justify-content-center flex-shrink-0"
                   style="width:28px;height:28px;background:#10b981;font-size:.75rem">3</div>
              <div>
                <div class="fw-700">Enjoy Your Stay!</div>
                <div class="text-muted">Relax and enjoy everything <?= esc($booking['hotel_name']) ?> has to offer</div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</div>

<?= $this->endSection() ?>
