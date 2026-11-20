import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../l10n/app_localizations.dart';
import '../../models/hotel.dart';
import '../../widgets/local_or_network_image.dart';
import '../../widgets/hotel_image.dart';
import '../../models/review.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/snack_helper.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../booking/booking_confirm_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final int hotelId;
  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen>
    with SingleTickerProviderStateMixin {
  // Gallery
  final _galleryCtrl   = PageController();
  final _lightboxCtrl  = PageController();
  int  _imgIdx         = 0;
  bool _lightbox       = false;

  // Dates
  DateTime _checkIn  = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 1));
  bool     _datesSelected = false;

  // Room selection: roomId → qty (max 2 per room type)
  final Map<int, int> _roomQty = {};

  // Review form
  final _reviewCtrl    = TextEditingController();
  int  _reviewRating   = 5;
  bool _showReviewForm = false;
  bool _postingReview  = false;

  // Tabs
  late TabController _tabCtrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        final hp = context.read<HotelProvider>();
        hp.loadHotel(widget.hotelId);
        // Load availability for today → tomorrow immediately
        hp.loadAvailability(
            widget.hotelId, _fmtDate(_checkIn), _fmtDate(_checkOut));
      }
    });
  }

  @override
  void dispose() {
    _galleryCtrl.dispose();
    _lightboxCtrl.dispose();
    _reviewCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDisplay(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  int get _nights =>
      _checkOut.difference(_checkIn).inDays.clamp(1, 999);

  // All selected rooms flattened
  List<Room> get _selectedRooms {
    final hp = context.read<HotelProvider>();
    return hp.rooms.where((r) => (_roomQty[r.id] ?? 0) > 0).toList();
  }

  int get _totalRooms =>
      _selectedRooms.fold(0, (s, r) => s + (_roomQty[r.id] ?? 0));

  double get _totalPrice => _selectedRooms.fold(0.0,
      (s, r) => s + r.pricePerNight * (_roomQty[r.id] ?? 0) * _nights);

  int get _maxCapacity => _selectedRooms.fold(
      0, (s, r) => s + r.maxGuests * (_roomQty[r.id] ?? 0));

  // ── Pick date ─────────────────────────────────────────────────────────────
  Future<void> _pickDate(bool isCheckIn) async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context:     context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate:   now,
      lastDate:    now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        if (picked.isAfter(_checkIn)) {
          _checkOut = picked;
        } else {
          showError(context, 'Check-out must be after check-in');
          return;
        }
      }
      _datesSelected = true;
      _roomQty.clear();
    });
    context.read<HotelProvider>().loadAvailability(
        widget.hotelId, _fmtDate(_checkIn), _fmtDate(_checkOut));
  }

  // ── Book Now ──────────────────────────────────────────────────────────────
  void _handleBook() {
    if (_selectedRooms.isEmpty) {
      showInfo(context, 'Please select at least one room');
      return;
    }
    final isAuth = context.read<AuthProvider>().isAuthenticated;
    if (!isAuth) {
      // Show auth modal — user can sign in or register
      _showAuthModal();
      return;
    }
    _navigateToBooking();
  }

  void _navigateToBooking() {
    final primary = _selectedRooms.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmScreen(
          hotelId:   widget.hotelId,
          checkIn:   _fmtDate(_checkIn),
          checkOut:  _fmtDate(_checkOut),
          nights:    _nights,
          roomId:    primary.id,
          roomName:  primary.name,
          roomPrice: primary.pricePerNight,
          rooms:     _totalRooms,
          maxGuests: _maxCapacity,
        ),
      ),
    );
  }

  void _showAuthModal() {
    showModalBottomSheet(
      context:         context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuthPromptSheet(
        onLogin: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ).then((_) {
            if (context.read<AuthProvider>().isAuthenticated) {
              _navigateToBooking();
            }
          });
        },
        onRegister: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ).then((_) {
            if (context.read<AuthProvider>().isAuthenticated) {
              _navigateToBooking();
            }
          });
        },
      ),
    );
  }

  // ── Wishlist ──────────────────────────────────────────────────────────────
  Future<void> _toggleWishlist(Hotel hotel) async {
    if (!context.read<AuthProvider>().isAuthenticated) {
      _showAuthModal(); return;
    }
    final res = await context.read<WishlistProvider>().toggle(hotel);
    if (!mounted) return;
    if (res == true)       showSuccess(context, 'Added to wishlist ♥');
    else if (res == false) showInfo(context, 'Removed from wishlist');
    else                   showError(context, 'Failed to update wishlist');
  }

  // ── Post review ───────────────────────────────────────────────────────────
  Future<void> _postReview(int hotelId) async {
    if (!context.read<AuthProvider>().isAuthenticated) {
      _showAuthModal(); return;
    }
    if (_reviewCtrl.text.trim().length < 5) {
      showError(context, 'Comment must be at least 5 characters'); return;
    }
    setState(() => _postingReview = true);
    final ok = await context
        .read<HotelProvider>()
        .postReview(hotelId, _reviewRating, _reviewCtrl.text.trim());
    if (!mounted) return;
    setState(() => _postingReview = false);
    if (ok) {
      showSuccess(context, 'Review posted!');
      _reviewCtrl.clear();
      setState(() { _showReviewForm = false; _reviewRating = 5; });
    } else {
      showError(context, 'Failed to post review. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp        = context.watch<HotelProvider>();
    final hotel     = hp.hotel;
    final wishlisted =
        context.watch<WishlistProvider>().isWishlisted(widget.hotelId);

    if (hp.detailLoading || hotel == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: const Center(child: AppSpinner(size: SpinnerSize.large)),
      );
    }

    final images = hotel.images.isNotEmpty
        ? hotel.images
        : <String>[];

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // ── Main content ─────────────────────────────────────────────────
        CustomScrollView(
          slivers: [
            // ── Gallery app bar ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 270,
              pinned:         true,
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                // Wishlist
                IconButton(
                  icon: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle),
                    child: Icon(
                      wishlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: wishlisted ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _toggleWishlist(hotel),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _GallerySection(
                  images:     images,
                  imgIdx:     _imgIdx,
                  controller: _galleryCtrl,
                  isFeatured: hotel.isFeatured,
                  onPageChanged: (i) => setState(() => _imgIdx = i),
                  onTapImage:    () => setState(() => _lightbox = true),
                ),
              ),
            ),

            // Thumbnail strip
            if (images.length > 1)
              SliverToBoxAdapter(
                child: Container(
                  color:  Colors.black,
                  height: 58,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: images.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () {
                        _galleryCtrl.animateToPage(i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                        setState(() => _imgIdx = i);
                      },
                      child: Container(
                        width: 56, height: 42,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _imgIdx == i
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                            imageUrl: images[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Hotel info + tabs ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(children: [
                // Info header
                _HotelInfoHeader(hotel: hotel),

                // Tab bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller:           _tabCtrl,
                    labelColor:           AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor:       AppColors.primary,
                    indicatorWeight:      3,
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: [
                      Tab(text: l10n.t('rooms_tab')),
                      Tab(text: l10n.t('details_tab')),
                      Tab(text: l10n.t('reviews_tab')),
                    ],
                  ),
                ),

                // Tab content
                SizedBox(
                  height: 560,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      // ── Rooms tab ───────────────────────────────────────
                      _RoomsTab(
                        hp:             hp,
                        hotel:          hotel,
                        checkIn:        _checkIn,
                        checkOut:       _checkOut,
                        nights:         _nights,
                        datesSelected:  _datesSelected,
                        roomQty:        _roomQty,
                        onPickCheckIn:  () => _pickDate(true),
                        onPickCheckOut: () => _pickDate(false),
                        onChangeQty: (id, delta) {
                          setState(() {
                            final cur  = _roomQty[id] ?? 0;
                            final next = (cur + delta).clamp(0, 2);
                            _roomQty[id] = next;
                          });
                        },
                        fmtDate: _fmtDisplay,
                      ),
                      // ── Details tab ─────────────────────────────────────
                      _DetailsTab(
                        hotel:        hotel,
                        managerName:  hp.managerName,
                        managerPhone: hp.managerPhone,
                        managerEmail: hp.managerEmail,
                        payMethods:   hp.payMethods,
                      ),
                      // ── Reviews tab ─────────────────────────────────────
                      _ReviewsTab(
                        hp:            hp,
                        showForm:      _showReviewForm,
                        reviewCtrl:    _reviewCtrl,
                        reviewRating:  _reviewRating,
                        posting:       _postingReview,
                        onToggleForm:  () => setState(
                            () => _showReviewForm = !_showReviewForm),
                        onRatingChanged: (r) =>
                            setState(() => _reviewRating = r),
                        onPost: () => _postReview(hotel.id),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90), // room for sticky bar
              ]),
            ),
          ],
        ),

        // ── Lightbox overlay ─────────────────────────────────────────────
        if (_lightbox)
          _Lightbox(
            images:       images,
            initialIndex: _imgIdx,
            onClose:      () => setState(() => _lightbox = false),
          ),

        // ── Sticky Book Now bar ───────────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _StickyBookBar(
            hotel:        hotel,
            selectedRooms: _selectedRooms,
            roomQty:      _roomQty,
            nights:       _nights,
            totalRooms:   _totalRooms,
            totalPrice:   _totalPrice,
            onBook:       _handleBook,
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GALLERY SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _GallerySection extends StatelessWidget {
  final List<String>  images;
  final int           imgIdx;
  final PageController controller;
  final bool          isFeatured;
  final ValueChanged<int> onPageChanged;
  final VoidCallback      onTapImage;

  const _GallerySection({
    required this.images, required this.imgIdx,
    required this.controller, required this.isFeatured,
    required this.onPageChanged, required this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapImage,
      child: Stack(fit: StackFit.expand, children: [
        images.isEmpty
            ? Container(color: AppColors.surfaceGray,
                child: const Icon(Icons.hotel_outlined,
                    size: 64, color: AppColors.textHint))
            : PageView.builder(
                controller:    controller,
                itemCount:     images.length,
                onPageChanged: onPageChanged,
                itemBuilder: (_, i) => HotelImage(
                  imageUrl:    images[i],
                  fit:         BoxFit.cover,
                  errorWidget: Container(
                      color: AppColors.surfaceGray,
                      child: const Icon(Icons.hotel_outlined,
                          size: 56, color: AppColors.textHint)),
                ),
              ),

        // Gradient overlay
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.25),
              Colors.transparent,
              Colors.black.withOpacity(0.45)
            ],
            stops: const [0, 0.45, 1],
          ),
        ))),

        // Featured badge
        if (isFeatured)
          Positioned(top: 60, left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star_rounded, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text('Featured',
                    style: TextStyle(color: Colors.white,
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            )),

        // Image counter
        Positioned(top: 60, right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.52),
                borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.photo_library_outlined,
                  color: Colors.white, size: 12),
              const SizedBox(width: 5),
              Text('${imgIdx + 1}/${images.isEmpty ? 0 : images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ]),
          )),

        // Dot indicators (bottom center)
        if (images.length > 1 && images.length <= 8)
          Positioned(bottom: 12, left: 0, right: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width:  i == imgIdx ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == imgIdx
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ))),
          ),

        // Tap-to-expand hint
        Positioned(bottom: 10, right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.42),
                borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.zoom_in_rounded, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text('Tap to expand',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ]),
          )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL INFO HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _HotelInfoHeader extends StatelessWidget {
  final Hotel hotel;
  const _HotelInfoHeader({required this.hotel});

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Type badge
        if (hotel.type != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20)),
            child: Text(hotel.type!.toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ),

        // Name
        Text(hotel.name,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),

        // Location
        Row(children: [
          const Icon(Icons.location_on_outlined,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Expanded(
            child: Text('${hotel.address}, ${hotel.city}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 10),

        // Rating row
        Row(children: [
          StarRatingDisplay(rating: hotel.rating, size: 16),
          const SizedBox(width: 8),
          StarRatingSmall(
              rating: hotel.rating, reviewCount: hotel.reviewCount),
        ]),
        const SizedBox(height: 12),

        // Price banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Starting from',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              RichText(text: TextSpan(children: [
                TextSpan(
                    text: 'ETB ${_fmt(hotel.pricePerNight)}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const TextSpan(text: '/night',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ])),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.bed_outlined, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text('Select Room',
                    style: TextStyle(color: Colors.white,
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL LOCATION CARD — single smart location widget, used only in Details tab
// ─────────────────────────────────────────────────────────────────────────────
class _HotelLocationCard extends StatelessWidget {
  final Hotel hotel;
  const _HotelLocationCard({required this.hotel});

  Future<void> _openMaps(BuildContext context) async {
    Uri uri;
    if (hotel.latitude != null && hotel.longitude != null) {
      final q = Uri.encodeComponent('${hotel.name}, ${hotel.city}, Ethiopia');
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=$q'
        '&center=${hotel.latitude},${hotel.longitude}',
      );
    } else {
      final q = Uri.encodeComponent(
          '${hotel.name}, ${hotel.address}, ${hotel.city}, Ethiopia');
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$q');
    }
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        showError(context, 'Could not open Google Maps');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasCoords = hotel.latitude != null && hotel.longitude != null;

    return GestureDetector(
      onTap: () => _openMaps(context),
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(children: [

          // ── Fake map background ──────────────────────────────────────
          Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFD1EAF8), Color(0xFFBDD5ED)],
              ),
            ),
            child: Stack(children: [
              // Grid lines (simulated map)
              CustomPaint(
                size: const Size(double.infinity, 100),
                painter: _MapGridPainter(),
              ),
              // Road lines
              Positioned.fill(child: CustomPaint(
                painter: _MapRoadPainter(),
              )),
              // Center pin
              Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: AppColors.error.withOpacity(0.5),
                          blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.place_rounded,
                        color: Colors.white, size: 20),
                  ),
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                  ),
                ]),
              ),
              // Hotel name label (top center)
              Positioned(top: 8, left: 8, right: 8,
                child: Center(child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4)]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.hotel_rounded,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(hotel.name,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ))),
              // Google Maps watermark
              Positioned(bottom: 4, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('Google Maps',
                      style: TextStyle(fontSize: 8,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600)),
                )),
            ]),
          ),

          // ── Location info row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  hotel.address.isNotEmpty
                      ? '${hotel.address}, ${hotel.city}'
                      : hotel.city,
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                if (hasCoords)
                  Text(
                    '${hotel.latitude!.toStringAsFixed(4)}, '
                    '${hotel.longitude!.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 10,
                        color: AppColors.textHint,
                        fontFamily: 'monospace'),
                  ),
              ])),
              // Open Maps button
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 6, offset: const Offset(0, 2))]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.open_in_new_rounded,
                      color: Colors.white, size: 13),
                  const SizedBox(width: 5),
                  Text(l10n.t('open_map'),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),

          // ── Directions banner ───────────────────────────────────────
          InkWell(
            onTap: () => _openMaps(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: const BoxDecoration(
                  color: Color(0xFFF0F9FF),
                  border: Border(top: BorderSide(
                      color: AppColors.border, width: 0.8))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const Icon(Icons.directions_rounded,
                    color: AppColors.primary, size: 15),
                const SizedBox(width: 6),
                Text(l10n.t('get_directions'),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.primary, size: 12),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// Grid and road painters for the fake map background
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8D8EF).withOpacity(0.5)
      ..strokeWidth = 0.8;
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _MapRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    // Horizontal roads
    canvas.drawLine(Offset(0, size.height * 0.35),
        Offset(size.width, size.height * 0.35), paint);
    canvas.drawLine(Offset(0, size.height * 0.65),
        Offset(size.width, size.height * 0.65), paint);
    // Vertical roads
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0),
        Offset(size.width * 0.7, size.height), paint);
  }
  @override bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOMS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _RoomsTab extends StatefulWidget {
  final HotelProvider    hp;
  final Hotel            hotel;
  final DateTime         checkIn, checkOut;
  final int              nights;
  final bool             datesSelected;
  final Map<int, int>    roomQty;
  final VoidCallback     onPickCheckIn, onPickCheckOut;
  final void Function(int id, int delta) onChangeQty;
  final String Function(DateTime) fmtDate;

  const _RoomsTab({
    required this.hp,     required this.hotel,
    required this.checkIn, required this.checkOut,
    required this.nights, required this.datesSelected,
    required this.roomQty, required this.onPickCheckIn,
    required this.onPickCheckOut, required this.onChangeQty,
    required this.fmtDate,
  });

  @override
  State<_RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<_RoomsTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bannerCtrl;
  late final Animation<double>   _bannerFade;
  late final Animation<Offset>   _bannerSlide;

  @override
  void initState() {
    super.initState();
    _bannerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _bannerFade  = CurvedAnimation(
        parent: _bannerCtrl, curve: Curves.easeOut);
    _bannerSlide = Tween<Offset>(
            begin: const Offset(0, -0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _bannerCtrl, curve: Curves.easeOutCubic));
    _bannerCtrl.forward();
  }

  @override
  void dispose() { _bannerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hp        = widget.hp;
    final hotel     = widget.hotel;
    final available = hp.availableRooms;
    final occupied  = hp.occupiedRooms;
    final l10n      = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Animated hotel image banner ──────────────────────────────────
        FadeTransition(
          opacity: _bannerFade,
          child: SlideTransition(
            position: _bannerSlide,
            child: Container(
              height: 140,
              width:  double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: Stack(fit: StackFit.expand, children: [
                // Hotel image
                Hero(
                  tag: 'hotel-cover-${hotel.id}',
                  child: LocalOrNetworkImage(
                    localPath:   AppImages.hotelCover(hotel.name),
                    networkUrl:  hotel.thumbnailUrl ?? AppImages.hotelNetworkUrl(hotel.name),
                    fit:         BoxFit.cover,
                    errorWidget: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryDark,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end:   Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.hotel_rounded,
                          color: Colors.white38, size: 48),
                    ),
                  ),
                ),
                // Gradient scrim — darken bottom so text is readable
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        stops: const [0.35, 1.0],
                      ),
                    ),
                  ),
                ),
                // Hotel name + city + price inside banner
                Positioned(
                  bottom: 12, left: 14, right: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(hotel.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    shadows: [Shadow(
                                        color: Colors.black38,
                                        blurRadius: 4)]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.location_on_rounded,
                                  color: Colors.white70, size: 11),
                              const SizedBox(width: 3),
                              Text(hotel.city,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11)),
                            ]),
                          ],
                        ),
                      ),
                      // Price pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'ETB ${hotel.pricePerNight.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900),
                            ),
                            const TextSpan(
                              text: '/nt',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 9),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                // "Select your room" hint at top
                Positioned(
                  top: 10, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.bed_rounded,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 5),
                        Text(l10n.t('select_room'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),

        // ── Rest of rooms tab ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [

            // Date selector
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border:       Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.date_range_rounded,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(l10n.t('select_dates'),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: AppColors.primary, letterSpacing: 1.2)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _DateBtn(
                    label: l10n.t('check_in'),
                    date:  widget.fmtDate(widget.checkIn),
                    onTap: widget.onPickCheckIn,
                  )),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${widget.nights} ${widget.nights == 1 ? l10n.t("night") : l10n.t("nights")}',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(child: _DateBtn(
                    label: l10n.t('check_out'),
                    date:  widget.fmtDate(widget.checkOut),
                    onTap: widget.onPickCheckOut,
                  )),
                ]),
              ]),
            ),
            const SizedBox(height: 16),

            // Available rooms
            if (hp.roomsLoading)
              const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: AppSpinner()))
            else if (available.isEmpty && occupied.isEmpty)
              _NoRooms(datesSelected: widget.datesSelected)
            else ...[
              if (available.isNotEmpty) ...[
                Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Text(
                    '${available.length} ${l10n.t("rooms_tab").toLowerCase()}'
                    ' ${l10n.t("available").toLowerCase()} — tap to select',
                    style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w700, color: AppColors.success)),
                ]),
                const SizedBox(height: 10),
                ...available.map((r) => _RoomCard(
                  room:        r,
                  qty:         widget.roomQty[r.id] ?? 0,
                  nights:      widget.nights,
                  onChangeQty: (d) => widget.onChangeQty(r.id, d),
                )),
              ],
              if (occupied.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(l10n.t('reserved').toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.textHint, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...occupied.map((r) => _OccupiedCard(room: r)),
              ],
            ],
          ]),
        ),
      ]),
    );
  }
}

