<?= $this->extend('layouts/main') ?>
<?= $this->section('content') ?>

<?php
$amenityIcons = [
    'Free WiFi'=>'bi-wifi','Pool'=>'bi-water','Gym'=>'bi-activity',
    'Restaurant'=>'bi-cup-hot','Spa'=>'bi-heart-pulse','Parking'=>'bi-p-square',
    'Bar'=>'bi-cup-straw','Boat Tours'=>'bi-tsunami','Breakfast'=>'bi-egg-fried',
    'Airport Shuttle'=>'bi-airplane','Air Conditioning'=>'bi-thermometer-snow',
    'Rooftop Terrace'=>'bi-building-up','Local Tours'=>'bi-camera','Garden'=>'bi-tree',
];
$nights = max(1, round((strtotime($checkOut) - strtotime($checkIn)) / 86400));
$selectedRoom = null; // will be set by JS
?>

<div class="bg-light border-bottom py-2">
  <div class="container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb mb-0 small">
        <li class="breadcrumb-item"><a href="/">Home</a></li>
        <li class="breadcrumb-item"><a href="/hotels">Hotels</a></li>
        <li class="breadcrumb-item active"><?= esc($hotel['name']) ?></li>
      </ol>
    </nav>
  </div>
</div>

<div class="container py-4">
  <div class="row g-4">

    <!-- ══ LEFT: Hotel Details ══ -->
    <div class="col-lg-8">

      <!-- GALLERY -->
      <div class="gallery-main mb-2 reveal">
        <img id="mainGalleryImg"
             src="<?= esc($hotel['images'][0] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200') ?>"
             alt="<?= esc($hotel['name']) ?>"
             style="transition:opacity .4s;width:100%;height:100%;object-fit:cover">
      </div>
      <?php if(count($hotel['images']??[]) > 1): ?>
      <div class="gallery-thumb-wrap mb-4 reveal">
        <?php foreach(array_slice($hotel['images'],0,5) as $i=>$img): ?>
        <div class="gallery-thumb <?= $i===0?'active':'' ?>" data-full="<?= esc($img) ?>">
          <img src="<?= esc($img) ?>" alt="Photo <?= $i+1 ?>" loading="lazy">
        </div>
        <?php endforeach; ?>
      </div>
      <?php endif; ?>

      <!-- Hotel Header -->
      <div class="d-flex justify-content-between align-items-start mb-3 reveal flex-wrap gap-2">
        <div>
          <h1 class="h3 fw-900 mb-1"><?= esc($hotel['name']) ?></h1>
          <p class="text-muted mb-1">
            <i class="bi bi-geo-alt-fill text-primary me-1"></i><?= esc($hotel['address']) ?>, <?= esc($hotel['city']) ?>
          </p>
          <div class="d-flex align-items-center gap-2 flex-wrap">
            <span class="badge rounded-pill" style="background:#eff6ff;color:#1a56db"><?= esc($hotel['type']) ?></span>
            <div class="stars">
              <?php for($s=1;$s<=5;$s++): ?>
              <i class="bi bi-star<?= $s<=round($hotel['rating'])?'-fill':'' ?>"></i>
              <?php endfor; ?>
            </div>
            <span class="fw-700"><?= number_format($hotel['rating'],1) ?></span>
            <span class="text-muted small">(<?= number_format($hotel['review_count']) ?> reviews)</span>
          </div>
        </div>
        <?php if(session()->get('user_id')): ?>
        <form class="wishlist-form" action="/dashboard/wishlist/toggle" method="POST">
          <?= csrf_field() ?>
          <input type="hidden" name="hotel_id" value="<?= $hotel['id'] ?>">
          <button type="submit" class="btn rounded-pill fw-700 <?= $isWishlisted?'btn-danger':'btn-outline-danger' ?> btn-sm px-3">
            <i class="bi bi-heart<?= $isWishlisted?'-fill':'' ?> me-1"></i><?= $isWishlisted?'Saved':'Save' ?>
          </button>
        </form>
        <?php endif; ?>
      </div>

      <!-- ABOUT -->
      <div class="mb-4 pb-4 border-bottom reveal">
        <h5 class="fw-700 mb-2">About This Property</h5>
        <p class="text-muted" style="line-height:1.8"><?= esc($hotel['description']??'') ?></p>
      </div>

      <!-- AMENITIES -->
      <div class="mb-4 pb-4 border-bottom reveal">
        <h5 class="fw-700 mb-3">Amenities & Services</h5>
        <div class="row g-2">
          <?php foreach($hotel['amenities']??[] as $am): $icon=$amenityIcons[$am]??'bi-check-circle'; ?>
          <div class="col-6 col-md-4">
            <div class="d-flex align-items-center gap-2 p-2 rounded-3" style="background:#f8fafc">
              <div class="rounded-2 d-flex align-items-center justify-content-center"
                   style="width:32px;height:32px;background:#eff6ff;flex-shrink:0">
                <i class="bi <?= $icon ?> text-primary"></i>
              </div>
              <span class="small fw-500"><?= esc($am) ?></span>
            </div>
          </div>
          <?php endforeach; ?>
        </div>
      </div>

      <!-- ROOM TYPES — click to select -->
      <?php if(!empty($hotel['room_types'])): ?>
      <div class="mb-4 pb-4 border-bottom reveal">
        <h5 class="fw-700 mb-3">Select Your Room</h5>
        <div class="row g-3" id="roomList">
          <?php foreach($hotel['room_types'] as $room): ?>
          <div class="col-md-6">
            <div class="room-card <?= !$room['is_available']?'opacity-60 position-relative':''; ?>"
                 data-room-type-id="<?= $room['id'] ?>"
                 data-price="<?= $room['price_per_night'] ?>"
                 data-name="<?= esc($room['name']) ?>"
                 data-bed="<?= esc($room['bed_type']) ?>"
                 onclick="<?= $room['is_available']?'selectRoom(this)':'showUnavailable(this)'; ?>"
                 style="<?= !$room['is_available']?'cursor:not-allowed':''; ?>">
              <?php if($room['image_url']): ?>
              <img src="<?= esc($room['image_url']) ?>" alt="<?= esc($room['name']) ?>">
              <?php if(!$room['is_available']): ?>
              <div style="position:absolute;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.45);display:flex;align-items:center;justify-content:center;border-radius:var(--radius) var(--radius) 0 0;">
                <div class="text-center text-white p-2">
                  <i class="bi bi-x-circle-fill fs-2 d-block mb-1"></i>
                  <span class="fw-700 small"><?= esc($room['unavailable_reason'] ?? 'Not Available') ?></span>
                </div>
              </div>
              <?php endif; ?>
              <?php endif; ?>
              <div class="p-3">
                <div class="d-flex justify-content-between align-items-start mb-1">
                  <h6 class="fw-700 mb-0"><?= esc($room['name']) ?></h6>
                  <?php if(!$room['is_available']): ?>
                  <span class="badge rounded-pill" style="background:#fee2e2;color:#b91c1c;font-size:.72rem">
                    <i class="bi bi-slash-circle me-1"></i><?= esc($room['unavailable_reason'] ?? 'Occupied') ?>
                  </span>
                  <?php else: ?>
                  <span class="badge bg-success rounded-pill" style="font-size:.72rem">
                    <i class="bi bi-check-circle me-1"></i>Available
                  </span>
                  <?php endif; ?>
                </div>
                <p class="text-muted small mb-2">
                  <i class="bi bi-moon-stars me-1"></i><?= esc($room['bed_type']) ?>
                  &nbsp;·&nbsp;<i class="bi bi-people me-1"></i>Up to <?= $room['max_guests'] ?> guests
                  &nbsp;·&nbsp;<?= $room['size_sqm'] ?>m²
                </p>
                <div class="d-flex flex-wrap gap-1 mb-2">
                  <?php foreach(array_slice($room['features']??[],0,3) as $f): ?>
                  <span class="amenity-pill"><?= esc($f) ?></span>
                  <?php endforeach; ?>
                </div>
                <div class="d-flex align-items-center justify-content-between">
                  <div class="price-tag">ETB <?= number_format($room['price_per_night'],0) ?><small>/night</small></div>
                  <?php if($room['is_available']): ?>
                  <span class="small text-primary fw-600 select-indicator" style="display:none">
                    <i class="bi bi-check-circle-fill me-1"></i>Selected
                  </span>
                  <?php else: ?>
                  <span class="text-muted small">Try different dates</span>
                  <?php endif; ?>
                </div>
              </div>
            </div>
          </div>
          <?php endforeach; ?>
        </div>
        <div id="noRoomWarning" class="alert rounded-3 small mt-3" style="background:#fef9c3;border:1px solid #fde68a;color:#92400e;display:none">
          <i class="bi bi-exclamation-triangle me-2"></i>Please select a room type before booking.
        </div>
      </div>
      <?php endif; ?>

      <!-- REVIEWS -->
      <div class="reveal rating-bars-section">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="fw-700 mb-0">Guest Reviews</h5>
          <div class="d-flex align-items-center gap-2">
            <span class="px-3 py-1 rounded-pill fw-900 text-white"
                  style="background:linear-gradient(135deg,#1a56db,#7c3aed);font-size:1.1rem">
              <?= number_format($summary['average']??0,1) ?>
            </span>
            <span class="text-muted small"><?= $summary['total']??0 ?> reviews</span>
          </div>
        </div>
        <div class="mb-4">
          <?php foreach([5=>'five_star',4=>'four_star',3=>'three_star',2=>'two_star',1=>'one_star'] as $n=>$key): ?>
          <?php $cnt=$summary[$key]??0; $pct=$summary['total']>0?round($cnt/$summary['total']*100):0; ?>
          <div class="rating-bar-wrap mb-2">
            <span class="small text-warning fw-600" style="width:20px"><?= $n ?>★</span>
            <div class="rating-bar"><div class="rating-bar-fill" data-pct="<?= $pct ?>" style="width:0"></div></div>
            <span class="small text-muted" style="width:30px"><?= $cnt ?></span>
          </div>
          <?php endforeach; ?>
        </div>
        <?php if(!empty($hotel['reviews'])): ?>
        <div class="row g-3 mb-3">
          <?php foreach($hotel['reviews'] as $rv): ?>
          <div class="col-12">
            <div class="p-3 rounded-3" style="background:#f8fafc;border:1px solid #e2e8f0">
              <div class="d-flex align-items-center gap-3 mb-2">
                <div style="width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,#1a56db,#f59e0b);display:flex;align-items:center;justify-content:center;font-weight:800;color:#fff;font-size:.9rem;flex-shrink:0">
                  <?= strtoupper(substr($rv['user_name']??'G',0,1)) ?>
                </div>
                <div>
                  <div class="fw-700 small"><?= esc($rv['user_name']??'Guest') ?></div>
                  <div class="stars" style="font-size:.75rem">
                    <?php for($s=1;$s<=5;$s++): ?><i class="bi bi-star<?= $s<=round($rv['rating'])?'-fill':'' ?>"></i><?php endfor; ?>
                    <span class="text-muted ms-1 fw-normal"><?= date('M Y',strtotime($rv['created_at'])) ?></span>
                  </div>
                </div>
              </div>
              <p class="small text-muted mb-0" style="line-height:1.6"><?= esc($rv['comment']) ?></p>
            </div>
          </div>
          <?php endforeach; ?>
        </div>
        <?php else: ?>
        <p class="text-muted small">No reviews yet. Be the first!</p>
        <?php endif; ?>
      </div>

      <!-- SIMILAR HOTELS (Expert Recommendation) -->
      <?php if(!empty($similar??[])): ?>
      <div class="mt-4 pt-4 border-top reveal">
        <div class="d-flex align-items-center gap-2 mb-3">
          <i class="bi bi-stars text-warning fs-5"></i>
          <h5 class="fw-700 mb-0">You May Also Like</h5>
          <span class="badge rounded-pill" style="background:#eff6ff;color:#1a56db;font-size:.72rem">Smart Picks</span>
        </div>
        <div class="row g-3">
          <?php foreach($similar as $sh): ?>
          <div class="col-md-4">
            <a href="/hotels/<?= $sh['id'] ?>?check_in=<?= urlencode($checkIn) ?>&check_out=<?= urlencode($checkOut) ?>&adults=<?= esc($adults) ?>&rooms=<?= esc($rooms) ?>"
               class="text-decoration-none">
              <div class="hotel-card h-100">
                <div class="card-img-slider" style="height:140px">
                  <div class="slide active" style="background-image:url('<?= esc($sh['images'][0]??'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400') ?>')"></div>
                </div>
                <div class="card-body p-2">
                  <div class="hotel-name" style="font-size:.85rem"><?= esc($sh['name']) ?></div>
                  <div class="d-flex justify-content-between align-items-center mt-1">
                    <div class="stars" style="font-size:.75rem">
                      <?php for($s=1;$s<=5;$s++): ?><i class="bi bi-star<?= $s<=round($sh['rating'])?'-fill':'' ?>"></i><?php endfor; ?>
                      <span class="ms-1 small"><?= number_format($sh['rating'],1) ?></span>
                    </div>
                    <div class="price-tag" style="font-size:.85rem">ETB <?= number_format($sh['price_per_night'],0) ?></div>
                  </div>
                </div>
              </div>
            </a>
          </div>
          <?php endforeach; ?>
        </div>
      </div>
      <?php endif; ?>
    </div>

    <!-- ══ RIGHT: BOOKING CARD ══ -->
    <div class="col-lg-4">
      <div class="booking-sticky card" id="bookingCard">
        <div class="card-header">
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <div class="text-white-50 small">Starting from</div>
              <div class="text-white fw-900" style="font-size:1.6rem" id="displayPrice">
                ETB <?= number_format($hotel['price_per_night'],0) ?><span class="fw-400 text-white-50 fs-6">/night</span>
              </div>
            </div>
            <div class="stars" style="color:#fbbf24">
              <?php for($s=1;$s<=5;$s++): ?><i class="bi bi-star<?= $s<=round($hotel['rating'])?'-fill':'' ?>"></i><?php endfor; ?>
            </div>
          </div>
          <!-- Selected room indicator -->
          <div id="selectedRoomBadge" style="display:none" class="mt-2">
            <span class="badge rounded-pill text-white" style="background:rgba(255,255,255,.2);font-size:.78rem">
              <i class="bi bi-check-circle me-1"></i><span id="selectedRoomName">Room selected</span>
            </span>
          </div>
        </div>

        <div class="card-body p-4">
          <!-- Dates -->
          <div class="row g-2 mb-3">
            <div class="col-6">
              <label class="form-label small fw-700">Check-In</label>
              <input type="date" id="ci" class="form-control" value="<?= esc($checkIn) ?>">
            </div>
            <div class="col-6">
              <label class="form-label small fw-700">Check-Out</label>
              <input type="date" id="co" class="form-control" value="<?= esc($checkOut) ?>">
            </div>
          </div>

          <!-- Guests -->
          <div class="row g-2 mb-3">
            <div class="col-6">
              <label class="form-label small fw-700">Adults</label>
              <div class="guest-counter">
                <button type="button" onclick="changeCount('adultsInput',-1)">−</button>
                <input type="number" id="adultsInput" value="<?= esc($adults) ?>" min="1" max="8" readonly>
                <button type="button" onclick="changeCount('adultsInput',1)">+</button>
              </div>
            </div>
            <div class="col-6">
              <label class="form-label small fw-700">Rooms</label>
              <div class="guest-counter">
                <button type="button" onclick="changeCount('roomsInput',-1)">−</button>
                <input type="number" id="roomsInput" value="<?= esc($rooms) ?>" min="1" max="5" readonly>
                <button type="button" onclick="changeCount('roomsInput',1)">+</button>
              </div>
            </div>
          </div>

          <!-- Price summary -->
          <div class="booking-summary-box mb-4">
            <span id="perNightPrice" data-price="<?= $hotel['price_per_night'] ?>" style="display:none"></span>
            <div class="d-flex justify-content-between small mb-1 text-muted">
              <span>ETB <span id="pricePerNight"><?= number_format($hotel['price_per_night'],0) ?></span> × <span id="nightsDisplay"><?= $nights ?> night<?= $nights>1?'s':'' ?></span></span>
              <span id="subtotalDisplay">ETB <?= number_format($hotel['price_per_night']*$nights,0) ?></span>
            </div>
            <div class="d-flex justify-content-between small mb-1 text-muted">
              <span>Rooms</span><span id="roomsDisplay"><?= $rooms ?></span>
            </div>
            <hr class="my-2">
            <div class="d-flex justify-content-between fw-800">
              <span>Total</span>
              <span class="text-primary" id="totalPriceDisplay">ETB <?= number_format($hotel['price_per_night']*$nights*$rooms,0) ?></span>
            </div>
          </div>

          <?php if(session()->get('user_id')): ?>
          <!-- ── LOGGED IN: Show Book Now button ── -->
          <button type="button" class="btn btn-primary w-100 py-3 fw-700 rounded-3 fs-6" onclick="submitBooking()">
            <i class="bi bi-calendar-check me-2"></i>Book Now
          </button>
          <p class="text-muted text-center small mt-2 mb-0">
            <i class="bi bi-shield-check text-success me-1"></i>Free cancellation · No hidden fees
          </p>

          <?php else: ?>
          <!-- ── NOT LOGGED IN: Login / Register choice ── -->
          <div class="text-center mb-3">
            <div class="fw-700 small text-muted mb-3">
              <i class="bi bi-lock me-1"></i>Sign in to complete your booking
            </div>
          </div>

          <!-- LOGIN button — for existing customers -->
          <a href="/login?redirect=<?= urlencode('/hotels/'.$hotel['id'].'?check_in='.urlencode($checkIn).'&check_out='.urlencode($checkOut).'&adults='.$adults.'&rooms='.$rooms) ?>"
             class="btn btn-primary w-100 py-3 fw-700 rounded-3 mb-2 d-flex align-items-center justify-content-center gap-2">
            <i class="bi bi-box-arrow-in-right fs-5"></i>
            <div>
              <div>I have an account — Login</div>
              <div style="font-size:.75rem;font-weight:400;opacity:.85">Sign in and book instantly</div>
            </div>
          </a>

          <!-- REGISTER button — for new customers -->
          <a href="/register?redirect=<?= urlencode('/hotels/'.$hotel['id'].'?check_in='.urlencode($checkIn).'&check_out='.urlencode($checkOut).'&adults='.$adults.'&rooms='.$rooms) ?>"
             class="btn btn-warning w-100 py-3 fw-700 rounded-3 d-flex align-items-center justify-content-center gap-2" style="color:#fff">
            <i class="bi bi-person-plus fs-5"></i>
            <div>
              <div>New here? Register Free</div>
              <div style="font-size:.75rem;font-weight:400;opacity:.9">Create account &amp; book in 1 minute</div>
            </div>
          </a>

          <div class="mt-3 p-2 rounded-3 small text-center" style="background:#f8fafc;border:1px solid #e2e8f0">
            <i class="bi bi-people-fill text-success me-1"></i>
            <strong>10,000+</strong> happy guests booked with us
          </div>
          <?php endif; ?>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Hidden booking form (submitted by JS after validation) -->
