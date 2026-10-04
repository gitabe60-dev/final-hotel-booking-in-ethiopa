<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-8">

      <!-- Progress Steps -->
      <?= view('payment/_steps', ['step' => $step, 'bookingId' => $booking['id']]) ?>

      <div class="text-center mb-4">
        <h3 class="fw-900 mb-1">Choose Payment Method</h3>
        <p class="text-muted">Select how you'd like to pay for your booking</p>
      </div>

      <!-- Hotel mini summary -->
      <div class="card border-0 rounded-4 shadow-sm mb-4 p-3">
        <div class="d-flex align-items-center gap-3">
          <img src="<?= esc($booking['hotel_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200') ?>"
               class="rounded-3" style="width:64px;height:56px;object-fit:cover" alt="">
          <div class="flex-grow-1">
            <div class="fw-800"><?= esc($booking['hotel_name']) ?></div>
            <div class="text-muted small">
              <?= date('d M', strtotime($booking['check_in'])) ?> → <?= date('d M Y', strtotime($booking['check_out'])) ?>
              · <?= $booking['adults'] ?> guests
            </div>
          </div>
          <div class="text-end">
            <div class="fw-900 text-primary fs-5">ETB <?= number_format($booking['total_price'], 0) ?></div>
            <div class="text-muted small">Total amount</div>
          </div>
        </div>
      </div>

      <form action="/payment/<?= $booking['id'] ?>/method" method="POST" id="methodForm">
        <?= csrf_field() ?>
        <input type="hidden" name="payment_method" id="selectedMethod" value="">

        <!-- ── Mobile Money ─────────────────────────────────────────────── -->
        <div class="mb-3">
          <div class="fw-700 small text-uppercase mb-2" style="letter-spacing:.08em;color:#64748b">
            <i class="bi bi-phone-fill me-1 text-primary"></i>Mobile Payments
          </div>
          <div class="row g-3">
            <?php foreach(['telebirr','cbe_birr','mobile_money'] as $key):
              $m = $methods[$key]; ?>
            <div class="col-6 col-md-4">
              <div class="payment-method-card2 text-center p-3" data-method="<?= $key ?>"
                   onclick="selectMethod('<?= $key ?>', this)" style="cursor:pointer">
                <div class="method-icon mb-2" style="font-size:2.2rem"><?= $m['icon'] ?></div>
                <div class="fw-700 small"><?= esc($m['name']) ?></div>
                <div class="method-check" style="display:none">
                  <i class="bi bi-check-circle-fill text-success"></i>
                </div>
              </div>
            </div>
            <?php endforeach; ?>
          </div>
        </div>

        <!-- ── Ethiopian Banks ──────────────────────────────────────────── -->
        <div class="mb-3">
          <div class="fw-700 small text-uppercase mb-2" style="letter-spacing:.08em;color:#64748b">
            <i class="bi bi-bank me-1 text-primary"></i>Ethiopian Banks
          </div>
          <div class="row g-3">
            <?php foreach(['amhara_bank','awash_bank','dashen_bank','abyssinia_bank','bunna_bank','oromia_bank'] as $key):
              $m = $methods[$key]; ?>
            <div class="col-6 col-md-4">
              <div class="payment-method-card2 text-center p-3" data-method="<?= $key ?>"
                   onclick="selectMethod('<?= $key ?>', this)" style="cursor:pointer">
                <div class="method-icon mb-2" style="font-size:2.2rem"><?= $m['icon'] ?></div>
                <div class="fw-700 small"><?= esc($m['name']) ?></div>
                <div class="method-check" style="display:none">
                  <i class="bi bi-check-circle-fill text-success"></i>
                </div>
              </div>
            </div>
            <?php endforeach; ?>
          </div>
        </div>

        <!-- ── Card & Other ─────────────────────────────────────────────── -->
        <div class="mb-4">
          <div class="fw-700 small text-uppercase mb-2" style="letter-spacing:.08em;color:#64748b">
            <i class="bi bi-credit-card me-1 text-primary"></i>Card & Other
          </div>
          <div class="row g-3">
            <?php foreach(['card','bank_transfer','cash'] as $key):
              $m = $methods[$key]; ?>
            <div class="col-6 col-md-4">
              <div class="payment-method-card2 text-center p-3" data-method="<?= $key ?>"
                   onclick="selectMethod('<?= $key ?>', this)" style="cursor:pointer">
                <div class="method-icon mb-2" style="font-size:2.2rem"><?= $m['icon'] ?></div>
                <div class="fw-700 small"><?= esc($m['name']) ?></div>
                <div class="method-check" style="display:none">
                  <i class="bi bi-check-circle-fill text-success"></i>
                </div>
              </div>
            </div>
            <?php endforeach; ?>
          </div>
        </div>

        <!-- No method warning -->
        <div id="noMethodWarn" class="alert rounded-3 small" style="background:#fef9c3;border:1px solid #fde68a;color:#92400e;display:none">
          <i class="bi bi-exclamation-triangle me-2"></i>Please select a payment method to continue.
        </div>

        <button type="submit" onclick="return validateMethod()"
                class="btn btn-primary w-100 py-3 fw-700 rounded-3 fs-5" id="continueBtn" disabled>
          <i class="bi bi-arrow-right-circle me-2"></i>Continue with Payment
        </button>

        <div class="text-center mt-3">
          <a href="/dashboard/bookings/<?= $booking['id'] ?>" class="text-muted small text-decoration-none">
            <i class="bi bi-arrow-left me-1"></i>Back to booking details
          </a>
        </div>
      </form>

    </div>
  </div>
</div>

<style>
.payment-method-card2 {
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  background: #fff;
  transition: all .2s ease;
  position: relative;
  min-height: 100px;
}
.payment-method-card2:hover {
  border-color: #93c5fd;
  background: #f0f9ff;
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(26,86,219,.12);
}
.payment-method-card2.selected {
  border-color: #1a56db;
  background: linear-gradient(135deg, #eff6ff, #dbeafe);
  box-shadow: 0 0 0 4px rgba(26,86,219,.15);
  transform: translateY(-2px);
}
.payment-method-card2.selected .method-check { display:block !important; position:absolute; top:8px; right:8px; font-size:1rem; }
</style>

<?= $this->section('scripts') ?>
<script>
let selectedMethod = '';

function selectMethod(method, card) {
  document.querySelectorAll('.payment-method-card2').forEach(c => {
    c.classList.remove('selected');
    const ch = c.querySelector('.method-check');
    if(ch) ch.style.display='none';
  });
  card.classList.add('selected');
  const ch = card.querySelector('.method-check');
  if(ch) ch.style.display='block';

  selectedMethod = method;
  document.getElementById('selectedMethod').value = method;
  document.getElementById('continueBtn').disabled = false;
  document.getElementById('noMethodWarn').style.display = 'none';

  // Animate button
  const btn = document.getElementById('continueBtn');
  btn.style.transform = 'scale(1.02)';
  setTimeout(() => btn.style.transform = '', 200);
}

function validateMethod() {
  if (!selectedMethod) {
    document.getElementById('noMethodWarn').style.display = 'block';
    return false;
  }
  return true;
}

// Auto-select if method is already stored
const stored = '<?= esc(session()->get("pay_method_{$booking['id']}") ?? $booking['payment_method'] ?? '') ?>';
if (stored) {
  const card = document.querySelector(`[data-method="${stored}"]`);
  if (card) selectMethod(stored, card);
}
</script>
<?= $this->endSection() ?>

<?= $this->endSection() ?>