class _DateBtn extends StatelessWidget {
  final String   label, date;
  final VoidCallback onTap;
  const _DateBtn({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.primary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(date,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ]),
    ),
  );
}

class _NoRooms extends StatelessWidget {
  final bool datesSelected;
  const _NoRooms({required this.datesSelected});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('😴', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        const Text('No rooms available',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(datesSelected
            ? 'No rooms available for the selected dates.\nTry different dates.'
            : 'Select check-in and check-out dates above to see available rooms.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      ]),
    ),
  );
}

class _RoomCard extends StatelessWidget {
  final Room   room;
  final int    qty, nights;
  final void Function(int delta) onChangeQty;
  const _RoomCard({required this.room, required this.qty,
    required this.nights, required this.onChangeQty});

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final sel = qty > 0;
    return GestureDetector(
      onTap: () => onChangeQty(qty == 0 ? 1 : -qty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        sel ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(
              color: sel ? AppColors.primary : AppColors.border,
              width: sel ? 2 : 1),
          boxShadow: sel
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04),
                  blurRadius: 6)],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Room image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 88, height: 72,
              child: room.imageUrl != null
                  ? CachedNetworkImage(imageUrl: room.imageUrl!, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _imgFallback())
                  : _imgFallback(),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Name + check
            Row(children: [
              Expanded(child: Text(room.name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: sel ? AppColors.primary : AppColors.textPrimary))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.border,
                    shape: BoxShape.circle),
                child: sel
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ]),
            const SizedBox(height: 4),

            // Tags
            Wrap(spacing: 8, children: [
              _tag('🛏 ${room.bedType}'),
              _tag('👥 max ${room.maxGuests}'),
              if (room.sizeSqm > 0) _tag('📐 ${room.sizeSqm.toInt()}m²'),
            ]),
            const SizedBox(height: 8),

            // Price + status
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: 'ETB ${_fmt(room.pricePerNight)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                          color: sel ? AppColors.primary : AppColors.textPrimary)),
                  const TextSpan(text: '/night',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
                if (sel && qty > 0)
                  Text('= ETB ${_fmt(room.pricePerNight * qty * nights)}',
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.primary, fontWeight: FontWeight.w600)),
              ])),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.successLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(sel ? 'Selected' : 'Available',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : AppColors.success)),
              ),
            ]),

            // Qty stepper (when selected)
            if (sel) Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(children: [
                const Text('Rooms:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                const SizedBox(width: 10),
                _StepBtn(
                    icon: Icons.remove_rounded,
                    enabled: qty > 1,
                    onTap:   () => onChangeQty(-1)),
                Container(
                  width: 32, alignment: Alignment.center,
                  child: Text('$qty', style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
                ),
                _StepBtn(
                    icon: Icons.add_rounded,
                    enabled: qty < 2,
                    onTap:   () => onChangeQty(1)),
              ]),
            ),
          ])),
        ]),
      ),
    );
  }

  Widget _tag(String t) => Text(t,
      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary));

  Widget _imgFallback() => Container(color: AppColors.surfaceGray,
      child: const Icon(Icons.bed_outlined, size: 30, color: AppColors.textHint));
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool     enabled;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(
            color: enabled ? AppColors.primary : AppColors.border,
            width: 1.5),
      ),
      child: Icon(icon, size: 16,
          color: enabled ? AppColors.primary : AppColors.border),
    ),
  );
}

