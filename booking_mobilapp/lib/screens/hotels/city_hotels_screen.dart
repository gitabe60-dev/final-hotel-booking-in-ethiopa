import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_images.dart';
import '../../core/services/api_service.dart';
import '../../models/hotel.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/local_or_network_image.dart';
import '../../widgets/star_rating.dart';
import '../auth/login_screen.dart';
import 'hotel_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CITY HOTELS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CityHotelsScreen extends StatefulWidget {
  final String  cityName;
  final String? cityRegion;
  final String? cityImageUrl;

  const CityHotelsScreen({
    super.key,
    required this.cityName,
    this.cityRegion,
    this.cityImageUrl,
  });

  @override
  State<CityHotelsScreen> createState() => _CityHotelsScreenState();
}

class _CityHotelsScreenState extends State<CityHotelsScreen> {
  List<Hotel> _hotels  = [];
  int         _total   = 0;
  bool        _loading = true;
  String?     _error;
  String      _sort   = 'rating';
  String      _dir    = 'desc';
  String?     _type;
  int         _offset = 0;
  static const int _limit = 20;

  static const _sortOptions = [
    {'label': 'Best Rating',  'sort': 'rating',          'dir': 'desc'},
    {'label': 'Price Low',    'sort': 'price_per_night',  'dir': 'asc'},
    {'label': 'Price High',   'sort': 'price_per_night',  'dir': 'desc'},
    {'label': 'Name A–Z',     'sort': 'name',             'dir': 'asc'},
  ];
  static const _types = ['hotel', 'resort', 'boutique', 'lodge'];

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch({int offset = 0}) async {
    setState(() { _loading = true; _error = null; _offset = offset; });
    try {
      final params = <String, dynamic>{
        'city': widget.cityName,
        'limit': _limit, 'offset': offset,
        'sort': _sort, 'dir': _dir,
      };
      if (_type != null) params['type'] = _type;
      final res  = await ApiService.instance.get(ApiEndpoints.hotels, params: params);
      final data = res['data'];
      if (data is Map) {
        final raw = data['hotels'] as List<dynamic>? ?? [];
        setState(() {
          _hotels = raw.map((e) => Hotel.fromJson(e as Map<String, dynamic>)).toList();
          _total  = data['total'] as int? ?? _hotels.length;
        });
      }
    } catch (e) { setState(() => _error = e.toString()); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _total == 0 ? 1 : (_total / _limit).ceil();
    final page  = _offset ~/ _limit + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            leading: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [const LangToggleDark(), const SizedBox(width: 4)],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _CityHeroHeader(
                city:        widget.cityName,
                region:      widget.cityRegion,
                totalHotels: _total,
              ),
            ),
          ),
        ],
        body: Column(children: [
          // ── Filter bar ───────────────────────────────────────────────────
          _FilterBar(
            total:    _total,
            page:     page,
            pages:    pages,
            loading:  _loading,
            city:     widget.cityName,
            sort:     _sort,
            dir:      _dir,
            type:     _type,
            sortOptions: _sortOptions,
            types:    _types,
            onSort:   (s, d) { setState(() { _sort = s; _dir = d; }); _fetch(); },
            onType:   (t)    { setState(() => _type = t); _fetch(); },
          ),

          // ── Hotel list ───────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: AppSpinner(size: SpinnerSize.large))
                : _error != null
                    ? _ErrorView(error: _error!, onRetry: _fetch)
                    : _hotels.isEmpty
                        ? _EmptyState(city: widget.cityName)
                        : RefreshIndicator(
                            onRefresh: () => _fetch(offset: 0),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                              itemCount: _hotels.length,
                              itemBuilder: (ctx, i) => _PremiumHotelTile(
                                hotel: _hotels[i],
                                index: i,
                                onTap: () => Navigator.push(ctx,
                                    MaterialPageRoute(builder: (_) =>
                                        HotelDetailScreen(hotelId: _hotels[i].id))),
                              ),
                            ),
                          ),
          ),

          // ── Pagination ───────────────────────────────────────────────────
          if (!_loading && _total > _limit)
            _PaginationBar(
              page: page, pages: pages,
              onPrev: _offset > 0 ? () => _fetch(offset: _offset - _limit) : null,
              onNext: _offset + _limit < _total ? () => _fetch(offset: _offset + _limit) : null,
            ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM HOTEL TILE  — full info card with animation
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumHotelTile extends StatefulWidget {
  final Hotel hotel;
  final int index;
  final VoidCallback onTap;
  const _PremiumHotelTile({required this.hotel, required this.index, required this.onTap});

  @override
  State<_PremiumHotelTile> createState() => _PremiumHotelTileState();
}

class _PremiumHotelTileState extends State<_PremiumHotelTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 450));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  Future<void> _openMaps() async {
    final h = widget.hotel;
    final Uri uri;
    if (h.latitude != null && h.longitude != null) {
      final q = Uri.encodeComponent(h.name);
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'
          '&center=${h.latitude},${h.longitude}');
    } else {
      final q = Uri.encodeComponent('${h.name}, ${h.address}, ${h.city}, Ethiopia');
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h        = widget.hotel;
    final wl       = context.watch<WishlistProvider>();
    final isAuth   = context.watch<AuthProvider>().isAuthenticated;
    final isWished = wl.isWishlisted(h.id);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08),
                    blurRadius: 18, offset: const Offset(0, 6)),
                BoxShadow(color: Colors.black.withOpacity(0.04),
                    blurRadius: 4),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Full-width image (200px tall) ───────────────────────────
              SizedBox(
                height: 200,
                width:  double.infinity,
                child: Stack(fit: StackFit.expand, children: [
                  LocalOrNetworkImage(
                    localPath:  AppImages.hotelCover(h.name),
                    networkUrl: h.thumbnailUrl,
                    fit:        BoxFit.cover,
                    errorWidget: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryDark,
                              AppColors.primary.withOpacity(0.7)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        const Icon(Icons.hotel_rounded,
                            color: Colors.white54, size: 52),
                        const SizedBox(height: 8),
                        Text(h.name, textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70,
                                fontSize: 14, fontWeight: FontWeight.w600),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                  ),

                  // Gradient
                  Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                      stops: const [0.4, 1.0],
                    ),
                  ))),

                  // Type badge top-left
                  if (h.type != null)
                    Positioned(top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(h.type!.toUpperCase(),
                            style: const TextStyle(color: Colors.white,
                                fontSize: 10, fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      )),

                  // Featured badge
                  if (h.isFeatured)
                    Positioned(top: h.type != null ? 44 : 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('Featured', style: TextStyle(
                              color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.w700)),
                        ]),
                      )),

                  // Wishlist button top-right
                  Positioned(top: 12, right: 12,
                    child: GestureDetector(
                      onTap: () async {
                        if (!isAuth) {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                          return;
                        }
                        await context.read<WishlistProvider>().toggle(h);
                      },
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8)]),
                        child: Icon(
                          isWished
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isWished ? Colors.red : AppColors.textHint,
                          size: 19,
                        ),
                      ),
                    )),

                  // Price bottom-left
                  Positioned(bottom: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10)),
                      child: RichText(text: TextSpan(children: [
                        TextSpan(text: 'ETB ${_fmt(h.pricePerNight)}',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 15, fontWeight: FontWeight.w900)),
                        const TextSpan(text: '/night',
                            style: TextStyle(color: Colors.white70,
                                fontSize: 11)),
                      ])),
                    )),

                  // Rating bottom-right
                  Positioned(bottom: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.star, size: 14),
                        const SizedBox(width: 3),
                        Text(h.rating.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white,
                                fontSize: 13, fontWeight: FontWeight.w800)),
                        Text(' (${h.reviewCount})',
                            style: const TextStyle(color: Colors.white70,
                                fontSize: 11)),
                      ]),
                    )),
                ]),
              ),

              // ── Info section ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                  // Name
                  Text(h.name, style: const TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),

                  // Address
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Expanded(child: Text(
                      h.address.isNotEmpty
                          ? '${h.address}, ${h.city}'
                          : h.city,
                      style: const TextStyle(fontSize: 13,
                          color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 10),

                  // Star + review row
                  Row(children: [
                    StarRatingDisplay(rating: h.rating, size: 15),
                    const SizedBox(width: 8),
                    Text(h.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    Text(' · ${h.reviewCount} review${h.reviewCount != 1 ? "s" : ""}',
                        style: const TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 10),

                  // Description snippet
                  if (h.description != null && h.description!.isNotEmpty) ...[
                    Text(h.description!,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13,
                            color: AppColors.textSecondary, height: 1.5)),
                    const SizedBox(height: 10),
                  ],

                  // Amenities
                  if (h.amenities.isNotEmpty) ...[
                    Wrap(spacing: 6, runSpacing: 6,
                      children: h.amenities.take(5).map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.2)),
                        ),
                        child: Text(a, style: const TextStyle(
                            fontSize: 11, color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Coordinates line
                  if (h.latitude != null && h.longitude != null) ...[
                    GestureDetector(
                      onTap: _openMaps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2))),
                        child: Row(children: [
                          const Icon(Icons.my_location_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            '${h.latitude!.toStringAsFixed(5)}, '
                            '${h.longitude!.toStringAsFixed(5)}',
                            style: const TextStyle(fontSize: 11,
                                color: AppColors.primary,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600),
                          )),
                          const Icon(Icons.open_in_new_rounded,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          const Text('Maps',
                              style: TextStyle(fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action buttons
                  Row(children: [
                    // Google Maps
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openMaps,
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('View on Map',
                            style: TextStyle(fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side:            const BorderSide(
                              color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // View rooms
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onTap,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                        label: const Text('View Rooms',
                            style: TextStyle(fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CITY HERO HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _CityHeroHeader extends StatelessWidget {
  final String  city;
  final String? region;
  final int     totalHotels;

  const _CityHeroHeader({required this.city, this.region,
    required this.totalHotels});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      // Local city photo → online fallback
      LocalOrNetworkImage(
        localPath:  AppImages.cityImage(city),
        networkUrl: AppImages.onlineCityFallback(city),
        fit:        BoxFit.cover,
        placeholder: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        errorWidget: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary]),
          ),
          child: Center(child: Text(city[0],
              style: const TextStyle(color: Colors.white38,
                  fontSize: 80, fontWeight: FontWeight.w900))),
        ),
      ),

      // Gradient overlay
      Container(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.72)],
        stops: const [0.25, 1.0],
      ))),

      // Text content
      Positioned(bottom: 20, left: 20, right: 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accent,
                borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.location_on_rounded, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text('Ethiopia', style: TextStyle(color: Colors.white,
                  fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 8),
          Text(city, style: const TextStyle(color: Colors.white,
              fontSize: 30, fontWeight: FontWeight.w900, height: 1.1,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
          if (region != null && region!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(region!, style: TextStyle(
                color: Colors.white.withOpacity(0.8), fontSize: 14)),
          ],
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            _pill('🏨 ${totalHotels > 0 ? "$totalHotels Hotel${totalHotels != 1 ? "s" : ""}" : "Exploring…"}'),
            _pill('📍 Ethiopia'),
            if (totalHotels > 0) _pill('✅ Available Now'),
          ]),
        ]),
      ),
    ]);
  }

  Widget _pill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3))),
    child: Text(label, style: const TextStyle(color: Colors.white,
        fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final int     total, page, pages;
  final bool    loading;
  final String  city, sort, dir;
  final String? type;
  final List<Map<String, String>> sortOptions;
  final List<String> types;
  final void Function(String sort, String dir) onSort;
  final void Function(String? type) onType;

  const _FilterBar({
    required this.total, required this.page, required this.pages,
    required this.loading, required this.city, required this.sort,
    required this.dir, required this.type, required this.sortOptions,
    required this.types, required this.onSort, required this.onType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(children: [
        Row(children: [
          loading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5,
                      color: AppColors.primary))
              : RichText(text: TextSpan(children: [
                  TextSpan(text: '$total ',
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary)),
                  const TextSpan(text: 'hotel',
                      style: TextStyle(fontSize: 13,
                          color: AppColors.textSecondary)),
                  if (total != 1)
                    const TextSpan(text: 's',
                        style: TextStyle(fontSize: 13,
                            color: AppColors.textSecondary)),
                  TextSpan(text: ' in $city',
                      style: const TextStyle(fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ])),
          const Spacer(),
          if (pages > 1)
            Text('$page / $pages',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ]),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            // Sort chips
            ...sortOptions.map((s) {
              final sel = sort == s['sort'] && dir == s['dir'];
              return _Chip(label: s['label']!, selected: sel,
                  color: AppColors.primary,
                  onTap: () => onSort(s['sort']!, s['dir']!));
            }),
            Container(width: 1, height: 20, color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 6)),
            // Type chips
            _Chip(label: 'All', selected: type == null,
                color: AppColors.accent, onTap: () => onType(null)),
            ...types.map((t) => _Chip(
                label:    t[0].toUpperCase() + t.substring(1),
                selected: type == t,
                color:    AppColors.accent,
                onTap:    () => onType(t))),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label; final bool selected; final Color color;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin:   const EdgeInsets.only(right: 8),
      padding:  const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color:        selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: selected ? color : AppColors.border),
        boxShadow:    selected ? [BoxShadow(color: color.withOpacity(0.25),
            blurRadius: 6, offset: const Offset(0, 2))] : null,
      ),
      child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary)),
    ),
  );
}

