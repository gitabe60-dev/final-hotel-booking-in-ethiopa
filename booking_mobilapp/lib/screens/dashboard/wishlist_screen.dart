import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/local_or_network_image.dart';
import '../../widgets/snack_helper.dart';
import '../../widgets/star_rating.dart';
import '../auth/login_screen.dart';
import '../hotels/hotel_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;
  final Set<int> _removing = {};
  late final AnimationController _headerCtrl;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized && context.read<AuthProvider>().isAuthenticated) {
        _initialized = true;
        context.read<WishlistProvider>().load();
      }
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context);
    final isAuth = context.watch<AuthProvider>().isAuthenticated;
    final wl     = context.watch<WishlistProvider>();
    final user   = context.watch<AuthProvider>().user;

    // ── Not authenticated ────────────────────────────────────────────────
    if (!isAuth) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: DallolAppBar(title: l10n.t('wishlist')),
        body: FadeTransition(
          opacity: _headerFade,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Icon circle
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.primary.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.favorite_border_rounded,
                      size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                Text(l10n.isAmharic ? 'የተቀመጡ ሆቴሎች' : 'Your Saved Hotels',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text(
                  l10n.isAmharic
                      ? 'ምርጥ ሆቴሎቻቸውን ለማስቀመጥ ይግቡ።\nከማንኛውም መሳሪያ ማግኘት ይቻላል።'
                      : 'Sign in to save your favourite hotels and\naccess them anytime from any device.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: Text(
                      l10n.isAmharic
                          ? 'ሆቴሎችን ለማስቀመጥ ይግቡ'
                          : 'Sign In to Save Hotels',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                const SizedBox(height: 24),
                _BenefitsBox(l10n: l10n),
              ]),
            ),
          ),
        ),
      );
    }

    // ── Authenticated ────────────────────────────────────────────────────
    final itemCount = wl.items.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(
        title: itemCount > 0
            ? '${l10n.t("wishlist")} ($itemCount)'
            : l10n.t('wishlist'),
        showBack: Navigator.canPop(context),
      ),
      body: wl.loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<WishlistProvider>().load(),
              child: itemCount == 0
                  ? _EmptyWishlist(userName: user?.firstName ?? '', l10n: l10n)
                  : CustomScrollView(
                      slivers: [
                        // ── Stats bar ──────────────────────────────────────
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _headerFade,
                            child: Container(
                              color:   Colors.white,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: Row(children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.favorite_rounded,
                                      color: Colors.red, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '$itemCount ${l10n.isAmharic ? "ሆቴሎች ተቀምጠዋል" : "saved hotel${itemCount != 1 ? "s" : ""}"}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'ETB ${_fmt(wl.items.fold(0.0, (s, h) => s + h.pricePerNight) / itemCount)} ${l10n.isAmharic ? "ሞዳ/ምሽት" : "avg/nt"}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                            child: Divider(height: 1)),

                        // ── Hotel grid ─────────────────────────────────────
                        SliverPadding(
                          padding: const EdgeInsets.all(14),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:   2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing:  12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) {
                                final hotel    = wl.items[i];
                                final removing = _removing.contains(hotel.id);
                                return _SavedHotelCard(
                                  hotel:    hotel,
                                  removing: removing,
                                  fmt:      _fmt,
                                  l10n:     l10n,
                                  onView: () => Navigator.push(ctx,
                                      MaterialPageRoute(builder: (_) =>
                                          HotelDetailScreen(hotelId: hotel.id))),
                                  onRemove: () async {
                                    setState(() => _removing.add(hotel.id));
                                    await context
                                        .read<WishlistProvider>()
                                        .toggle(hotel);
                                    if (mounted) {
                                      setState(
                                          () => _removing.remove(hotel.id));
                                      showInfo(ctx,
                                          '${hotel.name} ${l10n.isAmharic ? "ከተቀመጡ ተወገደ" : "removed from saved"}');
                                    }
                                  },
                                );
                              },
                              childCount: itemCount,
                            ),
                          ),
                        ),

                        // ── Tip banner ─────────────────────────────────────
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color(0xFFFDE68A))),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('💡',
                                      style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      l10n.isAmharic
                                          ? 'ማሳሰቢያ: ሆቴል ወደ ዝርዝር ሄደው ♥ ቁልፍ ይጫኑ ሆቴሉን ያስቀምጣሉ።'
                                          : 'Tip: Visit a hotel detail page and tap the ♥ button to save any hotel here.',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF92400E),
                                          height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SAVED HOTEL CARD
