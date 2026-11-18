import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  Map<String, int> _counts = {};
  bool    _loading    = false;
  bool    _submitting = false;
  String? _error;
  int?    _lastBookingId;
  int?    _lastPaymentId;

  List<Booking>    get bookings       => _bookings;
  Map<String, int> get counts         => _counts;
  bool             get loading        => _loading;
  bool             get submitting     => _submitting;
  String?          get error          => _error;
  int?             get lastBookingId  => _lastBookingId;
  int?             get lastPaymentId  => _lastPaymentId;

  // ── Load my bookings ───────────────────────────────────────────────────────
  Future<void> loadMyBookings() async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      final res  = await ApiService.instance.get(ApiEndpoints.myBookings);
      // Response: { "data": { "bookings": [...], "counts": { pending: N, ... } } }
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = data['bookings'] as List<dynamic>? ?? [];

      _bookings = list
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();

      final c = data['counts'] as Map<String, dynamic>? ?? {};
      _counts = {
        'pending':   c['pending']   as int? ?? 0,
        'confirmed': c['confirmed'] as int? ?? 0,
        'completed': c['completed'] as int? ?? 0,
        'cancelled': c['cancelled'] as int? ?? 0,
      };
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load bookings.';
    }
    _loading = false;
    notifyListeners();
  }

  // ── Create booking ─────────────────────────────────────────────────────────
  Future<bool> createBooking({
    required int hotelId,
    int? roomTypeId,
    required String checkIn,
    required String checkOut,
    required int adults,
    int children = 0,
    int rooms    = 1,
    required String paymentMethod,
    String? specialRequests,
    required String guestFullName,
    String? guestEmail,
    String? guestPhone,
    String? nationalIdFront,
    String? nationalIdBack,
  }) async {
    _submitting    = true;
    _error         = null;
    _lastBookingId = null;
    _lastPaymentId = null;
    notifyListeners();

    try {
      // Step 1 — Create booking
      // POST /bookings
      final bRes = await ApiService.instance.post(
        ApiEndpoints.bookings,
        data: {
          'hotel_id':        hotelId,
          if (roomTypeId != null) 'room_type_id': roomTypeId,
          'check_in':        checkIn,
          'check_out':       checkOut,
          'adults':          adults,
          'children':        children,
          'rooms':           rooms,
          'payment_method':  paymentMethod,
          if (specialRequests != null && specialRequests.isNotEmpty)
            'special_requests': specialRequests,
          'guest_full_name': guestFullName,
          if (guestEmail != null && guestEmail.isNotEmpty)
            'guest_email':  guestEmail,
          if (guestPhone != null && guestPhone.isNotEmpty)
            'guest_phone':  guestPhone,
          if (nationalIdFront != null && nationalIdFront.isNotEmpty)
            'national_id_front': nationalIdFront,
          if (nationalIdBack  != null && nationalIdBack.isNotEmpty)
            'national_id_back':  nationalIdBack,
        },
      );

      // Response: { "data": { "id": N, ... booking fields } }
      final bookingData = bRes['data'];
      final bookingId   = bookingData is Map ? bookingData['id'] as int? : null;

      if (bookingId == null) throw ApiException('Booking creation failed.');
      _lastBookingId = bookingId;

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _submitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  // ── Initiate payment ───────────────────────────────────────────────────────
  // POST /payments/initiate  { "booking_id": N, "method": "telebirr" }
  Future<int?> initiatePayment(int bookingId, String method) async {
    try {
      final res = await ApiService.instance.post(
        ApiEndpoints.paymentInitiate,
        data: {'booking_id': bookingId, 'method': method},
      );
      final data      = res['data'] as Map<String, dynamic>? ?? {};
      // Backend returns: { "payment_id": N, "amount": N, "currency": "ETB", "method": "..." }
      final paymentId = data['payment_id'] as int?
          ?? data['id']         as int?
          ?? data['paymentId']  as int?;
      _lastPaymentId  = paymentId;
      notifyListeners();
      return paymentId;
    } on ApiException {
      return null;
    }
  }

  // ── Submit payment proof ───────────────────────────────────────────────────
  // POST /payments/:id/submit  { "transaction_id": "...", "screenshot_url": "..." }
  Future<bool> submitPayment(
      int paymentId, String transactionId, String screenshotUrl) async {
    try {
      await ApiService.instance.post(
        ApiEndpoints.paymentSubmit(paymentId),
        data: {
          'transaction_id': transactionId,
          'screenshot_url': screenshotUrl,
        },
      );
      _submitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error      = e.message;
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  void finishSubmitting() {
    _submitting = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