<form id="hiddenBookingForm" action="/booking/<?= $hotel['id'] ?>" method="POST" style="display:none">
  <?= csrf_field() ?>
  <input type="hidden" name="hotel_id"         value="<?= $hotel['id'] ?>">
  <input type="hidden" name="room_type_id"      id="hRoomTypeId"    value="">
  <input type="hidden" name="check_in"          id="hCheckIn"       value="<?= esc($checkIn) ?>">
  <input type="hidden" name="check_out"         id="hCheckOut"      value="<?= esc($checkOut) ?>">
  <input type="hidden" name="adults"            id="hAdults"        value="<?= esc($adults) ?>">
  <input type="hidden" name="children"          id="hChildren"      value="0">
  <input type="hidden" name="rooms"             id="hRooms"         value="<?= esc($rooms) ?>">
  <input type="hidden" name="payment_method"    id="hPayment"       value="telebirr">
  <input type="hidden" name="special_requests"  id="hSpecial"       value="">
  <input type="hidden" name="calculated_total"  id="hTotal"         value="">
</form>

<?= $this->section('scripts') ?>
<script>
const BASE_PRICE = <?= (float)$hotel['price_per_night'] ?>;
let selectedRoomId   = '';
let selectedRoomPrice = BASE_PRICE;
let selectedRoomName  = '';

