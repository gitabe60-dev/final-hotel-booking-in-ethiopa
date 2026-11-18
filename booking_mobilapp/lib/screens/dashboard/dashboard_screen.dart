import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_spinner.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../auth/login_screen.dart';
import '../hotels/hotel_list_screen.dart';
import '../notifications/notifications_screen.dart';
import 'bookings_list_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  // Profile data loaded from GET /api/v1/guest/profile
  // Response: { data: { user: {...}, booking_counts: { pending, confirmed, completed, cancelled } } }
  Map<String, int> _profileCounts = {};
  bool _profileLoading = false;
  int  _unreadNotifs   = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuth = context.read<AuthProvider>().isAuthenticated;
      if (isAuth && !_initialized) {
        _initialized = true;
        _loadAll();
      }
    });
  }

  Future<void> _loadAll() async {
    await Future.wait([
      context.read<BookingProvider>().loadMyBookings(),
      _loadProfile(),
      _loadNotifCount(),
    ]);
  }

  // Load booking counts from GET /api/v1/guest/profile
  Future<void> _loadProfile() async {
    setState(() => _profileLoading = true);
    try {
      final res  = await ApiService.instance.get(ApiEndpoints.guestProfile);
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final c    = data['booking_counts'] as Map<String, dynamic>? ?? {};
      setState(() {
        _profileCounts = {
          'pending':   c['pending']   as int? ?? 0,
          'confirmed': c['confirmed'] as int? ?? 0,
          'completed': c['completed'] as int? ?? 0,
          'cancelled': c['cancelled'] as int? ?? 0,
        };
      });
    } catch (_) {}
    setState(() => _profileLoading = false);
  }

  // Load unread notification count from GET /api/v1/notifications
  Future<void> _loadNotifCount() async {
    try {
      final res  = await ApiService.instance.get(ApiEndpoints.notifications);
      final data = res['data'];
      final list = data is List
          ? data
          : (data is Map ? (data['notifications'] as List? ?? []) : []);
      final unread = list
          .where((n) => (n as Map)['is_read'] != true)
          .length;
      setState(() => _unreadNotifs = unread);
    } catch (_) {}
  }

  static const _statusStyles = <String, _StatusStyle>{
    'pending':   _StatusStyle(Color(0xFFFFFBEB), Color(0xFFD97706), '⏳'),
    'confirmed': _StatusStyle(Color(0xFFECFDF5), Color(0xFF059669), '✅'),
    'completed': _StatusStyle(Color(0xFFEFF6FF), Color(0xFF2563EB), '🏁'),
    'cancelled': _StatusStyle(Color(0xFFFEF2F2), Color(0xFFDC2626), '❌'),
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bp   = context.watch<BookingProvider>();

    if (!auth.isAuthenticated) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.person_outline_rounded,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.isAmharic
                    ? 'ዳሽቦርድ ለማግኘት ይግቡ'
                    : 'Sign in to access your dashboard',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                l10n.isAmharic
                    ? 'ቦኪንጎችን፣ ዝርዝሮችን እና መገለጫን ያስተዳድሩ'
                    : 'Manage bookings, wishlist, and profile',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen())),
                  child: Text(l10n.t('sign_in'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      );
    }

    // Use profile counts if loaded, fall back to bookings list counts
    final counts = _profileCounts.isNotEmpty
        ? _profileCounts
        : {
            'pending':   bp.bookings.where((b) => b.status == 'pending').length,
            'confirmed': bp.bookings.where((b) => b.status == 'confirmed').length,
            'completed': bp.bookings.where((b) => b.status == 'completed').length,
            'cancelled': bp.bookings.where((b) => b.status == 'cancelled').length,
          };

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            // ── Header SliverAppBar ─────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primary,
              expandedHeight: 140,
              automaticallyImplyLeading: false,
              actions: [
                // Notifications bell with badge
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 24),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      ).then((_) => _loadNotifCount()),
                    ),
                    if (_unreadNotifs > 0)
                      Positioned(
                        right: 8, top: 8,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              _unreadNotifs > 9 ? '9+' : '$_unreadNotifs',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const LangToggleDark(),
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.white70, size: 22),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      context.read<BookingProvider>().clearError();
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end:   Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Row(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          auth.user!.firstName.isNotEmpty
                              ? auth.user!.firstName[0].toUpperCase()
                              : 'G',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          'Welcome, ${auth.user!.firstName}! 👋',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.user!.email ?? auth.user!.phone ?? '',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Booking stats grid (from /guest/profile) ─────────────
                  Text(l10n.t('my_bookings'),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  _profileLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: AppSpinner(size: SpinnerSize.small),
                          ))
                      : GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount:  4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing:  8,
                          childAspectRatio: 0.85,
                          children: counts.entries.map((e) {
                            final s = _statusStyles[e.key]!;
                            return Container(
                              decoration: BoxDecoration(
                                color: s.bg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: s.fg.withOpacity(0.15)),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(s.emoji,
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text('${e.value}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: s.fg)),
                                  Text(
                                    e.key == 'pending'   ? l10n.t('pending')   :
                                    e.key == 'confirmed' ? l10n.t('confirmed') :
                                    e.key == 'completed' ? l10n.t('completed') :
                                                           l10n.t('cancelled'),
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: s.fg.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 20),

                  // ── Quick actions ────────────────────────────────────────
                  Text(l10n.t('quick_actions'),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _QuickAction(
                      emoji:       '📋',
                      label:       l10n.t('my_bookings'),
                      desc:        l10n.isAmharic ? 'ቦኪንጎችን ይመልከቱ' : 'View reservations',
                      borderColor: AppColors.primary.withOpacity(0.3),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const BookingsListScreen())),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickAction(
                      emoji:       '♥',
                      label:       l10n.t('wishlist'),
                      desc:        l10n.isAmharic ? 'የተቀመጡ ሆቴሎች' : 'Saved hotels',
                      borderColor: Colors.red.withOpacity(0.3),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WishlistScreen())),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickAction(
                      emoji:       '👤',
                      label:       l10n.t('profile'),
                      desc:        l10n.isAmharic ? 'የግል መረጃ' : 'Personal info',
                      borderColor: Colors.purple.withOpacity(0.3),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen())),
                    )),
                  ]),
                  const SizedBox(height: 20),

                  // ── Recent bookings ─────────────────────────────────────
                  Row(children: [
                    Text(l10n.t('recent_bookings'),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const BookingsListScreen())),
                      child: Text(
                        l10n.isAmharic ? 'ሁሉንም ይመልከቱ →' : 'View all →',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primary)),
                    ),
                  ]),
                  const SizedBox(height: 8),

                  if (bp.loading)
                    const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()))
                  else if (bp.error != null)
                    _ErrorBanner(message: bp.error!)
                  else if (bp.bookings.isEmpty)
                    _EmptyBookings(
                      onBrowse: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HotelListScreen())),
                    )
                  else
                    ...bp.bookings.take(5).map((b) => _BookingTile(
                          booking:   b,
                          statusStyles: _statusStyles,
                          fmt: (v) => v
                              .toStringAsFixed(0)
                              .replaceAllMapped(
                                  RegExp(
                                      r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]},'),
                        )),

                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _StatusStyle {
  final Color  bg, fg;
  final String emoji;
  const _StatusStyle(this.bg, this.fg, this.emoji);
}

