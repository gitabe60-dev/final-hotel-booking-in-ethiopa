<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<!-- PAGE HEADER -->
<div style="background:linear-gradient(135deg,#0f172a,#1a56db);padding:2.5rem 0 4rem">
  <div class="container text-white">
    <nav aria-label="breadcrumb" class="mb-2">
      <ol class="breadcrumb mb-0" style="font-size:.82rem">
        <li class="breadcrumb-item"><a href="/" class="text-white-50 text-decoration-none">Home</a></li>
        <li class="breadcrumb-item active text-white">Hotels</li>
      </ol>
    </nav>
    <h1 class="fw-900 mb-1" style="font-size:2rem">
      <?= !empty($params['city']) ? 'Hotels in '.esc($params['city']) : 'All Hotels in Ethiopia' ?>
    </h1>
    <p class="text-white-50 mb-0">
      <?= ($total ?? count($hotels)) ?> hotel<?= ($total ?? count($hotels)) !== 1 ? 's' : '' ?> found
      <?= !empty($params['check_in'])?' · '.date('d M',strtotime($params['check_in'])).' – '.date('d M Y',strtotime($params['check_out'])):'' ?>
    </p>
  </div>
</div>

<div class="container" style="margin-top:-2rem">
  <!-- Quick search bar -->
  <div class="search-bar-sticky mb-4 anim-fade-up">
    <form action="/hotels" method="GET" id="mainSearchForm">
      <div class="row g-2 align-items-center">
        <div class="col-md-3">
          <div class="input-icon-wrap">
            <i class="bi bi-geo-alt-fill input-icon text-primary"></i>
            <select name="city" class="form-select">
              <option value="">All Cities</option>
              <?php foreach($cities as $c):
                $cName   = is_array($c) ? ($c['name']   ?? $c) : $c;
                $cRegion = is_array($c) ? ($c['region'] ?? '')  : '';
                $cCount  = is_array($c) ? (int)($c['hotel_count'] ?? 0) : 0;
                $selected = ($params['city'] ?? '') === $cName ? 'selected' : '';
              ?>
              <option value="<?= esc($cName) ?>" <?= $selected ?>>
                <?= esc($cName) ?><?= $cRegion ? ' — '.esc($cRegion) : '' ?><?= $cCount > 0 ? " ({$cCount})" : '' ?>
              </option>
              <?php endforeach; ?>
            </select>
          </div>
        </div>
        <div class="col-md-2">
          <input type="date" name="check_in" id="listCheckIn" class="form-control"
                 min="<?= date('Y-m-d') ?>" value="<?= esc($params['check_in']) ?>">
        </div>
        <div class="col-md-2">
          <input type="date" name="check_out" id="listCheckOut" class="form-control"
                 min="<?= date('Y-m-d', strtotime('+1 day')) ?>" value="<?= esc($params['check_out']) ?>">
        </div>
        <div class="col-md-2">
          <select name="adults" class="form-select">
            <?php for($i=1;$i<=8;$i++): ?>
            <option value="<?= $i ?>" <?= ($params['adults']??2)==$i?'selected':'' ?>><?= $i ?> Guest<?= $i>1?'s':'' ?></option>
            <?php endfor; ?>
          </select>
        </div>
        <div class="col-md-1">
          <select name="rooms" class="form-select">
            <?php for($i=1;$i<=5;$i++): ?>
            <option value="<?= $i ?>" <?= ($params['rooms']??1)==$i?'selected':'' ?>><?= $i ?></option>
            <?php endfor; ?>
          </select>
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary w-100 fw-700 rounded-3">
            <i class="bi bi-search me-1"></i>Update
          </button>
        </div>
      </div>
    </form>
  </div>

  <div class="row g-4">
    <!-- FILTERS SIDEBAR -->
    <div class="col-lg-3">
      <div class="filter-card" style="position:sticky;top:80px">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="fw-700 mb-0"><i class="bi bi-sliders2 me-2 text-primary"></i>Filters</h6>
          <a href="/hotels<?= !empty($params['city'])?'?city='.urlencode($params['city']):'' ?>" class="btn btn-sm btn-outline-secondary rounded-pill" style="font-size:.75rem">Reset</a>
        </div>
        <form action="/hotels" method="GET">
          <input type="hidden" name="city"      value="<?= esc($params['city']??'') ?>">
          <input type="hidden" name="check_in"  value="<?= esc($params['check_in']??'') ?>">
          <input type="hidden" name="check_out" value="<?= esc($params['check_out']??'') ?>">
          <input type="hidden" name="adults"    value="<?= esc($params['adults']??2) ?>">
          <input type="hidden" name="rooms"     value="<?= esc($params['rooms']??1) ?>">

          <!-- Hotel Type -->
          <div class="mb-4">
            <div class="filter-section-title">Hotel Type</div>
            <div class="d-flex flex-wrap gap-2">
              <?php foreach($hotelTypes as $type): ?>
              <div>
                <input type="radio" class="type-pill-input visually-hidden filter-auto-submit" name="type" id="t_<?= $type ?>" value="<?= $type==='All'?'':$type ?>" <?= ($params['type']??'')===(($type==='All')?'':$type)?'checked':'' ?>>
                <label class="type-pill-label" for="t_<?= $type ?>"><?= $type ?></label>
              </div>
              <?php endforeach; ?>
            </div>
          </div>

          <!-- Rating -->
          <div class="mb-4">
            <div class="filter-section-title">Minimum Rating</div>
            <select name="min_rating" class="form-select form-select-sm filter-auto-submit">
              <option value="">Any Rating</option>
              <option value="4.5" <?= ($params['min_rating']??'')==='4.5'?'selected':'' ?>>⭐⭐⭐⭐⭐ 4.5+</option>
              <option value="4.0" <?= ($params['min_rating']??'')==='4.0'?'selected':'' ?>>⭐⭐⭐⭐ 4.0+</option>
              <option value="3.5" <?= ($params['min_rating']??'')==='3.5'?'selected':'' ?>>⭐⭐⭐ 3.5+</option>
            </select>
          </div>

          <!-- Price Range -->
          <div class="mb-4">
            <div class="filter-section-title">Max Price / Night</div>
            <input type="range" class="form-range" id="priceRange" name="max_price"
                   min="500" max="15000" step="100"
                   value="<?= esc($params['max_price']??15000) ?>">
            <div class="d-flex justify-content-between small text-muted mt-1">
              <span>ETB 500</span>
              <span id="priceRangeValue">ETB <?= number_format($params['max_price']??15000) ?></span>
            </div>
          </div>

          <!-- Sort -->
          <div class="mb-3">
            <div class="filter-section-title">Sort By</div>
            <select name="sort" class="form-select form-select-sm filter-auto-submit">
              <option value="rating"          <?= ($params['sort']??'')==='rating'?'selected':'' ?>>⭐ Top Rated</option>
              <option value="price_per_night" <?= ($params['sort']??'')==='price_per_night'?'selected':'' ?>>💰 Price: Low to High</option>
              <option value="review_count"    <?= ($params['sort']??'')==='review_count'?'selected':'' ?>>💬 Most Reviewed</option>
            </select>
          </div>

          <button type="submit" class="btn btn-primary w-100 rounded-3 fw-700">Apply Filters</button>
        </form>
      </div>
    </div>

    <!-- HOTELS GRID -->
    <div class="col-lg-9">
      <!-- Not logged in: register/login banner -->
      <?php if(!session()->get('user_id')): ?>
      <div class="alert rounded-3 d-flex align-items-center gap-3 mb-3" style="background:linear-gradient(135deg,#eff6ff,#dbeafe);border:1px solid #bfdbfe">
        <i class="bi bi-person-circle fs-3 text-primary flex-shrink-0"></i>
        <div class="flex-grow-1">
          <div class="fw-700 small">Join free to save hotels &amp; book instantly</div>
          <div class="text-muted" style="font-size:.78rem">Create an account to save wishlists and complete bookings.</div>
        </div>
        <div class="d-flex gap-2 flex-shrink-0">
          <a href="/register" class="btn btn-warning btn-sm rounded-pill fw-700 px-3">Register Free</a>
          <a href="/login"    class="btn btn-primary btn-sm rounded-pill fw-700 px-3">Login</a>
        </div>
      </div>
      <?php endif; ?>

      <!-- Active filters pills -->
      <div class="d-flex flex-wrap gap-2 mb-3">
        <?php if(!empty($params['city'])): ?>
        <a href="/hotels?check_in=<?= urlencode($params['check_in']??'') ?>&check_out=<?= urlencode($params['check_out']??'') ?>&adults=<?= $params['adults']??2 ?>&rooms=<?= $params['rooms']??1 ?>" class="badge rounded-pill text-decoration-none" style="background:#eff6ff;color:#1a56db;font-size:.82rem;padding:.4em .9em">
          <i class="bi bi-geo-alt me-1"></i><?= esc($params['city']) ?> <i class="bi bi-x ms-1"></i>
        </a>
        <?php endif; ?>
        <?php if(!empty($params['type'])): ?>
        <span class="badge rounded-pill" style="background:#f0fdf4;color:#15803d;font-size:.82rem;padding:.4em .9em">
          <i class="bi bi-building me-1"></i><?= esc($params['type']) ?>
        </span>
        <?php endif; ?>
        <?php if(!empty($params['min_rating'])): ?>
        <span class="badge rounded-pill" style="background:#fef9c3;color:#a16207;font-size:.82rem;padding:.4em .9em">
          ⭐ <?= esc($params['min_rating']) ?>+
        </span>
        <?php endif; ?>
      </div>

      <?php if(empty($hotels)): ?>
      <div class="text-center py-5 reveal">
        <div class="anim-float d-inline-block mb-3">
          <i class="bi bi-building-slash" style="font-size:4rem;color:#94a3b8"></i>
        </div>
        <h4 class="fw-700 mb-2">No Hotels Found</h4>
        <p class="text-muted mb-4">Try adjusting your filters or search a different city.</p>
        <a href="/hotels" class="btn btn-primary px-5 rounded-pill fw-700">Browse All Hotels</a>
      </div>
      <?php else: ?>
      <div class="row g-4" id="hotelsGrid">
        <?php foreach($hotels as $idx=>$hotel): ?>
        <div class="col-sm-6 col-xl-4 reveal" style="animation-delay:<?= $idx*.05 ?>s">
          <div class="hotel-card h-100" onclick="window.location='/hotels/<?= $hotel['id'] ?>?check_in=<?= urlencode($params['check_in']??'') ?>&check_out=<?= urlencode($params['check_out']??'') ?>&adults=<?= $params['adults']??2 ?>&rooms=<?= $params['rooms']??1 ?>'">
            <div class="card-img-slider">
              <?php
              $imgs = $hotel['images'] ?? [];
              if(empty($imgs)) $imgs = ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600'];
              foreach(array_slice($imgs,0,4) as $si=>$img):
              ?>
              <div class="slide <?= $si===0?'active':'' ?>" style="background-image:url('<?= esc($img) ?>')"></div>
              <?php endforeach; ?>
              <span class="hotel-type-badge"><?= esc($hotel['type']) ?></span>
              <?php if(session()->get('user_id')): ?>
              <form class="wishlist-form" action="/dashboard/wishlist/toggle" method="POST" onclick="event.stopPropagation()">
                <?= csrf_field() ?>
                <input type="hidden" name="hotel_id" value="<?= $hotel['id'] ?>">
                <button type="submit" class="btn-wishlist <?= ($hotel['is_wishlisted']??false)?'wishlisted':'' ?>">
                  <i class="bi bi-heart<?= ($hotel['is_wishlisted']??false)?'-fill':'' ?>"></i>
                </button>
              </form>
              <?php else: ?>
              <a href="/login" class="btn-wishlist" title="Login to save" onclick="event.stopPropagation()">
                <i class="bi bi-heart"></i>
              </a>
              <?php endif; ?>
              <div class="card-img-dots">
                <?php for($d=0;$d<min(count($imgs),4);$d++): ?>
                <div class="card-img-dot <?= $d===0?'active':'' ?>"></div>
                <?php endfor; ?>
              </div>
            </div>
            <div class="card-body">
              <h6 class="hotel-name"><?= esc($hotel['name']) ?></h6>
              <div class="hotel-city mb-2"><i class="bi bi-geo-alt me-1 text-primary"></i><?= esc($hotel['city']) ?></div>
              <div class="d-flex align-items-center gap-2 mb-2">
                <div class="stars">
                  <?php for($s=1;$s<=5;$s++): ?><i class="bi bi-star<?= $s<=round($hotel['rating'])?'-fill':'' ?>"></i><?php endfor; ?>
                </div>
                <span class="rating-val"><?= number_format($hotel['rating'],1) ?></span>
                <span class="review-cnt">(<?= number_format($hotel['review_count']) ?>)</span>
              </div>
              <div class="d-flex flex-wrap gap-1 mb-3">
                <?php foreach(array_slice($hotel['amenities']??[],0,3) as $am): ?>
                <span class="amenity-pill"><?= esc($am) ?></span>
                <?php endforeach; ?>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <div class="price-tag">ETB <?= number_format($hotel['price_per_night'],0) ?><small>/night</small></div>
                <a href="/hotels/<?= $hotel['id'] ?>?check_in=<?= urlencode($params['check_in']??'') ?>&check_out=<?= urlencode($params['check_out']??'') ?>&adults=<?= $params['adults']??2 ?>&rooms=<?= $params['rooms']??1 ?>" class="btn btn-primary btn-sm px-3 rounded-pill fw-700" onclick="event.stopPropagation()">Book</a>
              </div>
            </div>
          </div>
        </div>
        <?php endforeach; ?>
      </div>
      <?php endif; ?>
    </div>
  </div>
</div>

<?= $this->section('scripts') ?>
<script>
// ── Date enforcement on search list form ─────────────────────────────────
(function() {
  const ci = document.getElementById('listCheckIn');
  const co = document.getElementById('listCheckOut');
  if (!ci || !co) return;
  const today = new Date().toISOString().split('T')[0];
  ci.min = today;
  if (ci.value < today) ci.value = today;
  function updateCoMin() {
    const next = new Date(new Date(ci.value).getTime()+86400000).toISOString().split('T')[0];
    co.min = next;
    if (co.value <= ci.value) co.value = next;
  }
  updateCoMin();
  ci.addEventListener('change', updateCoMin);
  co.addEventListener('change', function() {
    if (co.value <= ci.value)
      co.value = new Date(new Date(ci.value).getTime()+86400000).toISOString().split('T')[0];
  });
})();
</script>
<?= $this->endSection() ?>

<?= $this->endSection() ?>
