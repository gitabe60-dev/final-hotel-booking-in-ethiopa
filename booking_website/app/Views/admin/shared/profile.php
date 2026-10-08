<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4">My Profile</h4>

<div class="row justify-content-center">
  <div class="col-lg-6">
    <div class="admin-form-card">
      <div class="text-center mb-4">
        <div class="mx-auto mb-3 d-flex align-items-center justify-content-center rounded-circle fw-900 text-white"
             style="width:72px;height:72px;background:linear-gradient(135deg,#1a56db,#7c3aed);font-size:1.8rem">
          <?= strtoupper(substr($admin['full_name']??'A',0,1)) ?>
        </div>
        <span class="badge role-<?= str_replace(['_admin','hotel_','_'],['','',' '],$admin['role']??'') ?> rounded-pill fs-6" style="font-size:.8rem!important"><?= ucfirst(str_replace('_',' ',$admin['role']??'')) ?></span>
      </div>
      <form action="/admin/profile" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <div class="col-12">
            <label class="form-label">Full Name</label>
            <input type="text" name="full_name" class="form-control"
                   value="<?= esc($admin['full_name']??'') ?>" required
                   data-rule="name" data-label="Full name">
          </div>
          <div class="col-md-6">
            <label class="form-label">Email <span class="text-muted fw-400">(read-only)</span></label>
            <input type="email" class="form-control" style="background:#f8fafc"
                   value="<?= esc($admin['email']??'') ?>" disabled>
          </div>
          <div class="col-md-6">
            <label class="form-label">Phone</label>
            <div class="input-group">
              <span class="input-group-text bg-white fw-700">+251</span>
              <input type="tel" name="phone" class="form-control"
                     value="<?= esc(ltrim($admin['phone']??'','+251')) ?>"
                     data-label="Phone" maxlength="10"
                     oninput="this.value=this.value.replace(/\D/g,'').substring(0,10)">
            </div>
          </div>
          <div class="col-12 d-flex gap-3">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4"><i class="bi bi-check-circle me-2"></i>Save</button>
            <a href="/admin/change-password" class="btn btn-outline-warning rounded-3 fw-700 px-4"><i class="bi bi-key me-1"></i>Change Password</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
