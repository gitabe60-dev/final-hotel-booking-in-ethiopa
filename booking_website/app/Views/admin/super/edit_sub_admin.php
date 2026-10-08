<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/super/sub-admins" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Back</a>
  <h4 class="fw-900 mb-0">Edit Sub-Admin: <?= esc($admin['full_name']) ?></h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="admin-form-card">
      <form action="/admin/super/sub-admins/<?= $admin['id'] ?>/edit" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Full Name *</label>
            <input type="text" name="full_name" class="form-control"
                   value="<?= esc($admin['full_name']) ?>" required
                   data-rule="name" data-label="Full name">
          </div>
          <div class="col-md-6">
            <label class="form-label">Email *</label>
            <input type="email" name="email" class="form-control"
                   value="<?= esc($admin['email']) ?>" required data-label="Email">
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
          <div class="col-md-6">
            <label class="form-label">City Assignment</label>
            <input type="text" name="city" list="et-cities-edit" class="form-control"
                   value="<?= esc($admin['cities'][0] ?? '') ?>"
                   placeholder="Type any Ethiopian city...">
            <datalist id="et-cities-edit">
              <?php foreach(['Addis Ababa','Dire Dawa','Mekelle','Gondar','Hawassa','Bahir Dar',
                'Dessie','Jimma','Jijiga','Shashamane','Bishoftu','Sodo','Arba Minch',
                'Hosaena','Harar','Dilla','Nekemte','Debre Birhan','Asella','Adama',
                'Woldia','Debre Markos','Kombolcha','Axum','Lalibela','Gambella',
                'Assosa','Semera','Logia','Shire'] as $ec): ?>
              <option value="<?= esc($ec) ?>">
              <?php endforeach; ?>
            </datalist>
            <div class="form-text">Current: <?= esc(implode(', ', $admin['cities'] ?? ['None'])) ?></div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Status</label>
            <select name="status" class="form-select">
              <option value="active"    <?= $admin['status']==='active'?'selected':'' ?>>Active</option>
              <option value="suspended" <?= $admin['status']==='suspended'?'selected':'' ?>>Suspended</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">New Password <span class="text-muted fw-400">(leave blank to keep)</span></label>
            <input type="password" name="password" class="form-control" placeholder="New password..." minlength="6">
          </div>
          <div class="col-12 d-flex gap-3 mt-2">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-5">
              <i class="bi bi-check-circle me-2"></i>Save Changes
            </button>
            <a href="/admin/super/sub-admins" class="btn btn-outline-secondary rounded-3 fw-700">Cancel</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
