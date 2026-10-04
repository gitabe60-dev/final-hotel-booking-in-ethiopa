/* ═══════════════════════════════════════════════════════════════
   Dallol Booking — Full Animated JavaScript
   ═══════════════════════════════════════════════════════════════ */
'use strict';

/* ══════════════════════════════════════════════════════════════════
   PAGE LOADER
══════════════════════════════════════════════════════════════════ */
window.addEventListener('load', () => {
  const loader = document.getElementById('pageLoader');
  if (loader) {
    loader.classList.add('done');
    setTimeout(() => loader.remove(), 600);
  }
});

/* ══════════════════════════════════════════════════════════════════
   HERO AUTO-SLIDER  (cycles background images every 5s)
══════════════════════════════════════════════════════════════════ */
function initHeroSlider() {
  const slides = document.querySelectorAll('.hero-bg');
  const dots   = document.querySelectorAll('.hero-dot');
  if (!slides.length) return;

  let current = 0;

  function goTo(idx) {
    slides[current].classList.remove('active');
    if (dots[current]) dots[current].classList.remove('active');
    current = (idx + slides.length) % slides.length;
    slides[current].classList.add('active');
    if (dots[current]) dots[current].classList.add('active');
  }

  goTo(0);
  const timer = setInterval(() => goTo(current + 1), 5000);

  dots.forEach((d, i) => d.addEventListener('click', () => { clearInterval(timer); goTo(i); }));
}

/* ══════════════════════════════════════════════════════════════════
   HOTEL CARD IMAGE AUTO-SLIDER
   Each card's .card-img-slider cycles its images automatically
══════════════════════════════════════════════════════════════════ */
function initCardSliders() {
  document.querySelectorAll('.card-img-slider').forEach(slider => {
    const slides = slider.querySelectorAll('.slide');
    const dots   = slider.querySelectorAll('.card-img-dot');
    if (slides.length < 2) return;

    let cur = 0;
    let paused = false;

    function goTo(i) {
      slides[cur].classList.remove('active');
      if (dots[cur]) dots[cur].classList.remove('active');
      cur = (i + slides.length) % slides.length;
      slides[cur].classList.add('active');
      if (dots[cur]) dots[cur].classList.add('active');
    }

    goTo(0);
    const t = setInterval(() => { if (!paused) goTo(cur + 1); }, 3500);

    slider.addEventListener('mouseenter', () => paused = true);
    slider.addEventListener('mouseleave', () => paused = false);

    // Touch swipe support
    let startX = 0;
    slider.addEventListener('touchstart', e => { startX = e.touches[0].clientX; });
    slider.addEventListener('touchend',   e => {
      const diff = startX - e.changedTouches[0].clientX;
      if (Math.abs(diff) > 40) goTo(diff > 0 ? cur + 1 : cur - 1);
    });
  });
}

/* ══════════════════════════════════════════════════════════════════
   SCROLL REVEAL  (Intersection Observer)
══════════════════════════════════════════════════════════════════ */
function initScrollReveal() {
  const observer = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        e.target.classList.add('visible');
        observer.unobserve(e.target);
      }
    });
  }, { threshold: 0.12 });

  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
}

/* ══════════════════════════════════════════════════════════════════
   STICKY NAVBAR on scroll
══════════════════════════════════════════════════════════════════ */
function initNavbar() {
  const nav = document.querySelector('.navbar');
  if (!nav) return;
  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 60);
  }, { passive: true });
}

