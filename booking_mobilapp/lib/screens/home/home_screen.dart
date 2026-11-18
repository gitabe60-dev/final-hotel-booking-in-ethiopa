import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../l10n/app_localizations.dart';
import '../../models/hotel.dart';
import '../../models/search_params.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/hotel_card.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/local_or_network_image.dart';
import '../hotels/hotel_list_screen.dart';
import '../hotels/hotel_detail_screen.dart';
import '../hotels/city_hotels_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/wishlist_screen.dart';
import '../auth/login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL WITH BOTTOM NAV (4 tabs: Home / Search / Saved / Profile)
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIdx = 0;
  final _pageCtrl = PageController();

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _onNav(int idx) {
    final isAuth = context.read<AuthProvider>().isAuthenticated;
    if ((idx == 2 || idx == 3) && !isAuth) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) {
        // After login, go to intended tab
        if (context.read<AuthProvider>().isAuthenticated) {
          setState(() => _navIdx = idx);
          _pageCtrl.jumpToPage(idx);
        }
      });
      return;
    }
    setState(() => _navIdx = idx);
    _pageCtrl.jumpToPage(idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _HomeTab(),
          HotelListScreen(),
          WishlistScreen(),
          DashboardScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(currentIndex: _navIdx, onTap: _onNav),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAVIGATION BAR — Home / Search / Saved / Profile
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    {'icon': Icons.home_outlined,          'active': Icons.home_rounded,         'label': 'Home'},
    {'icon': Icons.search_outlined,        'active': Icons.search_rounded,       'label': 'Search'},
    {'icon': Icons.favorite_border_rounded,'active': Icons.favorite_rounded,     'label': 'Saved'},
    {'icon': Icons.person_outline_rounded, 'active': Icons.person_rounded,       'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    // Use localized labels
    final labels = [
      AppLocalizations.of(context).t('home'),
      AppLocalizations.of(context).t('explore'),
      AppLocalizations.of(context).t('wishlist'),
      AppLocalizations.of(context).t('profile'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final sel   = i == currentIndex;
              final item  = _items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: sel ? 44 : 40,
                        height: sel ? 44 : 40,
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          sel
                              ? item['active'] as IconData
                              : item['icon'] as IconData,
                          color: sel ? AppColors.primary : AppColors.textHint,
                          size: sel ? 24 : 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          color: sel ? AppColors.primary : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _searchCtrl  = TextEditingController();
  bool _initialized  = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        context.read<HotelProvider>().loadHome();
      }
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _search() {
    final q = _searchCtrl.text.trim();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => HotelListScreen(
        initialParams: HotelSearchParams(name: q.isEmpty ? null : q),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hp   = context.watch<HotelProvider>();
    final user = context.watch<AuthProvider>().user;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<HotelProvider>().loadHome(forceRefresh: true),
        child: CustomScrollView(
          slivers: [
            // ── Hero SliverAppBar ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 290,
              pinned:  true,
              elevation: 0,
              backgroundColor: const Color(0xFF1D4ED8),
              // EthioStay logo on the left of the pinned app bar
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: AppLogoIcon(size: 36),
              ),
              leadingWidth: 54,
              title: RichText(
                text: const TextSpan(children: [
                  TextSpan(text: 'Ethio',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  TextSpan(text: 'Stay',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                          color: Color(0xFFD4AF37))),
                ]),
              ),
              actions: [
                // User avatar or Sign In
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: user != null
                      ? GestureDetector(
                          onTap: () => context
                              .findAncestorStateOfType<_HomeScreenState>()
                              ?._onNav(3),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withOpacity(0.22),
                            child: Text(
                              user.firstName.isNotEmpty
                                  ? user.firstName[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.login_rounded, color: Colors.white, size: 15),
                              const SizedBox(width: 6),
                              Text(l10n.t('sign_in'),
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 13, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _HeroSection(
                  searchCtrl: _searchCtrl,
                  onSearch:   _search,
                  cities:     hp.cities,
                  allHotels:  hp.allHotels,
                ),
              ),
            ),

            // ── Stats strip ───────────────────────────────────────────────
            if (!hp.homeLoading && hp.allHotels.isNotEmpty)
              SliverToBoxAdapter(
                child: _StatsStrip(
                  hotels:   hp.allHotels.length,
                  cities:   hp.cities.length,
                  featured: hp.featured.length,
                ),
              ),

            // ── Section: Browse by City (registered cities grid) ──────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon:      Icons.location_city_rounded,
                iconColor: AppColors.primary,
                title:     l10n.t('browse_city'),
                subtitle:  l10n.isAmharic
                    ? 'ሆቴሎቹን ለማየት ማንኛውም ከተማ ይምረጡ'
                    : 'Tap any city to see all its hotels',
              ),
            ),
            SliverToBoxAdapter(
              child: hp.homeLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: AppSpinner()))
                  : _CityGrid(
                      cities:    hp.cities,
                      allHotels: hp.allHotels,
                    ),
            ),

            // ── Section: Featured Hotels ──────────────────────────────────
            if (hp.featured.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon:      Icons.star_rounded,
                  iconColor: AppColors.accent,
                  title:     l10n.t('featured'),
                  subtitle:  l10n.isAmharic
                      ? 'ምርጥ ደረጃ ያላቸው ሆቴሎች'
                      : 'Hand-picked top rated stays',
                  onViewAll: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HotelListScreen())),
                ),
              ),
              // Horizontal scroll list — fixed card width/height, no squish
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 265, // card: 140 image + 85 info + 40 padding
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    itemCount: hp.featured.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: HotelCard(
                        hotel:   hp.featured[i],
                        compact: false,          // _ListCard (200w × 265h)
                        onTap:   () => Navigator.push(ctx,
                            MaterialPageRoute(builder: (_) =>
                                HotelDetailScreen(hotelId: hp.featured[i].id))),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // ── Section: Why DallolBook FAQ ───────────────────────────────
            const SliverToBoxAdapter(child: _WhyDallolBookSection()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatefulWidget {
  final TextEditingController searchCtrl;
  final VoidCallback          onSearch;
  final List<City>            cities;
  final List<Hotel>           allHotels;
  const _HeroSection({required this.searchCtrl, required this.onSearch,
    required this.cities, required this.allHotels});
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  int   _badgeIdx     = 0;
  bool  _badgeVisible = true;
  Timer? _timer;

  static const _badges = [
    '✨ አዲስ አበባ • ባህር ዳር • ሀዋሳ ✨',
    "Ethiopia's Premier Hotel Booking",
    '🏨 Discover • Book • Stay in Ethiopia',
    'የኢትዮጵያ ቀዳሚ የሆቴል ቦኪንግ',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
      if (!mounted) return;
      setState(() => _badgeVisible = false);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _badgeIdx   = (_badgeIdx + 1) % _badges.length;
          _badgeVisible = true;
        });
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF4338CA)],
        ),
      ),
      child: Stack(children: [
        Positioned(top: -50, left: -50, child: Container(
          width: 220, height: 220,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
        )),
        Positioned(bottom: -30, right: -30, child: Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
        )),
        SafeArea(bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 36),

              // Animated badge
              AnimatedOpacity(
                opacity: _badgeVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 280),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Text(_badges[_badgeIdx],
                      style: const TextStyle(color: Colors.white,
                          fontSize: 12, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(height: 14),

              Text(l10n.t('hero_title'),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                      color: Colors.white, height: 1.2),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                l10n.isAmharic
                    ? '${widget.allHotels.length} ሆቴሎች በ${widget.cities.length} ከተሞች'
                    : '${widget.allHotels.length} hotels across ${widget.cities.length} cities',
                style: TextStyle(fontSize: 13,
                    color: Colors.white.withOpacity(0.78)),
                textAlign: TextAlign.center),
              const SizedBox(height: 20),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Row(children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.searchCtrl,
                      onSubmitted: (_) => widget.onSearch(),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText:  l10n.t('search_hint'),
                        hintStyle: const TextStyle(
                            color: AppColors.textHint, fontSize: 13),
                        border:        InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onSearch,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                          color:        AppColors.accent,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(l10n.t('search'),
                          style: const TextStyle(color: Colors.white,
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS STRIP
// ─────────────────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final int hotels, cities, featured;
  const _StatsStrip({required this.hotels, required this.cities, required this.featured});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _Stat('$hotels',  l10n.t('stats_hotels'),   Icons.hotel_rounded,         AppColors.primary),
        _divider(),
        _Stat('$cities',  l10n.t('stats_cities'),   Icons.location_city_rounded, AppColors.accent),
        _divider(),
        _Stat('$featured',l10n.t('stats_featured'), Icons.star_rounded,          const Color(0xFF059669)),
        _divider(),
        _Stat('24/7',     l10n.t('stats_support'),  Icons.headset_mic_rounded,   const Color(0xFF7C3AED)),
      ]),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: AppColors.border);
}

class _Stat extends StatelessWidget {
  final String  value, label;
  final IconData icon;
  final Color   color;
  const _Stat(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 18),
    ),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w900, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// CITY GRID — tap a city → CityHotelsScreen
// ─────────────────────────────────────────────────────────────────────────────
class _CityGrid extends StatelessWidget {
  final List<City>  cities;
  final List<Hotel> allHotels;

  const _CityGrid({required this.cities, required this.allHotels});

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics:    const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          childAspectRatio: 1.35,  // wider = city photos show better
          crossAxisSpacing: 12,
          mainAxisSpacing:  12,
        ),
        itemCount: cities.length,
        itemBuilder: (ctx, i) {
          final city  = cities[i];
          final count = allHotels
              .where((h) => h.city.toLowerCase() == city.name.toLowerCase())
              .length;

          // Staggered entrance animation per card
          return _AnimatedCityCard(
            city:         city,
            hotelCount:   count,
            index:        i,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED CITY CARD — staggered entrance + press scale + shimmer on image
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedCityCard extends StatefulWidget {
  final City  city;
  final int   hotelCount;
  final int   index;        // used for staggered delay
  const _AnimatedCityCard({
    required this.city,
    required this.hotelCount,
    required this.index,
  });
  @override
  State<_AnimatedCityCard> createState() => _AnimatedCityCardState();
}

class _AnimatedCityCardState extends State<_AnimatedCityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>  _fade;
  late Animation<Offset>  _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 500),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.index.isEven ? 0.15 : -0.15),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: each card enters 80ms after the previous
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onTap(BuildContext ctx) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => CityHotelsScreen(
        cityName:    widget.city.name,
        cityRegion:  widget.city.region,
        cityImageUrl: AppImages.onlineCityFallback(widget.city.name),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown:   (_) => setState(() => _pressed = true),
          onTapUp:     (_) { setState(() => _pressed = false); _onTap(context); },
          onTapCancel: ()  => setState(() => _pressed = false),
          child: AnimatedScale(
            scale:    _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color:  Colors.black.withOpacity(_pressed ? 0.05 : 0.14),
                    blurRadius: _pressed ? 4 : 14,
                    offset: Offset(0, _pressed ? 2 : 5),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(fit: StackFit.expand, children: [
                // ── City photo (local → online fallback) ──────────────────
                LocalOrNetworkImage(
                  localPath:  AppImages.cityImage(widget.city.name),
                  networkUrl: AppImages.onlineCityFallback(widget.city.name),
                  fit:        BoxFit.cover,
                  placeholder: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.7),
                            AppColors.primaryDark],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.city.name[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.location_city_rounded,
                            color: Colors.white54, size: 36),
                        const SizedBox(height: 6),
                        Text(widget.city.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ),

                // ── Gradient scrim ─────────────────────────────────────────
                Positioned.fill(child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.72),
                      ],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                )),

                // ── Hotel count badge — top-right ──────────────────────────
                Positioned(top: 10, right: 10,
                  child: AnimatedOpacity(
                    opacity:  _pressed ? 0.7 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:        widget.hotelCount > 0
                            ? AppColors.accent
                            : Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6)],
                      ),
                      child: Text(
                        widget.hotelCount > 0
                            ? '${widget.hotelCount} 🏨'
                            : '—',
                        style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   11,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  )),

                // ── City name + region — bottom ────────────────────────────
                Positioned(bottom: 0, left: 0, right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.city.name,
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   16,
                            fontWeight: FontWeight.w900,
                            height:     1.15,
                            shadows: [Shadow(
                                color: Colors.black54,
                                blurRadius: 4)],
                          ),
                          maxLines:  1,
                          overflow:  TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          if (widget.hotelCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.t('explore'),
                                      style: const TextStyle(
                                          color:      Colors.white,
                                          fontSize:   10,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 10),
                                ]),
                            )
                          else
                            Text(l10n.isAmharic ? 'ቶሎ ይመጣል' : 'Coming soon',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 10)),
                        ]),
                      ],
                    ),
                  )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData   icon;
  final Color      iconColor;
  final String     title;
  final String?    subtitle;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.icon, required this.iconColor,
    required this.title, this.subtitle, this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        ])),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(l10n.t('view_all'),
                    style: const TextStyle(fontSize: 12, color: AppColors.primary,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 10, color: AppColors.primary),
              ]),
            ),
          ),
      ]),
    ]),
  );
}
}