// Smart image: AspectRatio(3/2) — same as hotel_card _GridCard
// ─────────────────────────────────────────────────────────────────────────────
class _SavedHotelCard extends StatefulWidget {
  final dynamic hotel;
  final bool removing;
  final String Function(double) fmt;
  final AppLocalizations l10n;
  final VoidCallback onView, onRemove;

  const _SavedHotelCard({
    required this.hotel,
    required this.removing,
    required this.fmt,
    required this.l10n,
    required this.onView,
    required this.onRemove,
  });

  @override
  State<_SavedHotelCard> createState() => _SavedHotelCardState();
}

class _SavedHotelCardState extends State<_SavedHotelCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final h = widget.hotel;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown:   (_) => _ctrl.forward(),
        onTapUp:     (_) { _ctrl.reverse(); widget.onView(); },
        onTapCancel: ()  => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image — 3:2 aspect ratio (same as HotelCard _GridCard) ──
              AspectRatio(
                aspectRatio: 3 / 2,
                child: Stack(fit: StackFit.expand, children: [
                  LocalOrNetworkImage(
                    localPath:   AppImages.hotelCover(h.name),
                    networkUrl:  h.thumbnailUrl,
                    fit:         BoxFit.cover,
                    errorWidget: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryDark,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end:   Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.hotel_rounded,
                          color: Colors.white38, size: 36),
                    ),
                  ),
                  // Gradient scrim
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin:  Alignment.topCenter,
                          end:    Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.52),
                          ],
                          stops: const [0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Remove / saved button — top right
                  Positioned(
                    top: 7, right: 7,
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color:  Colors.white.withValues(alpha: 0.92),
                          shape:  BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6),
                          ],
                        ),
                        child: widget.removing
                            ? const Padding(
                                padding: EdgeInsets.all(6),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.red))
                            : const Icon(Icons.favorite_rounded,
                                color: Colors.red, size: 16),
                      ),
                    ),
                  ),
                  // Price badge — bottom left
                  Positioned(
                    bottom: 7, left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'ETB ${widget.fmt(h.pricePerNight)}/nt',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ]),
              ),

              // ── Info section ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(h.city,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      StarRatingSmall(rating: h.rating, size: 11),
                      const Spacer(),
                      // "View" button
                      GestureDetector(
                        onTap: widget.onView,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              AppColors.primary,
                              AppColors.primaryDark,
                            ]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.l10n.isAmharic ? 'ይመልከቱ' : 'View',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY WISHLIST
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyWishlist extends StatelessWidget {
  final String            userName;
  final AppLocalizations  l10n;
  const _EmptyWishlist({required this.userName, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(children: [
            Container(
              width: 92, height: 92,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFEBEB), Color(0xFFFEF2F2)]),
                shape:  BoxShape.circle,
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2), width: 1.5),
              ),
              child: const Icon(Icons.favorite_border_rounded,
                  size: 44, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              userName.isNotEmpty
                  ? (l10n.isAmharic
                      ? 'ሰላም $userName፣ ምንም ሆቴሎች አልተቀመጡም!'
                      : 'Hi $userName, No Saved Hotels Yet!')
                  : (l10n.isAmharic
                      ? 'ምንም ሆቴሎች አልተቀመጡም!'
                      : 'No Saved Hotels Yet!'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.isAmharic
                  ? 'ሆቴሉን ሲጎበኙ ♥ ቁልፉን ይጫኑ።\nቦኪንጎ ሲያደርጉ ቀላል ያደርጋል።'
                  : 'Tap the ♥ button on any hotel to save it here.\nYour saved hotels are synced to your account.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: Text(
                  l10n.isAmharic ? 'ሆቴሎችን ያስሱ' : 'Explore Hotels',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 32),
        _BenefitsBox(l10n: l10n),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BENEFITS BOX (used in both unauthenticated + empty states)
// ─────────────────────────────────────────────────────────────────────────────
class _BenefitsBox extends StatelessWidget {
  final AppLocalizations l10n;
  const _BenefitsBox({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final items = l10n.isAmharic
        ? const [
            '❤️ ሆቴሎችን ወዲያው ያስቀምጡ',
            '🔔 የዋጋ ለውጥ ሲኖር ማሳወቂያ ይደርስዎታል',
            '📱 ከማንኛውም መሳሪያ ማግኘት ይቻላል',
            '🏨 የተቀመጡ ሆቴሎችን ቀላሉን ያወዳድሩ',
          ]
        : const [
            '❤️ Save hotels you love instantly',
            '🔔 Get notified on price changes',
            '📱 Access from any device anytime',
            '🏨 Compare saved hotels easily',
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          l10n.isAmharic ? 'ለምን ሆቴሎችን ያስቀምጣሉ?' : 'Why save hotels?',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(item,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4)),
            )),
      ]),
    );
  }
}