// ── Room selector ─────────────────────────────────────────────
function selectRoom(card) {
  document.querySelectorAll('.room-card').forEach(c => {
    c.classList.remove('selected');
    const ind = c.querySelector('.select-indicator');
    if(ind) ind.style.display='none';
  });
  card.classList.add('selected');
  const ind = card.querySelector('.select-indicator');
  if(ind) ind.style.display='inline-flex';

  selectedRoomId    = card.dataset.roomTypeId;
  selectedRoomPrice = parseFloat(card.dataset.price);
  selectedRoomName  = card.dataset.name;

  document.getElementById('hRoomTypeId').value = selectedRoomId;
  document.getElementById('perNightPrice').dataset.price = selectedRoomPrice;

  // Update badge
  document.getElementById('selectedRoomBadge').style.display='block';
  document.getElementById('selectedRoomName').textContent = selectedRoomName;
  document.getElementById('pricePerNight').textContent = selectedRoomPrice.toLocaleString();

  updatePriceCalc();
  document.getElementById('noRoomWarning').style.display='none';
  card.scrollIntoView({behavior:'smooth',block:'nearest'});
}

// ── Price calculator ──────────────────────────────────────────
function updatePriceCalc() {
  const ci    = document.getElementById('ci').value;
  const co    = document.getElementById('co').value;
  const rooms = parseInt(document.getElementById('roomsInput').value)||1;

  if(!ci || !co) return;
  const nights = Math.max(1, Math.round((new Date(co)-new Date(ci))/86400000));
  const price  = selectedRoomPrice || BASE_PRICE;
  const total  = price * nights * rooms;

  document.getElementById('nightsDisplay').textContent  = nights + (nights===1?' night':' nights');
  document.getElementById('roomsDisplay').textContent   = rooms;
  document.getElementById('subtotalDisplay').textContent = 'ETB ' + (price*nights).toLocaleString();
  document.getElementById('totalPriceDisplay').textContent = 'ETB ' + total.toLocaleString();
  document.getElementById('hTotal').value   = total.toFixed(2);
  document.getElementById('hCheckIn').value = ci;
  document.getElementById('hCheckOut').value= co;
  document.getElementById('hRooms').value   = rooms;
  document.getElementById('hAdults').value  = document.getElementById('adultsInput').value;
}

