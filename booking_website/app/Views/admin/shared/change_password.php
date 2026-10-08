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
          <div class="input-group">
            <input type="password" name="current_password" id="cpCur" class="form-control" required
                   data-label="Current password">
            <button type="button" class="input-group-text bg-white"
                    onclick="const i=document.getElementById('cpCur');const ic=this.querySelector('i');i.type=i.type==='password'?'text':'password';ic.className=i.type==='text'?'bi bi-eye-slash':'bi bi-eye'">
              <i class="bi bi-eye"></i>
            </button>
          </div>
        </div>
        <div class="mb-3">
          <label class="form-label">New Password *</label>
          <div class="input-group">
            <input type="password" name="new_password" id="cpNew" class="form-control"
                   minlength="6" required data-label="New password">
            <button type="button" class="input-group-text bg-white"
                    onclick="const i=document.getElementById('cpNew');const ic=this.querySelector('i');i.type=i.type==='password'?'text':'password';ic.className=i.type==='text'?'bi bi-eye-slash':'bi bi-eye'">
              <i class="bi bi-eye"></i>
            </button>
          </div>
        </div>
        <div class="mb-4">
          <label class="form-label">Confirm New Password *</label>
          <div class="input-group">
            <input type="password" name="confirm_password" id="cpConf" class="form-control" required
                   data-label="Confirm password" data-ref="new_password">
            <button type="button" class="input-group-text bg-white"
                    onclick="const i=document.getElementById('cpConf');const ic=this.querySelector('i');i.type=i.type==='password'?'text':'password';ic.className=i.type==='text'?'bi bi-eye-slash':'bi bi-eye'">
              <i class="bi bi-eye"></i>
            </button>
          </div>
        </div>
        <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">
          <i class="bi bi-key me-2"></i>Update Password
        </button>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
