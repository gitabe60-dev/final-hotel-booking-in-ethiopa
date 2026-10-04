<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/super/sub-admins" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Back</a>
  <h4 class="fw-900 mb-0">Create Sub-Admin</h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="admin-form-card">
      <?php if(session()->getFlashdata('errors')): ?>
      <div class="alert alert-danger rounded-3 small mb-3">
        <?php foreach(session()->getFlashdata('errors') as $e): ?><div><i class="bi bi-x-circle me-1"></i><?= esc($e) ?></div><?php endforeach; ?>
      </div>
      <?php endif; ?>

      <form action="/admin/super/sub-admins/create" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Full Name *</label>
            <input type="text" name="full_name" class="form-control" placeholder="Kebede Alemu" value="<?= old('full_name') ?>" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Email Address *</label>
            <input type="email" name="email" class="form-control" placeholder="kebede@example.com" value="<?= old('email') ?>" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Phone Number</label>
            <div class="input-group">
              <span class="input-group-text">+251</span>
              <input type="tel" name="phone" class="form-control" placeholder="9xxxxxxxxx" value="<?= old('phone') ?>">
            </div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Assign City</label>
            <input type="text" name="city" list="et-cities-create" class="form-control"
                   placeholder="Type any Ethiopian city..." value="<?= old('city') ?>">
            <datalist id="et-cities-create">
              <?php foreach(['Addis Ababa','Dire Dawa','Mekelle','Gondar','Hawassa','Bahir Dar',
                'Dessie','Jimma','Jijiga','Shashamane','Bishoftu','Sodo','Arba Minch',
                'Hosaena','Harar','Dilla','Nekemte','Debre Birhan','Asella','Adama',
                'Woldia','Debre Markos','Kombolcha','Axum','Lalibela','Gambella',
                'Assosa','Semera','Logia','Shire'] as $ec): ?>
              <option value="<?= esc($ec) ?>">
              <?php endforeach; ?>
            </datalist>
            <div class="form-text">Start typing — or enter any city in Ethiopia</div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Password *</label>
            <input type="password" name="password" class="form-control" placeholder="Min. 6 characters" required minlength="6">
          </div>
          <div class="col-md-6">
            <label class="form-label">Confirm Password *</label>
            <input type="password" name="password_confirm" class="form-control" placeholder="Repeat password" required>
          </div>
          <div class="col-12">
            <div class="alert alert-info rounded-3 small py-2">
              <i class="bi bi-info-circle me-1"></i>
              The sub-admin will only be able to manage hotels in their assigned city.
            </div>
          </div>
          <div class="col-12 d-flex gap-3">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-5">
              <i class="bi bi-person-plus me-2"></i>Create Sub-Admin
            </button>
            <a href="/admin/super/sub-admins" class="btn btn-outline-secondary rounded-3 fw-700">Cancel</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
