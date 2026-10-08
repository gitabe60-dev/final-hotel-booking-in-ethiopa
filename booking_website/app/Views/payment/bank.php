<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-8">

      <?= view('payment/_steps', ['step' => $step, 'bookingId' => $booking['id']]) ?>

      <?php
      $isMobile  = $methodInfo['type'] === 'mobile';
      $isCash    = $methodInfo['type'] === 'cash';
      $color     = esc($methodInfo['color']);
      $icon      = $methodInfo['icon'];
      $name      = esc($methodInfo['name']);
      ?>

      <div class="text-center mb-4">
        <div class="d-inline-flex align-items-center gap-2 px-4 py-2 rounded-pill mb-3"
             style="background:#fff3cd;border:1px solid #ffc107;color:#856404">
          <i class="bi bi-cone-striped"></i>
          <span class="fw-700 small">TEST MODE — No real money will be charged</span>
        </div>
        <div style="font-size:3.5rem;line-height:1"><?= $icon ?></div>
        <h3 class="fw-900 mb-1 mt-2"><?= $name ?> Payment</h3>
        <p class="text-muted small">
          <?= $isMobile ? 'Enter your registered mobile number' : 'Enter your bank account details' ?>
        </p>
      </div>

      <div class="row g-4">
        <div class="col-lg-7">

          <!-- ── Mobile Payment Form (Telebirr, CBE Birr, HelloCash) ──── -->
          <?php if($isMobile): ?>
          <form action="/payment/<?= $booking['id'] ?>/process" method="POST" id="bankForm">
            <?= csrf_field() ?>
            <input type="hidden" name="bank_name" value="<?= esc($method) ?>">

            <!-- Simulated Mobile UI -->
            <div class="mb-4 p-4 rounded-4 text-center text-white"
                 style="background:linear-gradient(135deg,<?= $color ?>,<?= $color ?>dd);box-shadow:0 12px 40px <?= $color ?>66">
              <div style="font-size:2.5rem;margin-bottom:8px"><?= $icon ?></div>
              <div class="fw-800 fs-5"><?= $name ?></div>
              <div class="small opacity-75">Ethiopian Mobile Money Service</div>
              <hr style="border-color:rgba(255,255,255,.2);margin:12px 0">
              <div class="fw-700 fs-4">ETB <?= number_format($booking['total_price'],0) ?></div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-700">
                Registered Phone Number *
                <span class="text-muted fw-400 small">(<?= $name ?> account)</span>
              </label>
              <div class="input-group input-group-lg">
                <span class="input-group-text bg-white fw-700" style="font-size:1rem">+251</span>
                <input type="tel" name="phone" id="phoneInput" class="form-control"
                       placeholder="9xxxxxxxxx" maxlength="10" required
                       data-label="Phone number" minlength="9"
                       oninput="this.value=this.value.replace(/\D/g,'').substring(0,10)">
              </div>
              <div class="form-text text-success fw-600">
                <i class="bi bi-info-circle me-1"></i>Test: use any 9-digit number e.g. 911234567
              </div>
            </div>

            <!-- Simulated push notification preview -->
            <div class="p-3 rounded-3 mb-4" id="pushPreview" style="display:none;background:#f1f5f9;border:1px solid #e2e8f0">
              <div class="d-flex align-items-center gap-2 mb-2">
                <div style="width:36px;height:36px;border-radius:10px;background:<?= $color ?>;display:flex;align-items:center;justify-content:center;font-size:1.2rem"><?= $icon ?></div>
                <div>
                  <div class="fw-700 small"><?= $name ?> Payment Request</div>
                  <div class="text-muted" style="font-size:.72rem">Just now</div>
                </div>
              </div>
              <div class="small">
                <strong>DallolBooking</strong> is requesting a payment of
                <strong>ETB <?= number_format($booking['total_price'],0) ?></strong>
                for booking at <strong><?= esc($booking['hotel_name']) ?></strong>.
                <br><span class="text-muted">Accept on your <?= $name ?> app to confirm.</span>
              </div>
            </div>

            <!-- Amount -->
            <div class="p-3 rounded-3 mb-4" style="background:linear-gradient(135deg,#eff6ff,#dbeafe);border:1px solid #bfdbfe">
              <div class="d-flex justify-content-between fw-800 fs-5">
                <span>Amount</span>
                <span class="text-primary">ETB <?= number_format($booking['total_price'],0) ?></span>
              </div>
              <div class="text-muted small mt-1">
                Booking #<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?> · <?= esc($booking['hotel_name']) ?>
              </div>
            </div>

            <button type="submit" class="btn w-100 py-3 fw-800 rounded-3 fs-5" id="payBtn"
                    style="background:<?= $color ?>;color:#fff">
              <?= $icon ?> Confirm <?= $name ?> Payment — Test Mode
            </button>

            <div class="text-center mt-3">
              <a href="/payment/<?= $booking['id'] ?>/summary" class="text-muted small text-decoration-none">
                <i class="bi bi-arrow-left me-1"></i>Back to summary
              </a>
            </div>
          </form>

          <!-- ── Bank Transfer Form ─────────────────────────────────── -->
          <?php else: ?>
          <form action="/payment/<?= $booking['id'] ?>/process" method="POST" id="bankForm">
            <?= csrf_field() ?>

            <?php if($method === 'bank_transfer'): ?>
            <!-- Generic bank transfer — user picks their bank -->
            <div class="mb-3">
              <label class="form-label fw-700">Select Your Bank *</label>
              <select name="bank_name" id="bankSelect" class="form-select form-select-lg" required
                      onchange="updateBankUI(this.value)">
                <option value="">-- Choose your bank --</option>
                <?php
                $banks = [
                    'cbe'          => 'Commercial Bank of Ethiopia (CBE)',
                    'amhara_bank'  => 'Amhara Bank',
                    'awash_bank'   => 'Awash Bank',
                    'dashen_bank'  => 'Dashen Bank',
                    'abyssinia'    => 'Bank of Abyssinia',
                    'bunna'        => 'Bunna Bank',
                    'oromia'       => 'Oromia Bank',
                    'hibret'       => 'Hibret Bank',
                    'wegagen'      => 'Wegagen Bank',
                    'nib'          => 'NIB International Bank',
                    'zemen'        => 'Zemen Bank',
                ];
                foreach($banks as $k=>$v): ?>
                <option value="<?= $k ?>"><?= $v ?></option>
                <?php endforeach; ?>
              </select>
            </div>
            <?php else: ?>
            <input type="hidden" name="bank_name" value="<?= esc($method) ?>">
            <?php endif; ?>

            <!-- Bank card preview -->
            <div class="mb-4 p-4 rounded-4 text-white" id="bankCard"
                 style="background:linear-gradient(135deg,<?= $color ?>,<?= $color ?>cc);box-shadow:0 12px 40px <?= $color ?>44;transition:.3s">
              <div class="d-flex justify-content-between align-items-start mb-3">
                <div style="font-size:1.8rem"><?= $icon ?></div>
                <div id="bankName" class="fw-700"><?= $name ?></div>
              </div>
              <div style="font-size:.75rem;opacity:.75;margin-bottom:4px">Account Number</div>
              <div id="previewAcct" style="font-family:monospace;font-size:1.3rem;letter-spacing:.1em;font-weight:700">
                •••• •••• ••••
              </div>
              <div class="mt-3">
                <div style="font-size:.7rem;opacity:.7">Account Holder</div>
                <div id="previewHolder" class="fw-700">YOUR NAME</div>
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-700">Account Number *</label>
              <div class="input-group input-group-lg">
                <span class="input-group-text bg-white"><i class="bi bi-bank text-muted"></i></span>
                <input type="text" name="account_number" id="acctInput" class="form-control"
                       placeholder="e.g. 1000123456789" maxlength="16" required
                       data-label="Account number" minlength="10"
                       oninput="this.value=this.value.replace(/\D/g,'');document.getElementById('previewAcct').textContent=this.value.substring(0,4)+' '+this.value.substring(4,8)+' '+this.value.substring(8)||'•••• •••• ••••'">
              </div>
              <div class="form-text text-success fw-600">Test: enter any account number e.g. 1000123456789</div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-700">Account Holder Name *</label>
              <div class="input-group input-group-lg">
                <span class="input-group-text bg-white"><i class="bi bi-person text-muted"></i></span>
                <input type="text" name="card_name" id="holderInput" class="form-control"
                       placeholder="As registered at bank" required
                       data-rule="name" data-label="Account holder name"
                       oninput="document.getElementById('previewHolder').textContent=this.value||'YOUR NAME'">
              </div>
            </div>

            <!-- Amount -->
            <div class="p-3 rounded-3 mb-4" style="background:linear-gradient(135deg,#eff6ff,#dbeafe);border:1px solid #bfdbfe">
              <div class="d-flex justify-content-between fw-800 fs-5">
                <span>Amount</span>
                <span class="text-primary">ETB <?= number_format($booking['total_price'],0) ?></span>
              </div>
              <div class="text-muted small mt-1">Booking #<?= str_pad($booking['id'],6,'0',STR_PAD_LEFT) ?> · <?= esc($booking['hotel_name']) ?></div>
            </div>

            <button type="submit" class="btn w-100 py-3 fw-800 rounded-3 fs-5" id="payBtn"
                    style="background:linear-gradient(135deg,#1a56db,#7c3aed);color:#fff">
              <i class="bi bi-send-fill me-2"></i>Pay via <?= $name ?> — Test Mode
            </button>

            <div class="text-center mt-3">
              <a href="/payment/<?= $booking['id'] ?>/summary" class="text-muted small text-decoration-none">
                <i class="bi bi-arrow-left me-1"></i>Back to summary
              </a>
            </div>
          </form>
          <?php endif; ?>

        </div>

        <!-- ── Right: Test info + booking mini ────────────────────────── -->
        <div class="col-lg-5">
          <!-- Booking mini card -->
          <div class="card border-0 rounded-4 shadow-sm mb-3">
            <div class="card-body p-3">
              <div class="fw-700 small text-muted mb-2">Your Booking</div>
              <div class="fw-800 mb-1"><?= esc($booking['hotel_name']) ?></div>
              <div class="text-muted small mb-2">
                <?= date('d M', strtotime($booking['check_in'])) ?> → <?= date('d M Y', strtotime($booking['check_out'])) ?>
              </div>
              <div class="fw-900 text-primary">ETB <?= number_format($booking['total_price'], 0) ?></div>
            </div>
          </div>

          <!-- Test mode box -->
          <div class="card border-0 rounded-4" style="background:#fff3cd;border:1px solid #ffc107!important">
            <div class="card-body p-3 small">
              <div class="fw-800 mb-2"><i class="bi bi-cone-striped me-1"></i>TEST MODE</div>
              <div class="text-muted mb-2">This is a simulated payment. Use:</div>
              <div class="p-2 rounded-2 font-monospace" style="background:#fff;font-size:.78rem">
                <?php if($isMobile): ?>
                Phone: 0911234567<br>
                Any 10-digit number works
                <?php else: ?>
                Account: 1000123456789<br>
                Name: Any name<br>
                Bank: Any selection
                <?php endif; ?>
              </div>
              <div class="mt-2 text-muted">No real transaction will occur.</div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</div>

<?= $this->section('scripts') ?>
<script>
<?php if($isMobile): ?>
// Show push notification preview when phone is entered
document.getElementById('phoneInput').addEventListener('input', function() {
  document.getElementById('pushPreview').style.display = this.value.length >= 9 ? 'block' : 'none';
});
<?php endif; ?>

function updateBankUI(bankKey) {
  const colors = {
    cbe:'#003087',amhara_bank:'#1a56db',awash_bank:'#c0392b',
    dashen_bank:'#27ae60',abyssinia:'#8e44ad',bunna:'#e67e22',
    oromia:'#16a085',hibret:'#2c3e50',wegagen:'#d35400',
    nib:'#1abc9c',zemen:'#2980b9'
  };
  const color = colors[bankKey] || '#1a56db';
  document.getElementById('bankCard').style.background =
    `linear-gradient(135deg,${color},${color}cc)`;
}

document.getElementById('bankForm')?.addEventListener('submit', function(e) {
  const btn = document.getElementById('payBtn');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing Payment...';
});
</script>
<?= $this->endSection() ?>

<?= $this->endSection() ?>
