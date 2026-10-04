<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-900 mb-0">Inbox <?php if($unread>0): ?><span class="badge bg-danger ms-2" style="font-size:.75rem"><?= $unread ?> New</span><?php endif; ?></h4>
  <a href="/admin/manager/reply" class="btn btn-primary rounded-pill fw-700 btn-sm px-4"><i class="bi bi-reply me-1"></i>Reply to Broker</a>
</div>

<div class="admin-card p-0">
  <?php if(empty($messages)): ?>
  <div class="text-center py-5"><i class="bi bi-inbox fs-1 text-muted d-block mb-2"></i><p class="text-muted">No messages yet.</p></div>
  <?php else: ?>
  <?php foreach($messages as $msg): ?>
  <?php $isUnread = !($msg['is_read']==='t'||$msg['is_read']===true); ?>
  <a href="/admin/manager/messages/<?= $msg['id'] ?>" class="d-flex align-items-start gap-3 p-3 border-bottom text-decoration-none" style="<?= $isUnread?'background:#f0f9ff':'' ?>">
    <div style="width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,#10b981,#059669);flex-shrink:0;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.9rem;color:#fff">
      <?= strtoupper(substr($msg['from_name']??'?',0,1)) ?>
    </div>
    <div class="flex-grow-1">
      <div class="d-flex justify-content-between">
        <span class="fw-<?= $isUnread?'800':'600' ?> small <?= $isUnread?'text-primary':'' ?>"><?= esc($msg['subject']) ?></span>
        <span class="text-muted" style="font-size:.73rem"><?= date('d M Y H:i',strtotime($msg['created_at'])) ?></span>
      </div>
      <div class="text-muted small">From: <?= esc($msg['from_name']) ?> (<?= ucfirst(str_replace('_',' ',$msg['from_role'])) ?>)</div>
    </div>
    <?php if($isUnread): ?><span class="badge bg-primary rounded-pill align-self-center" style="font-size:.65rem">New</span><?php endif; ?>
  </a>
  <?php endforeach; ?>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
