/// validators.dart
///
/// Shared validation rules used by every form in the app.
/// Each function returns null (valid) or a human-readable error string.
/// Pass directly to TextFormField.validator.
library;

class V {
  V._();

  // ── Name: letters, spaces, hyphens and apostrophes only ───────────────────
  // "Abebe Kebede", "O'Brien", "Al-Hassan" all pass.
  static String? name(String? v, {String label = 'Name', bool required = true}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return required ? '$label is required' : null;
    if (s.length < 2) return '$label must be at least 2 characters';
    if (s.length > 60) return '$label is too long';
    if (!RegExp(r"^[a-zA-Z\u1200-\u137F\s'\-]+$").hasMatch(s)) {
      return '$label must contain letters only (no numbers or symbols)';
    }
    return null;
  }

  // ── Full name (two words minimum encouraged but not required) ─────────────
  static String? fullName(String? v, {bool required = true}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return required ? 'Full name is required' : null;
    if (s.length < 3) return 'Full name is too short';
    if (!RegExp(r"^[a-zA-Z\u1200-\u137F\s'\-]+$").hasMatch(s)) {
      return 'Full name must contain letters only';
    }
    return null;
  }

  // ── Email ─────────────────────────────────────────────────────────────────
  static String? email(String? v, {bool required = true}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return required ? 'Email is required' : null;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(s)) {
      return 'Enter a valid email address (e.g. you@example.com)';
    }
    return null;
  }

  // ── Phone: Ethiopian mobile (09xxxxxxxx or +2519xxxxxxxx or 07xxxxxxxx) ───
  // Accepts: 09XXXXXXXX, 07XXXXXXXX, +2519XXXXXXXX, +2517XXXXXXXX
  static String? phone(String? v, {bool required = true}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return required ? 'Phone number is required' : null;
    // Strip leading + or 0
    final clean = s.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^(\+?251[79]\d{8}|0[79]\d{8})$').hasMatch(clean)) {
      return 'Enter a valid Ethiopian phone (e.g. 0912345678)';
    }
    return null;
  }

  // ── Phone: optional variant ───────────────────────────────────────────────
  static String? phoneOptional(String? v) => phone(v, required: false);

  // ── Email OR phone (at least one required) ────────────────────────────────
  // Used in register — returns null only if at least one is non-empty and valid.
  static String? emailOrPhone(String? email, String? phone) {
    final e = email?.trim() ?? '';
    final p = phone?.trim() ?? '';
    if (e.isEmpty && p.isEmpty) return 'Provide email or phone number';
    return null;
  }

  // ── Password: min 6 chars, must have at least one letter AND one digit ────
  static String? password(String? v, {bool required = true}) {
    final s = v ?? '';
    if (s.isEmpty) return required ? 'Password is required' : null;
    if (s.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'[a-zA-Z]').hasMatch(s)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(s)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // ── Confirm password ──────────────────────────────────────────────────────
  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  // ── Price: positive number ────────────────────────────────────────────────
  static String? price(String? v, {String label = 'Price'}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return '$label is required';
    final d = double.tryParse(s);
    if (d == null) return '$label must be a valid number';
    if (d <= 0) return '$label must be greater than 0';
    return null;
  }

  // ── Positive integer ──────────────────────────────────────────────────────
  static String? positiveInt(String? v, {String label = 'Value'}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return '$label is required';
    final n = int.tryParse(s);
    if (n == null) return '$label must be a whole number';
    if (n <= 0) return '$label must be greater than 0';
    return null;
  }

  // ── Latitude: -90 to 90, optional ─────────────────────────────────────────
  static String? latitude(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null; // optional
    final d = double.tryParse(s);
    if (d == null) return 'Latitude must be a valid number';
    if (d < -90 || d > 90) return 'Latitude must be between -90 and 90';
    return null;
  }

  // ── Longitude: -180 to 180, optional ──────────────────────────────────────
  static String? longitude(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null; // optional
    final d = double.tryParse(s);
    if (d == null) return 'Longitude must be a valid number';
    if (d < -180 || d > 180) return 'Longitude must be between -180 and 180';
    return null;
  }

  // ── OTP: exactly 6 digits ─────────────────────────────────────────────────
  static String? otp(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'OTP code is required';
    if (!RegExp(r'^\d{6}$').hasMatch(s)) return 'OTP must be exactly 6 digits';
    return null;
  }

  // ── Required (generic non-empty) ──────────────────────────────────────────
  static String? required(String? v, {String label = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  // ── URL: optional, must be http/https if provided ─────────────────────────
  static String? urlOptional(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    if (!RegExp(r'^https?://').hasMatch(s)) {
      return 'URL must start with http:// or https://';
    }
    return null;
  }

  // ── Commission: 0–100 ─────────────────────────────────────────────────────
  static String? commission(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null; // optional
    final d = double.tryParse(s);
    if (d == null) return 'Commission must be a number';
    if (d < 0 || d > 100) return 'Commission must be between 0 and 100';
    return null;
  }

  // ── Transaction ID: min 4 chars ───────────────────────────────────────────
  static String? transactionId(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Transaction ID is required';
    if (s.length < 4) return 'Transaction ID is too short (min 4 characters)';
    return null;
  }
}
