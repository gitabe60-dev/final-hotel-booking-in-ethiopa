class Hotel {
  final int id;
  final String name;
  final String? description;
  final String city;
  final String address;
  final String? type;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final bool isFeatured;
  final bool isActive;
  final List<String> images;
  final List<String> amenities;
  final double? latitude;
  final double? longitude;
  final bool isWishlisted;
  final DateTime? createdAt;

  const Hotel({
    required this.id,
    required this.name,
    this.description,
    required this.city,
    required this.address,
    this.type,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    this.isFeatured = false,
    this.isActive = true,
    this.images = const [],
    this.amenities = const [],
    this.latitude,
    this.longitude,
    this.isWishlisted = false,
    this.createdAt,
  });

  String? get thumbnailUrl => images.isNotEmpty ? images.first : null;

  factory Hotel.fromJson(Map<String, dynamic> j) => Hotel(
        id: _i(j['id']),
        name: j['name'] as String? ?? '',
        description: j['description'] as String?,
        city: j['city'] as String? ?? '',
        address: j['address'] as String? ?? '',
        type: j['type'] as String?,
        rating: _d(j['rating']),
        reviewCount: _i(j['review_count']),
        pricePerNight: _d(j['price_per_night']),
        isFeatured: j['is_featured'] as bool? ?? false,
        isActive: j['is_active'] as bool? ?? true,
        images: _strList(j['images']),
        amenities: _strList(j['amenities']),
        latitude: j['latitude'] != null ? _d(j['latitude']) : null,
        longitude: j['longitude'] != null ? _d(j['longitude']) : null,
        isWishlisted: j['is_wishlisted'] as bool? ?? false,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );

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

  static List<String> _strList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}

// ── Room ──────────────────────────────────────────────────────────────────────
class Room {
  final int id;
  final int hotelId;
  final String name;
  final String bedType;
  final int maxGuests;
  final double pricePerNight;
  final double sizeSqm;
  final String? imageUrl;
  final bool isAvailable;
  final bool isOccupied;
  final String roomStatus;
  final String? occupiedUntil;
  final String? occupiedBy;

  const Room({
    required this.id,
    this.hotelId = 0,
    required this.name,
    required this.bedType,
    required this.maxGuests,
    required this.pricePerNight,
    this.sizeSqm = 0,
    this.imageUrl,
    this.isAvailable = true,
    this.isOccupied = false,
    this.roomStatus = 'available',
    this.occupiedUntil,
    this.occupiedBy,
  });

  bool get canBook => !isOccupied && roomStatus == 'available';

  factory Room.fromJson(Map<String, dynamic> j) => Room(
        id: Hotel._i(j['id']),
        hotelId: Hotel._i(j['hotel_id']),
        name: j['name'] as String? ?? '',
        bedType: j['bed_type'] as String? ?? '',
        maxGuests: Hotel._i(j['max_guests']),
        pricePerNight: Hotel._d(j['price_per_night']),
        sizeSqm: Hotel._d(j['size_sqm']),
        imageUrl: j['image_url'] as String?,
        isAvailable: j['is_available'] as bool? ?? true,
        isOccupied: j['is_occupied'] as bool? ?? false,
        roomStatus: j['room_status'] as String? ?? 'available',
        occupiedUntil: j['occupied_until'] as String?,
        occupiedBy: j['occupied_by'] as String?,
      );
}

// ── City ──────────────────────────────────────────────────────────────────────
class City {
  final int id;
  final String name;
  final String? region;

  const City({required this.id, required this.name, this.region});

  factory City.fromJson(Map<String, dynamic> j) => City(
        id: Hotel._i(j['id']),
        name: j['name'] as String? ?? '',
        region: j['region'] as String?,
      );
}

// ── Payment Method ────────────────────────────────────────────────────────────
class PaymentMethod {
  final int id;
  final int hotelId;
  final String method;
  final String? accountName;
  final String? accountNumber;
  final String? phoneNumber;
  final String? instructions;
  final bool isActive;

  const PaymentMethod({
    required this.id,
    this.hotelId = 0,
    required this.method,
    this.accountName,
    this.accountNumber,
    this.phoneNumber,
    this.instructions,
    this.isActive = true,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> j) => PaymentMethod(
        id: Hotel._i(j['id']),
        hotelId: Hotel._i(j['hotel_id']),
        method: j['method'] as String? ?? '',
        accountName: j['account_name'] as String?,
        accountNumber: j['account_number'] as String?,
        phoneNumber: j['phone_number'] as String?,
        instructions: j['instructions'] as String?,
        isActive: j['is_active'] as bool? ?? true,
      );
}
