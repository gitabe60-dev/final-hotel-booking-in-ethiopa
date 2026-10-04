<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php $isEdit = !empty($room); ?>
<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/subadmin/hotels/<?= $hotel['id'] ?>/rooms" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Back to Rooms</a>
  <h4 class="fw-900 mb-0"><?= $isEdit?'Edit Room: '.esc($room['name']):'Add Room — '.esc($hotel['name']) ?></h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="admin-form-card">
      <form action="<?= $isEdit?"/admin/subadmin/hotels/{$hotel['id']}/rooms/{$room['id']}/edit":"/admin/subadmin/hotels/{$hotel['id']}/rooms/add" ?>" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <div class="col-md-8">
            <label class="form-label">Room Name *</label>
            <input type="text" name="name" class="form-control" placeholder="e.g. Deluxe Double Room" value="<?= esc($room['name']??old('name')) ?>" required>
          </div>
          <div class="col-md-4">
            <label class="form-label">Bed Type *</label>
            <select name="bed_type" class="form-select">
              <?php foreach(['King Bed','Queen Bed','Twin Beds','Single Bed','Bunk Beds','Super King Bed'] as $bt): ?>
              <option value="<?= $bt ?>" <?= ($room['bed_type']??'')===$bt?'selected':'' ?>><?= $bt ?></option>
              <?php endforeach; ?>
            </select>
          </div>
          <div class="col-md-4">
            <label class="form-label">Price Per Night (ETB) *</label>
            <input type="number" name="price_per_night" class="form-control" placeholder="1500" value="<?= esc($room['price_per_night']??old('price_per_night')) ?>" required min="0" step="0.01">
          </div>
          <div class="col-md-4">
            <label class="form-label">Size (m²)</label>
            <input type="number" name="size_sqm" class="form-control" placeholder="22" value="<?= esc($room['size_sqm']??old('size_sqm')??0) ?>" min="0" step="0.1">
          </div>
          <div class="col-md-4">
            <label class="form-label">Max Guests</label>
            <input type="number" name="max_guests" class="form-control" placeholder="2" value="<?= esc($room['max_guests']??old('max_guests')??2) ?>" min="1" max="20">
          </div>
          <div class="col-12">
            <label class="form-label">Room Image URL</label>
            <input type="url" name="image_url" class="form-control" placeholder="https://images.unsplash.com/..." value="<?= esc($room['image_url']??old('image_url')??'') ?>">
          </div>
          <div class="col-12">
            <label class="form-label">Features <span class="text-muted fw-400 small">(comma-separated)</span></label>
            <input type="text" name="features" class="form-control" placeholder="Free WiFi, Air Conditioning, TV, Mini Bar" value="<?= esc($room['features_str']??old('features')??'') ?>">
            <div class="form-text">E.g. Free WiFi, Air Conditioning, Balcony, Mini Bar</div>
          </div>
          <?php if($isEdit): ?>
          <div class="col-12">
            <div class="form-check form-switch">
              <input class="form-check-input" type="checkbox" name="is_available" id="isAvailable" <?= ($room['is_available']===true||$room['is_available']==='t')?'checked':'' ?>>
              <label class="form-check-label fw-600" for="isAvailable">Available for Booking</label>
            </div>
          </div>
          <?php endif; ?>
          <div class="col-12 d-flex gap-3 mt-2">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-5">
              <i class="bi bi-check-circle me-2"></i><?= $isEdit?'Save Changes':'Add Room' ?>
            </button>
            <a href="/admin/subadmin/hotels/<?= $hotel['id'] ?>/rooms" class="btn btn-outline-secondary rounded-3 fw-700">Cancel</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