// ── Date sync ─────────────────────────────────────────────────
document.getElementById('ci').addEventListener('change', () => {
  const ci = document.getElementById('ci');
  const co = document.getElementById('co');
  const next = new Date(new Date(ci.value).getTime()+86400000).toISOString().split('T')[0];
  if(co.value<=ci.value) co.value=next;
  co.min=next;
  updatePriceCalc();
});
document.getElementById('co').addEventListener('change', updatePriceCalc);

// Enforce min dates
(function(){
  const today = new Date().toISOString().split('T')[0];
  document.getElementById('ci').min=today;
  updatePriceCalc();
})();

// ── Submit booking ────────────────────────────────────────────
function submitBooking() {
  <?php if(!empty($hotel['room_types'])): ?>
  if(!selectedRoomId) {
    document.getElementById('noRoomWarning').style.display='block';
    document.getElementById('roomList').scrollIntoView({behavior:'smooth',block:'start'});
    return;
  }
  <?php endif; ?>

  const ci = document.getElementById('ci').value;
  const co = document.getElementById('co').value;
  if(!ci||!co) { showToast('Please select check-in and check-out dates','danger'); return; }
  if(new Date(co)<=new Date(ci)) { showToast('Check-out must be after check-in','danger'); return; }

  // Fill hidden form
  document.getElementById('hCheckIn').value  = ci;
  document.getElementById('hCheckOut').value = co;
  document.getElementById('hRoomTypeId').value = selectedRoomId;
  document.getElementById('hAdults').value = document.getElementById('adultsInput').value;
  document.getElementById('hRooms').value  = document.getElementById('roomsInput').value;
  updatePriceCalc();

  // Show payment method picker before submit
  showPaymentPicker();
}

