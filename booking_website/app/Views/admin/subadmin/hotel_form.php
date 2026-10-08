<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php
$isEdit  = !empty($hotel);
$mgr     = $manager ?? [];
$hasMgr  = !empty($mgr);
$brokers = $brokers ?? [];
$amenStr = '';
if ($isEdit && !empty($hotel['amenities'])) {
    $amenStr = implode(', ', array_column($hotel['amenities'], 'amenity'));
}
?>

<style>
.section-card{background:#fff;border-radius:16px;box-shadow:0 2px 16px rgba(0,0,0,.06);padding:28px 32px;margin-bottom:24px}
.section-title{font-size:1rem;font-weight:800;color:#1a1a2e;display:flex;align-items:center;gap:8px;margin-bottom:20px;padding-bottom:12px;border-bottom:2px solid #f0f4ff}
.section-title .badge-icon{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:1rem}
.toggle-section{cursor:pointer;user-select:none}
.toggle-section .bi-chevron-down{transition:transform .3s}
.toggle-section.collapsed .bi-chevron-down{transform:rotate(-90deg)}
.mgr-card{background:linear-gradient(135deg,#f0f7ff 0%,#e8f4fd 100%);border:2px solid #c3dffe;border-radius:14px;padding:20px 24px}
.mgr-existing{background:linear-gradient(135deg,#f0fff4 0%,#e8fdf0 100%);border:2px solid #b7efc5;border-radius:12px;padding:16px 20px;margin-bottom:18px}
.form-label{font-weight:700;font-size:.85rem;color:#333;margin-bottom:5px}
.required-star{color:#e74c3c}
.img-preview{max-width:100%;max-height:140px;border-radius:10px;object-fit:cover;display:none;margin-top:8px}
</style>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary btn-sm rounded-pill fw-700">
    <i class="bi bi-arrow-left me-1"></i>Back to Hotels
  </a>
  <div>
    <h4 class="fw-900 mb-0"><?= $isEdit ? 'Edit Hotel' : 'Add New Hotel' ?></h4>
    <small class="text-muted">City: <strong><?= esc($city) ?></strong></small>
  </div>
</div>

<?php if(session()->getFlashdata('error')): ?>
<div class="alert alert-danger rounded-3 border-0 mb-3">
  <i class="bi bi-exclamation-triangle me-2"></i><?= session()->getFlashdata('error') ?>
</div>
<?php endif; ?>

<form action="<?= $isEdit ? "/admin/subadmin/hotels/{$hotel['id']}/edit" : '/admin/subadmin/hotels/add' ?>" method="POST" id="hotelForm">
  <?= csrf_field() ?>

  <!-- ══ SECTION 1: Hotel Details ══════════════════════════════════════════ -->
  <div class="section-card">
    <div class="section-title">
      <span class="badge-icon bg-primary text-white"><i class="bi bi-building"></i></span>
      Hotel Information
    </div>

    <div class="row g-3">
      <div class="col-md-8">
        <label class="form-label">Hotel Name <span class="required-star">*</span></label>
        <input type="text" name="name" class="form-control" placeholder="e.g. Grand Sheraton Hotel"
               value="<?= esc($hotel['name'] ?? old('name')) ?>" required>
      </div>
      <div class="col-md-4">
        <label class="form-label">Hotel Type</label>
        <select name="type" class="form-select">
          <?php foreach($hotelTypes as $t): ?>
          <option value="<?= $t ?>" <?= ($hotel['type'] ?? '') === $t ? 'selected' : '' ?>><?= $t ?></option>
          <?php endforeach; ?>
        </select>
      </div>

      <div class="col-12">
        <label class="form-label">Address <span class="required-star">*</span></label>
        <input type="text" name="address" class="form-control" placeholder="Full address in <?= esc($city) ?>"
               value="<?= esc($hotel['address'] ?? old('address')) ?>" required>
      </div>

      <div class="col-12">
        <label class="form-label">Description</label>
        <textarea name="description" class="form-control" rows="3"
                  placeholder="Describe the hotel facilities, ambiance, and highlights..."><?= esc($hotel['description'] ?? '') ?></textarea>
      </div>

      <div class="col-md-4">
        <label class="form-label">Price Per Night (ETB) <span class="required-star">*</span></label>
        <div class="input-group">
          <span class="input-group-text fw-700">ETB</span>
          <input type="number" name="price_per_night" class="form-control" placeholder="2500"
                 value="<?= esc($hotel['price_per_night'] ?? old('price_per_night')) ?>" required min="0" step="0.01">
        </div>
      </div>
      <div class="col-md-4">
        <label class="form-label">Latitude</label>
        <input type="number" name="latitude" class="form-control" placeholder="9.0192"
               value="<?= esc($hotel['latitude'] ?? '') ?>" step="0.000001">
      </div>
      <div class="col-md-4">
        <label class="form-label">Longitude</label>
        <input type="number" name="longitude" class="form-control" placeholder="38.7525"
               value="<?= esc($hotel['longitude'] ?? '') ?>" step="0.000001">
      </div>

      <div class="col-12">
        <label class="form-label">Amenities <span class="text-muted fw-400">(comma-separated)</span></label>
        <input type="text" name="amenities" class="form-control"
               placeholder="Free WiFi, Swimming Pool, Gym, Spa, Parking, Restaurant..."
               value="<?= esc($amenStr ?: old('amenities')) ?>">
        <div class="form-text">Separate each amenity with a comma</div>
      </div>

      <div class="col-12">
        <label class="form-label">Primary Image URL</label>
        <input type="url" name="image_url" class="form-control" id="imgUrlInput"
               placeholder="https://images.unsplash.com/..."
               value="<?= esc($hotel['images'][0]['image_url'] ?? '') ?>"
               oninput="previewImg(this.value)">
        <div class="form-text">Paste any public image URL (Unsplash recommended)</div>
        <img id="imgPreview" class="img-preview"
             src="<?= esc($hotel['images'][0]['image_url'] ?? '') ?>"
             alt="Preview"
             <?= !empty($hotel['images'][0]['image_url']) ? 'style="display:block"' : '' ?>>
      </div>
    </div>
  </div>

  <!-- ══ SECTION 2: Hotel Manager ══════════════════════════════════════════ -->
  <div class="section-card">
    <div class="section-title toggle-section <?= $hasMgr ? '' : 'collapsed' ?>"
         onclick="toggleMgrSection(this)" id="mgrToggle">
      <span class="badge-icon bg-success text-white"><i class="bi bi-person-badge"></i></span>
      Hotel Manager
      <span class="ms-auto badge bg-<?= $hasMgr ? 'success' : 'secondary' ?> rounded-pill small fw-600" id="mgrBadge">
        <?= $hasMgr ? 'Assigned' : 'Optional' ?>
      </span>
      <i class="bi bi-chevron-down ms-2" style="<?= $hasMgr ? '' : 'transform:rotate(-90deg)' ?>"></i>
    </div>

    <div id="mgrSection" style="<?= $hasMgr ? '' : 'display:none' ?>">

      <?php if($hasMgr): ?>
      <!-- Existing manager info banner -->
      <div class="mgr-existing d-flex align-items-center gap-3 mb-3">
        <div style="width:44px;height:44px;background:linear-gradient(135deg,#28a745,#20c997);border-radius:12px;display:flex;align-items:center;justify-content:center">
          <i class="bi bi-person-check-fill text-white fs-5"></i>
        </div>
        <div class="flex-grow-1">
          <div class="fw-800 small"><?= esc($mgr['full_name']) ?></div>
          <div class="text-muted" style="font-size:.8rem"><?= esc($mgr['email']) ?> <?= !empty($mgr['phone']) ? '· '.esc($mgr['phone']) : '' ?></div>
        </div>
        <span class="badge bg-success rounded-pill">Current Manager</span>
      </div>
      <p class="text-muted small mb-3">
        <i class="bi bi-info-circle me-1"></i>
        To replace this manager, go to <a href="/admin/subadmin/hotels/<?= $hotel['id'] ?>/assign-manager" class="text-primary fw-700">Assign Manager</a>.
        Below you can only update the broker assignment.
      </p>
      <?php else: ?>
      <div class="mgr-card mb-3">
        <p class="text-muted small mb-3">
          <i class="bi bi-info-circle me-1 text-primary"></i>
          Optionally register a Hotel Manager account now. The manager can login to manage rooms, view bookings, and communicate with brokers.
          Leave blank to add a manager later.
        </p>
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Manager Full Name</label>
            <input type="text" name="mgr_name" class="form-control" placeholder="e.g. Abebe Girma"
                   value="<?= esc(old('mgr_name')) ?>" oninput="updateMgrRequired()">
          </div>
          <div class="col-md-6">
            <label class="form-label">Manager Phone</label>
            <input type="tel" name="mgr_phone" class="form-control" placeholder="+251911..."
                   value="<?= esc(old('mgr_phone')) ?>">
          </div>
          <div class="col-md-6">
            <label class="form-label">Manager Email</label>
            <input type="email" name="mgr_email" id="mgrEmail" class="form-control"
                   placeholder="manager@hotel.com"
                   value="<?= esc(old('mgr_email')) ?>">
          </div>
          <div class="col-md-6">
            <label class="form-label">Manager Password</label>
            <div class="input-group">
              <input type="password" name="mgr_password" id="mgrPass" class="form-control"
                     placeholder="Min 6 characters" minlength="6">
              <button type="button" class="btn btn-outline-secondary" onclick="togglePass('mgrPass',this)">
                <i class="bi bi-eye"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
      <?php endif; ?>

      <!-- Broker assignment (always editable) -->
      <div class="row g-3 mt-1">
        <div class="col-md-6">
          <label class="form-label">Assign to Broker <span class="text-muted fw-400">(optional)</span></label>
          <?php if(empty($brokers)): ?>
            <div class="alert alert-light border rounded-3 py-2 small mb-0">
              <i class="bi bi-info-circle me-1"></i>
              No brokers yet. <a href="/admin/subadmin/brokers/create" class="text-primary fw-700">Create a broker first</a>.
            </div>
          <?php else: ?>
            <select name="broker_id" class="form-select">
              <option value="">— No broker —</option>
              <?php foreach($brokers as $b): ?>
              <option value="<?= $b['admin_id'] ?>"
                <?= (isset($mgr['broker_id']) && (int)$mgr['broker_id'] === (int)$b['admin_id']) ? 'selected' : '' ?>>
                <?= esc($b['broker_name']) ?>
                <?php if(!empty($b['commission_pct'])): ?>(<?= $b['commission_pct'] ?>% commission)<?php endif; ?>
              </option>
              <?php endforeach; ?>
            </select>
            <div class="form-text">Broker will be notified of bookings for this hotel.</div>
          <?php endif; ?>
        </div>
      </div>

    </div><!-- /mgrSection -->
  </div>

  <!-- ══ Action Buttons ════════════════════════════════════════════════════ -->
  <div class="d-flex gap-3 flex-wrap">
    <button type="submit" class="btn btn-primary rounded-3 fw-800 px-5 py-2">
      <i class="bi bi-check-circle me-2"></i>
      <?= $isEdit ? 'Save Changes' : 'Add Hotel' ?>
    </button>
    <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary rounded-3 fw-700 px-4 py-2">Cancel</a>
    <?php if($isEdit): ?>
    <a href="/admin/subadmin/hotels/<?= $hotel['id'] ?>/rooms" class="btn btn-outline-primary rounded-3 fw-700 px-4 py-2">
      <i class="bi bi-door-open me-1"></i>Manage Rooms
    </a>
    <a href="/admin/subadmin/hotels/<?= $hotel['id'] ?>/assign-manager" class="btn btn-outline-success rounded-3 fw-700 px-4 py-2">
      <i class="bi bi-person-check me-1"></i>Replace Manager
    </a>
    <?php endif; ?>
  </div>

</form>

<script>
function toggleMgrSection(el) {
    const sec = document.getElementById('mgrSection');
    const chevron = el.querySelector('.bi-chevron-down');
    const hidden = sec.style.display === 'none';
    sec.style.display = hidden ? 'block' : 'none';
    chevron.style.transform = hidden ? '' : 'rotate(-90deg)';
}

function previewImg(url) {
    const img = document.getElementById('imgPreview');
    if (url && url.startsWith('http')) {
        img.src = url;
        img.style.display = 'block';
        img.onerror = () => img.style.display = 'none';
    } else {
        img.style.display = 'none';
    }
}

function togglePass(inputId, btn) {
    const inp = document.getElementById(inputId);
    const icon = btn.querySelector('i');
    if (inp.type === 'password') {
        inp.type = 'text';
        icon.className = 'bi bi-eye-slash';
    } else {
        inp.type = 'password';
        icon.className = 'bi bi-eye';
    }
}

function updateMgrRequired() {
    const name  = document.querySelector('[name="mgr_name"]').value.trim();
    const email = document.getElementById('mgrEmail');
    const pass  = document.getElementById('mgrPass');
    const hasAny = name.length > 0;
    if (email) email.required = hasAny;
    if (pass)  pass.required  = hasAny;
}

// Auto-open manager section if there were validation errors and mgr fields were filled
document.addEventListener('DOMContentLoaded', () => {
    const mgrName = document.querySelector('[name="mgr_name"]');
    if (mgrName && mgrName.value.trim()) {
        const sec = document.getElementById('mgrSection');
        if (sec) sec.style.display = 'block';
    }
    // Init image preview
    const imgUrl = document.getElementById('imgUrlInput');
    if (imgUrl && imgUrl.value) previewImg(imgUrl.value);
});
</script>

<?= $this->endSection() ?>
