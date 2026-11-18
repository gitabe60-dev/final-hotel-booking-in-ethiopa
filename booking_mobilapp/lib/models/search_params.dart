class HotelSearchParams {
  final String? name;
  final String? city;
  final String? type;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String sort;
  final String dir;
  final int limit;
  final int offset;

  const HotelSearchParams({
    this.name,
    this.city,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.sort = 'rating',
    this.dir = 'desc',
    this.limit = 12,
    this.offset = 0,
  });

  Map<String, dynamic> toQueryParams() {
    final p = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (name != null && name!.isNotEmpty) p['name'] = name;
    if (city != null && city!.isNotEmpty) p['city'] = city;
    if (type != null && type!.isNotEmpty) p['type'] = type;
    if (minPrice != null) p['min_price'] = minPrice;
    if (maxPrice != null) p['max_price'] = maxPrice;
    if (minRating != null) p['min_rating'] = minRating;

    // Handle sort aliases same as web
    String s = sort, d = dir;
    if (sort == 'price_asc')  { s = 'price_per_night'; d = 'asc'; }
    if (sort == 'price_desc') { s = 'price_per_night'; d = 'desc'; }
    p['sort'] = s;
    p['dir']  = d;

    return p;
  }

  HotelSearchParams copyWith({
    String? name,
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sort,
    String? dir,
    int? limit,
    int? offset,
    bool clearName = false,
    bool clearCity = false,
    bool clearType = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinRating = false,
  }) =>
      HotelSearchParams(
        name: clearName ? null : (name ?? this.name),
        city: clearCity ? null : (city ?? this.city),
        type: clearType ? null : (type ?? this.type),
        minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
        maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
        minRating: clearMinRating ? null : (minRating ?? this.minRating),
        sort: sort ?? this.sort,
        dir: dir ?? this.dir,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
      );

  bool get hasFilters =>
      (city != null && city!.isNotEmpty) ||
      (name != null && name!.isNotEmpty) ||
      (type != null && type!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      minRating != null;
}
