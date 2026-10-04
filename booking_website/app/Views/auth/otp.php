<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Phone Verification — Dallol Booking</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet">
<link href="/assets/css/app.css" rel="stylesheet">
</head>
<body>
<div class="auth-page">
  <div class="container">
    <div class="row justify-content-center min-vh-100 align-items-center">
      <div class="col-sm-9 col-md-6 col-lg-4">
        <div class="auth-card text-center">
          <a href="/" class="text-decoration-none d-block mb-4 auth-logo">
            <i class="bi bi-compass-fill text-warning me-2"></i>DallolBooking
          </a>
          <div class="anim-float d-inline-block mb-3">
            <div class="rounded-circle d-inline-flex align-items-center justify-content-center" style="width:72px;height:72px;background:linear-gradient(135deg,#1a56db,#7c3aed)">
              <i class="bi bi-phone-fill text-white fs-3"></i>
            </div>
          </div>

          <?php if(!session()->get('otp_phone')): ?>
          <h4 class="fw-900 mb-1">Phone Login</h4>
          <p class="text-muted small mb-4">Enter your phone number to receive a verification code</p>

          <?php if(session()->getFlashdata('error')): ?>
          <div class="alert alert-danger alert-flash rounded-3 small mb-3"><i class="bi bi-exclamation-circle me-2"></i><?= esc(session()->getFlashdata('error')) ?></div>
          <?php endif; ?>

          <form action="/otp/send" method="POST">
            <?= csrf_field() ?>
            <div class="input-group mb-4">
              <span class="input-group-text bg-white fw-700 fs-6">🇪🇹 +251</span>
              <input type="tel" name="phone" class="form-control form-control-lg text-center fw-700" placeholder="9xx xxx xxxx" required autofocus>
            </div>
            <button type="submit" class="btn btn-primary w-100 py-3 fw-700 rounded-3">
              <i class="bi bi-send me-2"></i>Send Verification Code
            </button>
          </form>

          <?php else: ?>
          <h4 class="fw-900 mb-1">Enter OTP Code</h4>
          <p class="text-muted small mb-4">
            We sent a 6-digit code to<br>
            <strong class="text-primary">+251 <?= esc(session()->get('otp_phone')) ?></strong>
            <?php if(ENVIRONMENT==='development'): ?>
            <br><small class="text-warning">(Dev mode: check server logs for code)</small>
            <?php endif; ?>
          </p>

          <?php if(session()->getFlashdata('error')): ?>
          <div class="alert alert-danger alert-flash rounded-3 small mb-3"><i class="bi bi-exclamation-circle me-2"></i><?= esc(session()->getFlashdata('error')) ?></div>
          <?php endif; ?>
          <?php if(session()->getFlashdata('success')): ?>
          <div class="alert alert-success alert-flash rounded-3 small mb-3"><i class="bi bi-check-circle me-2"></i><?= esc(session()->getFlashdata('success')) ?></div>
          <?php endif; ?>

          <form action="/otp/verify" method="POST" id="otpForm">
            <?= csrf_field() ?>
            <input type="hidden" name="phone" value="<?= esc(session()->get('otp_phone')) ?>">
            <input type="hidden" name="otp" id="otpHidden">
            <div class="otp-boxes mb-4">
              <?php for($i=0;$i<6;$i++): ?>
              <input type="text" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]" <?= $i===0?'autofocus':'' ?>>
              <?php endfor; ?>
            </div>
            <button type="submit" class="btn btn-primary w-100 py-3 fw-700 rounded-3 mb-3">
              <i class="bi bi-check-circle me-2"></i>Verify & Sign In
            </button>
          </form>

          <div class="text-muted small">
            Didn't receive the code?
            <form action="/otp/send" method="POST" class="d-inline">
              <?= csrf_field() ?>
              <input type="hidden" name="phone" value="<?= esc(session()->get('otp_phone')) ?>">
              <button type="submit" class="btn btn-link btn-sm text-primary fw-700 p-0 text-decoration-none">Resend Code</button>
            </form>
          </div>
          <?php endif; ?>

          <div class="mt-4 pt-3 border-top">
            <a href="/login" class="text-muted small text-decoration-none"><i class="bi bi-arrow-left me-1"></i>Back to Login</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="/assets/js/app.js"></script>
</body>
</html>
