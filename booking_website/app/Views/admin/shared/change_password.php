<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4">Change Password</h4>
<div class="row justify-content-center">
  <div class="col-lg-5">
    <div class="admin-form-card">
      <form action="/admin/change-password" method="POST">
        <?= csrf_field() ?>
        <div class="mb-3">
          <label class="form-label">Current Password *</label>
          <input type="password" name="current_password" class="form-control" required>
        </div>
        <div class="mb-3">
          <label class="form-label">New Password *</label>
          <input type="password" name="new_password" class="form-control" minlength="6" required>
        </div>
        <div class="mb-4">
          <label class="form-label">Confirm New Password *</label>
          <input type="password" name="confirm_password" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4"><i class="bi bi-key me-2"></i>Update Password</button>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
