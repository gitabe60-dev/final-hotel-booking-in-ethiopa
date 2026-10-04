<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sign In — Dallol Booking</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link href="/assets/css/app.css" rel="stylesheet">
</head>
<body>
<div class="auth-page">
  <div class="container">
    <div class="row justify-content-center min-vh-100 align-items-center py-5">
      <div class="col-sm-10 col-md-7 col-lg-5 col-xl-4">

        <!-- Booking intent notice -->
        <?php if(session()->get('post_auth_redirect') && str_contains(session()->get('post_auth_redirect'),'hotels')): ?>
        <div class="text-center mb-3">
          <div class="d-inline-flex align-items-center gap-2 px-4 py-2 rounded-pill text-white" style="background:rgba(255,255,255,.15);backdrop-filter:blur(8px)">
            <i class="bi bi-calendar-check-fill text-warning"></i>
            <span class="small fw-600">Complete your hotel booking after login</span>
          </div>
        </div>
        <?php endif; ?>

        <div class="auth-card">
          <div class="text-center mb-4">
            <a href="/" class="text-decoration-none d-block mb-2 auth-logo">
              <i class="bi bi-compass-fill text-warning me-2"></i>DallolBooking
            </a>
            <h4 class="fw-900 mb-1">Welcome Back</h4>
            <p class="text-muted small">Sign in to book Ethiopia's best hotels</p>
          </div>

          <?php if(session()->getFlashdata('error')): ?>
          <div class="alert alert-danger rounded-3 small py-2 mb-3"><i class="bi bi-exclamation-circle me-2"></i><?= esc(session()->getFlashdata('error')) ?></div>
          <?php endif; ?>
          <?php if(session()->getFlashdata('errors')): ?>
          <div class="alert alert-danger rounded-3 small py-2 mb-3">
            <?php foreach((array)session()->getFlashdata('errors') as $e): ?><div><i class="bi bi-x-circle me-1"></i><?= esc($e) ?></div><?php endforeach; ?>
          </div>
          <?php endif; ?>

          <!-- Tabs: Email / Phone OTP -->
          <div class="d-flex gap-1 p-1 mb-4 rounded-3" style="background:#f1f5f9">
            <button class="btn btn-sm fw-700 w-50 rounded-2 active" id="tabEmail" onclick="showTab('email',this)" style="background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.08)">
              <i class="bi bi-envelope me-1"></i>Email
            </button>
            <button class="btn btn-sm fw-700 w-50 rounded-2 text-muted" id="tabPhone" onclick="showTab('phone',this)">
              <i class="bi bi-phone me-1"></i>Phone OTP
            </button>
          </div>

          <!-- Email tab -->
          <div id="emailTab">
            <form action="/login" method="POST">
              <?= csrf_field() ?>
              <div class="mb-3">
                <label class="form-label small fw-700">Email Address</label>
                <div class="input-icon-wrap">
                  <i class="bi bi-envelope input-icon"></i>
                  <input type="email" name="email" class="form-control" placeholder="you@email.com"
                         value="<?= old('email') ?>" required autofocus>
                </div>
              </div>
              <div class="mb-4">
                <label class="form-label small fw-700 d-flex justify-content-between">
                  Password <a href="/forgot-password" class="text-primary text-decoration-none fw-400">Forgot?</a>
                </label>
                <div class="input-group">
                  <span class="input-group-text bg-white border-end-0"><i class="bi bi-lock text-muted"></i></span>
                  <input type="password" name="password" id="pwField" class="form-control border-start-0" placeholder="••••••••" required>
                  <button type="button" class="input-group-text bg-white" onclick="togglePw()"><i class="bi bi-eye text-muted" id="eyeIcon"></i></button>
                </div>
              </div>
              <button type="submit" class="btn btn-primary w-100 py-3 fw-700 rounded-3">
                <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
              </button>
            </form>
          </div>

          <!-- Phone OTP tab -->
          <div id="phoneTab" style="display:none">
            <form action="/otp/send" method="POST">
              <?= csrf_field() ?>
              <div class="mb-3">
                <label class="form-label small fw-700">Phone Number</label>
                <div class="input-group">
                  <span class="input-group-text bg-white fw-700">+251</span>
                  <input type="tel" name="phone" class="form-control" placeholder="9xxxxxxxxx" required>
                </div>
              </div>
              <button type="submit" class="btn btn-primary w-100 py-3 fw-700 rounded-3">
                <i class="bi bi-send me-2"></i>Send OTP Code
              </button>
            </form>
          </div>

          <!-- DIVIDER -->
          <div class="d-flex align-items-center gap-2 my-4">
            <hr class="flex-grow-1 m-0">
            <span class="text-muted small px-2">New to DallolBooking?</span>
            <hr class="flex-grow-1 m-0">
          </div>

          <!-- REGISTER BUTTON — prominent, below login -->
          <a href="/register<?= session()->get('post_auth_redirect') ? '?redirect='.urlencode(session()->get('post_auth_redirect')) : '' ?>"
             class="btn btn-warning w-100 py-3 fw-700 rounded-3 d-flex align-items-center justify-content-center gap-2" style="color:#fff">
            <i class="bi bi-person-plus fs-5"></i>
            <div class="text-start">
              <div>Create Free Account</div>
              <div style="font-size:.75rem;font-weight:400;opacity:.9">Register &amp; book hotels in 60 seconds</div>
            </div>
          </a>

          <div class="text-center mt-3">
            <a href="/admin/login" class="text-muted small text-decoration-none">
              <i class="bi bi-shield-lock me-1"></i>Staff / Admin Portal
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
function showTab(tab,btn) {
  document.getElementById('emailTab').style.display=tab==='email'?'block':'none';
  document.getElementById('phoneTab').style.display=tab==='phone'?'block':'none';
  document.querySelectorAll('#tabEmail,#tabPhone').forEach(b=>{
    b.classList.remove('active','text-white');
    b.style.background='transparent';
    b.style.boxShadow='none';
    b.classList.add('text-muted');
  });
  btn.classList.add('active');
  btn.classList.remove('text-muted');
  btn.style.background='#fff';
  btn.style.boxShadow='0 1px 4px rgba(0,0,0,.08)';
}
function togglePw(){
  const pw=document.getElementById('pwField');
  const ic=document.getElementById('eyeIcon');
  pw.type=pw.type==='password'?'text':'password';
  ic.className=pw.type==='text'?'bi bi-eye-slash text-muted':'bi bi-eye text-muted';
}
</script>
</body>
</html>
