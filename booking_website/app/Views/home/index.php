<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<?php
$heroBgs = [
  'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1600&q=80',
  'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1600&q=80',
  'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1600&q=80',
  'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1600&q=80',
];
$destImages = [
  'Addis Ababa'=>'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=70',
  'Hawassa'   =>'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600&q=70',
  'Bahir Dar' =>'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600&q=70',
  'Gondar'    =>'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600&q=70',
  'Harar'     =>'https://images.unsplash.com/photo-1601918774516-5c7fe187b2a1?w=600&q=70',
  'Jimma'     =>'https://images.unsplash.com/photo-1521401830884-6c03c1c87ebb?w=600&q=70',
  'Arba Minch'=>'https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=600&q=70',
  'Adama'     =>'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=600&q=70',
];
?>

<!-- ═══ HERO ═══ -->
<section class="hero-section">
  <?php foreach($heroBgs as $i=>$bg): ?>
  <div class="hero-bg <?= $i===0?'active':'' ?>" style="background-image:url('<?= $bg ?>')"></div>
  <?php endforeach; ?>
  <div class="hero-overlay"></div>

  <div class="container hero-content py-5">
    <div class="row justify-content-center text-center mb-4">
      <div class="col-lg-9">
        <div class="section-pill text-white border border-white border-opacity-25 mb-3 anim-fade-in">
          <i class="bi bi-geo-alt-fill me-1"></i>Ethiopia's #1 Hotel Booking Platform
        </div>
        <h1 class="hero-title mb-3">Discover Your Perfect<br>Stay in Ethiopia</h1>
        <p class="hero-subtitle lead text-white-50 mb-4">From luxury Addis hotels to lakeside resorts — find, compare and book your ideal stay.</p>
        <div class="hero-stats d-flex flex-wrap justify-content-center gap-3">
          <div class="stat-pill"><i class="bi bi-building text-warning"></i><span><b class="count-up" data-count="500">500</b>+ Hotels</span></div>
          <div class="stat-pill"><i class="bi bi-geo-alt text-warning"></i><span><b class="count-up" data-count="50">50</b>+ Cities</span></div>
          <div class="stat-pill"><i class="bi bi-people text-warning"></i><span><b class="count-up" data-count="10000">10,000</b>+ Guests</span></div>
          <div class="stat-pill"><i class="bi bi-star-fill text-warning"></i><span>4.8 Avg Rating</span></div>
        </div>
      </div>
    </div>

    <!-- Search Card -->
    <div class="row justify-content-center">
      <div class="col-xl-10">
        <div class="hero-search-card p-4">
          <div class="d-flex gap-2 mb-3">
            <button class="tab-btn active" onclick="switchTab(this,'hotels')"><i class="bi bi-building me-1"></i>Hotels</button>
            <button class="tab-btn" onclick="switchTab(this,'resorts')"><i class="bi bi-water me-1"></i>Resorts</button>
            <button class="tab-btn" onclick="switchTab(this,'lodges')"><i class="bi bi-tree me-1"></i>Lodges</button>
          </div>
          <form action="/hotels" method="GET">
            <input type="hidden" name="type" id="searchType" value="">
            <div class="row g-3 align-items-end">
              <div class="col-md-3">
                <label class="form-label fw-600 small text-muted mb-1"><i class="bi bi-geo-alt-fill text-primary me-1"></i>Destination</label>
                <select name="city" class="form-select">
                  <option value="">All Destinations</option>
                  <?php
                  // Cities from DB — when super admin adds a city it shows here
                  if(!empty($cities)):
                    foreach($cities as $c):
                      $cName = is_array($c) ? ($c['name'] ?? $c) : $c;
                      $cRegion = is_array($c) ? ($c['region'] ?? '') : '';
                      $cHotels = is_array($c) ? (int)($c['hotel_count'] ?? 0) : 0;
                  ?>
                  <option value="<?= esc($cName) ?>">
                    <?= esc($cName) ?><?= $cRegion ? ' — '.esc($cRegion) : '' ?><?= $cHotels > 0 ? " ({$cHotels} hotel".($cHotels>1?'s':'').")" : '' ?>
                  </option>
                  <?php endforeach; endif; ?>
                </select>
              </div>
              <div class="col-md-2">
                <label class="form-label fw-600 small text-muted mb-1"><i class="bi bi-calendar-event text-primary me-1"></i>Check-In</label>
                <input type="date" name="check_in" id="homeCheckIn" class="form-control"
                       min="<?= date('Y-m-d') ?>" value="<?= date('Y-m-d') ?>">
              </div>
              <div class="col-md-2">
                <label class="form-label fw-600 small text-muted mb-1"><i class="bi bi-calendar2-check text-primary me-1"></i>Check-Out</label>
                <input type="date" name="check_out" id="homeCheckOut" class="form-control"
                       min="<?= date('Y-m-d', strtotime('+1 day')) ?>" value="<?= date('Y-m-d', strtotime('+1 day')) ?>">
              </div>
              <div class="col-md-2">
                <label class="form-label fw-600 small text-muted mb-1"><i class="bi bi-people-fill text-primary me-1"></i>Guests</label>
                <select name="adults" class="form-select">
                  <?php for($i=1;$i<=8;$i++): ?>
                  <option value="<?= $i ?>" <?= $i===2?'selected':'' ?>><?= $i ?> Adult<?= $i>1?'s':'' ?></option>
                  <?php endfor; ?>
                </select>
              </div>
              <div class="col-md-1">
                <label class="form-label fw-600 small text-muted mb-1"><i class="bi bi-door-closed text-primary me-1"></i>Rooms</label>
                <select name="rooms" class="form-select">
                  <?php for($i=1;$i<=5;$i++): ?><option><?= $i ?></option><?php endfor; ?>
                </select>
              </div>
              <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100 py-2 fw-700 rounded-3">
                  <i class="bi bi-search me-2"></i>Search Hotels
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Hero Dots -->
    <div class="hero-dots mt-4">
      <?php foreach($heroBgs as $i=>$_): ?>
      <div class="hero-dot <?= $i===0?'active':'' ?>"></div>
      <?php endforeach; ?>
    </div>
  </div>
