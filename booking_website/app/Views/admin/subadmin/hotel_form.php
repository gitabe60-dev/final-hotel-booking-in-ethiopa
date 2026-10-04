<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php $admin['city'] = $city ?? ''; ?>
<?php $isEdit = !empty($hotel); ?>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Back</a>
  <h4 class="fw-900 mb-0"><?= $isEdit?'Edit Hotel: '.esc($hotel['name']):'Add New Hotel' ?></h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-8">
    <div class="admin-form-card">
      <form action="<?= $isEdit?"/admin/subadmin/hotels/{$hotel['id']}/edit":'/admin/subadmin/hotels/add' ?>" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <div class="col-md-8">
            <label class="form-label">Hotel Name *</label>
            <input type="text" name="name" class="form-control" placeholder="e.g. Grand Sheraton Hotel" value="<?= esc($hotel['name']??old('name')) ?>" required>
          </div>
          <div class="col-md-4">
            <label class="form-label">Type</label>
            <select name="type" class="form-select">
              <?php foreach($hotelTypes as $t): ?>
              <option value="<?= $t ?>" <?= ($hotel['type']??'')===$t?'selected':'' ?>><?= $t ?></option>
              <?php endforeach; ?>
            </select>
          </div>
          <div class="col-12">
            <label class="form-label">Address *</label>
            <input type="text" name="address" class="form-control" placeholder="Full address in <?= esc($city) ?>" value="<?= esc($hotel['address']??old('address')) ?>" required>
          </div>
          <div class="col-12">
            <label class="form-label">Description</label>
            <textarea name="description" class="form-control" rows="3" placeholder="Describe the hotel..."><?= esc($hotel['description']??'') ?></textarea>
          </div>
          <div class="col-md-4">
            <label class="form-label">Price Per Night (ETB) *</label>
            <input type="number" name="price_per_night" class="form-control" placeholder="2500" value="<?= esc($hotel['price_per_night']??old('price_per_night')) ?>" required min="0" step="0.01">
          </div>
          <div class="col-md-4">
            <label class="form-label">Latitude</label>
            <input type="number" name="latitude" class="form-control" placeholder="9.0192" value="<?= esc($hotel['latitude']??'') ?>" step="0.000001">
          </div>
          <div class="col-md-4">
            <label class="form-label">Longitude</label>
            <input type="number" name="longitude" class="form-control" placeholder="38.7525" value="<?= esc($hotel['longitude']??'') ?>" step="0.000001">
          </div>
          <div class="col-12">
            <label class="form-label">Primary Image URL</label>
            <input type="url" name="image_url" class="form-control" placeholder="https://images.unsplash.com/..." value="<?= esc($hotel['images'][0]['image_url']??'') ?>">
            <div class="form-text">Use Unsplash or any online image URL</div>
          </div>
          <div class="col-12 d-flex gap-3 mt-3">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-5">
              <i class="bi bi-check-circle me-2"></i><?= $isEdit?'Save Changes':'Add Hotel' ?>
            </button>
            <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary rounded-3 fw-700">Cancel</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
