<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-900 mb-0">Inbox <?php if($unread>0): ?><span class="badge bg-danger ms-2" style="font-size:.75rem"><?= $unread ?> New</span><?php endif; ?></h4>
  <div class="d-flex gap-2">
    <a href="/admin/broker/sent"    class="btn btn-outline-secondary rounded-pill fw-700 btn-sm"><i class="bi bi-send me-1"></i>Sent</a>
    <a href="/admin/broker/compose" class="btn btn-primary rounded-pill fw-700 btn-sm"><i class="bi bi-pencil-square me-1"></i>Compose</a>
  </div>
</div>

<div class="admin-card p-0">
  <?php if(empty($messages)): ?>
  <div class="text-center py-5"><i class="bi bi-inbox fs-1 text-muted d-block mb-2"></i><p class="text-muted">Inbox is empty.</p></div>
  <?php else: ?>
  <?php foreach($messages as $msg): ?>
  <?php $isUnread = !($msg['is_read']==='t'||$msg['is_read']===true); ?>
  <a href="/admin/broker/messages/<?= $msg['id'] ?>" class="d-flex align-items-start gap-3 p-3 border-bottom text-decoration-none" style="<?= $isUnread?'background:#f0f9ff':'' ?>">
    <div style="width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,#1a56db,#7c3aed);flex-shrink:0;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.9rem;color:#fff">
      <?= strtoupper(substr($msg['from_name']??'?',0,1)) ?>
    </div>
    <div class="flex-grow-1">
      <div class="d-flex justify-content-between align-items-center">
        <span class="fw-<?= $isUnread?'800':'600' ?> small <?= $isUnread?'text-primary':'' ?>"><?= esc($msg['subject']) ?></span>
        <span class="text-muted" style="font-size:.73rem"><?= date('d M Y H:i',strtotime($msg['created_at'])) ?></span>
      </div>
      <div class="text-muted small">From: <?= esc($msg['from_name']) ?> (<?= esc($msg['from_role']) ?>)
        <?php if($msg['hotel_name']??''): ?> · Hotel: <?= esc($msg['hotel_name']) ?><?php endif; ?>
      </div>
    </div>
    <?php if($isUnread): ?><span class="badge bg-primary rounded-pill align-self-center" style="font-size:.65rem">New</span><?php endif; ?>
  </a>
  <?php endforeach; ?>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
