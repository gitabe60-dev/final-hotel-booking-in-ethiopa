<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4">My Hotels</h4>

<div class="admin-card p-0">
  <?php if(empty($hotels)): ?>
  <div class="text-center py-5"><i class="bi bi-building fs-1 text-muted d-block mb-2"></i><p class="text-muted">No hotels assigned to you yet.</p></div>
  <?php else: ?>
  <div class="row g-3 p-3">
    <?php foreach($hotels as $h): ?>
    <div class="col-md-6 col-lg-4">
      <div class="admin-card h-100 p-0 overflow-hidden">
        <?php if($h['primary_image']??''): ?>
        <img src="<?= esc($h['primary_image']) ?>" style="width:100%;height:160px;object-fit:cover" alt="">
        <?php endif; ?>
        <div class="p-3">
          <h6 class="fw-800 mb-1"><?= esc($h['name']) ?></h6>
          <p class="text-muted small mb-2"><i class="bi bi-geo-alt me-1 text-primary"></i><?= esc($h['city']) ?></p>
          <div class="d-flex align-items-center justify-content-between">
            <span class="fw-700 text-primary small">ETB <?= number_format($h['price_per_night'],0) ?>/night</span>
            <a href="/admin/broker/hotels/<?= $h['id'] ?>/rooms" class="btn btn-sm btn-primary rounded-pill fw-700">View Rooms</a>
          </div>
        </div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
