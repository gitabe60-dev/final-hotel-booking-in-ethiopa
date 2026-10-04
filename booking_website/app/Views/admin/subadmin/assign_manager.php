<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Back</a>
  <h4 class="fw-900 mb-0">Assign Hotel Manager — <?= esc($hotel['name']) ?></h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-6">
    <div class="admin-form-card">
      <div class="alert alert-info rounded-3 small mb-4 py-2">
        <i class="bi bi-info-circle me-1"></i>
        This will create a new Hotel Manager account and link it to <strong><?= esc($hotel['name']) ?></strong>.
      </div>
      <form action="/admin/subadmin/hotels/<?= $hotel['id'] ?>/assign-manager" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <div class="col-12">
            <label class="form-label">Manager Full Name *</label>
            <input type="text" name="full_name" class="form-control" placeholder="Manager name" value="<?= old('full_name') ?>" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Email *</label>
            <input type="email" name="email" class="form-control" placeholder="manager@hotel.com" value="<?= old('email') ?>" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Password *</label>
            <input type="password" name="password" class="form-control" placeholder="Min 6 chars" required minlength="6">
          </div>
          <div class="col-md-6">
            <label class="form-label">Phone</label>
            <input type="tel" name="phone" class="form-control" placeholder="+251..." value="<?= old('phone') ?>">
          </div>
          <div class="col-md-6">
            <label class="form-label">Assign to Broker <span class="text-muted fw-400">(optional)</span></label>
            <select name="broker_id" class="form-select">
              <option value="">No broker</option>
              <?php foreach($brokers as $b): ?>
              <option value="<?= $b['admin_id'] ?>"><?= esc($b['broker_name']) ?></option>
              <?php endforeach; ?>
            </select>
          </div>
          <div class="col-12 d-flex gap-3 mt-2">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-5">
              <i class="bi bi-person-check me-2"></i>Assign Manager
            </button>
            <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary rounded-3 fw-700">Cancel</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
