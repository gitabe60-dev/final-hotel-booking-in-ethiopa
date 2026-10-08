<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php $admin['city'] = $city ?? ''; $isEdit = !empty($broker); ?>
<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/subadmin/brokers" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Back</a>
  <h4 class="fw-900 mb-0"><?= $isEdit?'Edit Broker: '.esc($broker['broker_name']??''):'Create Broker' ?></h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-6">
    <div class="admin-form-card">
      <form action="<?= $isEdit?'/admin/subadmin/brokers/'.($broker['admin_id']??0).'/edit':'/admin/subadmin/brokers/create' ?>" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <?php if(!$isEdit): ?>
          <div class="col-12">
            <label class="form-label">Full Name *</label>
            <input type="text" name="full_name" class="form-control" placeholder="Broker full name"
                   value="<?= old('full_name') ?>" required data-rule="name" data-label="Full name">
          </div>
          <div class="col-md-6">
            <label class="form-label">Email *</label>
            <input type="email" name="email" class="form-control" placeholder="broker@example.com"
                   value="<?= old('email') ?>" required data-label="Email">
          </div>
          <div class="col-md-6">
            <label class="form-label">Password *</label>
            <div class="input-group">
              <input type="password" name="password" id="brkPass" class="form-control"
                     placeholder="Min 6 chars" required minlength="6" data-label="Password">
              <button type="button" class="input-group-text bg-white"
                      onclick="const i=document.getElementById('brkPass');const ic=this.querySelector('i');i.type=i.type==='password'?'text':'password';ic.className=i.type==='text'?'bi bi-eye-slash':'bi bi-eye'">
                <i class="bi bi-eye"></i>
              </button>
            </div>
          </div>
          <?php else: ?>
          <div class="col-12">
            <label class="form-label">Full Name *</label>
            <input type="text" name="full_name" class="form-control"
                   value="<?= esc($broker['broker_name']??'') ?>" required
                   data-rule="name" data-label="Full name">
          </div>
          <?php endif; ?>
          <div class="col-md-6">
            <label class="form-label">Phone</label>
            <div class="input-group">
              <span class="input-group-text bg-white fw-700">+251</span>
              <input type="tel" name="phone" class="form-control" placeholder="9xxxxxxxxx"
                     value="<?= esc($broker['broker_phone']??old('phone')??'') ?>"
                     data-label="Phone" maxlength="10"
                     oninput="this.value=this.value.replace(/\D/g,'').substring(0,10)">
            </div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Commission %</label>
            <input type="number" name="commission_pct" class="form-control" placeholder="5"
                   value="<?= esc($broker['commission_pct']??0) ?>" min="0" max="100" step="0.01"
                   data-label="Commission">
          </div>
          <?php if($isEdit): ?>
          <div class="col-12">
            <label class="form-label">Status</label>
            <select name="status" class="form-select">
              <option value="active" <?= ($broker['status']??'')==='active'?'selected':'' ?>>Active</option>
              <option value="suspended" <?= ($broker['status']??'')==='suspended'?'selected':'' ?>>Suspended</option>
            </select>
          </div>
          <?php endif; ?>
          <div class="col-12 d-flex gap-3 mt-2">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-5">
              <i class="bi bi-check-circle me-2"></i><?= $isEdit?'Save Changes':'Create Broker' ?>
            </button>
            <a href="/admin/subadmin/brokers" class="btn btn-outline-secondary rounded-3 fw-700">Cancel</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
