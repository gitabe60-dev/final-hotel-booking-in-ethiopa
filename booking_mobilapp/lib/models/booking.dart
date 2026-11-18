class Booking {
  final int id;
  final int userId;
  final int hotelId;
  final String hotelName;
  final String? hotelCity;
  final String? hotelImage;
  final int? roomTypeId;
  final String? roomTypeName;
  final String checkIn;
  final String checkOut;
  final int adults;
  final int children;
  final int rooms;
  final double totalPrice;
  final String paymentMethod;
  final String status;
  final String? specialRequests;
  final String guestFullName;
  final String? guestEmail;
  final String? guestPhone;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    this.userId = 0,
    required this.hotelId,
    required this.hotelName,
    this.hotelCity,
    this.hotelImage,
    this.roomTypeId,
    this.roomTypeName,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    this.children = 0,
    required this.rooms,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    this.specialRequests,
    required this.guestFullName,
    this.guestEmail,
    this.guestPhone,
    this.createdAt,
  });

  int get nights {
    try {
      final diff =
          DateTime.parse(checkOut).difference(DateTime.parse(checkIn)).inDays;
      return diff < 1 ? 1 : diff;
    } catch (_) {
      return 1;
    }
  }

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: _i(j['id']),
        userId: _i(j['user_id']),
        hotelId: _i(j['hotel_id']),
        hotelName: j['hotel_name'] as String? ?? '',
        hotelCity: j['hotel_city'] as String?,
        hotelImage: j['hotel_image'] as String?,
        roomTypeId: j['room_type_id'] != null ? _i(j['room_type_id']) : null,
        roomTypeName: j['room_type_name'] as String?,
        checkIn: j['check_in'] as String? ?? '',
        checkOut: j['check_out'] as String? ?? '',
        adults: _i(j['adults']),
        children: _i(j['children']),
        rooms: _i(j['rooms']),
        totalPrice: _d(j['total_price']),
        paymentMethod: j['payment_method'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
        specialRequests: j['special_requests'] as String?,
        guestFullName: j['guest_full_name'] as String? ?? '',
        guestEmail: j['guest_email'] as String?,
        guestPhone: j['guest_phone'] as String?,
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
}