class _OccupiedCard extends StatelessWidget {
  final Room room;
  const _OccupiedCard({required this.room});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color:        AppColors.surfaceGray,
      borderRadius: BorderRadius.circular(12),
      border:       Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 60, height: 48,
          child: room.imageUrl != null
              ? ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                      Colors.grey, BlendMode.saturation),
                  child: CachedNetworkImage(
                      imageUrl: room.imageUrl!, fit: BoxFit.cover))
              : Container(color: AppColors.border,
                  child: const Icon(Icons.bed_outlined,
                      color: AppColors.textHint, size: 22)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(room.name,
            style: const TextStyle(fontWeight: FontWeight.w700,
                color: AppColors.textSecondary, fontSize: 14)),
        Text('${room.bedType} · max ${room.maxGuests} guests',
            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        if (room.occupiedUntil != null)
          Text('Available after: ${room.occupiedUntil}',
              style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: AppColors.errorLight, borderRadius: BorderRadius.circular(8)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock_outline_rounded, size: 11, color: AppColors.error),
          SizedBox(width: 4),
          Text('Reserved',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppColors.error)),
        ]),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAILS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _DetailsTab extends StatelessWidget {
  final Hotel  hotel;
  final String? managerName;
  final String? managerPhone;
  final String? managerEmail;
  final List<PaymentMethod> payMethods;

  const _DetailsTab({
    required this.hotel,
    this.managerName,
    this.managerPhone,
    this.managerEmail,
    this.payMethods = const [],
  });

  static const _amenityIcons = <String, IconData>{
    'Free WiFi': Icons.wifi_rounded, 'WiFi': Icons.wifi_rounded,
    'Restaurant': Icons.restaurant_rounded,
    'Swimming Pool': Icons.pool_rounded, 'Pool': Icons.pool_rounded,
    'Gym': Icons.fitness_center_rounded,
    'Parking': Icons.local_parking_rounded,
    'Breakfast': Icons.free_breakfast_rounded,
    'Spa': Icons.spa_rounded, 'Bar': Icons.local_bar_rounded,
    'Room Service': Icons.room_service_rounded,
    'Air Conditioning': Icons.ac_unit_rounded,
    'Laundry': Icons.local_laundry_service_rounded,
    'Conference Room': Icons.meeting_room_rounded,
    'Airport Shuttle': Icons.airport_shuttle_rounded,
  };

  // Ethiopian payment method meta
  static const _pmMeta = <String, Map<String, dynamic>>{
    'telebirr':     {'label': 'Telebirr',          'emoji': '📱', 'color': Color(0xFF059669)},
    'cbe_birr':     {'label': 'CBE Birr',           'emoji': '🏦', 'color': Color(0xFFD97706)},
    'chapa':        {'label': 'Chapa',              'emoji': '💳', 'color': Color(0xFF2563EB)},
    'awash_bank':   {'label': 'Awash Bank',         'emoji': '🏦', 'color': Color(0xFF7C3AED)},
    'abyssinia':    {'label': 'Bank of Abyssinia',  'emoji': '🏦', 'color': Color(0xFFDB2777)},
    'dashen':       {'label': 'Dashen Bank',        'emoji': '🏦', 'color': Color(0xFF0D9488)},
    'oromia_coop':  {'label': 'Oromia Bank',        'emoji': '🏦', 'color': Color(0xFFEA580C)},
    'united':       {'label': 'United Bank',        'emoji': '🏦', 'color': Color(0xFF4F46E5)},
    'nib':          {'label': 'NIB International',  'emoji': '🏦', 'color': Color(0xFF65A30D)},
    'wegagen':      {'label': 'Wegagen Bank',       'emoji': '🏦', 'color': Color(0xFF0891B2)},
    'bunna':        {'label': 'Bunna Bank',         'emoji': '🏦', 'color': Color(0xFFA21CAF)},
    'cooperative':  {'label': 'Cooperative Bank',   'emoji': '🏦', 'color': Color(0xFF047857)},
    'bank_transfer':{'label': 'Bank Transfer',      'emoji': '🏦', 'color': Color(0xFF374151)},
    'card':         {'label': 'Card Payment',       'emoji': '💳', 'color': Color(0xFF1D4ED8)},
    'mobile_money': {'label': 'Mobile Money',       'emoji': '📲', 'color': Color(0xFF059669)},
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── About ─────────────────────────────────────────────────────────
        if (hotel.description != null && hotel.description!.isNotEmpty) ...[
          _secTitle('About', Icons.info_outline_rounded),
          const SizedBox(height: 8),
          _card(child: Text(hotel.description!,
              style: const TextStyle(fontSize: 14,
                  color: AppColors.textSecondary, height: 1.65))),
          const SizedBox(height: 18),
        ],

        // ── Amenities ─────────────────────────────────────────────────────
        if (hotel.amenities.isNotEmpty) ...[
          _secTitle('Amenities & Services', Icons.check_circle_outline_rounded),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8,
              children: hotel.amenities.map((a) {
            final icon = _amenityIcons[a] ?? Icons.check_rounded;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.25))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Text(a, style: const TextStyle(fontSize: 13,
                    color: AppColors.success, fontWeight: FontWeight.w500)),
              ]),
            );
          }).toList()),
          const SizedBox(height: 18),
        ],

        // ── Manager Contact Card ───────────────────────────────────────────
        if (managerName != null || managerPhone != null) ...[
          _secTitle('Hotel Manager Contact', Icons.support_agent_rounded),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      (managerName?.isNotEmpty == true)
                          ? managerName![0].toUpperCase()
                          : 'M',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (managerName != null)
                    Text(managerName!, style: const TextStyle(
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w800)),
                  const Text('Hotel Manager', style: TextStyle(
                      color: Colors.white70, fontSize: 12)),
                ])),
              ]),
              const SizedBox(height: 14),
              // Phone
              if (managerPhone != null && managerPhone!.isNotEmpty)
                _ContactRow(
                  icon:   Icons.phone_rounded,
                  label:  'Phone',
                  value:  managerPhone!,
                  dark:   true,
                  onCopy: () => _copy(context, managerPhone!, 'Phone'),
                  onCall: () => _call(managerPhone!),
                ),
              if (managerEmail != null && managerEmail!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ContactRow(
                  icon:   Icons.email_rounded,
                  label:  'Email',
                  value:  managerEmail!,
                  dark:   true,
                  onCopy: () => _copy(context, managerEmail!, 'Email'),
                ),
              ],
              const SizedBox(height: 10),
              const Text(
                '⚠️ Contact the manager for payment confirmation, '
                'special requests, or booking issues.',
                style: TextStyle(color: Colors.white70, fontSize: 11,
                    height: 1.4),
              ),
            ]),
          ),
          const SizedBox(height: 18),
        ],

        // ── Payment Methods ────────────────────────────────────────────────
        if (payMethods.isNotEmpty) ...[
          _secTitle('Accepted Payment Methods', Icons.payment_rounded),
          const SizedBox(height: 10),
          ...payMethods.map((pm) {
            final meta  = _pmMeta[pm.method] ??
                {'label': pm.method, 'emoji': '🏦', 'color': AppColors.primary};
            final color = meta['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.2)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                      blurRadius: 8)]),
              child: Column(children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.07),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(13))),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(meta['emoji'] as String,
                          style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(meta['label'] as String,
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w800, color: color)),
                      if (pm.accountName != null &&
                          pm.accountName!.isNotEmpty)
                        Text(pm.accountName!, style: TextStyle(
                            fontSize: 12, color: color.withOpacity(0.7))),
                    ])),
                    if (!pm.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Inactive',
                            style: TextStyle(fontSize: 10,
                                color: AppColors.error,
                                fontWeight: FontWeight.w700)),
                      ),
                  ]),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    if (pm.phoneNumber != null && pm.phoneNumber!.isNotEmpty)
                      _ContactRow(
                        icon:   Icons.phone_rounded,
                        label:  'Phone / Wallet',
                        value:  pm.phoneNumber!,
                        bold:   true,
                        color:  color,
                        onCopy: () => _copy(context, pm.phoneNumber!, 'Phone number'),
                        onCall: () => _call(pm.phoneNumber!),
                      ),
                    if (pm.accountNumber != null && pm.accountNumber!.isNotEmpty) ...[
                      if (pm.phoneNumber != null && pm.phoneNumber!.isNotEmpty)
                        const SizedBox(height: 8),
                      _ContactRow(
                        icon:   Icons.tag_rounded,
                        label:  'Account Number',
                        value:  pm.accountNumber!,
                        bold:   true,
                        mono:   true,
                        color:  color,
                        onCopy: () => _copy(context, pm.accountNumber!,
                            'Account number'),
                      ),
                    ],
                    if (pm.instructions != null && pm.instructions!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.12))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 14, color: color),
                            const SizedBox(width: 8),
                            Expanded(child: Text(pm.instructions!,
                                style: TextStyle(fontSize: 12,
                                    color: color, height: 1.5))),
                          ],
                        ),
                      ),
                    ],
                  ]),
                ),
              ]),
            );
          }),
          const SizedBox(height: 10),
          // Payment instructions banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A))),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('💡', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(child: Text(
                'How to pay:\n'
                '1. Select a room and tap "Book Now"\n'
                '2. Fill your details (name, ID, guests)\n'
                '3. Transfer the exact amount to any method above\n'
                '4. Upload your payment screenshot + transaction ID\n'
                '5. Manager will verify and confirm your booking',
                style: TextStyle(fontSize: 12, color: Color(0xFF92400E),
                    height: 1.6),
              )),
            ]),
          ),
          const SizedBox(height: 18),
        ],

        // ── Location ──────────────────────────────────────────────────────────
        _secTitle('Location', Icons.location_on_outlined),
        const SizedBox(height: 8),
        _HotelLocationCard(hotel: hotel),
      ]),
    );
  }

  void _copy(BuildContext ctx, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccess(ctx, '$label copied!');
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Widget _secTitle(String t, IconData icon) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
        color: AppColors.textPrimary)),
  ]);

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
    child: child,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTACT ROW — reusable copyable row used in _DetailsTab
