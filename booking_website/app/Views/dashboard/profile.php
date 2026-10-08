<?= $this->extend('layouts/dashboard') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4"><i class="bi bi-person-circle me-2 text-primary"></i>My Profile</h4>

<div class="row g-4">
  <div class="col-lg-4">
    <div class="card border-0 rounded-4 shadow text-center p-4 mb-4 reveal">
      <div class="mx-auto mb-3 d-flex align-items-center justify-content-center rounded-circle fw-900 text-white"
           style="width:80px;height:80px;background:linear-gradient(135deg,#1a56db,#7c3aed);font-size:2rem">
        <?= strtoupper(substr($user['first_name'],0,1)) ?>
      </div>
      <h5 class="fw-800 mb-1"><?= esc($user['first_name'].' '.$user['last_name']) ?></h5>
      <p class="text-muted small mb-2"><?= esc($user['email']??'') ?></p>
      <?php if($user['phone']??''): ?>
      <p class="text-muted small mb-2"><i class="bi bi-telephone me-1"></i><?= esc($user['phone']) ?></p>
      <?php endif; ?>
      <?php if($user['is_verified']==='t'||$user['is_verified']===true||$user['is_verified']==='1'): ?>
      <span class="badge rounded-pill" style="background:#dcfce7;color:#15803d"><i class="bi bi-patch-check-fill me-1"></i>Verified Account</span>
      <?php else: ?>
      <span class="badge rounded-pill bg-warning text-dark"><i class="bi bi-clock me-1"></i>Unverified</span>
      <?php endif; ?>
      <hr class="my-3">
      <div class="small text-muted">
        Member since <?= date('M Y',strtotime($user['registered_date']??'now')) ?>
      </div>
    </div>
    <div class="card border-0 rounded-4 shadow p-3 text-center reveal" style="background:linear-gradient(135deg,#eff6ff,#dbeafe)">
      <div class="small text-muted mb-1 fw-600">Total Bookings</div>
      <div class="fw-900 text-primary" style="font-size:1.8rem"><?= array_sum($bookingCounts??[]) ?></div>
      <a href="/dashboard/bookings" class="btn btn-outline-primary btn-sm rounded-pill mt-2 fw-700 px-3">View All</a>
    </div>
  </div>

  <div class="col-lg-8">
    <div class="card border-0 rounded-4 shadow reveal">
      <div class="card-header bg-white border-0 pt-4 px-4"><h6 class="fw-800 mb-0"><i class="bi bi-pencil-square me-2 text-primary"></i>Edit Profile</h6></div>
      <div class="card-body px-4 pb-4">
        <form action="/dashboard/profile" method="POST">
          <?= csrf_field() ?>
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label small fw-700">First Name *</label>
              <input type="text" name="first_name" class="form-control"
                     value="<?= esc($user['first_name']) ?>" required
                     data-rule="name" data-label="First name">
            </div>
            <div class="col-md-6">
              <label class="form-label small fw-700">Last Name *</label>
              <input type="text" name="last_name" class="form-control"
                     value="<?= esc($user['last_name']) ?>" required
                     data-rule="name" data-label="Last name">
            </div>
            <div class="col-md-6">
              <label class="form-label small fw-700">Email <span class="text-muted fw-400">(read-only)</span></label>
              <input type="email" class="form-control" style="background:#f8fafc"
                     value="<?= esc($user['email']??'') ?>" disabled>
            </div>
            <div class="col-md-6">
              <label class="form-label small fw-700">Phone Number</label>
              <div class="input-group">
                <span class="input-group-text bg-white fw-700">+251</span>
                <input type="tel" name="phone" class="form-control"
                       value="<?= esc(ltrim($user['phone']??'','+251')) ?>"
                       data-label="Phone" maxlength="10"
                       oninput="this.value=this.value.replace(/\D/g,'').substring(0,10)">
              </div>
            </div>
            <div class="col-md-6">
              <label class="form-label small fw-700">Nationality</label>
              <input type="text" name="nationality" class="form-control"
                     placeholder="e.g. Ethiopian"
                     value="<?= esc($user['nationality']??'') ?>"
                     data-rule="name" data-label="Nationality">
            </div>
            <div class="col-12 mt-2">
              <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4 py-2">
                <i class="bi bi-check-circle me-2"></i>Save Changes
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