/* ══════════════════════════════════════════════════════════════════
   DATE INPUTS — enforce min dates & sync check-out
══════════════════════════════════════════════════════════════════ */
function initDates() {
  const today    = new Date().toISOString().split('T')[0];
  const tomorrow = new Date(Date.now() + 86400000).toISOString().split('T')[0];

  document.querySelectorAll('input[name="check_in"]').forEach(el => {
    el.min = today;
    if (!el.value || el.value < today) el.value = today;
  });
  document.querySelectorAll('input[name="check_out"]').forEach(el => {
    el.min = tomorrow;
    if (!el.value || el.value <= document.querySelector('input[name="check_in"]')?.value) {
      el.value = tomorrow;
    }
  });

  document.querySelectorAll('input[name="check_in"]').forEach(ci => {
    ci.addEventListener('change', () => {
      const co = ci.closest('form')?.querySelector('input[name="check_out"]');
      if (!co) return;
      const minOut = new Date(new Date(ci.value).getTime() + 86400000).toISOString().split('T')[0];
      co.min = minOut;
      if (co.value <= ci.value) co.value = minOut;
      updatePriceCalc();
    });
  });
  document.querySelectorAll('input[name="check_out"]').forEach(co => {
    co.addEventListener('change', updatePriceCalc);
  });
}

/* ══════════════════════════════════════════════════════════════════
   PRICE CALCULATOR  (live update in booking form)
══════════════════════════════════════════════════════════════════ */
function updatePriceCalc() {
  const ci   = document.querySelector('input[name="check_in"]');
  const co   = document.querySelector('input[name="check_out"]');
  const rms  = document.querySelector('input[name="rooms"]');
  const disp = document.getElementById('nightsDisplay');
  const tot  = document.getElementById('totalPriceDisplay');
  const perN = parseFloat(document.getElementById('perNightPrice')?.dataset.price || 0);

  if (!ci || !co) return;

  const nights = Math.max(0, Math.round((new Date(co.value) - new Date(ci.value)) / 86400000));
  const rooms  = parseInt(rms?.value || 1);
  const total  = perN * nights * rooms;

  if (disp) disp.textContent = nights + (nights === 1 ? ' night' : ' nights');

  if (tot) {
    tot.textContent = 'ETB ' + total.toLocaleString('en-US');
    tot.classList.add('anim-scale-in');
    setTimeout(() => tot.classList.remove('anim-scale-in'), 300);
  }

  // update hidden fields if present
  const totInput = document.getElementById('totalPriceInput');
  if (totInput) totInput.value = total.toFixed(2);
}

/* ══════════════════════════════════════════════════════════════════
   COUNTER BUTTONS  (+/-)
══════════════════════════════════════════════════════════════════ */
window.changeCount = function(id, delta) {
  const inp = document.getElementById(id);
  if (!inp) return;
  const newVal = Math.min(parseInt(inp.max || 20), Math.max(parseInt(inp.min || 0), parseInt(inp.value || 0) + delta));
  inp.value = newVal;
  updatePriceCalc();
  inp.classList.add('anim-scale-in');
  setTimeout(() => inp.classList.remove('anim-scale-in'), 300);
};

/* ══════════════════════════════════════════════════════════════════
   GALLERY THUMBNAIL SWITCHER
══════════════════════════════════════════════════════════════════ */
function initGallery() {
  const mainImg = document.getElementById('mainGalleryImg');
  if (!mainImg) return;

  document.querySelectorAll('.gallery-thumb').forEach((thumb, i) => {
    thumb.addEventListener('click', () => {
      const src = thumb.dataset.full || thumb.querySelector('img')?.src;
      if (!src) return;

      mainImg.style.opacity = '0';
      setTimeout(() => {
        mainImg.src = src;
        mainImg.style.opacity = '1';
      }, 250);

      document.querySelectorAll('.gallery-thumb').forEach(t => t.classList.remove('active'));
      thumb.classList.add('active');
    });
    if (i === 0) thumb.classList.add('active');
  });
}