</section>

<!-- ═══ WHY CHOOSE US ═══ -->
<section class="py-5 bg-white">
  <div class="container">
    <div class="row g-4 text-center">
      <?php
      $features = [
        ['bi-shield-check','primary','Secure Booking','256-bit SSL encrypted payments. Your data is always safe.'],
        ['bi-cash-coin','success','Best Price Guarantee','Find a lower price anywhere? We match it instantly.'],
        ['bi-headset','warning','24/7 Support','Our local team is available round the clock for you.'],
        ['bi-phone','info','Mobile App','Book, manage and explore from iOS & Android.'],
      ];
      foreach($features as [$icon,$color,$title,$desc]):
      ?>
      <div class="col-6 col-md-3 reveal">
        <div class="p-3">
          <div class="d-inline-flex align-items-center justify-content-center rounded-3 mb-3 bg-<?= $color ?> bg-opacity-10" style="width:64px;height:64px">
            <i class="bi <?= $icon ?> fs-4 text-<?= $color ?>"></i>
          </div>
          <h6 class="fw-700"><?= $title ?></h6>
          <p class="text-muted small mb-0"><?= $desc ?></p>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
</section>

<!-- ═══ POPULAR DESTINATIONS ═══ -->
<section class="py-5" style="background:#f8fafc">
  <div class="container">
    <div class="d-flex justify-content-between align-items-end mb-4 reveal">
      <div>
        <div class="section-pill mb-2"><i class="bi bi-compass me-1"></i>Explore Ethiopia</div>
        <h2 class="section-title mb-0">Popular Destinations</h2>
      </div>
      <a href="/hotels" class="btn btn-outline-primary rounded-pill px-4 d-none d-md-inline-flex align-items-center gap-2">
        View All <i class="bi bi-arrow-right"></i>
      </a>
    </div>
    <div class="row g-3">
      <?php
      // Destinations come from DB — when super admin adds a city, it shows here
      $fallbackDestImages = [
        'Addis Ababa'=>'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=70',
        'Hawassa'=>'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600&q=70',
        'Bahir Dar'=>'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600&q=70',
        'Gondar'=>'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600&q=70',
        'Harar'=>'https://images.unsplash.com/photo-1601918774516-5c7fe187b2a1?w=600&q=70',
        'Jimma'=>'https://images.unsplash.com/photo-1521401830884-6c03c1c87ebb?w=600&q=70',
        'Arba Minch'=>'https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=600&q=70',
        'Adama'=>'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=600&q=70',
      ];
      $destList = !empty($destCities) ? $destCities : [];
      if(empty($destList)):
        // Fallback if no cities with hotels
        foreach($fallbackDestImages as $name=>$img) $destList[] = ['name'=>$name,'hotel_count'=>0];
      endif;

      $i=0;
      foreach($destList as $dc):
        $dest = $dc['name'] ?? ($dc ?? '');
        $cnt  = $dc['hotel_count'] ?? 0;
        $img  = $fallbackDestImages[$dest] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=70';
        $col  = $i===0 ? 'col-md-6' : ($i<4 ? 'col-md-3' : 'col-md-2');
        $h    = $i<3 ? '280px' : '200px';
        $i++;
      ?>
      <div class="<?= $col ?> reveal">
        <a href="/hotels?city=<?= urlencode($dest) ?>" class="text-decoration-none">
          <div class="dest-card" style="height:<?= $h ?>">
            <img src="<?= $img ?>" alt="<?= esc($dest) ?>" loading="lazy">
            <div class="dest-card-overlay">
              <div>
                <h6 class="text-white fw-700 mb-0"><?= esc($dest) ?></h6>
                <span class="text-white-50 small">
                  <?= $cnt > 0 ? "$cnt hotel".($cnt>1?'s':'') : 'Explore' ?>
                  <i class="bi bi-arrow-right"></i>
                </span>
              </div>
            </div>
          </div>
        </a>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
