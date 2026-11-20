// lib/core/constants/api_constants.dart
//
// SINGLE SOURCE OF TRUTH for all API URLs.
// Change _env to switch targets:
//   'dev'     → localhost:8080  (Linux desktop + Chrome web + iOS simulator)
//   'android' → 10.0.2.2:8080  (Android emulator)
//   'device'  → LAN IP          (physical device — set _lanIp below)
//   'prod'    → production URL

class ApiConstants {
  // ── Environment switch ────────────────────────────────────────────────────
  // 'dev'     → localhost:8080  (Linux desktop + Chrome web + iOS simulator)
  // 'android' → 10.0.2.2:8080  (Android emulator only)
  // 'device'  → LAN IP          (physical Android phone — your PC's WiFi IP)
  // 'prod'    → production URL
  //
  // IMPORTANT: Both phone and PC must be on the same WiFi network.
  // Run `ip route get 8.8.8.8` on PC to find your LAN IP.
  static const String _env   = 'device';        // ← 'device' for real phone
  static const String _lanIp = '10.129.161.58'; // ← your PC's current IP

  static const String _devBase     = 'http://localhost:8080';
  static const String _androidBase = 'http://10.0.2.2:8080';
  static const String _deviceBase  = 'http://$_lanIp:8080';
  static const String _prodBase    = 'https://api.dallolbook.com';

  static String get host {
    switch (_env) {
      case 'android': return _androidBase;
      case 'device':  return _deviceBase;
      case 'prod':    return _prodBase;
      default:        return _devBase;
    }
  }

  // ── Base URLs (mirrors web frontend exactly) ──────────────────────────────
  // Web: axios baseURL = '/api/v1'   → guest API
  // Web: axios baseURL = '/api/admin' → admin API
  static String get baseUrl    => '$host/api/v1';
  static String get adminBase  => '$host/api/admin';
  static String get publicBase => '$host/api';

  // ── Guest Auth  POST /api/v1/auth/* ───────────────────────────────────────
  static const String register       = '/auth/register';
  static const String login          = '/auth/login';
  static const String logout         = '/auth/logout';
  static const String otpSend        = '/auth/otp/send';
  static const String otpVerify      = '/auth/otp/verify';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword  = '/auth/reset-password';

  // ── Guest Profile  /api/v1/guest/* ────────────────────────────────────────
  static const String guestProfile    = '/guest/profile';
  static const String changePassword  = '/guest/change-password';

  // ── Hotels  /api/v1/hotels/* ──────────────────────────────────────────────
  static const String hotelsFeatured = '/hotels/featured';
  static const String hotelsSearch   = '/hotels/search';
  static String hotelDetail(int id)         => '/hotels/$id';
  static String hotelAvailability(int id)   => '/hotels/$id/availability';
  static String hotelReviews(int id)        => '/hotels/$id/reviews';
  static String hotelPaymentMethods(int id) => '/hotels/$id/payment-methods';

  // ── Bookings  /api/v1/bookings/* ─────────────────────────────────────────
  static const String bookings        = '/bookings';
  static String bookingDetail(int id) => '/bookings/$id';
  static String bookingCancel(int id) => '/bookings/$id/cancel';

  // ── Payments  /api/v1/payments/* ─────────────────────────────────────────
  static const String paymentInitiate            = '/payments/initiate';
  static String paymentStatus(int id)            => '/payments/$id/status';
  static String paymentSubmit(int id)            => '/payments/$id/submit';
  static String paymentRetry(int bookingId)      => '/payments/retry/$bookingId';

  // ── Wishlist  /api/v1/wishlist/* ─────────────────────────────────────────
  static const String wishlist                   = '/wishlist';
  static String wishlistRemove(int hotelId)      => '/wishlist/$hotelId';

  // ── Notifications  /api/v1/notifications/* ───────────────────────────────
  static const String notifications              = '/notifications';
  static String notificationRead(int id)         => '/notifications/$id/read';
  static const String notificationsReadAll       = '/notifications/read-all';

  // ── Public cities  /api/public/cities ────────────────────────────────────
  // NOTE: This is outside /api/v1 — use absolute URL
  static String get citiesUrl => '$publicBase/public/cities';

  // ── Admin login  POST /api/admin/login ───────────────────────────────────
  static const String adminLogin = '/login';   // relative to adminBase

  // ── Payment method metadata ───────────────────────────────────────────────
  static const List<Map<String, dynamic>> paymentMethodMeta = [
    {'key': 'telebirr',    'label': 'Telebirr',           'emoji': '📱', 'color': 0xFF059669},
    {'key': 'cbe_birr',   'label': 'CBE Birr',            'emoji': '🏦', 'color': 0xFFD97706},
    {'key': 'chapa',       'label': 'Chapa',               'emoji': '🔵', 'color': 0xFF2563EB},
    {'key': 'awash_bank',  'label': 'Awash Bank',          'emoji': '🏦', 'color': 0xFF7C3AED},
    {'key': 'abyssinia',   'label': 'Bank of Abyssinia',   'emoji': '🏦', 'color': 0xFFDB2777},
    {'key': 'dashen',      'label': 'Dashen Bank',         'emoji': '🏦', 'color': 0xFF0D9488},
    {'key': 'oromia_coop', 'label': 'Oromia Bank',         'emoji': '🏦', 'color': 0xFFEA580C},
    {'key': 'united',      'label': 'United Bank',         'emoji': '🏦', 'color': 0xFF4F46E5},
    {'key': 'nib',         'label': 'NIB International',   'emoji': '🏦', 'color': 0xFF65A30D},
    {'key': 'wegagen',     'label': 'Wegagen Bank',        'emoji': '🏦', 'color': 0xFF0891B2},
    {'key': 'bunna',       'label': 'Bunna Bank',          'emoji': '🏦', 'color': 0xFFA21CAF},
    {'key': 'cooperative', 'label': 'Cooperative Bank',    'emoji': '🏦', 'color': 0xFF047857},
    {'key': 'bank_transfer','label': 'Bank Transfer',      'emoji': '🏦', 'color': 0xFF374151},
    {'key': 'card',        'label': 'Card Payment',        'emoji': '💳', 'color': 0xFF1D4ED8},
    {'key': 'mobile_money','label': 'Mobile Money',        'emoji': '📲', 'color': 0xFF059669},
  ];

  static Map<String, dynamic> paymentMeta(String key) =>
      paymentMethodMeta.firstWhere(
        (m) => m['key'] == key,
        orElse: () => {'key': key, 'label': key, 'emoji': '🏦', 'color': 0xFF374151},
      );
}
