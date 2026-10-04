<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php $isEdit = !empty($hotel); ?>
<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/super/hotels" class="btn btn-outline-secondary btn-sm rounded-pill fw-700">
    <i class="bi bi-arrow-left me-1"></i>Back
  </a>
  <h4 class="fw-900 mb-0"><?= $isEdit ? 'Edit Hotel: '.esc($hotel['name']) : '➕ Add New Hotel' ?></h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-8">
    <div class="admin-form-card">
      <div class="alert alert-info rounded-3 small py-2 mb-4">
        <i class="bi bi-info-circle me-1"></i>
        Hotel will appear <strong>immediately</strong> on the booking website after saving.
        Use an Unsplash image URL for the photo.
      </div>

      <form action="<?= $isEdit ? '/admin/super/hotels/'.$hotel['id'].'/edit' : '/admin/super/hotels/add' ?>" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <!-- Name -->
          <div class="col-md-8">
            <label class="form-label">Hotel Name *</label>
            <input type="text" name="name" class="form-control" placeholder="e.g. Lalibela Heritage Hotel"
                   value="<?= esc($hotel['name']??old('name')) ?>" required>
          </div>
          <div class="col-md-4">
            <label class="form-label">Hotel Type</label>
            <select name="type" class="form-select">
              <?php foreach($hotelTypes as $t): ?>
              <option value="<?= $t ?>" <?= ($hotel['type']??'')===$t?'selected':'' ?>><?= $t ?></option>
              <?php endforeach; ?>
            </select>
          </div>

          <!-- City — pulls from DB -->
          <div class="col-md-6">
            <label class="form-label">City *
              <small class="text-muted fw-400">(type any Ethiopian city)</small>
            </label>
            <input type="text" name="city" class="form-control"
                   placeholder="e.g. Lalibela"
                   value="<?= esc($hotel['city']??old('city')) ?>"
                   list="city-list" required>
            <datalist id="city-list">
              <?php foreach($cities as $city): ?>
              <option value="<?= esc($city['name']) ?>"><?= esc($city['name']) ?><?= $city['region']?' — '.$city['region']:'' ?></option>
              <?php endforeach; ?>
            </datalist>
            <div class="form-text">
              <a href="/admin/super/cities" target="_blank" class="text-primary">
                <i class="bi bi-plus-circle me-1"></i>Add a new city first if not in the list
              </a>
            </div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Price Per Night (ETB) *</label>
            <div class="input-group">
              <span class="input-group-text bg-white fw-700">ETB</span>
              <input type="number" name="price_per_night" class="form-control"
                     placeholder="2500" min="0" step="0.01"
                     value="<?= esc($hotel['price_per_night']??old('price_per_night')) ?>" required>
            </div>
          </div>

          <!-- Address -->
          <div class="col-12">
            <label class="form-label">Address</label>
            <input type="text" name="address" class="form-control"
                   placeholder="e.g. Main Street, near St. George Church"
                   value="<?= esc($hotel['address']??old('address')) ?>">
          </div>

          <!-- Description -->
          <div class="col-12">
            <label class="form-label">Description</label>
            <textarea name="description" class="form-control" rows="3"
                      placeholder="Describe the hotel, location, and highlights..."><?= esc($hotel['description']??'') ?></textarea>
          </div>

          <!-- Image URL -->
          <div class="col-12">
            <label class="form-label">Primary Image URL</label>
            <input type="url" name="image_url" class="form-control" id="imgUrl"
                   placeholder="https://images.unsplash.com/photo-xxxxxxx?w=800"
                   value="<?= esc($hotel['img']??old('image_url')) ?>"
                   oninput="previewImg(this.value)">
            <div class="form-text">
              Use free images from
              <a href="https://unsplash.com/s/photos/hotel-ethiopia" target="_blank">Unsplash</a>.
              Right-click any photo → Copy image address
            </div>
            <img id="imgPreview" src="<?= esc($hotel['img']??'') ?>" alt="Preview"
                 class="mt-2 rounded-3" style="height:100px;object-fit:cover;display:<?= ($hotel['img']??'')?'block':'none' ?>">
          </div>

          <!-- Amenities -->
          <div class="col-12">
            <label class="form-label">Amenities <small class="text-muted fw-400">(comma-separated)</small></label>
            <input type="text" name="amenities" class="form-control"
                   placeholder="Free WiFi, Pool, Restaurant, Spa, Parking"
                   value="<?= old('amenities') ?>">
          </div>

          <!-- Coords -->
          <div class="col-md-6">
            <label class="form-label">Latitude <small class="text-muted fw-400">(optional)</small></label>
            <input type="number" name="latitude" class="form-control" step="0.000001"
                   placeholder="9.0192" value="<?= esc($hotel['latitude']??'') ?>">
          </div>
          <div class="col-md-6">
            <label class="form-label">Longitude <small class="text-muted fw-400">(optional)</small></label>
            <input type="number" name="longitude" class="form-control" step="0.000001"
                   placeholder="38.7525" value="<?= esc($hotel['longitude']??'') ?>">
          </div>

          <!-- Featured -->
          <div class="col-12">
            <div class="form-check form-switch">
              <input class="form-check-input" type="checkbox" name="is_featured" id="isFeatured"
                     <?= ($hotel['is_featured']??false)===true||($hotel['is_featured']??'')==='t'?'checked':'' ?>>
              <label class="form-check-label fw-600" for="isFeatured">
                ⭐ Feature on Home Page
                <span class="text-muted fw-400 small">(shows in "Featured Hotels" section)</span>
              </label>
            </div>
          </div>

          <div class="col-12 d-flex gap-3 mt-2">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-5">
              <i class="bi bi-check-circle me-2"></i><?= $isEdit ? 'Save Changes' : 'Add Hotel to Website' ?>
            </button>
            <a href="/admin/super/hotels" class="btn btn-outline-secondary rounded-3 fw-700">Cancel</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->section('scripts') ?>
<script>
function previewImg(url) {
  const img = document.getElementById('imgPreview');
  if(url) { img.src=url; img.style.display='block'; }
  else img.style.display='none';
}
</script>
<?= $this->endSection() ?>

<?= $this->endSection() ?>
