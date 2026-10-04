<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-9">
      <!-- Steps -->
      <div class="booking-steps mb-4">
        <div class="step-item done"><div class="step-circle"><i class="bi bi-check-lg"></i></div><div class="small text-muted">Details</div></div>
        <div class="step-item active"><div class="step-circle">2</div><div class="small fw-700 text-primary">Payment</div></div>
        <div class="step-item"><div class="step-circle">3</div><div class="small text-muted">Confirmed</div></div>
      </div>

      <div class="row g-4">
        <!-- Payment Form -->
        <div class="col-lg-7">
          <div class="card border-0 rounded-4 shadow">
            <div class="card-body p-4">
              <h5 class="fw-800 mb-4"><i class="bi bi-credit-card me-2 text-primary"></i>Select Payment Method</h5>

              <form action="/booking/payment/<?= $booking['id'] ?>" method="POST" id="paymentForm">
                <?= csrf_field() ?>

                <div class="row g-3 mb-4">
                  <?php
                  $methods = [
                    'telebirr'     =>['📱','Telebirr','Fast mobile payment'],
                    'cbe_birr'     =>['🏦','CBE Birr','Commercial Bank of Ethiopia'],
                    'card'         =>['💳','Credit/Debit Card','Visa, Mastercard'],
                    'mobile_money' =>['📲','Mobile Money','Safaricom, Ethio Telecom'],
                    'bank_transfer'=>['🏛️','Bank Transfer','Direct bank transfer'],
                    'cash'         =>['🏨','Pay at Hotel','Cash on arrival'],
                  ];
                  $current = $booking['payment_method'] ?? 'telebirr';
                  foreach($methods as $key=>[$emoji,$label,$sub]):
                  ?>
                  <div class="col-6">
                    <input type="radio" name="payment_method_select" id="pay_<?= $key ?>" value="<?= $key ?>" class="visually-hidden" <?= $current===$key?'checked':'' ?>>
                    <label for="pay_<?= $key ?>" class="payment-method-card w-100" data-method="<?= $key ?>">
                      <div class="fs-2 mb-1"><?= $emoji ?></div>
                      <div class="fw-700 small"><?= $label ?></div>
                      <div class="text-muted" style="font-size:.72rem"><?= $sub ?></div>
                    </label>
                  </div>
                  <?php endforeach; ?>
                </div>

                <!-- Card Fields (shown only for card) -->
                <div id="cardFields" style="display:<?= $current==='card'?'block':'none' ?>">
                  <div class="mb-3">
                    <label class="form-label small fw-700">Card Number</label>
                    <div class="input-icon-wrap">
                      <i class="bi bi-credit-card input-icon text-primary"></i>
                      <input type="text" class="form-control" placeholder="1234 5678 9012 3456" maxlength="19" oninput="this.value=this.value.replace(/[^\d ]/g,'').replace(/(.{4})/g,'$1 ').trim()">
                    </div>
                  </div>
                  <div class="row g-2">
                    <div class="col-6">
                      <label class="form-label small fw-700">Expiry Date</label>
                      <input type="text" class="form-control" placeholder="MM/YY" maxlength="5">
                    </div>
                    <div class="col-6">
                      <label class="form-label small fw-700">CVV</label>
                      <input type="password" class="form-control" placeholder="•••" maxlength="4">
                    </div>
                  </div>
                </div>

                <!-- Telebirr Fields (shown only for telebirr) -->
                <div id="telebirrFields" style="display:<?= $current==='telebirr'?'block':'none' ?>">
                  <div class="mb-3">
                    <label class="form-label small fw-700">Telebirr Phone Number</label>
                    <div class="input-group">
                      <span class="input-group-text">+251</span>
                      <input type="tel" class="form-control" placeholder="9xxxxxxxxx" maxlength="10">
                    </div>
                    <div class="form-text">You'll receive a payment prompt on your phone</div>
                  </div>
                </div>

                <div class="d-flex align-items-center gap-2 p-3 rounded-3 mb-4" style="background:#f0fdf4;border:1px solid #bbf7d0">
                  <i class="bi bi-shield-check text-success fs-4"></i>
                  <span class="small fw-600 text-success">Your payment is secured with 256-bit SSL encryption</span>
                </div>

                <button type="submit" class="btn btn-primary w-100 py-3 fw-800 rounded-3" style="font-size:1.05rem">
                  <i class="bi bi-lock-fill me-2"></i>Pay ETB <?= number_format($booking['total_price'],0) ?>
                </button>
              </form>
            </div>
          </div>
        </div>

        <!-- Order Summary -->
        <div class="col-lg-5">
          <div class="card border-0 rounded-4 shadow">
            <div class="card-header bg-white border-0 pt-3 px-4">
              <h6 class="fw-800 mb-0">Order Summary</h6>
            </div>
            <div class="card-body px-4">
              <div class="d-flex gap-3 mb-3">
                <img src="<?= esc($booking['hotel_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200') ?>"
                     class="rounded-3" style="width:65px;height:58px;object-fit:cover" alt="">
                <div>
                  <div class="fw-700 small"><?= esc($booking['hotel_name']) ?></div>
                  <div class="text-muted" style="font-size:.75rem"><?= esc($booking['hotel_city']) ?></div>
                </div>
              </div>
              <hr>
              <div class="small">
                <div class="d-flex justify-content-between mb-2"><span class="text-muted">Check-In</span><span class="fw-600"><?= date('d M Y',strtotime($booking['check_in'])) ?></span></div>
                <div class="d-flex justify-content-between mb-2"><span class="text-muted">Check-Out</span><span class="fw-600"><?= date('d M Y',strtotime($booking['check_out'])) ?></span></div>
                <div class="d-flex justify-content-between mb-2"><span class="text-muted">Nights</span><span class="fw-600"><?= (strtotime($booking['check_out'])-strtotime($booking['check_in']))/86400 ?></span></div>
                <div class="d-flex justify-content-between mb-2"><span class="text-muted">Rooms</span><span class="fw-600"><?= $booking['rooms'] ?></span></div>
                <div class="d-flex justify-content-between mb-2"><span class="text-muted">Guests</span><span class="fw-600"><?= $booking['adults'] ?> adults</span></div>
              </div>
              <hr>
              <div class="d-flex justify-content-between fw-800 fs-5">
                <span>Total</span>
                <span class="text-primary">ETB <?= number_format($booking['total_price'],0) ?></span>
              </div>
              <div class="mt-3 text-center">
                <span class="status-badge status-<?= $booking['status'] ?>"><?= ucfirst($booking['status']) ?></span>
              </div>
            </div>
          </div>
          <a href="/dashboard/bookings/<?= $booking['id'] ?>" class="btn btn-outline-secondary w-100 mt-3 rounded-3 fw-700">
            <i class="bi bi-arrow-left me-2"></i>Back to Booking
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<?= $this->section('scripts') ?>
<script>
// Set active payment methods on page load
document.querySelectorAll('.payment-method-card').forEach(card => {
  const method = card.dataset.method;
  const radio  = document.getElementById('pay_' + method);
  if(radio?.checked) card.classList.add('active');
});
// Show payment form feedback
document.getElementById('paymentForm')?.addEventListener('submit', e => {
  const btn = e.target.querySelector('[type="submit"]');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing Payment...';
});
</script>
<?= $this->endSection() ?>

<?= $this->endSection() ?>