// ─────────────────────────────────────────────────────────────────────────────
// WHY DALLOLBOOK — FAQ SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _WhyDallolBookSection extends StatelessWidget {
  const _WhyDallolBookSection();

  static const _faqs = [
    {
      'icon':  '🏨',
      'color': Color(0xFF2563EB),
      'q':     'Why book with EthioStay?',
      'a':     "EthioStay is Ethiopia's premier hotel booking platform. Book with confidence — real hotels, real rooms, real prices.",
    },
    {
      'icon':  '✅',
      'color': Color(0xFF059669),
      'q':     'How are hotels verified?',
      'a':     'Every hotel on our platform is manually registered by our sub-administrators and hotel managers. We verify hotel name, address, room details, and photos before listing. Managers must upload valid business registration.',
    },
    {
      'icon':  '💳',
      'color': Color(0xFFD97706),
      'q':     'How does payment work?',
      'a':     'We support all major Ethiopian payment methods: Telebirr, CBE Birr, Awash Bank, Dashen Bank, Chapa, and more. After transferring, you upload your payment screenshot — the hotel manager manually verifies and confirms your booking.',
    },
    {
      'icon':  '🛡️',
      'color': Color(0xFF7C3AED),
      'q':     'Is my booking secure?',
      'a':     'Your National ID is uploaded at booking time and securely stored. The hotel manager reviews your identity before check-in. All bookings have a unique reference number for tracking.',
    },
    {
      'icon':  '📞',
      'color': Color(0xFFDB2777),
      'q':     'What if I have an issue?',
      'a':     'Each hotel has a dedicated manager reachable via phone. You can also cancel your booking before check-in from your dashboard. Our team responds within 24 hours for escalated issues.',
    },
    {
      'icon':  '🌍',
      'color': Color(0xFF0891B2),
      'q':     'Which cities are covered?',
      'a':     'We currently cover Addis Ababa, Bahir Dar, Hawassa, Dire Dawa, Mekelle, Gondar, Adama, Jimma, Harar, Arba Minch, and more — with new cities added regularly by our sub-admins.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Section header
      Container(
        margin: const EdgeInsets.fromLTRB(14, 24, 14, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🇪🇹', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.t('why_title'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                      color: Colors.white)),
              Text(l10n.t('why_sub'),
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ])),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pill('🏨 100+ ${l10n.t('stats_hotels')}'),
            _pill('12 ${l10n.t('stats_cities')}'),
            _pill('✅ ${l10n.isAmharic ? "የተረጋገጡ" : "Verified"}'),
            _pill('24/7 ${l10n.t('stats_support')}'),
          ]),
        ]),
      ),

      // FAQ cards
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(children: _faqs.map((faq) =>
            _FaqCard(
              icon:  faq['icon'] as String,
              color: faq['color'] as Color,
              question: faq['q'] as String,
              answer:   faq['a'] as String,
            )).toList()),
      ),

      // Trust badges
      Container(
        margin: const EdgeInsets.fromLTRB(14, 16, 14, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Text(
            l10n.isAmharic
                ? 'ሺዎች ተጓዦች ያምኑበታል'
                : 'Trusted by thousands of travelers',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _trust('🔒', l10n.isAmharic ? 'ደህንነቱ\nተጠብቋል'  : 'Secure\nPayments'),
            _trust('🏅', l10n.isAmharic ? 'የተረጋገጡ\nሆቴሎች'   : 'Verified\nHotels'),
            _trust('⭐', l10n.isAmharic ? 'ምርጥ\nልምድ'       : 'Rated\nExperience'),
            _trust('🇪🇹', l10n.isAmharic ? 'ኢትዮጵያ\nውስጥ'    : 'Made in\nEthiopia'),
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
        border: Border.all(color: Colors.white.withOpacity(0.25))),
    child: Text(label,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _trust(String emoji, String label) => Column(
    mainAxisSize: MainAxisSize.min, children: [
    Text(emoji, style: const TextStyle(fontSize: 28)),
    const SizedBox(height: 4),
    Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary,
            fontWeight: FontWeight.w600, height: 1.3)),
  ]);
}

// FAQ expandable card
class _FaqCard extends StatefulWidget {
  final String icon, question, answer;
  final Color  color;
  const _FaqCard({required this.icon, required this.color,
    required this.question, required this.answer});
  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl   = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 250));
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(
            color: _expanded
                ? widget.color.withOpacity(0.35)
                : AppColors.border,
            width: _expanded ? 1.5 : 1,
          ),
          boxShadow: _expanded
              ? [BoxShadow(color: widget.color.withOpacity(0.1),
                  blurRadius: 10, offset: const Offset(0, 3))]
              : [BoxShadow(color: Colors.black.withOpacity(0.03),
                  blurRadius: 6)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(widget.icon,
                  style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.question,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _expanded ? widget.color : AppColors.textPrimary)),
            ),
            RotationTransition(
              turns: _rotate,
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: _expanded ? widget.color : AppColors.textHint,
                  size: 24),
            ),
          ]),
          if (_expanded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.color.withOpacity(0.1))),
              child: Text(widget.answer,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6)),
            ),
          ],
        ]),
      ),
    );
  }
}