/* ══════════════════════════════════════════════════════════════════
   ROOM CARD SELECTOR
══════════════════════════════════════════════════════════════════ */
function initRoomSelector() {
  document.querySelectorAll('.room-card').forEach(card => {
    card.addEventListener('click', () => {
      document.querySelectorAll('.room-card').forEach(c => c.classList.remove('selected'));
      card.classList.add('selected');

      const roomTypeId = card.dataset.roomTypeId;
      const price      = parseFloat(card.dataset.price || 0);
      const hidden     = document.getElementById('room_type_id');
      const perNight   = document.getElementById('perNightPrice');

      if (hidden)   hidden.value = roomTypeId;
      if (perNight) perNight.dataset.price = price;

      // Animate selection
      card.style.transform = 'scale(.97)';
      setTimeout(() => card.style.transform = '', 200);

      updatePriceCalc();
      showToast('Room selected: ' + (card.querySelector('.room-name')?.textContent || ''), 'info');
    });
  });
}

/* ══════════════════════════════════════════════════════════════════
   PAYMENT METHOD SELECTOR
══════════════════════════════════════════════════════════════════ */
function initPaymentSelector() {
  document.querySelectorAll('.payment-method-card').forEach(card => {
    card.addEventListener('click', () => {
      document.querySelectorAll('.payment-method-card').forEach(c => c.classList.remove('active'));
      card.classList.add('active');
      const method = card.dataset.method;
      const radio  = document.getElementById('pay_' + method);
      if (radio) radio.checked = true;

      // Show/hide card fields
      const cardFields = document.getElementById('cardFields');
      if (cardFields) cardFields.style.display = method === 'card' ? 'block' : 'none';
    });
  });
}

/* ══════════════════════════════════════════════════════════════════
   PRICE RANGE SLIDER
══════════════════════════════════════════════════════════════════ */
function initPriceSlider() {
  const slider = document.getElementById('priceRange');
  const label  = document.getElementById('priceRangeValue');
  if (!slider || !label) return;

  const update = () => {
    label.textContent = 'ETB ' + parseInt(slider.value).toLocaleString();
  };
  update();
  slider.addEventListener('input', update);
}

/* ══════════════════════════════════════════════════════════════════
   LIVE SEARCH (city filter auto-submit with debounce)
══════════════════════════════════════════════════════════════════ */
function initLiveSearch() {
  const cityInput = document.getElementById('liveCitySearch');
  if (!cityInput) return;

  let timer;
  cityInput.addEventListener('input', () => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      cityInput.closest('form')?.submit();
    }, 700);
  });
}

/* ══════════════════════════════════════════════════════════════════
   OTP INPUT — auto-advance + combine on submit
══════════════════════════════════════════════════════════════════ */
function initOTP() {
  const boxes = document.querySelectorAll('.otp-box');
  if (!boxes.length) return;

  boxes.forEach((box, i) => {
    box.addEventListener('input', e => {
      box.value = box.value.replace(/\D/g, '').slice(0, 1);
      box.classList.toggle('filled', !!box.value);
      if (box.value && boxes[i + 1]) boxes[i + 1].focus();
    });
    box.addEventListener('keydown', e => {
      if (e.key === 'Backspace' && !box.value && boxes[i - 1]) {
        boxes[i - 1].value = '';
        boxes[i - 1].classList.remove('filled');
        boxes[i - 1].focus();
      }
    });
    box.addEventListener('paste', e => {
      e.preventDefault();
      const digits = e.clipboardData.getData('text').replace(/\D/g,'').slice(0,6);
      digits.split('').forEach((d, j) => {
        if (boxes[j]) { boxes[j].value = d; boxes[j].classList.add('filled'); }
      });
      if (boxes[digits.length - 1]) boxes[digits.length - 1].focus();
    });
  });

  document.getElementById('otpForm')?.addEventListener('submit', () => {
    const combined = Array.from(boxes).map(b => b.value).join('');
    const h = document.getElementById('otpHidden');
    if (h) h.value = combined;
  });
}