</section>

<!-- ═══ FEATURED HOTELS ═══ -->
<section class="py-5 bg-white">
  <div class="container">
    <div class="d-flex justify-content-between align-items-end mb-4 reveal">
      <div>
        <div class="section-pill mb-2"><i class="bi bi-star-fill text-warning me-1"></i>Hand-Picked</div>
        <h2 class="section-title mb-0">Featured Hotels</h2>
      </div>
      <a href="/hotels?sort=rating&dir=DESC" class="btn btn-outline-primary rounded-pill px-4 d-none d-md-inline-flex align-items-center gap-2">
        View All <i class="bi bi-arrow-right"></i>
      </a>
    </div>
    <div class="row g-4">
      <?php foreach($featured as $idx=>$hotel): ?>
      <div class="col-sm-6 col-lg-3 reveal" style="animation-delay:<?= $idx*.08 ?>s">
        <div class="hotel-card featured-card h-100" onclick="window.location='/hotels/<?= $hotel['id'] ?>'">
          <div class="card-img-slider">
            <?php foreach(array_slice($hotel['images'],0,4) as $si=>$img): ?>
            <div class="slide <?= $si===0?'active':'' ?>" style="background-image:url('<?= esc($img) ?>')"></div>
            <?php endforeach; ?>
            <div class="img-progress"></div>
            <span class="hotel-type-badge"><?= esc($hotel['type']) ?></span>
            <?php if(session()->get('user_id')): ?>
            <form class="wishlist-form" action="/dashboard/wishlist/toggle" method="POST" onclick="event.stopPropagation()">
              <?= csrf_field() ?>
              <input type="hidden" name="hotel_id" value="<?= $hotel['id'] ?>">
              <button type="submit" class="btn-wishlist <?= ($hotel['is_wishlisted']??false)?'wishlisted':'' ?>" title="Wishlist">
                <i class="bi bi-heart<?= ($hotel['is_wishlisted']??false)?'-fill':'' ?>"></i>
              </button>
            </form>
            <?php endif; ?>
            <div class="card-img-dots">
              <?php foreach(array_slice($hotel['images'],0,4) as $si=>$_): ?>
              <div class="card-img-dot <?= $si===0?'active':'' ?>"></div>
              <?php endforeach; ?>
            </div>
          </div>
          <div class="card-body">
            <h6 class="hotel-name"><?= esc($hotel['name']) ?></h6>
            <div class="hotel-city mb-2"><i class="bi bi-geo-alt me-1"></i><?= esc($hotel['city']) ?></div>
            <div class="d-flex align-items-center gap-2 mb-2">
              <div class="stars">
                <?php for($s=1;$s<=5;$s++): ?><i class="bi bi-star<?= $s<=round($hotel['rating'])?'-fill':($s-.5<=$hotel['rating']?'-half':'') ?>"></i><?php endfor; ?>
              </div>
              <span class="rating-val"><?= number_format($hotel['rating'],1) ?></span>
              <span class="review-cnt">(<?= number_format($hotel['review_count']) ?>)</span>
            </div>
            <div class="d-flex flex-wrap gap-1 mb-3">
              <?php foreach(array_slice($hotel['amenities'],0,3) as $am): ?>
              <span class="amenity-pill"><i class="bi bi-check2 me-1"></i><?= esc($am) ?></span>
              <?php endforeach; ?>
            </div>
            <div class="d-flex justify-content-between align-items-center">
              <div class="price-tag">ETB <?= number_format($hotel['price_per_night'],0) ?><small>/night</small></div>
              <a href="/hotels/<?= $hotel['id'] ?>" class="btn btn-primary btn-sm px-3 rounded-pill" onclick="event.stopPropagation()">Book Now</a>
            </div>
          </div>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