// ─────────────────────────────────────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final String     value;
  final bool       dark;    // white text on dark bg
  final bool       bold;    // bigger text
  final bool       mono;    // monospace font
  final Color      color;
  final VoidCallback? onCopy;
  final VoidCallback? onCall;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.dark  = false,
    this.bold  = false,
    this.mono  = false,
    this.color = AppColors.primary,
    this.onCopy,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor  = dark ? Colors.white70 : AppColors.textHint;
    final valueColor  = dark ? Colors.white   : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:        dark
            ? Colors.white.withOpacity(0.1)
            : color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: dark
                ? Colors.white.withOpacity(0.2)
                : color.withOpacity(0.18)),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: dark ? Colors.white70 : color),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
              fontSize: 10, color: labelColor,
              fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              color: valueColor,
              fontFamily: mono ? 'monospace' : null,
              letterSpacing: mono ? 1.5 : 0)),
        ])),
        if (onCall != null)
          IconButton(
            icon: Icon(Icons.call_rounded, size: 18,
                color: dark ? Colors.white70 : color),
            onPressed: onCall,
            tooltip: 'Call',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        if (onCopy != null)
          IconButton(
            icon: Icon(Icons.copy_rounded, size: 16,
                color: dark ? Colors.white60 : color.withOpacity(0.7)),
            onPressed: onCopy,
            tooltip: 'Copy',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
      ]),
    );
  }
}