/* ══════════════════════════════════════════════════════════════════
   WISHLIST TOGGLE (AJAX — no page reload)
══════════════════════════════════════════════════════════════════ */
function initWishlistToggle() {
  document.querySelectorAll('.wishlist-form').forEach(form => {
    form.addEventListener('submit', async e => {
      e.preventDefault();
      const btn     = form.querySelector('.btn-wishlist');
      const hotelId = form.querySelector('[name="hotel_id"]')?.value;
      if (!hotelId) return;

      // Animate button
      btn.style.transform = 'scale(1.3)';
      setTimeout(() => btn.style.transform = '', 300);

      try {
        const fd = new FormData(form);
        const res = await fetch('/dashboard/wishlist/toggle', {
          method: 'POST',
          body: fd,
          headers: { 'X-Requested-With': 'XMLHttpRequest' }
        });
        const data = await res.json().catch(() => null);

        const isNowWishlisted = data?.wishlisted ?? btn.classList.contains('wishlisted') ? false : true;
        btn.classList.toggle('wishlisted', isNowWishlisted);
        btn.innerHTML = isNowWishlisted
          ? '<i class="bi bi-heart-fill"></i>'
          : '<i class="bi bi-heart"></i>';
        showToast(isNowWishlisted ? '❤️ Added to wishlist!' : 'Removed from wishlist', isNowWishlisted ? 'success' : 'secondary');
      } catch {
        form.submit(); // fallback
      }
    });
  });
}

/* ══════════════════════════════════════════════════════════════════
   TOAST NOTIFICATIONS
══════════════════════════════════════════════════════════════════ */
window.showToast = function(msg, type = 'success', duration = 3500) {
  let container = document.getElementById('toastContainer');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toastContainer';
    container.className = 'toast-container';
    document.body.appendChild(container);
  }

  const icons = { success:'bi-check-circle-fill', danger:'bi-x-circle-fill', info:'bi-info-circle-fill', warning:'bi-exclamation-triangle-fill', secondary:'bi-heart' };
  const id = 'toast_' + Date.now();

  const html = `
    <div id="${id}" class="toast align-items-center text-bg-${type} border-0 mb-2" role="alert" style="border-radius:12px;min-width:280px;animation:fadeUp .3s ease">
      <div class="d-flex align-items-center gap-2 p-3">
        <i class="bi ${icons[type]||'bi-bell'} fs-5"></i>
        <span class="flex-grow-1 fw-500">${msg}</span>
        <button type="button" class="btn-close btn-close-white" onclick="this.closest('.toast').remove()"></button>
      </div>
    </div>`;

  container.insertAdjacentHTML('beforeend', html);
  const el = document.getElementById(id);
  setTimeout(() => { if (el) { el.style.opacity='0'; el.style.transform='translateX(100%)'; el.style.transition='.4s'; setTimeout(() => el.remove(), 400); } }, duration);
};

/* ══════════════════════════════════════════════════════════════════
   AUTO DISMISS FLASH ALERTS
══════════════════════════════════════════════════════════════════ */
function initFlashAlerts() {
  document.querySelectorAll('.alert-flash').forEach(alert => {
    setTimeout(() => {
      alert.style.transition = 'opacity .5s';
      alert.style.opacity = '0';
      setTimeout(() => alert.remove(), 500);
    }, 4000);
  });
}

/* ══════════════════════════════════════════════════════════════════
   COUNTER ANIMATION (stat numbers)
══════════════════════════════════════════════════════════════════ */
function animateCounters() {
  const observer = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (!e.isIntersecting) return;
      const el  = e.target;
      const end = parseInt(el.dataset.count || el.textContent.replace(/\D/g,''));
      const suf = el.dataset.suffix || '';
      let cur = 0;
      const step = Math.ceil(end / 60);
      const t = setInterval(() => {
        cur = Math.min(cur + step, end);
        el.textContent = cur.toLocaleString() + suf;
        if (cur >= end) clearInterval(t);
      }, 20);
      observer.unobserve(el);
    });
  }, { threshold: .5 });

  document.querySelectorAll('.count-up').forEach(el => observer.observe(el));
}

