class Review {
  final int id;
  final int hotelId;
  final int rating;
  final String comment;
  final String userName;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.hotelId,
    required this.rating,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: j['id'] as int,
        hotelId: j['hotel_id'] as int? ?? 0,
        rating: j['rating'] as int? ?? 0,
        comment: j['comment'] as String? ?? '',
        userName: j['user_name'] as String? ?? 'Guest',
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
