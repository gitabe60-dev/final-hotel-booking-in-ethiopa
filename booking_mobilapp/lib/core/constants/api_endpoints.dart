/// api_endpoints.dart
/// Re-exports from ApiConstants so all existing imports keep working.
/// The single source of truth is api_constants.dart.
library;

import 'api_constants.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get host         => ApiConstants.host;
  static String get baseUrl      => ApiConstants.baseUrl;
  static String get adminBaseUrl => ApiConstants.adminBase;

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String register        = ApiConstants.register;
  static const String login           = ApiConstants.login;
  static const String logout          = ApiConstants.logout;
  static const String otpSend         = ApiConstants.otpSend;
  static const String otpVerify       = ApiConstants.otpVerify;
  static const String forgotPassword  = ApiConstants.forgotPassword;
  static const String resetPassword   = ApiConstants.resetPassword;

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminLogin = ApiConstants.adminLogin;

  // ── Hotels ────────────────────────────────────────────────────────────────
  static const String hotelsFeatured = ApiConstants.hotelsFeatured;
  static const String hotels         = ApiConstants.hotelsSearch;
  static String get citiesAbsolute   => ApiConstants.citiesUrl;
  static String hotelById(int id)           => ApiConstants.hotelDetail(id);
  static String hotelAvailability(int id)   => ApiConstants.hotelAvailability(id);
  static String hotelPaymentMethods(int id) => ApiConstants.hotelPaymentMethods(id);
  static String hotelReviews(int id)        => ApiConstants.hotelReviews(id);

  // ── Bookings ──────────────────────────────────────────────────────────────
  static const String bookings   = ApiConstants.bookings;
  static const String myBookings = ApiConstants.bookings;
  static String bookingById(int id) => ApiConstants.bookingDetail(id);
  static String cancelBooking(int id) => ApiConstants.bookingCancel(id);

  // ── Payments ──────────────────────────────────────────────────────────────
  static const String paymentInitiate        = ApiConstants.paymentInitiate;
  static String paymentStatus(int id)        => ApiConstants.paymentStatus(id);
  static String paymentSubmit(int id)        => ApiConstants.paymentSubmit(id);
  static String paymentRetry(int bookingId)  => ApiConstants.paymentRetry(bookingId);

  // ── Wishlist ──────────────────────────────────────────────────────────────
  static const String wishlist               = ApiConstants.wishlist;
  static const String wishlistToggle         = ApiConstants.wishlist;
  static String wishlistRemove(int hotelId)  => ApiConstants.wishlistRemove(hotelId);

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications          = ApiConstants.notifications;
  static String notificationRead(int id)     => ApiConstants.notificationRead(id);
  static const String notificationsReadAll   = ApiConstants.notificationsReadAll;

  // ── Guest / Profile ───────────────────────────────────────────────────────
  static const String guestProfile           = ApiConstants.guestProfile;
  static const String guestChangePassword    = ApiConstants.changePassword;
}