</section>

<!-- ═══ AMENITIES ═══ -->
<section class="py-5" style="background:linear-gradient(135deg,#0f172a,#1a56db)">
  <div class="container">
    <div class="row align-items-center g-5">
      <div class="col-lg-5 text-white reveal">
        <div class="section-pill text-white border border-white border-opacity-25 mb-3">World-Class Amenities</div>
        <h2 class="fw-900 mb-3" style="font-size:2.2rem;line-height:1.2">Everything You Need<br>for a Perfect Stay</h2>
        <p class="text-white-50 mb-4">Our partner hotels are carefully selected to ensure every stay exceeds your expectations.</p>
        <a href="/hotels" class="btn btn-warning fw-700 px-5 py-3 rounded-pill">Browse Hotels <i class="bi bi-arrow-right ms-2"></i></a>
      </div>
      <div class="col-lg-7 reveal delay-2">
        <div class="row g-3">
          <?php
          $amenities = [
            ['bi-wifi','Free WiFi'],['bi-water','Swimming Pool'],
            ['bi-activity','Fitness Gym'],['bi-cup-hot','Restaurant'],
            ['bi-heart-pulse','Spa & Wellness'],['bi-p-square','Parking'],
            ['bi-airplane','Airport Shuttle'],['bi-camera','Local Tours'],
          ];
          foreach($amenities as [$icon,$name]):
          ?>
          <div class="col-6 col-md-3">
            <div class="text-center p-3 rounded-3" style="background:rgba(255,255,255,.08);backdrop-filter:blur(4px);border:1px solid rgba(255,255,255,.1);transition:.3s" onmouseenter="this.style.background='rgba(255,255,255,.18)'" onmouseleave="this.style.background='rgba(255,255,255,.08)'">
              <i class="bi <?= $icon ?> fs-2 text-warning d-block mb-2"></i>
              <small class="text-white fw-600"><?= $name ?></small>
            </div>
          </div>
          <?php endforeach; ?>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- ═══ TESTIMONIALS ═══ -->