/* ══════════════════════════════════════════════════════════════════
   BOOKING FORM VALIDATION + SUBMIT FEEDBACK
══════════════════════════════════════════════════════════════════ */
function initBookingForm() {
  const form = document.getElementById('bookingForm');
  if (!form) return;

  form.addEventListener('submit', e => {
    const ci = form.querySelector('[name="check_in"]')?.value;
    const co = form.querySelector('[name="check_out"]')?.value;

    if (!ci || !co) {
      e.preventDefault();
      showToast('Please select check-in and check-out dates', 'danger');
      return;
    }
    if (new Date(co) <= new Date(ci)) {
      e.preventDefault();
      showToast('Check-out must be after check-in', 'danger');
      return;
    }

    const btn = form.querySelector('[type="submit"]');
    if (btn) {
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing...';
    }
  });
}

/* ══════════════════════════════════════════════════════════════════
   STAR RATING INPUT
══════════════════════════════════════════════════════════════════ */
function initStarRating() {
  const stars = document.querySelectorAll('.star-input');
  if (!stars.length) return;

  stars.forEach((star, i) => {
    star.addEventListener('mouseenter', () => {
      stars.forEach((s, j) => s.classList.toggle('text-warning', j <= i));
    });
    star.addEventListener('mouseleave', () => {
      const val = parseInt(document.getElementById('ratingInput')?.value || 0);
      stars.forEach((s, j) => s.classList.toggle('text-warning', j < val));
    });
    star.addEventListener('click', () => {
      const val = i + 1;
      const inp = document.getElementById('ratingInput');
      if (inp) inp.value = val;
      stars.forEach((s, j) => s.classList.toggle('text-warning', j < val));
      showToast(`You rated: ${val} star${val > 1 ? 's' : ''}`, 'info');
    });
  });
}

/* ══════════════════════════════════════════════════════════════════
   PROGRESS BAR ANIMATION (rating bars in detail page)
══════════════════════════════════════════════════════════════════ */
function initRatingBars() {
  const observer = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (!e.isIntersecting) return;
      e.target.querySelectorAll('.rating-bar-fill').forEach(bar => {
        const pct = bar.dataset.pct || '0';
        setTimeout(() => bar.style.width = pct + '%', 100);
      });
    });
  }, { threshold: .3 });

  const ratingSection = document.querySelector('.rating-bars-section');
  if (ratingSection) observer.observe(ratingSection);
}

/* ══════════════════════════════════════════════════════════════════
   FILTER FORM AUTO-SUBMIT (type pills, sort, rating)
══════════════════════════════════════════════════════════════════ */
function initFilterAutoSubmit() {
  document.querySelectorAll('.filter-auto-submit').forEach(el => {
    el.addEventListener('change', () => {
      const form = el.closest('form');
      if (form) {
        // Show loading spinner on results
        const grid = document.getElementById('hotelsGrid');
        if (grid) {
          grid.style.opacity = '.4';
          grid.style.transition = 'opacity .3s';
        }
        form.submit();
      }
    });
  });
}

/* ══════════════════════════════════════════════════════════════════
   SMOOTH SCROLL to sections
══════════════════════════════════════════════════════════════════ */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      const target = document.querySelector(a.getAttribute('href'));
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });
}

/* ══════════════════════════════════════════════════════════════════
   CONFIRM DIALOG for cancellations
══════════════════════════════════════════════════════════════════ */
function initConfirmDialogs() {
  document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', e => {
      if (!confirm(el.dataset.confirm)) e.preventDefault();
    });
  });
}

/* ══════════════════════════════════════════════════════════════════
   INIT ALL
══════════════════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', () => {
  initHeroSlider();
  initCardSliders();
  initScrollReveal();
  initNavbar();
  initDates();
  initGallery();
  initRoomSelector();
  initPaymentSelector();
  initPriceSlider();
  initLiveSearch();
  initOTP();
  initWishlistToggle();
  initFlashAlerts();
  animateCounters();
  initBookingForm();
  initStarRating();
  initRatingBars();
  initFilterAutoSubmit();
  initSmoothScroll();
  initConfirmDialogs();
  updatePriceCalc();
});