class _QuickAction extends StatelessWidget {
  final String emoji, label, desc;
  final Color  borderColor;
  final VoidCallback onTap;
  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.desc,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(14),
            border:       Border.all(color: borderColor, width: 2),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.03), blurRadius: 6)],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Text(desc,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textHint)),
          ]),
        ),
      );
}

class _BookingTile extends StatelessWidget {
  final booking;
  final Map<String, _StatusStyle> statusStyles;
  final String Function(double) fmt;
  const _BookingTile({required this.booking, required this.statusStyles, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final style = statusStyles[booking.status] ??
        const _StatusStyle(AppColors.surfaceGray, AppColors.textHint, '•');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: booking.hotelImage != null
              ? Image.network(booking.hotelImage,
                  width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder())
              : _placeholder(),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(booking.hotelName,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(
            '${booking.checkIn} → ${booking.checkOut} · '
            '${booking.rooms} room${booking.rooms > 1 ? "s" : ""}',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(8)),
            child: Builder(builder: (ctx) {
              final l = AppLocalizations.of(ctx);
              final label =
                  booking.status == 'pending'   ? l.t('pending')   :
                  booking.status == 'confirmed' ? l.t('confirmed') :
                  booking.status == 'completed' ? l.t('completed') :
                  booking.status == 'cancelled' ? l.t('cancelled') :
                  booking.status;
              return Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: style.fg));
            }),
          ),
          const SizedBox(height: 4),
          Text('ETB ${fmt(booking.totalPrice)}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
        ]),
      ]),
    );
  }

  Widget _placeholder() => Container(
      width: 56, height: 56, color: AppColors.surfaceGray,
      child: const Icon(Icons.hotel_outlined,
          color: AppColors.textHint, size: 28));
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AppColors.errorLight,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(message,
            style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          l10n.isAmharic
              ? 'ባክዳን port 8080 ላይ መሠራቱን ያረጋግጡ።'
              : 'Make sure the backend is running on port 8080.',
          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
          textAlign: TextAlign.center),
      ]),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyBookings({required this.onBrowse});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color:        AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        const Icon(Icons.calendar_month_outlined,
            size: 44, color: AppColors.textHint),
        const SizedBox(height: 10),
        Text(l10n.t('no_bookings'),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          l10n.isAmharic
              ? 'ሆቴሎችን ያስሱ እና የመጀመሪያ ቦኪንጉን ያድርጉ!'
              : 'Browse hotels and make your first reservation!',
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
          textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onBrowse,
          icon:  const Icon(Icons.search_rounded, size: 16),
          label: Text(l10n.t('browse_hotels')),
        ),
      ]),
    );
  }
}
