<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/manager/inbox" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Inbox</a>
  <h4 class="fw-900 mb-0">Message</h4>
</div>

<div class="row justify-content-center">
  <div class="col-lg-8">
    <div class="admin-form-card mb-4">
      <div class="d-flex align-items-center gap-3 mb-3 pb-3 border-bottom">
        <div style="width:46px;height:46px;border-radius:50%;background:linear-gradient(135deg,#10b981,#059669);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:1rem;color:#fff">
          <?= strtoupper(substr($msg['from_name']??'?',0,1)) ?>
        </div>
        <div>
          <div class="fw-800"><?= esc($msg['from_name']) ?> <span class="text-muted fw-400 small">(<?= ucfirst(str_replace('_',' ',$msg['from_role'])) ?>)</span></div>
          <div class="text-muted small"><?= esc($msg['from_email']) ?> · <?= date('d M Y H:i',strtotime($msg['created_at'])) ?></div>
        </div>
      </div>
      <h5 class="fw-800 mb-3"><?= esc($msg['subject']) ?></h5>
      <?php if($msg['hotel_name']??''): ?>
      <span class="badge rounded-pill mb-3" style="background:#eff6ff;color:#1a56db"><i class="bi bi-building me-1"></i><?= esc($msg['hotel_name']) ?></span>
      <?php endif; ?>
      <div class="p-3 rounded-3" style="background:#f8fafc;line-height:1.8;font-size:.92rem">
        <?= nl2br(esc($msg['body'])) ?>
      </div>
    </div>

    <!-- Reply -->
    <div class="admin-form-card">
      <h6 class="fw-800 mb-3"><i class="bi bi-reply me-2 text-primary"></i>Reply to <?= esc($msg['from_name']) ?></h6>
      <form action="/admin/manager/reply" method="POST">
        <?= csrf_field() ?>
        <input type="hidden" name="to_admin"  value="<?= $msg['from_admin'] ?>">
        <input type="hidden" name="parent_id" value="<?= $msg['id'] ?>">
        <input type="hidden" name="hotel_id"  value="<?= $msg['hotel_id'] ?? '' ?>">
        <div class="mb-3">
          <input type="text" name="subject" class="form-control" value="Re: <?= esc($msg['subject']) ?>">
        </div>
        <div class="mb-3">
          <textarea name="body" class="form-control" rows="5" placeholder="Write your reply..." required></textarea>
        </div>
        <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">
          <i class="bi bi-send me-2"></i>Send Reply
        </button>
      </form>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
