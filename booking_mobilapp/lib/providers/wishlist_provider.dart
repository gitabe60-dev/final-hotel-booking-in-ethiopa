import 'package:flutter/foundation.dart';
import '../models/hotel.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class WishlistProvider extends ChangeNotifier {
  List<Hotel> _items   = [];
  bool        _loading = false;
  String?     _error;

  List<Hotel> get items   => _items;
  bool        get loading => _loading;
  String?     get error   => _error;

  bool isWishlisted(int hotelId) => _items.any((h) => h.id == hotelId);

  // ── Load ──────────────────────────────────────────────────────────────────
  // GET /wishlist → { "data": [ { id, hotel_id, hotel_name, city, rating, price_per_night, image, added_at } ] }
  Future<void> load() async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      final res  = await ApiService.instance.get(ApiEndpoints.wishlist);
      final list = res['data'] as List<dynamic>? ?? [];
      _items = list.map((e) {
        final m = e as Map<String, dynamic>;
        // Wishlist items have hotel_id + flat hotel fields — map to Hotel
        return Hotel(
          id:            _i(m['hotel_id'] ?? m['id']),
          name:          m['hotel_name']      as String? ?? '',
          city:          m['city']            as String? ?? '',
          address:       m['address']         as String? ?? '',
          rating:        _d(m['rating']),
          reviewCount:   _i(m['review_count']),
          pricePerNight: _d(m['price_per_night'] ?? m['price']),
          images:        m['image'] != null ? [m['image'] as String] : [],
        );
      }).toList();
    } on ApiException catch (e) {
      _error = e.message;
    }
    _loading = false;
    notifyListeners();
  }

  // ── Toggle ────────────────────────────────────────────────────────────────
  // POST /wishlist  { "hotel_id": N }
  // Response: { "data": { "action": "added"/"removed", "wishlisted": bool, "hotel_id": N } }
  Future<bool?> toggle(Hotel hotel) async {
    final wasIn = isWishlisted(hotel.id);
    // Optimistic
    if (wasIn) {
      _items.removeWhere((h) => h.id == hotel.id);
    } else {
      _items.add(hotel);
    }
    notifyListeners();

    try {
      final res    = await ApiService.instance.post(
        ApiEndpoints.wishlistToggle,
        data: {'hotel_id': hotel.id},
      );
      final action = res['data']?['action'] as String?;
      final added  = action == 'added';

      // Sync with server
      if (added && !isWishlisted(hotel.id)) _items.add(hotel);
      if (!added && isWishlisted(hotel.id)) {
        _items.removeWhere((h) => h.id == hotel.id);
      }
      notifyListeners();
      return added;
    } on ApiException {
      // Revert on error
      if (wasIn && !isWishlisted(hotel.id)) _items.add(hotel);
      if (!wasIn && isWishlisted(hotel.id)) {
        _items.removeWhere((h) => h.id == hotel.id);
      }
      notifyListeners();
      return null;
    }
  }

  // ── Remove directly ────────────────────────────────────────────────────────
  // DELETE /wishlist/:hotel_id
  Future<bool> remove(int hotelId) async {
    _items.removeWhere((h) => h.id == hotelId); // optimistic
    notifyListeners();
    try {
      await ApiService.instance.delete(ApiEndpoints.wishlistRemove(hotelId));
      return true;
    } on ApiException {
      return false;
    }
  }

  void clear() {
    _items = [];
    notifyListeners();
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
