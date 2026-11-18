import 'package:flutter/foundation.dart';
import '../models/hotel.dart';
import '../models/review.dart';
import '../models/search_params.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class HotelProvider extends ChangeNotifier {
  // ── Home / All Hotels ─────────────────────────────────────────────────────
  List<Hotel> _featured   = [];
  List<Hotel> _allHotels  = [];  // ALL hotels shown on home page
  List<City>  _cities     = [];  // Registered cities from backend
  bool        _homeLoading = false;
  String?     _homeError;

  List<Hotel> get featured    => _featured;
  List<Hotel> get allHotels   => _allHotels;
  List<City>  get cities      => _cities;
  bool        get homeLoading => _homeLoading;
  String?     get homeError   => _homeError;

  // ── Search / Hotel List ───────────────────────────────────────────────────
  List<Hotel>       _hotels      = [];
  int               _total       = 0;
  bool              _listLoading = false;
  HotelSearchParams _params      = const HotelSearchParams(limit: 20);

  List<Hotel>       get hotels      => _hotels;
  int               get total       => _total;
  bool              get listLoading => _listLoading;
  HotelSearchParams get params      => _params;

  // ── Hotel Detail ──────────────────────────────────────────────────────────
  Hotel?              _hotel;
  List<Room>          _rooms         = [];
  List<Review>        _reviews       = [];
  List<PaymentMethod> _payMethods    = [];
  bool                _detailLoading = false;
  bool                _roomsLoading  = false;
  String?             _managerPhone;
  String?             _managerName;
  String?             _managerEmail;

  Hotel?              get hotel         => _hotel;
  List<Room>          get rooms         => _rooms;
  List<Review>        get reviews       => _reviews;
  List<PaymentMethod> get payMethods    => _payMethods;
  bool                get detailLoading => _detailLoading;
  bool                get roomsLoading  => _roomsLoading;
  String?             get managerPhone  => _managerPhone;
  String?             get managerName   => _managerName;
  String?             get managerEmail  => _managerEmail;

  List<Room> get availableRooms => _rooms.where((r) => r.canBook).toList();
  List<Room> get occupiedRooms  => _rooms.where((r) => !r.canBook).toList();

  // ── Load Home Page ─────────────────────────────────────────────────────────

  // 5-minute in-memory cache — avoids re-fetching on every tab switch
  DateTime? _lastHomeLoad;
  static const _cacheTtl = Duration(minutes: 5);

  bool get _cacheValid =>
      _lastHomeLoad != null &&
      DateTime.now().difference(_lastHomeLoad!) < _cacheTtl;

  Future<void> loadHome({bool forceRefresh = false}) async {
    // Return immediately if data is fresh and not force-refreshed
    if (!forceRefresh && _cacheValid && _allHotels.isNotEmpty) return;

    _homeLoading = true;
    _homeError   = null;
    notifyListeners();

    try {
      // Run all 3 in parallel; a single failure won't block the others
      final hotelsFeaturedFuture = ApiService.instance
          .get(ApiEndpoints.hotelsFeatured)
          .catchError((_) => <String, dynamic>{'data': []});

      // Fetch only 50 hotels — enough for home page, much faster than 100
      final hotelsAllFuture = ApiService.instance
          .get(ApiEndpoints.hotels, params: {
            'limit': 50, 'offset': 0, 'sort': 'rating', 'dir': 'desc',
          })
          .catchError((_) => <String, dynamic>{'data': {'hotels': [], 'total': 0}});

      final citiesFuture = _fetchCities()
          .catchError((_) => <String, dynamic>{'data': []});

      final results = await Future.wait([
        hotelsFeaturedFuture,
        hotelsAllFuture,
        citiesFuture,
      ]);

      _featured  = _hotelList(results[0]['data']);
      final searchData = results[1]['data'];
      if (searchData is Map) {
        _allHotels = _hotelList(searchData['hotels']);
      } else {
        _allHotels = _hotelList(searchData);
      }
      _cities = _cityList(results[2]['data']);

      // Update cache timestamp on success
      _lastHomeLoad = DateTime.now();
    } catch (e) {
      _homeError = e.toString();
    }

    _homeLoading = false;
    notifyListeners();
  }

  // ── Search Hotels (Hotel List Screen) ─────────────────────────────────────
  Future<void> search({HotelSearchParams? params, int? offset}) async {
    if (params != null) {
      _params = params.copyWith(offset: offset ?? 0);
    } else if (offset != null) {
      _params = _params.copyWith(offset: offset);
    }

    _listLoading = true;
    notifyListeners();

    try {
      final qp = _params.toQueryParams();
      final res = await ApiService.instance.get(ApiEndpoints.hotels, params: qp);
      final data = res['data'];
      if (data is Map) {
        _hotels = _hotelList(data['hotels']);
        _total  = data['total'] as int? ?? _hotels.length;
      } else {
        _hotels = _hotelList(data);
        _total  = _hotels.length;
      }
    } catch (_) {
      _hotels = [];
      _total  = 0;
    }

    _listLoading = false;
    notifyListeners();
  }

  // ── Load Hotel Detail ─────────────────────────────────────────────────────
  Future<void> loadHotel(int id) async {
    // Skip if we already have this hotel loaded (avoids flicker on back-nav)
    if (_hotel?.id == id && !_detailLoading) {
      unawaited(_loadReviews(id));
      unawaited(_loadPaymentMethods(id));
      return;
    }
    _detailLoading = true;
    _hotel         = null;
    _rooms         = [];
    _reviews       = [];
    _payMethods    = [];
    _managerPhone  = null;
    _managerName   = null;
    _managerEmail  = null;
    notifyListeners();

    try {
      final res  = await ApiService.instance.get(ApiEndpoints.hotelById(id));
      final data = res['data'];

      if (data is Map) {
        // Shape: { "hotel": {...}, "rooms": [...] }
        final hotelMap = data['hotel'] as Map<String, dynamic>?;
        _hotel = Hotel.fromJson(hotelMap ?? (data as Map<String, dynamic>));

        final rawRooms = data['rooms'] as List<dynamic>? ?? [];
        _rooms = rawRooms
            .map((e) => Room.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    _detailLoading = false;
    notifyListeners();

    // Load in parallel (non-blocking UI)
    unawaited(_loadReviews(id));
    unawaited(_loadPaymentMethods(id));
  }

  // ── Load Availability for selected dates ──────────────────────────────────
  Future<void> loadAvailability(
      int hotelId, String checkIn, String checkOut) async {
    _roomsLoading = true;
    _rooms        = [];
    notifyListeners();

    try {
      final res = await ApiService.instance.get(
        ApiEndpoints.hotelAvailability(hotelId),
        params: {'check_in': checkIn, 'check_out': checkOut},
      );
      final data = res['data'];
      List<dynamic> list = [];
      if (data is Map) {
        list = data['rooms'] as List<dynamic>? ?? [];
      } else if (data is List) {
        list = data;
      }
      _rooms = list
          .map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _rooms = [];
    }

    _roomsLoading = false;
    notifyListeners();
  }

  // ── Post Review ───────────────────────────────────────────────────────────
  Future<bool> postReview(int hotelId, int rating, String comment) async {
    try {
      await ApiService.instance.post(
        ApiEndpoints.hotelReviews(hotelId),
        data: {'rating': rating, 'comment': comment},
      );
      await _loadReviews(hotelId);
      return true;
    } on ApiException {
      return false;
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────
  Future<void> _loadReviews(int id) async {
    try {
      final res = await ApiService.instance
          .get(ApiEndpoints.hotelReviews(id), params: {'limit': 20, 'offset': 0});
      final data = res['data'];
      List<dynamic> list = [];
      if (data is Map) {
        list = data['reviews'] as List<dynamic>? ?? [];
      } else if (data is List) {
        list = data;
      }
      _reviews = list
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadPaymentMethods(int id) async {
    try {
      final res = await ApiService.instance
          .get(ApiEndpoints.hotelPaymentMethods(id));
      final data = res['data'];

      List<dynamic> list = [];
      if (data is Map) {
        list          = data['methods'] as List<dynamic>? ?? [];
        _managerPhone = data['manager_phone'] as String?;
        _managerName  = data['manager_name']  as String?;
        _managerEmail = data['manager_email'] as String?;
      } else if (data is List) {
        list = data;
      }

      _payMethods = list
          .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  List<Hotel> _hotelList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Hotel.fromJson)
          .toList();
    }
    return [];
  }

  List<City> _cityList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(City.fromJson)
          .toList();
    }
    return [];
  }
}

// ignore: avoid_void_async
void unawaited(Future<void> future) {}

// ── Standalone cities fetcher (uses absolute URL outside /api/v1) ─────────────
Future<Map<String, dynamic>> _fetchCities() async {
  try {
    final res = await ApiService.instance.dio.get(
      ApiEndpoints.citiesAbsolute,
    );
    return res.data as Map<String, dynamic>;
  } catch (_) {
    return {'data': []};
  }
}