class _PaginationBar extends StatelessWidget {
  final int page, pages;
  final VoidCallback? onPrev, onNext;
  const _PaginationBar({required this.page, required this.pages,
    this.onPrev, this.onNext});

  @override
  Widget build(BuildContext context) => Container(
    color:   Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _btn('← Prev', onPrev),
      const SizedBox(width: 14),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
            color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
        child: Text('$page / $pages', style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
      const SizedBox(width: 14),
      _btn('Next →', onNext),
    ]),
  );

  Widget _btn(String label, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
          color: onTap != null ? Colors.white : AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: onTap != null ? AppColors.border : AppColors.surfaceGray)),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: onTap != null ? AppColors.primary : AppColors.textHint)),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String error; final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off_rounded, size: 52, color: AppColors.textHint),
      const SizedBox(height: 14),
      const Text('Could not load hotels',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      const Text('Make sure the backend is running on port 8080.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Try Again')),
    ]),
  ));
}

class _EmptyState extends StatelessWidget {
  final String city;
  const _EmptyState({required this.city});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min, children: [
    const Text('🏙️', style: TextStyle(fontSize: 56)),
    const SizedBox(height: 16),
    Text('No hotels in $city', style: const TextStyle(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary)),
    const SizedBox(height: 6),
    const Text('Check back later or try a nearby city.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    const SizedBox(height: 24),
    OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded, size: 16),
        label: const Text('Back to Cities')),
  ]));
}
