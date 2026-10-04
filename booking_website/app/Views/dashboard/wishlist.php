<?= $this->extend('layouts/dashboard') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0"><i class="bi bi-heart-fill me-2 text-danger"></i>My Wishlist</h4>
    <p class="text-muted small mb-0"><?= count($hotels) ?> saved propert<?= count($hotels)===1?'y':'ies' ?></p>
  </div>
  <a href="/hotels" class="btn btn-outline-primary rounded-pill px-4 fw-700"><i class="bi bi-search me-2"></i>Find More Hotels</a>
</div>

<?php if(empty($hotels)): ?>
<div class="card border-0 rounded-4 shadow text-center py-5">
  <div class="anim-float d-inline-block mb-3"><i class="bi bi-heart" style="font-size:4rem;color:#f87171"></i></div>
  <h5 class="fw-800 mb-2">Your Wishlist is Empty</h5>
  <p class="text-muted small mb-4">Save hotels you love by clicking the heart icon while browsing.</p>
  <div><a href="/hotels" class="btn btn-primary rounded-pill px-5 fw-700"><i class="bi bi-search me-2"></i>Browse Hotels</a></div>
</div>
<?php else: ?>
<div class="row g-4">
  <?php foreach($hotels as $idx=>$hotel): ?>
  <div class="col-sm-6 col-xl-4 reveal" style="animation-delay:<?= $idx*.06 ?>s">
    <div class="hotel-card h-100">
      <div class="card-img-slider">
        <div class="slide active" style="background-image:url('<?= esc($hotel['primary_image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600') ?>')"></div>
        <span class="hotel-type-badge"><?= esc($hotel['type']) ?></span>
        <form class="wishlist-form" action="/dashboard/wishlist/toggle" method="POST">
          <?= csrf_field() ?>
          <input type="hidden" name="hotel_id" value="<?= $hotel['id'] ?>">
          <button type="submit" class="btn-wishlist wishlisted" title="Remove from wishlist"><i class="bi bi-heart-fill"></i></button>
        </form>
      </div>
      <div class="card-body">
        <h6 class="hotel-name"><?= esc($hotel['name']) ?></h6>
        <div class="hotel-city mb-2"><i class="bi bi-geo-alt me-1 text-primary"></i><?= esc($hotel['city']) ?></div>
        <div class="d-flex align-items-center gap-2 mb-3">
          <div class="stars"><?php for($s=1;$s<=5;$s++): ?><i class="bi bi-star<?= $s<=round($hotel['rating'])?'-fill':'' ?>"></i><?php endfor; ?></div>
          <span class="rating-val"><?= number_format($hotel['rating'],1) ?></span>
        </div>
        <div class="d-flex justify-content-between align-items-center">
          <div class="price-tag">ETB <?= number_format($hotel['price_per_night'],0) ?><small>/night</small></div>
          <a href="/hotels/<?= $hotel['id'] ?>" class="btn btn-primary btn-sm px-3 rounded-pill fw-700">Book Now</a>
        </div>
      </div>
    </div>
  </div>
  <?php endforeach; ?>
</div>
<?php endif; ?>

<?= $this->endSection() ?>