// ── Payment picker modal ──────────────────────────────────────
function showPaymentPicker() {
  // Create modal dynamically
  const modal = document.createElement('div');
  modal.innerHTML = `
    <div class="modal fade" id="payModal" tabindex="-1">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow-lg">
          <div class="modal-header border-0 pb-0">
            <h5 class="modal-title fw-800">Choose Payment Method</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body pt-2">
            <div class="row g-2 mb-3">
              ${[
                ['telebirr','📱','Telebirr','Instant mobile payment'],
                ['cbe_birr','🏦','CBE Birr','Commercial Bank Ethiopia'],
                ['card','💳','Credit/Debit Card','Visa, Mastercard'],
                ['mobile_money','📲','Mobile Money','Ethio Telecom'],
                ['bank_transfer','🏛️','Bank Transfer','Direct transfer'],
                ['cash','🏨','Pay at Hotel','Cash on arrival'],
              ].map(([val,emoji,label,sub])=>`
                <div class="col-6">
                  <div class="payment-method-card" data-method="${val}" onclick="pickPayment('${val}',this)" style="cursor:pointer">
                    <div style="font-size:1.5rem">${emoji}</div>
                    <div class="fw-700 small">${label}</div>
                    <div class="text-muted" style="font-size:.72rem">${sub}</div>
                  </div>
                </div>`).join('')}
            </div>
            <div class="p-2 rounded-3 small" style="background:#f0fdf4;border:1px solid #bbf7d0">
              <i class="bi bi-shield-check text-success me-1"></i>
              <strong>Total: </strong>${document.getElementById('totalPriceDisplay').textContent}
              &nbsp;·&nbsp; ${document.getElementById('nightsDisplay').textContent}
            </div>
          </div>
          <div class="modal-footer border-0 pt-0">
            <button type="button" class="btn btn-outline-secondary rounded-pill fw-700 px-4" data-bs-dismiss="modal">Back</button>
            <button type="button" class="btn btn-primary rounded-pill fw-700 px-5" id="confirmPayBtn" onclick="confirmPay()">
              <i class="bi bi-lock me-1"></i>Confirm Booking
            </button>
          </div>
        </div>
      </div>
    </div>`;
  document.body.appendChild(modal);
  const bsModal = new bootstrap.Modal(document.getElementById('payModal'));
  bsModal.show();
  document.getElementById('payModal').addEventListener('hidden.bs.modal', () => modal.remove());

  // Select first option by default
  setTimeout(()=>{
    const first = document.querySelector('#payModal .payment-method-card');
    if(first) pickPayment('telebirr', first);
  }, 100);
}

function pickPayment(method, el) {
  document.querySelectorAll('#payModal .payment-method-card').forEach(c=>c.classList.remove('active'));
  el.classList.add('active');
  document.getElementById('hPayment').value = method;
}

function confirmPay() {
  const btn = document.getElementById('confirmPayBtn');
  btn.disabled=true;
  btn.innerHTML='<span class="spinner-border spinner-border-sm me-2"></span>Processing...';
  document.getElementById('hiddenBookingForm').submit();
}
</script>
<?= $this->endSection() ?>

<?= $this->endSection() ?>
