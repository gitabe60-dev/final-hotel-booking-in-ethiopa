<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<?php
$existing    = $existing    ?? null;
$allManagers = $allManagers ?? [];
$brokers     = $brokers     ?? [];
?>

<style>
.section-card{background:#fff;border-radius:16px;box-shadow:0 2px 16px rgba(0,0,0,.06);padding:28px 32px;margin-bottom:22px}
.section-title{font-size:.95rem;font-weight:800;color:#1a1a2e;display:flex;align-items:center;gap:8px;margin-bottom:18px;padding-bottom:10px;border-bottom:2px solid #f0f4ff}
.badge-icon{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.9rem}
.existing-card{background:linear-gradient(135deg,#f0fff4,#e6fdf2);border:2px solid #b7efc5;border-radius:12px;padding:18px 22px}
.mode-tab{cursor:pointer;padding:10px 20px;border-radius:10px;font-weight:700;font-size:.85rem;transition:.2s}
.mode-tab.active{background:#0d6efd;color:#fff}
.mode-tab:not(.active){background:#f0f4ff;color:#555}
.form-label{font-weight:700;font-size:.85rem;color:#333;margin-bottom:5px}
</style>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary btn-sm rounded-pill fw-700">
    <i class="bi bi-arrow-left me-1"></i>Back to Hotels
  </a>
  <div>
    <h4 class="fw-900 mb-0">Assign Hotel Manager</h4>
    <small class="text-muted">Hotel: <strong><?= esc($hotel['name']) ?></strong></small>
  </div>
</div>

<?php if(session()->getFlashdata('error')): ?>
<div class="alert alert-danger rounded-3 border-0 mb-3">
  <i class="bi bi-exclamation-triangle me-2"></i><?= session()->getFlashdata('error') ?>
</div>
<?php endif; ?>

<!-- Current manager banner -->
<?php if($existing): ?>
<div class="section-card mb-3">
  <div class="section-title">
    <span class="badge-icon bg-success text-white"><i class="bi bi-person-check-fill"></i></span>
    Current Manager
  </div>
  <div class="existing-card d-flex align-items-center gap-3">
    <div style="width:50px;height:50px;background:linear-gradient(135deg,#28a745,#20c997);border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0">
      <i class="bi bi-person-fill text-white fs-4"></i>
    </div>
    <div class="flex-grow-1">
      <div class="fw-800"><?= esc($existing['full_name']) ?></div>
      <div class="text-muted small"><?= esc($existing['email']) ?></div>
      <?php if(!empty($existing['phone'])): ?>
      <div class="text-muted small"><?= esc($existing['phone']) ?></div>
      <?php endif; ?>
    </div>
    <div class="text-end">
      <span class="badge bg-success rounded-pill px-3">Active Manager</span>
      <div class="text-muted small mt-1">Login: <?= esc($existing['email']) ?></div>
    </div>
  </div>
  <p class="text-muted small mt-3 mb-0">
    <i class="bi bi-exclamation-circle me-1"></i>
    Assigning a new manager will <strong>replace</strong> the current one. The old manager account remains active but loses hotel access.
  </p>
</div>
<?php endif; ?>

<div class="section-card">
  <div class="section-title">
    <span class="badge-icon bg-primary text-white"><i class="bi bi-person-plus-fill"></i></span>
    <?= $existing ? 'Replace with New Manager' : 'Register Hotel Manager' ?>
  </div>

  <!-- Mode tabs (only show if there are existing managers to reassign) -->
  <?php if(!empty($allManagers)): ?>
  <div class="d-flex gap-2 mb-4">
    <div class="mode-tab active" id="tabNew" onclick="switchMode('new')">
      <i class="bi bi-person-plus me-1"></i>Create New Account
    </div>
    <div class="mode-tab" id="tabExisting" onclick="switchMode('existing')">
      <i class="bi bi-person-check me-1"></i>Reassign Existing (<?= count($allManagers) ?>)
    </div>
  </div>
  <?php endif; ?>

  <form action="/admin/subadmin/hotels/<?= $hotel['id'] ?>/assign-manager" method="POST" id="assignForm">
    <?= csrf_field() ?>
    <input type="hidden" name="existing_manager_id" id="existingMgrId" value="">

    <!-- Mode A: Create new -->
    <div id="modeNew">
      <div class="row g-3">
        <div class="col-md-6">
          <label class="form-label">Full Name <span class="text-danger">*</span></label>
          <input type="text" name="full_name" id="newFullName" class="form-control"
                 placeholder="Manager's full name" value="<?= esc(old('full_name')) ?>" required>
        </div>
        <div class="col-md-6">
          <label class="form-label">Phone Number</label>
          <input type="tel" name="phone" class="form-control"
                 placeholder="+251911..." value="<?= esc(old('phone')) ?>">
        </div>
        <div class="col-md-6">
          <label class="form-label">Email Address <span class="text-danger">*</span></label>
          <input type="email" name="email" class="form-control"
                 placeholder="manager@hotel.com" value="<?= esc(old('email')) ?>" required>
          <div class="form-text">This will be the manager's login email.</div>
        </div>
        <div class="col-md-6">
          <label class="form-label">Password <span class="text-danger">*</span></label>
          <div class="input-group">
            <input type="password" name="password" id="mgrPass" class="form-control"
                   placeholder="Min 6 characters" minlength="6" required>
            <button type="button" class="btn btn-outline-secondary" onclick="togglePass()">
              <i class="bi bi-eye" id="passIcon"></i>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Mode B: Reassign existing (hidden by default) -->
    <div id="modeExisting" style="display:none">
      <label class="form-label mb-2">Select Existing Manager</label>
      <div class="row g-2">
        <?php foreach($allManagers as $m): ?>
        <div class="col-md-6">
          <div class="border rounded-3 p-3 d-flex align-items-center gap-2 existing-mgr-option"
               style="cursor:pointer" onclick="selectExistingMgr(<?= $m['id'] ?>, this)">
            <div style="width:38px;height:38px;background:#e9ecef;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0">
              <i class="bi bi-person text-muted"></i>
            </div>
            <div>
              <div class="fw-700 small"><?= esc($m['full_name']) ?></div>
              <div class="text-muted" style="font-size:.75rem"><?= esc($m['email']) ?></div>
            </div>
          </div>
        </div>
        <?php endforeach; ?>
      </div>
    </div>

    <!-- Broker assignment -->
    <div class="mt-4 pt-3 border-top">
      <label class="form-label">Assign to Broker <span class="text-muted fw-400">(optional)</span></label>
      <?php if(empty($brokers)): ?>
        <div class="alert alert-light border rounded-3 py-2 small mb-0">
          <i class="bi bi-info-circle me-1"></i>
          No brokers yet. <a href="/admin/subadmin/brokers/create" class="text-primary fw-700">Create a broker</a> first.
        </div>
      <?php else: ?>
        <select name="broker_id" class="form-select" style="max-width:360px">
          <option value="">— No broker —</option>
          <?php foreach($brokers as $b): ?>
          <option value="<?= $b['admin_id'] ?>">
            <?= esc($b['broker_name']) ?>
            <?php if(!empty($b['commission_pct'])): ?>(<?= $b['commission_pct'] ?>% commission)<?php endif; ?>
          </option>
          <?php endforeach; ?>
        </select>
        <div class="form-text">The broker will be notified of all bookings for this hotel.</div>
      <?php endif; ?>
    </div>

    <div class="d-flex gap-3 mt-4">
      <button type="submit" class="btn btn-success rounded-3 fw-800 px-5 py-2">
        <i class="bi bi-person-check-fill me-2"></i>
        <?= $existing ? 'Replace Manager' : 'Assign Manager' ?>
      </button>
      <a href="/admin/subadmin/hotels" class="btn btn-outline-secondary rounded-3 fw-700 px-4">Cancel</a>
    </div>
  </form>
</div>

<!-- Info box -->
<div class="section-card" style="background:linear-gradient(135deg,#f8f9ff,#f0f4ff);border:1px solid #d0dcff">
  <div class="section-title">
    <span class="badge-icon bg-info text-white"><i class="bi bi-lightbulb"></i></span>
    What the Hotel Manager Can Do
  </div>
  <div class="row g-3">
    <div class="col-md-4">
      <div class="d-flex gap-2 align-items-start">
        <i class="bi bi-door-open text-primary fs-5 mt-1"></i>
        <div>
          <div class="fw-700 small">Manage Rooms</div>
          <div class="text-muted" style="font-size:.8rem">Add, edit, delete and toggle room availability.</div>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="d-flex gap-2 align-items-start">
        <i class="bi bi-calendar-check text-success fs-5 mt-1"></i>
        <div>
          <div class="fw-700 small">View Bookings</div>
          <div class="text-muted" style="font-size:.8rem">See all guest bookings and update booking status.</div>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="d-flex gap-2 align-items-start">
        <i class="bi bi-chat-dots text-warning fs-5 mt-1"></i>
        <div>
          <div class="fw-700 small">Message Broker</div>
          <div class="text-muted" style="font-size:.8rem">Communicate with the assigned broker via inbox.</div>
        </div>
      </div>
    </div>
  </div>
  <div class="mt-3 pt-2 border-top">
    <small class="text-muted"><strong>Login URL:</strong>
      <code>http://localhost:8080/admin/login</code> → use the manager's email &amp; password.
    </small>
  </div>
</div>

<script>
function switchMode(mode) {
    const modeNew  = document.getElementById('modeNew');
    const modeExst = document.getElementById('modeExisting');
    const tabNew   = document.getElementById('tabNew');
    const tabExst  = document.getElementById('tabExisting');
    const exstId   = document.getElementById('existingMgrId');
    const newName  = document.getElementById('newFullName');

    if (mode === 'new') {
        modeNew.style.display  = 'block';
        modeExst.style.display = 'none';
        tabNew.classList.add('active');   tabExst.classList.remove('active');
        exstId.value = '';
        // Re-enable required on new fields
        modeNew.querySelectorAll('[required]').forEach(el => el.removeAttribute('data-disabled'));
        document.querySelector('[name="full_name"]').required = true;
        document.querySelector('[name="email"]').required = true;
        document.querySelector('[name="password"]').required = true;
    } else {
        modeNew.style.display  = 'none';
        modeExst.style.display = 'block';
        tabNew.classList.remove('active'); tabExst.classList.add('active');
        // Remove required from new-account fields
        document.querySelector('[name="full_name"]').required = false;
        document.querySelector('[name="email"]').required = false;
        document.querySelector('[name="password"]').required = false;
    }
}

function selectExistingMgr(id, el) {
    document.getElementById('existingMgrId').value = id;
    document.querySelectorAll('.existing-mgr-option').forEach(e => {
        e.style.background = '';
        e.style.borderColor = '';
    });
    el.style.background = '#e8f4fd';
    el.style.borderColor = '#0d6efd';
}

function togglePass() {
    const inp  = document.getElementById('mgrPass');
    const icon = document.getElementById('passIcon');
    if (inp.type === 'password') {
        inp.type = 'text';
        icon.className = 'bi bi-eye-slash';
    } else {
        inp.type = 'password';
        icon.className = 'bi bi-eye';
    }
}
</script>

<?= $this->endSection() ?>
