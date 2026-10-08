/**
 * Dallol Booking — Smart Form Validation Library
 * Applies to every form with data-validate="true"
 * Rules are driven by data-* attributes on inputs.
 */
(function () {
  'use strict';

  // ── Style injection ────────────────────────────────────────────────────────
  const style = document.createElement('style');
  style.textContent = `
    .dv-field { position: relative; }
    .dv-error  { border-color: #ef4444 !important; box-shadow: 0 0 0 3px rgba(239,68,68,.15) !important; }
    .dv-ok     { border-color: #22c55e !important; box-shadow: 0 0 0 3px rgba(34,197,94,.12) !important; }
    .dv-msg    { font-size: .78rem; margin-top: 4px; display: flex; align-items: center; gap: 4px; }
    .dv-msg.err{ color: #dc2626; }
    .dv-msg.ok { color: #16a34a; }
    .dv-strength { height: 4px; border-radius: 4px; margin-top: 6px; background: #e5e7eb; overflow: hidden; }
    .dv-strength-bar { height: 100%; border-radius: 4px; transition: width .3s, background .3s; width: 0; }
    .pw-toggle { cursor: pointer; }
    input.dv-error:focus, select.dv-error:focus, textarea.dv-error:focus { outline: none; }
  `;
  document.head.appendChild(style);

  // ── Helpers ────────────────────────────────────────────────────────────────
  const LETTERS_RE   = /^[\p{L}\s'\-\.]+$/u;   // letters + space/hyphen/apostrophe/dot (any script)
  const EMAIL_RE     = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
  const PHONE_RE     = /^[0-9]{7,15}$/;
  const ETPHONE_RE   = /^[9][0-9]{8}$/;         // Ethiopian: 9xxxxxxxx (9 digits after +251)
  const PASSWORD_RE  = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$/;

  function getMsg(el) {
    return el.closest('.dv-field')?.querySelector('.dv-msg') ||
           el.parentElement?.querySelector('.dv-msg') ||
           el.nextElementSibling;
  }

  function show(el, msg, ok) {
    // Remove old
    const old = el.closest('.mb-3, .mb-4, .col-md-6, .col-md-4, .col-12, .col-6')?.querySelector('.dv-msg');
    if (old) old.remove();

    el.classList.toggle('dv-error', !ok);
    el.classList.toggle('dv-ok', ok);

    const m = document.createElement('div');
    m.className = 'dv-msg ' + (ok ? 'ok' : 'err');
    m.innerHTML = (ok ? '✓ ' : '✗ ') + msg;

    const wrap = el.closest('.input-group') || el;
    wrap.insertAdjacentElement('afterend', m);
  }

  function clear(el) {
    el.classList.remove('dv-error', 'dv-ok');
    const wrap = el.closest('.input-group') || el;
    const m = wrap.nextElementSibling;
    if (m && m.classList.contains('dv-msg')) m.remove();
  }

  // ── Password strength ──────────────────────────────────────────────────────
  function strength(val) {
    let s = 0;
    if (val.length >= 6)  s++;
    if (val.length >= 10) s++;
    if (/[A-Z]/.test(val)) s++;
    if (/[0-9]/.test(val)) s++;
    if (/[^A-Za-z0-9]/.test(val)) s++;
    return s; // 0-5
  }

  function strengthLabel(s) {
    const labels = ['', 'Too short', 'Weak', 'Fair', 'Good', 'Strong'];
    const colors  = ['#e5e7eb', '#ef4444', '#f97316', '#eab308', '#22c55e', '#16a34a'];
    return { label: labels[s] || '', color: colors[s] || '#e5e7eb', pct: (s / 5) * 100 };
  }

  // ── Core validator ─────────────────────────────────────────────────────────
  function validate(el) {
    const type     = el.type;
    const val      = el.value.trim();
    const name     = el.name || el.id || '';
    const required = el.required || el.dataset.required === 'true';
    const rule     = el.dataset.rule || '';
    const label    = el.dataset.label || el.closest('.mb-3,.mb-4,.col-md-6,.col-12,.col-6')
                       ?.querySelector('label')?.textContent?.replace(/\s*\*.*/, '').trim() || 'This field';

    if (!val) {
      if (required) { show(el, `${label} is required.`, false); return false; }
      clear(el); return true;
    }

    // ── Name fields: letters only ──────────────────────────────────────────
    if (rule === 'name' || name.includes('name') || name.includes('full_name') ||
        name === 'first_name' || name === 'last_name') {
      if (!LETTERS_RE.test(val)) {
        show(el, `${label} must contain only letters.`, false); return false;
      }
      if (val.length < 2)  { show(el, `${label} is too short (min 2 characters).`, false); return false; }
      if (val.length > 100){ show(el, `${label} is too long (max 100 characters).`, false); return false; }
      show(el, `${label} looks good!`, true); return true;
    }

    // ── Email ──────────────────────────────────────────────────────────────
    if (type === 'email' || rule === 'email') {
      if (!EMAIL_RE.test(val)) { show(el, 'Enter a valid email address.', false); return false; }
      show(el, 'Email looks good!', true); return true;
    }

    // ── Phone ──────────────────────────────────────────────────────────────
    if (type === 'tel' || rule === 'phone') {
      const digits = val.replace(/[\s\-\+\(\)]/g, '');
      if (name === 'phone' && el.closest('.input-group')?.querySelector('.input-group-text')?.textContent?.includes('251')) {
        // Ethiopian phone after +251: must be 9xxxxxxxx
        if (!ETPHONE_RE.test(digits)) {
          show(el, 'Enter a valid Ethiopian number: 9xxxxxxxx (9 digits).', false); return false;
        }
      } else {
        if (!PHONE_RE.test(digits)) {
          show(el, 'Enter a valid phone number (7–15 digits).', false); return false;
        }
      }
      show(el, 'Phone number is valid.', true); return true;
    }

    // ── Password ───────────────────────────────────────────────────────────
    if (type === 'password' && !name.includes('current') && !name.includes('confirm') && !name.includes('new')) {
      if (val.length < 6)  { show(el, 'Password must be at least 6 characters.', false); return false; }
      if (!PASSWORD_RE.test(val)) {
        show(el, 'Include uppercase, lowercase and a number.', false);
        updateStrengthBar(el, val);
        return false;
      }
      show(el, 'Strong password!', true);
      updateStrengthBar(el, val);
      return true;
    }

    // ── Confirm password ───────────────────────────────────────────────────
    if (name.includes('confirm') && (name.includes('password') || rule === 'confirm_password')) {
      const refName = el.dataset.ref || 'password';
      const ref = el.form?.querySelector(`[name="${refName}"]`) ||
                  el.form?.querySelector('[name="new_password"]');
      if (ref && val !== ref.value.trim()) {
        show(el, 'Passwords do not match.', false); return false;
      }
      show(el, 'Passwords match!', true); return true;
    }

    // ── Number fields ──────────────────────────────────────────────────────
    if (type === 'number' || rule === 'number') {
      const num = parseFloat(val);
      const min = el.min !== '' ? parseFloat(el.min) : null;
      const max = el.max !== '' ? parseFloat(el.max) : null;
      if (isNaN(num))              { show(el, 'Enter a valid number.', false); return false; }
      if (min !== null && num < min) { show(el, `Minimum value is ${min}.`, false); return false; }
      if (max !== null && num > max) { show(el, `Maximum value is ${max}.`, false); return false; }
      show(el, 'Valid!', true); return true;
    }

    // ── URL ────────────────────────────────────────────────────────────────
    if (type === 'url' || rule === 'url') {
      try { new URL(val); show(el, 'Valid URL!', true); return true; }
      catch { show(el, 'Enter a valid URL (start with https://).', false); return false; }
    }

    // ── Date ───────────────────────────────────────────────────────────────
    if (type === 'date') {
      const today = new Date().toISOString().split('T')[0];
      if (val < today && el.min === today) {
        show(el, 'Date cannot be in the past.', false); return false;
      }
      show(el, 'Date selected!', true); return true;
    }

    // ── Textarea ───────────────────────────────────────────────────────────
    if (el.tagName === 'TEXTAREA') {
      const min = parseInt(el.dataset.minlength || 0);
      const max = parseInt(el.dataset.maxlength || 9999);
      if (val.length < min) { show(el, `Minimum ${min} characters required.`, false); return false; }
      if (val.length > max) { show(el, `Maximum ${max} characters allowed.`, false); return false; }
      show(el, 'Looks good!', true); return true;
    }

    // ── Select ─────────────────────────────────────────────────────────────
    if (el.tagName === 'SELECT' && required) {
      if (!val) { show(el, `Please select a ${label}.`, false); return false; }
      show(el, `${label} selected!`, true); return true;
    }

    // ── Generic text ──────────────────────────────────────────────────────
    if (val.length < (parseInt(el.minLength) || 0)) {
      show(el, `Minimum ${el.minLength} characters required.`, false); return false;
    }
    show(el, 'Looks good!', true); return true;
  }

  // ── Strength bar ───────────────────────────────────────────────────────────
  function updateStrengthBar(el, val) {
    let bar = el.form?.querySelector(`.dv-strength-bar[data-for="${el.name}"]`);
    if (!bar) {
      const wrap = el.closest('.input-group') || el;
      const div  = document.createElement('div');
      div.className = 'dv-strength';
      bar = document.createElement('div');
      bar.className = 'dv-strength-bar';
      bar.dataset.for = el.name;
      div.appendChild(bar);
      wrap.insertAdjacentElement('afterend', div);
    }
    const s = strengthLabel(strength(val));
    bar.style.width = s.pct + '%';
    bar.style.background = s.color;
    bar.title = s.label;
  }

  // ── Block non-letters in name fields (live) ────────────────────────────────
  function blockNumbers(el) {
    el.addEventListener('keypress', function (e) {
      const ch = e.key;
      // Allow: letters (any Unicode), space, hyphen, apostrophe, dot, backspace, delete, arrows
      if (ch.length === 1 && !/[\p{L}\s'\-\.]/u.test(ch)) {
        e.preventDefault();
        showTip(el, '⚠ Numbers and symbols are not allowed in name fields.');
      }
    });
    el.addEventListener('paste', function (e) {
      e.preventDefault();
      const text = (e.clipboardData || window.clipboardData).getData('text');
      const clean = text.replace(/[^\p{L}\s'\-\.]/gu, '');
      document.execCommand('insertText', false, clean);
    });
  }

  function showTip(el, msg) {
    let tip = el.closest('.mb-3,.mb-4,.col-md-6,.col-12,.col-6')?.querySelector('.dv-tip');
    if (!tip) {
      tip = document.createElement('div');
      tip.className = 'dv-msg err dv-tip';
      const wrap = el.closest('.input-group') || el;
      wrap.insertAdjacentElement('afterend', tip);
    }
    tip.innerHTML = msg;
    clearTimeout(tip._t);
    tip._t = setTimeout(() => tip.remove(), 2500);
  }

  // ── Attach to all forms ─────────────────────────────────────────────────────
  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('form').forEach(function (form) {
      // Skip search-only forms (GET forms without important fields)
      if (form.method === 'get' && !form.dataset.validate) return;

      const fields = form.querySelectorAll('input:not([type=hidden]):not([type=checkbox]):not([type=radio]):not([type=submit]):not([type=button]):not([type=file]), select, textarea');

      fields.forEach(function (el) {
        // Block numbers in name fields
        const n = el.name || '';
        if (n.includes('name') || n.includes('full_name') || n === 'first_name' || n === 'last_name') {
          blockNumbers(el);
        }

        // Block non-digits in number / phone fields
        if (el.type === 'number') {
          el.addEventListener('keypress', e => {
            if (!/[\d\.\-]/.test(e.key) && !['Backspace','Tab','Delete','ArrowLeft','ArrowRight'].includes(e.key)) {
              e.preventDefault();
            }
          });
        }

        // Live validation on blur and input
        el.addEventListener('blur',  () => validate(el));
        el.addEventListener('input', () => {
          if (el.classList.contains('dv-error')) validate(el);
          // Live strength for password
          if (el.type === 'password' && !n.includes('current') && !n.includes('confirm') && !n.includes('new')) {
            updateStrengthBar(el, el.value);
          }
        });
      });

      // On submit: validate all, block if errors
      form.addEventListener('submit', function (e) {
        let valid = true;
        fields.forEach(function (el) {
          if (el.disabled || el.type === 'hidden') return;
          if (!validate(el)) valid = false;
        });
        if (!valid) {
          e.preventDefault();
          // Scroll to first error
          const first = form.querySelector('.dv-error');
          if (first) first.scrollIntoView({ behavior: 'smooth', block: 'center' });
          // Shake the submit button
          const btn = form.querySelector('[type=submit]');
          if (btn) {
            btn.style.animation = 'none';
            btn.style.transition = 'transform .1s';
            btn.style.transform = 'translateX(-6px)';
            setTimeout(() => { btn.style.transform = 'translateX(6px)'; }, 100);
            setTimeout(() => { btn.style.transform = 'translateX(0)'; }, 200);
          }
        }
      });
    });
  });

})();