// REVIEWS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewsTab extends StatelessWidget {
  final HotelProvider        hp;
  final bool                 showForm, posting;
  final TextEditingController reviewCtrl;
  final int                  reviewRating;
  final VoidCallback         onToggleForm, onPost;
  final ValueChanged<int>    onRatingChanged;

  const _ReviewsTab({
    required this.hp, required this.showForm, required this.posting,
    required this.reviewCtrl, required this.reviewRating,
    required this.onToggleForm, required this.onPost,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('${hp.reviews.length} Review${hp.reviews.length != 1 ? "s" : ""}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const Spacer(),
          TextButton(
            onPressed: onToggleForm,
            child: Text(showForm ? 'Cancel' : '+ Write a Review',
                style: const TextStyle(fontSize: 13, color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ]),

        // Review form
        if (showForm)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.surfaceGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your Rating',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              StarRatingInteractive(value: reviewRating,
                  onChanged: onRatingChanged, size: 34),
              const SizedBox(height: 12),
              TextFormField(
                controller: reviewCtrl,
                maxLines:   3,
                decoration: const InputDecoration(
                  hintText: 'Share your experience with this hotel…',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 44,
                child: ElevatedButton(
                  onPressed: posting ? null : onPost,
                  child: posting
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Text('Post Review'),
                ),
              ),
            ]),
          ),

        // Reviews list
        if (hp.reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.rate_review_outlined,
                    size: 48, color: AppColors.textHint),
                SizedBox(height: 12),
                Text('No reviews yet',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('Be the first to review this hotel!',
                    style: TextStyle(fontSize: 13, color: AppColors.textHint)),
              ]),
            ),
          )
        else
          ...hp.reviews.map((r) => _ReviewCard(review: r)),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03),
            blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(
          radius: 18, backgroundColor: AppColors.primaryLight,
          child: Text(
            review.userName.isNotEmpty
                ? review.userName[0].toUpperCase()
                : 'G',
            style: const TextStyle(color: AppColors.primary,
                fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(review.userName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          StarRatingDisplay(rating: review.rating.toDouble(), size: 13),
        ])),
        Text(
          '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ]),
      const SizedBox(height: 8),
      Text(review.comment,
          style: const TextStyle(fontSize: 13,
              color: AppColors.textSecondary, height: 1.5)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STICKY BOOK BAR
// ─────────────────────────────────────────────────────────────────────────────
class _StickyBookBar extends StatelessWidget {
  final Hotel         hotel;
  final List<Room>    selectedRooms;
  final Map<int, int> roomQty;
  final int           nights, totalRooms;
  final double        totalPrice;
  final VoidCallback  onBook;

  const _StickyBookBar({
    required this.hotel,     required this.selectedRooms,
    required this.roomQty,   required this.nights,
    required this.totalRooms,required this.totalPrice,
    required this.onBook,
  });

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context);
    final hasRooms    = selectedRooms.isNotEmpty;
    final roomSummary = selectedRooms
        .map((r) => '${roomQty[r.id]}× ${r.name}')
        .join(', ');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve:    Curves.easeOutCubic,
      decoration: BoxDecoration(
        color:      Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(hasRooms ? 0.15 : 0.08),
            blurRadius: 24, offset: const Offset(0, -6))],
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      child: hasRooms

          // ── Rooms selected: show total + "Continue to Payment" ────────────
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              // Room summary + price row
              Row(children: [
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Room names
                  Text(roomSummary,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  // Price + nights
                  RichText(text: TextSpan(children: [
                    TextSpan(
                        text: 'ETB ${_fmt(totalPrice)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary)),
                    TextSpan(
                        text: ' · $nights ${nights > 1 ? l10n.t("nights") : l10n.t("night")}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ])),
                ])),
                const SizedBox(width: 10),
                // Room count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '$totalRooms ${l10n.t("rooms_selected")}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              // BIG "Continue to Payment" button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const Icon(Icons.payment_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      l10n.t('continue_to_payment'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ]),
                ),
              ),
            ])

          // ── No rooms selected: show starting price + "Select a Room" ──────
          : Row(children: [
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(l10n.t('starting_from'),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                RichText(text: TextSpan(children: [
                  TextSpan(
                      text: 'ETB ${_fmt(hotel.pricePerNight)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary)),
                  TextSpan(
                      text: '/${l10n.t("night")}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ])),
              ])),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onBook,
                icon:  const Icon(Icons.bed_outlined, size: 18),
                label: Text(l10n.t('select_room'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              ),
            ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH PROMPT BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _AuthPromptSheet extends StatelessWidget {
  final VoidCallback onLogin, onRegister;
  const _AuthPromptSheet({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(
          child: Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 20),

        // Icon + title
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        const Text('Sign in to Book',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Create a free account or sign in to complete your booking.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                height: 1.4),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),

        // Buttons
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: onLogin,
            icon:  const Icon(Icons.login_rounded, size: 18),
            label: const Text('Sign In to My Account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity, height: 50,
          child: OutlinedButton.icon(
            onPressed: onRegister,
            icon:  const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Create Free Account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('It\'s free and takes less than 2 minutes',
            style: TextStyle(fontSize: 12, color: AppColors.textHint)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIGHTBOX OVERLAY
// ─────────────────────────────────────────────────────────────────────────────
class _Lightbox extends StatefulWidget {
  final List<String> images;
  final int          initialIndex;
  final VoidCallback onClose;
  const _Lightbox({required this.images, required this.initialIndex,
      required this.onClose});

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late int             _idx;
  late PageController  _ctrl;

  @override
  void initState() {
    super.initState();
    _idx  = widget.initialIndex;
    _ctrl = PageController(initialPage: _idx);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.96),
        child: Stack(children: [
          PageView.builder(
            controller:    _ctrl,
            itemCount:     widget.images.length,
            onPageChanged: (i) => setState(() => _idx = i),
            itemBuilder: (_, i) => InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl:    widget.images[i],
                  fit:         BoxFit.contain,
                  placeholder: (_, __) =>
                      const Center(child: AppSpinner(color: Colors.white)),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined,
                          color: Colors.white54, size: 60),
                ),
              ),
            ),
          ),

          // Close
          Positioned(top: 44, right: 16,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 22),
              ),
            )),

          // Counter
          Positioned(top: 50, left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_idx + 1} / ${widget.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ))),

          // Thumbnails strip
          if (widget.images.length > 1)
            Positioned(bottom: 28, left: 0, right: 0,
              child: SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: widget.images.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _ctrl.animateToPage(i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                    child: Container(
                      width: 52, height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _idx == i
                                ? Colors.white
                                : Colors.transparent,
                            width: 2),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Opacity(
                        opacity: _idx == i ? 1.0 : 0.5,
                        child: CachedNetworkImage(
                            imageUrl: widget.images[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              )),
        ]),
      ),
    );
  }
}
