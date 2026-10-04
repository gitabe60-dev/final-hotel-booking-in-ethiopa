<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-900 mb-0">Sent Messages</h4>
  <a href="/admin/broker/compose" class="btn btn-primary rounded-pill fw-700 btn-sm"><i class="bi bi-pencil-square me-1"></i>Compose</a>
</div>

<div class="admin-card p-0">
  <?php if(empty($messages)): ?>
  <div class="text-center py-5"><i class="bi bi-send fs-1 text-muted d-block mb-2"></i><p class="text-muted">No sent messages.</p></div>
  <?php else: ?>
  <?php foreach($messages as $msg): ?>
  <div class="d-flex align-items-start gap-3 p-3 border-bottom">
    <div style="width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,#10b981,#059669);flex-shrink:0;display:flex;align-items:center;justify-content:center;font-weight:800;color:#fff;font-size:.9rem">
      <?= strtoupper(substr($msg['to_name']??'?',0,1)) ?>
    </div>
    <div class="flex-grow-1">
      <div class="d-flex justify-content-between">
        <span class="fw-700 small"><?= esc($msg['subject']) ?></span>
        <span class="text-muted" style="font-size:.73rem"><?= date('d M Y H:i',strtotime($msg['created_at'])) ?></span>
      </div>
      <div class="text-muted small">To: <?= esc($msg['to_name']) ?> (<?= esc($msg['to_role']) ?>)<?= ($msg['hotel_name']??'')?(' · '.esc($msg['hotel_name'])):'' ?></div>
    </div>
  </div>
  <?php endforeach; ?>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
