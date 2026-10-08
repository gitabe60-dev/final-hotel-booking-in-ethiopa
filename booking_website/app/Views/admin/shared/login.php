<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Login — DallolBooking</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<style>
*{font-family:'Inter',sans-serif}
body{background:linear-gradient(135deg,#0f172a 0%,#1e3a8a 60%,#1a56db 100%);min-height:100vh;display:flex;align-items:center;justify-content:center}
.login-card{background:#fff;border-radius:24px;padding:2.5rem;box-shadow:0 32px 80px rgba(15,23,42,.4);width:100%;max-width:420px;animation:scaleIn .5s ease}
@keyframes scaleIn{from{opacity:0;transform:scale(.92)}to{opacity:1;transform:scale(1)}}
.brand{font-size:1.7rem;font-weight:900;color:#1a56db}
.role-badge{display:inline-flex;align-items:center;gap:6px;background:#f1f5f9;border-radius:50px;padding:.35rem .9rem;font-size:.8rem;font-weight:600;color:#475569;margin-bottom:1.5rem}
.form-control{border:2px solid #e2e8f0;border-radius:10px;padding:.7rem .9rem;font-size:.92rem;transition:.2s}
.form-control:focus{border-color:#1a56db;box-shadow:0 0 0 4px rgba(26,86,219,.1);outline:none}
.btn-admin{background:linear-gradient(135deg,#1a56db,#1044b8);border:none;border-radius:12px;padding:.85rem;font-weight:700;font-size:1rem;color:#fff;width:100%;transition:.2s}
.btn-admin:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(26,86,219,.4);color:#fff}
.role-info{background:#eff6ff;border:1px solid #bfdbfe;border-radius:12px;padding:1rem;font-size:.82rem;color:#1e40af}
</style>
</head>
<body>
<div class="login-card">
  <div class="text-center mb-4">
    <div class="brand mb-1"><i class="bi bi-compass-fill" style="color:#f59e0b"></i> Dallol<span style="color:#f59e0b">Admin</span></div>
    <div class="role-badge">
      <i class="bi bi-shield-lock-fill text-primary"></i>
      Staff & Admin Portal
    </div>
    <h5 class="fw-800 mb-0">Sign In to Admin Panel</h5>
    <p class="text-muted small mt-1">Access your dashboard based on your role</p>
  </div>

  <?php if(session()->getFlashdata('error')): ?>
  <div class="alert alert-danger rounded-3 small mb-3 py-2">
    <i class="bi bi-exclamation-circle me-2"></i><?= esc(session()->getFlashdata('error')) ?>
  </div>
  <?php endif; ?>
  <?php if(session()->getFlashdata('success')): ?>
  <div class="alert alert-success rounded-3 small mb-3 py-2">
    <i class="bi bi-check-circle me-2"></i><?= esc(session()->getFlashdata('success')) ?>
  </div>
  <?php endif; ?>

  <form action="/admin/login" method="POST">
    <?= csrf_field() ?>
    <div class="mb-3">
      <label class="form-label fw-700 small">Email Address</label>
      <div class="input-group">
        <span class="input-group-text bg-white border-end-0"><i class="bi bi-envelope text-muted"></i></span>
        <input type="email" name="email" class="form-control border-start-0"
               placeholder="admin@dalloltech.com"
               value="<?= old('email') ?>" required autofocus>
      </div>
    </div>
    <div class="mb-4">
      <label class="form-label fw-700 small">Password</label>
      <div class="input-group">
        <span class="input-group-text bg-white border-end-0"><i class="bi bi-lock text-muted"></i></span>
        <input type="password" name="password" id="pwField" class="form-control border-start-0"
               placeholder="••••••••" required>
        <button type="button" class="input-group-text bg-white" onclick="togglePw()">
          <i class="bi bi-eye text-muted" id="eyeIcon"></i>
        </button>
      </div>
    </div>
    <button type="submit" class="btn-admin mb-3">
      <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
    </button>
  </form>

  <div class="role-info">
    <div class="fw-700 mb-2"><i class="bi bi-info-circle me-1"></i>Access Roles</div>
    <div class="d-flex flex-wrap gap-2">
      <span class="badge rounded-pill" style="background:#fef3c7;color:#92400e;font-size:.73rem">👑 Super Admin</span>
      <span class="badge rounded-pill" style="background:#dbeafe;color:#1e40af;font-size:.73rem">🏙️ Sub Admin</span>
      <span class="badge rounded-pill" style="background:#f0fdf4;color:#166534;font-size:.73rem">🤝 Broker</span>
      <span class="badge rounded-pill" style="background:#fdf4ff;color:#6b21a8;font-size:.73rem">🏨 Hotel Manager</span>
    </div>
  </div>

  <hr class="my-3">
  <div class="text-center">
    <a href="/" class="text-muted small text-decoration-none">
      <i class="bi bi-arrow-left me-1"></i>Back to Booking Website
    </a>
  </div>
</div>

<script>
function togglePw(){
  const pw=document.getElementById('pwField');
  const ic=document.getElementById('eyeIcon');
  if(pw.type==='password'){pw.type='text';ic.className='bi bi-eye-slash text-muted';}
  else{pw.type='password';ic.className='bi bi-eye text-muted';}
}
</script>
<script src="/assets/js/dallol-validate.js"></script>
</body>
</html>