<section class="py-5 bg-white">
  <div class="container">
    <div class="text-center mb-5 reveal">
      <div class="section-pill mb-2"><i class="bi bi-chat-quote me-1"></i>Guest Stories</div>
      <h2 class="section-title d-inline-block">What Our Guests Say</h2>
    </div>
    <div class="row g-4">
      <?php
      $reviews = [
        ['Kebede Alemu','Addis Ababa','Sheraton Addis',5,'Absolutely stunning experience! The Sheraton exceeded all my expectations. The staff were incredibly warm and the rooms were immaculate.'],
        ['Sara Tesfaye','Hawassa','Haile Resort',5,'The lakeside view was breathtaking. Woke up to the sound of birds and a perfect sunrise over Lake Hawassa. Will definitely return!'],
        ['Yonas Girma','Bahir Dar','Kuriftu Resort',4,'Amazing eco-resort with a perfect blend of luxury and nature. The boat tour to the island monasteries was unforgettable.'],
      ];
      foreach($reviews as $i=>[$name,$city,$hotel,$rating,$text]):
      ?>
      <div class="col-md-4 reveal" style="animation-delay:<?= $i*.1 ?>s">
        <div class="h-100 p-4 rounded-4" style="background:#f8fafc;border:1px solid #e2e8f0">
          <div class="stars mb-2">
            <?php for($s=1;$s<=5;$s++): ?><i class="bi bi-star<?= $s<=$rating?'-fill':'' ?>"></i><?php endfor; ?>
          </div>
          <p class="text-muted small mb-3" style="line-height:1.7">"<?= $text ?>"</p>
          <div class="d-flex align-items-center gap-3">
            <div style="width:42px;height:42px;border-radius:50%;background:linear-gradient(135deg,#1a56db,#f59e0b);display:flex;align-items:center;justify-content:center;font-weight:800;color:#fff;font-size:.9rem">
              <?= strtoupper(substr($name,0,1)) ?>
            </div>
            <div>
              <div class="fw-700 small"><?= $name ?></div>
              <div class="text-muted" style="font-size:.75rem"><i class="bi bi-geo-alt me-1"></i><?= $city ?> · <?= $hotel ?></div>
            </div>
          </div>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
</section>

<!-- ═══ APP CTA ═══ -->
<section class="py-5" style="background:#f8fafc">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-7 text-center reveal">
        <div class="anim-float d-inline-block mb-3">
          <div class="rounded-4 p-3 d-inline-flex" style="background:linear-gradient(135deg,#1a56db,#f59e0b)">
            <i class="bi bi-phone-fill text-white fs-1"></i>
          </div>
        </div>
        <h2 class="fw-900 mb-3">Get the Dallol Booking App</h2>
        <p class="text-muted mb-4">Book hotels, track reservations, and explore Ethiopia — all from your pocket.</p>
        <div class="d-flex justify-content-center gap-3">
          <a href="#" class="btn px-4 py-3 fw-700 rounded-3" style="background:#0f172a;color:#fff"><i class="bi bi-apple me-2"></i>App Store</a>
          <a href="#" class="btn px-4 py-3 fw-700 rounded-3" style="background:#0f172a;color:#fff"><i class="bi bi-google-play me-2"></i>Google Play</a>
        </div>
      </div>
    </div>
  </div>
</section>

<?= $this->section('scripts') ?>
<script>
function switchTab(btn, type) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  document.getElementById('searchType').value = type === 'hotels' ? '' : type.charAt(0).toUpperCase() + type.slice(1);
}

// ── Date enforcement on home search form ─────────────────────────────────
(function() {
  const ci = document.getElementById('homeCheckIn');
  const co = document.getElementById('homeCheckOut');
  if (!ci || !co) return;

  const today    = new Date().toISOString().split('T')[0];
  ci.min = today;
  if (!ci.value || ci.value < today) ci.value = today;

  function updateCoMin() {
    const next = new Date(new Date(ci.value).getTime() + 86400000).toISOString().split('T')[0];
    co.min = next;
    if (!co.value || co.value <= ci.value) co.value = next;
  }
  updateCoMin();

  ci.addEventListener('change', updateCoMin);
  co.addEventListener('change', function() {
    if (co.value <= ci.value) {
      co.value = new Date(new Date(ci.value).getTime() + 86400000).toISOString().split('T')[0];
    }
  });
})();
</script>
<?= $this->endSection() ?>

<?= $this->endSection() ?>
