<?php
$steps = [
    1 => ['label'=>'Choose Method',  'icon'=>'bi-credit-card'],
    2 => ['label'=>'Review & Pay',   'icon'=>'bi-receipt'],
    3 => ['label'=>'Payment Details','icon'=>'bi-shield-lock'],
    4 => ['label'=>'Confirmed',      'icon'=>'bi-check-circle'],
];
?>
<div class="d-flex align-items-center justify-content-center mb-5">
  <?php foreach($steps as $num => $s): ?>
  <div class="d-flex align-items-center">
    <div class="d-flex flex-column align-items-center">
      <div class="rounded-circle d-flex align-items-center justify-content-center fw-800 mb-1"
           style="width:42px;height:42px;font-size:.9rem;
                  background:<?= $step>=$num?'linear-gradient(135deg,#1a56db,#7c3aed)':'#e2e8f0' ?>;
                  color:<?= $step>=$num?'#fff':'#94a3b8' ?>;
                  box-shadow:<?= $step===$num?'0 0 0 6px rgba(26,86,219,.2)':'none' ?>">
        <?php if($step > $num): ?>
          <i class="bi bi-check-lg"></i>
        <?php else: ?>
          <i class="bi <?= $s['icon'] ?>"></i>
        <?php endif; ?>
      </div>
      <div class="small fw-<?= $step===$num?'700':'500' ?> text-<?= $step>=$num?'primary':'muted' ?>"
           style="font-size:.72rem;white-space:nowrap">
        <?= $s['label'] ?>
      </div>
    </div>
    <?php if($num < count($steps)): ?>
    <div class="mx-2" style="width:50px;height:2px;background:<?= $step>$num?'#1a56db':'#e2e8f0' ?>;margin-bottom:18px"></div>
    <?php endif; ?>
  </div>
  <?php endforeach; ?>
</div>
