<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">Broker Dashboard 🤝</h4>
    <p class="text-muted small mb-0">City: <strong><?= esc($broker['city'] ?? '-') ?></strong> &nbsp;·&nbsp; Commission: <strong><?= $broker['commission_pct'] ?? 0 ?>%</strong></p>
  </div>
  <a href="/admin/broker/compose" class="btn btn-primary rounded-pill fw-700 px-4">
    <i class="bi bi-pencil-square me-1"></i>Send Message
  </a>
</div>

<!-- Stats -->
<div class="row g-3 mb-4">
  <?php
  $stats = [
    ['My Hotels',    count($hotels),                           'bi-building-fill', '#3b82f6','#1d4ed8'],
    ['Managers',     count($managers),                         'bi-building-gear', '#8b5cf6','#6d28d9'],
    ['Unread Msgs',  $unread,                                  'bi-envelope-fill', '#ef4444','#dc2626'],
    ['Revenue (ETB)',number_format($revenue,0),                'bi-cash-coin',     '#10b981','#059669'],
  ];
  foreach($stats as [$label,$val,$icon,$bg,$dark]):
  ?>
  <div class="col-6 col-md-3">
    <div class="stat-box" style="background:linear-gradient(135deg,<?= $bg ?>,<?= $dark ?>)">
      <i class="bi <?= $icon ?> fs-3 mb-2 d-block opacity-75"></i>
      <div class="fw-900 fs-4"><?= $val ?></div>
      <div class="small opacity-75 fw-500"><?= $label ?></div>
    </div>
  </div>
  <?php endforeach; ?>
</div>

<div class="row g-4">
  <!-- My Hotels -->
  <div class="col-lg-6">
    <div class="admin-card p-0">
      <div class="d-flex justify-content-between align-items-center p-3 border-bottom">
        <h6 class="fw-800 mb-0"><i class="bi bi-building-fill me-2 text-primary"></i>My Hotels</h6>
        <a href="/admin/broker/hotels" class="btn btn-sm btn-outline-primary rounded-pill fw-700">View All</a>
      </div>
      <?php if(empty($hotels)): ?>
      <div class="text-center py-4 text-muted small">No hotels assigned yet.</div>
      <?php else: ?>
      <?php foreach(array_slice($hotels,0,5) as $h): ?>
      <div class="d-flex align-items-center gap-3 p-3 border-bottom">
        <?php if($h['primary_image']??''): ?>
        <img src="<?= esc($h['primary_image']) ?>" style="width:44px;height:40px;object-fit:cover;border-radius:8px" alt="">
        <?php endif; ?>
        <div class="flex-grow-1">
          <div class="fw-700 small"><?= esc($h['name']) ?></div>
          <div class="text-muted" style="font-size:.73rem"><?= esc($h['city']) ?></div>
        </div>
        <a href="/admin/broker/hotels/<?= $h['id'] ?>/rooms" class="btn btn-sm btn-outline-secondary rounded-pill fw-700" style="font-size:.75rem">Rooms</a>
      </div>
      <?php endforeach; ?>
      <?php endif; ?>
    </div>
  </div>

  <!-- Recent Inbox -->
  <div class="col-lg-6">
    <div class="admin-card p-0">
      <div class="d-flex justify-content-between align-items-center p-3 border-bottom">
        <h6 class="fw-800 mb-0">
          <i class="bi bi-inbox-fill me-2 text-warning"></i>Recent Inbox
          <?php if($unread>0): ?><span class="badge bg-danger rounded-pill ms-1"><?= $unread ?></span><?php endif; ?>
        </h6>
        <a href="/admin/broker/inbox" class="btn btn-sm btn-outline-warning rounded-pill fw-700">View All</a>
      </div>
      <?php if(empty($inbox)): ?>
      <div class="text-center py-4 text-muted small">No messages yet.</div>
      <?php else: ?>
      <?php foreach($inbox as $msg): ?>
      <a href="/admin/broker/messages/<?= $msg['id'] ?>" class="d-flex align-items-start gap-3 p-3 border-bottom text-decoration-none <?= !($msg['is_read']==='t'||$msg['is_read']===true)?'bg-blue-50':''; ?>" style="<?= !($msg['is_read']==='t'||$msg['is_read']===true)?'background:#f0f9ff':'' ?>">
        <div style="width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#ef4444);flex-shrink:0;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.82rem;color:#fff">
          <?= strtoupper(substr($msg['from_name']??'?',0,1)) ?>
        </div>
        <div class="flex-grow-1">
          <div class="fw-700 small <?= !($msg['is_read']==='t'||$msg['is_read']===true)?'text-primary':'' ?>"><?= esc($msg['subject']) ?></div>
          <div class="text-muted" style="font-size:.73rem"><?= esc($msg['from_name']) ?> · <?= date('d M',strtotime($msg['created_at'])) ?></div>
        </div>
        <?php if(!($msg['is_read']==='t'||$msg['is_read']===true)): ?>
        <span class="badge bg-primary rounded-pill" style="font-size:.65rem">New</span>
        <?php endif; ?>
      </a>
      <?php endforeach; ?>
      <?php endif; ?>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
