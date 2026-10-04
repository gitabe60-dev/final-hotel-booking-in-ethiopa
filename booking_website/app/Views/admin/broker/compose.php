<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/broker/inbox" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Inbox</a>
  <h4 class="fw-900 mb-0">Compose Message</h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="admin-form-card">
      <form action="/admin/broker/compose" method="POST">
        <?= csrf_field() ?>
        <div class="row g-3">
          <div class="col-12">
            <label class="form-label fw-700">Send To *</label>
            <select name="to_admin" class="form-select" required>
              <option value="">Select recipient...</option>
              <?php foreach($managers as $m): ?>
              <option value="<?= $m['admin_id'] ?>">🏨 <?= esc($m['manager_name']) ?> — <?= esc($m['hotel_name']) ?></option>
              <?php endforeach; ?>
            </select>
          </div>
          <div class="col-md-8">
            <label class="form-label fw-700">Subject *</label>
            <input type="text" name="subject" class="form-control" placeholder="Message subject..." required>
          </div>
          <div class="col-md-4">
            <label class="form-label fw-700">Related Hotel</label>
            <select name="hotel_id" class="form-select">
              <option value="">None</option>
              <?php foreach($hotels as $h): ?>
              <option value="<?= $h['id'] ?>"><?= esc($h['name']) ?></option>
              <?php endforeach; ?>
            </select>
          </div>
          <div class="col-12">
            <label class="form-label fw-700">Message *</label>
            <textarea name="body" class="form-control" rows="8" placeholder="Write your message here..." required></textarea>
          </div>
          <div class="col-12 d-flex gap-3">
            <button type="submit" class="btn btn-primary rounded-3 fw-700 px-5">
              <i class="bi bi-send me-2"></i>Send Message
            </button>
            <a href="/admin/broker/inbox" class="btn btn-outline-secondary rounded-3 fw-700">Cancel</a>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
