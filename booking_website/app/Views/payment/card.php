<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-8">

      <?= view('payment/_steps', ['step' => $step, 'bookingId' => $booking['id']]) ?>

      <div class="text-center mb-4">
        <div class="d-inline-flex align-items-center gap-2 px-4 py-2 rounded-pill mb-3"
             style="background:#fff3cd;border:1px solid #ffc107;color:#856404">
          <i class="bi bi-cone-striped"></i>
          <span class="fw-700 small">TEST MODE — No real money will be charged</span>
        </div>
        <h3 class="fw-900 mb-1">💳 Card Payment</h3>
        <p class="text-muted small">Enter your card details below</p>
      </div>

      <div class="row g-4">
        <div class="col-lg-7">

          <!-- ── Animated Credit Card Preview ─────────────────────────── -->
          <div class="mb-4" style="perspective:1000px">
            <div id="cardPreview" style="
              width:100%;max-width:380px;height:220px;margin:0 auto;
              border-radius:20px;padding:28px;
              background:linear-gradient(135deg,#1a56db 0%,#7c3aed 60%,#2563eb 100%);
              color:#fff;position:relative;overflow:hidden;
              box-shadow:0 20px 60px rgba(26,86,219,.4);
              transition:transform .3s ease;
            ">
              <!-- Card background decoration -->
              <div style="position:absolute;top:-40px;right:-40px;width:180px;height:180px;border-radius:50%;background:rgba(255,255,255,.08)"></div>
              <div style="position:absolute;bottom:-60px;left:-40px;width:200px;height:200px;border-radius:50%;background:rgba(255,255,255,.05)"></div>

              <!-- Chip -->
              <div style="width:44px;height:34px;background:linear-gradient(135deg,#ffd700,#b8860b);border-radius:6px;margin-bottom:18px;display:flex;align-items:center;justify-content:center">
                <div style="width:28px;height:22px;border:1px solid rgba(0,0,0,.2);border-radius:3px;display:grid;grid-template-columns:1fr 1fr">
                  <div style="border-right:1px solid rgba(0,0,0,.2);border-bottom:1px solid rgba(0,0,0,.2)"></div>
                  <div style="border-bottom:1px solid rgba(0,0,0,.2)"></div>
                  <div style="border-right:1px solid rgba(0,0,0,.2)"></div>
                  <div></div>
                </div>
              </div>

              <!-- Card number -->
              <div id="previewNumber" style="font-size:1.4rem;font-weight:700;letter-spacing:.15em;margin-bottom:18px;font-family:monospace">
                •••• •••• •••• ••••
              </div>

              <!-- Bottom row -->
              <div class="d-flex justify-content-between align-items-end">
                <div>
                  <div style="font-size:.65rem;opacity:.7;text-transform:uppercase;letter-spacing:.1em">Card Holder</div>
                  <div id="previewName" style="font-size:.9rem;font-weight:700;text-transform:uppercase;letter-spacing:.05em">YOUR NAME</div>
                </div>
                <div class="text-end">
                  <div style="font-size:.65rem;opacity:.7;text-transform:uppercase;letter-spacing:.1em">Expires</div>
                  <div id="previewExpiry" style="font-size:.9rem;font-weight:700">MM/YY</div>
                </div>
                <div style="font-size:1.8rem;opacity:.9">💳</div>
              </div>
            </div>
          </div>

          <!-- ── Card Form ─────────────────────────────────────────────── -->
          <form action="/payment/<?= $booking['id'] ?>/process" method="POST" id="cardForm">
            <?= csrf_field() ?>

            <div class="mb-3">
              <label class="form-label fw-700">Cardholder Name *</label>
              <div class="input-group">
                <span class="input-group-text bg-white"><i class="bi bi-person text-muted"></i></span>
                <input type="text" name="card_name" id="cardName" class="form-control"
                       placeholder="e.g. ABEBE KEBEDE" style="text-transform:uppercase" required
                       data-rule="name" data-label="Cardholder name"
                       oninput="document.getElementById('previewName').textContent=this.value.toUpperCase()||'YOUR NAME'">
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-700">Card Number *</label>
              <div class="input-group">
                <span class="input-group-text bg-white"><i class="bi bi-credit-card text-muted"></i></span>
                <input type="text" name="card_number" id="cardNumber" class="form-control"
                       placeholder="1234 5678 9012 3456" maxlength="19" required
                       data-label="Card number" minlength="19"
                       oninput="formatCard(this)"
                       onkeypress="return /[\d ]/.test(event.key)">
                <span class="input-group-text bg-white" id="cardBrand" style="font-size:1.3rem">💳</span>
              </div>
              <div class="form-text">
                <span class="text-success fw-600">Test numbers: </span>
                <span class="font-monospace small" style="cursor:pointer;color:#1a56db"
                      onclick="fillTestCard('4111 1111 1111 1111','VISA')">4111 1111 1111 1111 (Visa)</span>
                &nbsp;·&nbsp;
                <span class="font-monospace small" style="cursor:pointer;color:#1a56db"
                      onclick="fillTestCard('5500 0000 0000 0004','MASTERCARD')">5500 0000 0000 0004 (MC)</span>
              </div>
            </div>

            <div class="row g-3 mb-4">
              <div class="col-6">
                <label class="form-label fw-700">Expiry Date *</label>
                <div class="input-group">
                  <span class="input-group-text bg-white"><i class="bi bi-calendar3 text-muted"></i></span>
                  <input type="text" name="expiry" id="expiry" class="form-control"
                         placeholder="MM/YY" maxlength="5" required
                         data-label="Expiry date" minlength="5"
                         oninput="formatExpiry(this)"
                         onkeypress="return /[\d/]/.test(event.key)">
                </div>
                <div class="form-text text-success small fw-600">Test: 12/28</div>
              </div>
              <div class="col-6">
                <label class="form-label fw-700">CVV *</label>
                <div class="input-group">
                  <span class="input-group-text bg-white"><i class="bi bi-shield-lock text-muted"></i></span>
                  <input type="password" name="cvv" id="cvv" class="form-control"
                         placeholder="•••" maxlength="4" required
                         onkeypress="return /[\d]/.test(event.key)">
                  <button type="button" class="input-group-text bg-white"
                          onmousedown="document.getElementById('cvv').type='text'"
                          onmouseup="document.getElementById('cvv').type='password'"
                          ontouchstart="document.getElementById('cvv').type='text'"
                          ontouchend="document.getElementById('cvv').type='password'">
                    <i class="bi bi-eye text-muted"></i>
                  </button>
                </div>
                <div class="form-text text-success small fw-600">Test: 123</div>
              </div>
            </div>

            <!-- Amount display -->
            <div class="p-3 rounded-3 mb-4" style="background:linear-gradient(135deg,#eff6ff,#dbeafe);border:1px solid #bfdbfe">
              <div class="d-flex justify-content-between fw-800 fs-5">
                <span>Amount to Pay</span>
                <span class="text-primary">ETB <?= number_format($booking['total_price'],0) ?></span>
              </div>
              <div class="text-muted small mt-1">
                Booking #<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?> · <?= esc($booking['hotel_name']) ?>
              </div>
            </div>

            <button type="submit" class="btn w-100 py-3 fw-800 rounded-3 fs-5" id="payBtn"
                    style="background:linear-gradient(135deg,#1a56db,#7c3aed);color:#fff">
              <i class="bi bi-lock-fill me-2"></i>Pay ETB <?= number_format($booking['total_price'],0) ?> — Test Mode
            </button>

            <div class="text-center mt-3">
              <a href="/payment/<?= $booking['id'] ?>/summary" class="text-muted small text-decoration-none">
                <i class="bi bi-arrow-left me-1"></i>Back to summary
              </a>
            </div>
          </form>
        </div>

        <!-- ── Right: Security Info ───────────────────────────────────── -->
        <div class="col-lg-5">
          <div class="card border-0 rounded-4 shadow-sm mb-3"
               style="background:linear-gradient(135deg,#f0fdf4,#dcfce7);border:1px solid #bbf7d0!important">
            <div class="card-body p-3">
              <h6 class="fw-800 text-success mb-3"><i class="bi bi-shield-check me-2"></i>Secure Payment</h6>
              <div class="small text-muted">
                <div class="d-flex gap-2 mb-2"><i class="bi bi-check-circle-fill text-success"></i><span>256-bit SSL encrypted</span></div>
                <div class="d-flex gap-2 mb-2"><i class="bi bi-check-circle-fill text-success"></i><span>PCI DSS compliant</span></div>
                <div class="d-flex gap-2 mb-2"><i class="bi bi-check-circle-fill text-success"></i><span>3D Secure protected</span></div>
                <div class="d-flex gap-2"><i class="bi bi-check-circle-fill text-success"></i><span>No data stored on our servers</span></div>
              </div>
            </div>
          </div>
          <div class="card border-0 rounded-4 shadow-sm" style="background:#fff3cd;border:1px solid #ffc107!important">
            <div class="card-body p-3 small">
              <div class="fw-800 mb-2"><i class="bi bi-cone-striped me-1"></i>TEST MODE</div>
              <div class="text-muted mb-2">This is a test payment. Use these details:</div>
              <div class="font-monospace p-2 rounded-2" style="background:#fff;font-size:.78rem">
                Card: 4111 1111 1111 1111<br>
                Expiry: 12/28<br>
                CVV: 123<br>
                Name: Any name
              </div>
              <div class="mt-2 text-muted">No real money will be charged.</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<?= $this->section('scripts') ?>
<script>
function formatCard(inp) {
  let v = inp.value.replace(/\D/g,'').substring(0,16);
  inp.value = v.replace(/(.{4})/g,'$1 ').trim();
  document.getElementById('previewNumber').textContent =
    (inp.value.padEnd(19,'•').replace(/\d(?=\d{4})/g,'•')) || '•••• •••• •••• ••••';

  // Detect card brand
  const brand = document.getElementById('cardBrand');
  if(v.startsWith('4'))      brand.textContent='💙'; // Visa
  else if(v.startsWith('5')) brand.textContent='🟠'; // MC
  else if(v.startsWith('3')) brand.textContent='🟢'; // Amex
  else                       brand.textContent='💳';
}

function formatExpiry(inp) {
  let v = inp.value.replace(/\D/g,'');
  if(v.length >= 2) v = v.substring(0,2) + '/' + v.substring(2,4);
  inp.value = v;
  document.getElementById('previewExpiry').textContent = inp.value || 'MM/YY';
}

function fillTestCard(num, brand) {
  const ni = document.getElementById('cardNumber');
  ni.value = num;
  document.getElementById('previewNumber').textContent = num;
  document.getElementById('expiry').value = '12/28';
  document.getElementById('previewExpiry').textContent = '12/28';
  document.getElementById('cvv').value = '123';
  document.getElementById('cardBrand').textContent = brand==='VISA'?'💙':'🟠';
  if(!document.getElementById('cardName').value)
    document.getElementById('cardName').value = 'TEST CARDHOLDER';
  document.getElementById('previewName').textContent = 'TEST CARDHOLDER';
}

document.getElementById('cardForm').addEventListener('submit', function(e) {
  const btn = document.getElementById('payBtn');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing Payment...';
});
</script>
<?= $this->endSection() ?>

<?= $this->endSection() ?>
