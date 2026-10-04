<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<div class="d-flex align-items-center py-5 bg-light min-vh-80">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-sm-10 col-md-7 col-lg-5">
                <div class="auth-card bg-white">
                    <div class="text-center mb-4">
                        <div class="bg-warning bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width:72px;height:72px">
                            <i class="bi bi-key text-warning fs-2"></i>
                        </div>
                        <h4 class="fw-bold">Forgot Password?</h4>
                        <p class="text-muted small">Enter your email and we'll send a reset link.</p>
                    </div>

                    <form action="/forgot-password" method="POST">
                        <?= csrf_field() ?>
                        <div class="mb-4">
                            <label class="form-label small fw-semibold">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-envelope text-muted"></i></span>
                                <input type="email" name="email" class="form-control" placeholder="you@email.com" required autofocus>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-warning fw-semibold w-100 py-2">
                            <i class="bi bi-send me-2"></i>Send Reset Link
                        </button>
                    </form>

                    <p class="text-center mt-4 mb-0 small text-muted">
                        Remember it? <a href="/login" class="text-primary fw-semibold text-decoration-none">Back to Login</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<?= $this->endSection() ?>
