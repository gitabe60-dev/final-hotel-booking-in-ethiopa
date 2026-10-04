<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Create Account — Dallol Booking</title>
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
            <span class="small fw-600">Create account to complete your hotel booking</span>
          </div>
        </div>
        <?php endif; ?>

        <div class="auth-card">
          <div class="text-center mb-4">
            <a href="/" class="text-decoration-none d-block mb-2 auth-logo">
              <i class="bi bi-compass-fill text-warning me-2"></i>DallolBooking
            </a>
            <h4 class="fw-900 mb-1">Create Your Account</h4>
            <p class="text-muted small">Join 10,000+ travellers booking Ethiopia</p>
          </div>

          <?php if(session()->getFlashdata('errors')): ?>
          <div class="alert alert-danger rounded-3 small py-2 mb-3">
            <?php foreach((array)session()->getFlashdata('errors') as $e): ?><div><i class="bi bi-x-circle me-1"></i><?= esc($e) ?></div><?php endforeach; ?>
          </div>
          <?php endif; ?>
          <?php if(session()->getFlashdata('error')): ?>
          <div class="alert alert-danger rounded-3 small py-2 mb-3"><i class="bi bi-exclamation-circle me-2"></i><?= esc(session()->getFlashdata('error')) ?></div>
          <?php endif; ?>
          <?php if(session()->getFlashdata('info')): ?>
          <div class="alert rounded-3 small py-2 mb-3" style="background:#eff6ff;border:1px solid #bfdbfe;color:#1e40af">
            <i class="bi bi-info-circle-fill me-2"></i><?= esc(session()->getFlashdata('info')) ?>
          </div>
          <?php endif; ?>

          <form action="/register" method="POST" id="registerForm">
            <?= csrf_field() ?>
            <div class="row g-3 mb-3">
              <div class="col-6">
                <label class="form-label small fw-700">First Name *</label>
                <input type="text" name="first_name" class="form-control" placeholder="Abebe"
                       value="<?= old('first_name') ?>" required autofocus>
              </div>
              <div class="col-6">
                <label class="form-label small fw-700">Last Name *</label>
                <input type="text" name="last_name" class="form-control" placeholder="Kebede"
                       value="<?= old('last_name') ?>" required>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label small fw-700">Email Address *</label>
              <div class="input-icon-wrap">
                <i class="bi bi-envelope input-icon"></i>
                <input type="email" name="email" class="form-control" placeholder="you@email.com"
                       value="<?= old('email') ?>" required>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label small fw-700">Phone <span class="text-muted fw-400">(optional)</span></label>
              <div class="input-group">
                <span class="input-group-text bg-white fw-700">+251</span>
                <input type="tel" name="phone" class="form-control" placeholder="9xxxxxxxxx"
                       value="<?= old('phone') ?>">
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label small fw-700">Password *</label>
              <div class="input-group">
                <span class="input-group-text bg-white border-end-0"><i class="bi bi-lock text-muted"></i></span>
                <input type="password" name="password" id="pw1" class="form-control border-start-0"
                       placeholder="Min. 6 characters" required minlength="6">
                <button type="button" class="input-group-text bg-white" onclick="togglePw('pw1',this)">
                  <i class="bi bi-eye text-muted"></i>
                </button>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label small fw-700">Confirm Password *</label>
              <div class="input-group">
                <span class="input-group-text bg-white border-end-0"><i class="bi bi-lock-fill text-muted"></i></span>
                <input type="password" name="confirm_password" id="pw2" class="form-control border-start-0"
                       placeholder="Repeat password" required>
                <button type="button" class="input-group-text bg-white" onclick="togglePw('pw2',this)">
                  <i class="bi bi-eye text-muted"></i>
                </button>
              </div>
            </div>
            <div class="form-check mb-4">
              <input class="form-check-input" type="checkbox" id="terms" required>
              <label class="form-check-label small text-muted" for="terms">
                I agree to the <a href="#" class="text-primary">Terms</a> and <a href="#" class="text-primary">Privacy Policy</a>
              </label>
            </div>

            <button type="submit" class="btn btn-warning w-100 py-3 fw-700 rounded-3" style="color:#fff">
              <i class="bi bi-person-plus me-2 fs-5"></i>Create Account &amp; Book
            </button>

            <!-- Benefits list -->
            <div class="mt-3 p-3 rounded-3 small" style="background:#f8fafc;border:1px solid #e2e8f0">
              <div class="d-flex gap-2 mb-1"><i class="bi bi-check-circle-fill text-success"></i><span>Free cancellation on most hotels</span></div>
              <div class="d-flex gap-2 mb-1"><i class="bi bi-check-circle-fill text-success"></i><span>Save hotels to your wishlist</span></div>
              <div class="d-flex gap-2"><i class="bi bi-check-circle-fill text-success"></i><span>View all your bookings in one place</span></div>
            </div>
          </form>

          <hr class="my-3">
          <p class="text-center text-muted small mb-0">
            Already have an account?
            <a href="/login<?= session()->get('post_auth_redirect') ? '?redirect='.urlencode(session()->get('post_auth_redirect')) : '' ?>"
               class="text-primary fw-700 text-decoration-none">Sign In</a>
          </p>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
function togglePw(id,btn){
  const inp=document.getElementById(id);
  const ic=btn.querySelector('i');
  inp.type=inp.type==='password'?'text':'password';
  ic.className=inp.type==='text'?'bi bi-eye-slash text-muted':'bi bi-eye text-muted';
}
document.getElementById('registerForm')?.addEventListener('submit',function(e){
  const p1=document.getElementById('pw1').value;
  const p2=document.getElementById('pw2').value;
  if(p1!==p2){e.preventDefault();alert('Passwords do not match!');}
});
</script>
</body>
</html>
