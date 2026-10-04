<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex align-items-center gap-3 mb-4">
  <a href="/admin/broker/hotels" class="btn btn-outline-secondary btn-sm rounded-pill fw-700"><i class="bi bi-arrow-left me-1"></i>Hotels</a>
  <h4 class="fw-900 mb-0">Rooms — <?= esc($hotel['name']) ?></h4>
</div>

<div class="admin-card p-0">
  <div class="p-3 border-bottom fw-700"><?= count($rooms) ?> room type<?= count($rooms)!==1?'s':'' ?></div>
  <?php if(empty($rooms)): ?>
  <div class="text-center py-5 text-muted"><i class="bi bi-door-open fs-1 d-block mb-2"></i><p>No rooms configured yet.</p></div>
  <?php else: ?>
  <div style="overflow-x:auto">
    <table class="admin-table">
      <thead><tr><th>Room</th><th>Bed Type</th><th>Size</th><th>Max Guests</th><th>Price/Night</th><th>Availability</th></tr></thead>
      <tbody>
      <?php foreach($rooms as $r): ?>
      <tr>
        <td>
          <div class="d-flex align-items-center gap-2">
            <?php if($r['image_url']??''): ?>
            <img src="<?= esc($r['image_url']) ?>" style="width:42px;height:36px;object-fit:cover;border-radius:8px" alt="">
            <?php endif; ?>
            <span class="fw-700 small"><?= esc($r['name']) ?></span>
          </div>
        </td>
        <td class="small"><?= esc($r['bed_type']) ?></td>
        <td class="small"><?= $r['size_sqm'] ?>m²</td>
        <td class="small"><?= $r['max_guests'] ?> guests</td>
        <td class="fw-700 text-primary small">ETB <?= number_format($r['price_per_night'],0) ?></td>
        <td>
          <?php if($r['is_available']): ?>
          <span class="status-active">Available</span>
          <?php else: ?>
          <span class="status-inactive">Unavailable</span>
          <?php endif; ?>
        </td>
      </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>

<?= $this->endSection() ?>
