/// admin_dashboard_screen.dart
/// 
/// Mirrors the web system's admin dashboards exactly.
/// Same backend API calls as the web frontend:
///   super_admin  → GET /api/admin/super/dashboard
///   sub_admin    → GET /api/admin/subadmin/dashboard
///   hotel_manager→ GET /api/admin/manager/dashboard + /manager/payments + /manager/notifications
///   broker       → GET /api/admin/broker/dashboard
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/admin_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/snack_helper.dart';
import '../auth/login_screen.dart';
import 'admin_profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL
// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    final role = context.read<AuthProvider>().user?.role ?? 'hotel_manager';
    _tab = TabController(length: _tabCount(role), vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  int _tabCount(String role) {
    switch (role) {
      case 'super_admin':   return 4; // Overview / Sub-Admins / Bookings / Profile
      case 'sub_admin':     return 4; // Overview / Hotels / Bookings / Profile
      case 'hotel_manager': return 5; // Overview / Rooms / Bookings / Payments / Profile
      case 'broker':        return 3; // Overview / Bookings / Profile
      default:              return 3;
    }
  }

  List<Tab> _tabs(String role) {
    const prof = Tab(icon: Icon(Icons.person_rounded, size: 18), text: 'Profile');
    switch (role) {
      case 'super_admin':
        return const [
          Tab(icon: Icon(Icons.dashboard_rounded,      size: 18), text: 'Overview'),
          Tab(icon: Icon(Icons.manage_accounts_rounded, size: 18), text: 'Sub-Admins'),
          Tab(icon: Icon(Icons.book_online_rounded,    size: 18), text: 'Bookings'),
          prof,
        ];
      case 'sub_admin':
        return const [
          Tab(icon: Icon(Icons.dashboard_rounded,  size: 18), text: 'Overview'),
          Tab(icon: Icon(Icons.hotel_rounded,       size: 18), text: 'Hotels'),
          Tab(icon: Icon(Icons.book_online_rounded, size: 18), text: 'Bookings'),
          prof,
        ];
      case 'hotel_manager':
        return const [
          Tab(icon: Icon(Icons.dashboard_rounded,  size: 18), text: 'Overview'),
          Tab(icon: Icon(Icons.bed_rounded,         size: 18), text: 'Rooms'),
          Tab(icon: Icon(Icons.book_online_rounded, size: 18), text: 'Bookings'),
          Tab(icon: Icon(Icons.payment_rounded,     size: 18), text: 'Payments'),
          prof,
        ];
      case 'broker':
      default:
        return const [
          Tab(icon: Icon(Icons.dashboard_rounded,  size: 18), text: 'Overview'),
          Tab(icon: Icon(Icons.book_online_rounded, size: 18), text: 'Bookings'),
          prof,
        ];
    }
  }

  List<Widget> _views(String role) {
    switch (role) {
      case 'super_admin':
        return [
          const _SuperOverview(),
          const _SubAdminsTab(),
          const _BookingsTab(endpoint: AdminEndpoints.superBookings, role: 'super_admin'),
          const AdminProfileScreen(),
        ];
      case 'sub_admin':
        return [
          const _SubAdminOverview(),
          const _SubHotelsTab(),
          const _BookingsTab(endpoint: AdminEndpoints.subBookings, role: 'sub_admin'),
          const AdminProfileScreen(),
        ];
      case 'hotel_manager':
        return [
          const _ManagerOverview(),
          const _ManagerRoomsTab(),
          const _BookingsTab(
              endpoint: AdminEndpoints.managerBookings,
              role:     'hotel_manager',
              canUpdateStatus: true),
          const _ManagerPaymentsTab(),
          const AdminProfileScreen(),
        ];
      case 'broker':
      default:
        return [
          const _BrokerOverview(),
          const _BookingsTab(endpoint: AdminEndpoints.brokerBookings, role: 'broker'),
          const AdminProfileScreen(),
        ];
    }
  }

  static const _roleColors = <String, Color>{
    'super_admin':   Color(0xFF7C3AED),
    'sub_admin':     Color(0xFF2563EB),
    'hotel_manager': Color(0xFF059669),
    'broker':        Color(0xFFD97706),
  };
  static const _roleLabels = <String, String>{
    'super_admin':   'Super Admin',
    'sub_admin':     'Sub Admin',
    'hotel_manager': 'Hotel Manager',
    'broker':        'Broker',
  };

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final user  = auth.user;
    final role  = user?.role ?? 'hotel_manager';
    final color = _roleColors[role] ?? AppColors.primary;
    final label = _roleLabels[role] ?? role;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor:   color,
        foregroundColor:   Colors.white,
        elevation:         0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.22),
            child: Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName[0].toUpperCase() : 'A',
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user?.fullName ?? 'Admin',
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w800, color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(label,
                    style: const TextStyle(fontSize: 10,
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          )),
        ]),
        actions: [
          _AdminLangToggle(color: color),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
            tooltip: 'Sign Out',
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller:           _tab,
          labelColor:           Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor:       Colors.white,
          indicatorWeight:      3,
          isScrollable:         _tabCount(role) > 4,
          tabs: _tabs(role),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children:   _views(role),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPER ADMIN — OVERVIEW
// Mirrors web SuperDashboard.tsx: stats grid + quick actions + platform overview
// API: GET /api/admin/super/dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _SuperOverview extends StatefulWidget {
  const _SuperOverview();
  @override State<_SuperOverview> createState() => _SuperOverviewState();
}
class _SuperOverviewState extends State<_SuperOverview> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance
          .adminGet(AdminEndpoints.superDashboard);
      setState(() => _data = (r['data'] as Map<String, dynamic>?) ?? {});
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));
    final o = (_data['overview'] as Map<String, dynamic>?) ?? {};
    final bookings = (_data['recent_bookings'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Stats grid — matches web: Sub-Admins, Cities, Managers, Revenue
          _gridTitle('Platform Overview'),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _StatCard('Sub-Admins',        '${o['sub_admins'] ?? 0}',         '👥', const Color(0xFF2563EB)),
              _StatCard('Hotel Managers',    '${o['hotel_managers'] ?? 0}',     '👨‍💼', const Color(0xFF059669)),
              _StatCard('Active Hotels',     '${o['active_hotels'] ?? 0}',      '🏨', const Color(0xFF7C3AED)),
              _StatCard('Total Revenue',     'ETB ${_fmt(o['total_revenue'])}', '💰', const Color(0xFFD97706)),
              _StatCard('Total Guests',      '${o['total_guests'] ?? 0}',       '👤', const Color(0xFF0891B2)),
              _StatCard('Confirmed',         '${o['confirmed_bookings'] ?? 0}', '✅', const Color(0xFF059669)),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions
          _gridTitle('Quick Actions'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _ActionCard('🗺️', 'Manage Cities',
                'Add/remove cities', const Color(0xFF7C3AED), () {})),
            const SizedBox(width: 10),
            Expanded(child: _ActionCard('👥', 'Sub-Admins',
                'Create & assign cities', const Color(0xFF2563EB), () {})),
          ]),
          const SizedBox(height: 20),

          // Platform stats detail
          _gridTitle('Platform Details'),
          const SizedBox(height: 10),
          _DetailCard(items: [
            {'label': 'Pending Bookings',  'value': '${o['pending_bookings'] ?? 0}'},
            {'label': 'Confirmed Bookings','value': '${o['confirmed_bookings'] ?? 0}'},
            {'label': 'Total Guests',      'value': '${o['total_guests'] ?? 0}'},
            {'label': 'Brokers',           'value': '${o['brokers'] ?? 0}'},
          ]),
          const SizedBox(height: 20),

          // Recent bookings
          _gridTitle('Recent Bookings (last 8)'),
          const SizedBox(height: 10),
          if (bookings.isEmpty)
            _emptyMsg('No bookings yet')
          else
            ...bookings.take(8).map((b) =>
                _BookingRow(b as Map<String, dynamic>, role: 'super_admin')),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPER ADMIN — SUB-ADMINS LIST
// API: GET /api/admin/super/sub-admins
// ─────────────────────────────────────────────────────────────────────────────
class _SubAdminsTab extends StatefulWidget {
  const _SubAdminsTab();
  @override State<_SubAdminsTab> createState() => _SubAdminsTabState();
}
class _SubAdminsTabState extends State<_SubAdminsTab> {
  List<dynamic> _list    = [];
  bool          _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.superSubAdmins);
      final d = r['data'];
      setState(() => _list = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));
    return RefreshIndicator(
      onRefresh: _load,
      child: _list.isEmpty
          ? _EmptyState('No sub-admins yet', '👥')
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _list.length,
              itemBuilder: (_, i) {
                final a = _list[i] as Map<String, dynamic>;
                return _AdminCard(
                  leading: _avatar(a['full_name'], const Color(0xFF2563EB)),
                  title:   a['full_name']?.toString() ?? '',
                  subtitle: a['email']?.toString() ?? '',
                  status:  a['status']?.toString() ?? 'active',
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB ADMIN — OVERVIEW
// Mirrors web SubAdminDashboard.tsx: assigned city, hotels, managers, bookings
// API: GET /api/admin/subadmin/dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _SubAdminOverview extends StatefulWidget {
  const _SubAdminOverview();
  @override State<_SubAdminOverview> createState() => _SubAdminOverviewState();
}
class _SubAdminOverviewState extends State<_SubAdminOverview> {
  Map<String, dynamic> _data   = {};
  bool                 _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.subDashboard);
      setState(() => _data = (r['data'] as Map<String, dynamic>?) ?? {});
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));
    final city     = _data['city']?.toString() ?? 'Not assigned';
    final hotels   = (_data['hotels']          as List<dynamic>?) ?? [];
    final managers = (_data['managers']        as List<dynamic>?) ?? [];
    final bookings = (_data['recent_bookings'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Assigned city banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.location_city_rounded,
                  color: Colors.white, size: 28),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your Assigned City',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                Text(city, style: const TextStyle(color: Colors.white,
                    fontSize: 22, fontWeight: FontWeight.w900)),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          // Stats
          Row(children: [
            Expanded(child: _StatCard('Hotels',   '${hotels.length}',   '🏨', const Color(0xFF2563EB))),
            const SizedBox(width: 10),
            Expanded(child: _StatCard('Managers', '${managers.length}', '👨‍💼', const Color(0xFF059669))),
            const SizedBox(width: 10),
            Expanded(child: _StatCard('Bookings', '${bookings.length}', '📅', const Color(0xFFD97706))),
          ]),
          const SizedBox(height: 20),

          // Hotels in city
          _gridTitle('Hotels in $city'),
          const SizedBox(height: 10),
          if (hotels.isEmpty)
            _emptyMsg('No hotels yet in $city')
          else
            ...hotels.take(5).map((h) {
              final ho = h as Map<String, dynamic>;
              return _AdminCard(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      color: (ho['is_active'] == true)
                          ? AppColors.successLight : AppColors.surfaceGray,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.hotel_rounded,
                      color: (ho['is_active'] == true)
                          ? AppColors.success : AppColors.textHint, size: 22),
                ),
                title:   ho['name']?.toString() ?? '',
                subtitle: '${ho['type'] ?? ''} · ETB ${_fmt(ho['price_per_night'])}',
                status:  (ho['is_active'] == true) ? 'active' : 'inactive',
              );
            }),
          const SizedBox(height: 20),

          // Managers
          _gridTitle('Hotel Managers'),
          const SizedBox(height: 10),
          if (managers.isEmpty)
            _emptyMsg('No managers assigned yet')
          else
            ...managers.take(5).map((m) {
              final mg = m as Map<String, dynamic>;
              return _AdminCard(
                leading: _avatar(mg['full_name'], const Color(0xFF059669)),
                title:   mg['full_name']?.toString() ?? '',
                subtitle: mg['hotel_name']?.toString() ?? '',
                status:  mg['status']?.toString() ?? 'active',
              );
            }),
          const SizedBox(height: 20),

          // Recent bookings
          _gridTitle('Recent Bookings'),
          const SizedBox(height: 10),
          if (bookings.isEmpty)
            _emptyMsg('No bookings yet')
          else
            ...bookings.take(6).map((b) =>
                _BookingRow(b as Map<String, dynamic>, role: 'sub_admin')),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB ADMIN — HOTELS TAB
// API: GET /api/admin/subadmin/hotels
// ─────────────────────────────────────────────────────────────────────────────
class _SubHotelsTab extends StatefulWidget {
  const _SubHotelsTab();
  @override State<_SubHotelsTab> createState() => _SubHotelsTabState();
}
class _SubHotelsTabState extends State<_SubHotelsTab> {
  List<dynamic> _hotels  = [];
  bool          _loading = true;
  final Set<int> _toggling = {};

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.subHotels);
      final d = r['data'];
      setState(() => _hotels = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _toggle(int id) async {
    setState(() => _toggling.add(id));
    try {
      await ApiService.instance.adminDio
          .post(AdminEndpoints.subToggleHotel(id).replaceFirst('/subadmin', ''));
      showSuccess(context, 'Hotel status toggled');
      _load();
    } catch (_) { showError(context, 'Failed'); }
    setState(() => _toggling.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));
    return RefreshIndicator(
      onRefresh: _load,
      child: _hotels.isEmpty
          ? _EmptyState('No hotels in your city', '🏨')
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _hotels.length,
              itemBuilder: (_, i) {
                final h      = _hotels[i] as Map<String, dynamic>;
                final active = h['is_active'] as bool? ?? false;
                final id     = h['id'] as int? ?? 0;
                return _AdminCard(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: active ? AppColors.successLight : AppColors.surfaceGray,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.hotel_rounded,
                        color: active ? AppColors.success : AppColors.textHint, size: 22),
                  ),
                  title:    h['name']?.toString() ?? '',
                  subtitle: '${h['type'] ?? ''} · ${h['city'] ?? ''} · ETB ${_fmt(h['price_per_night'])}',
                  status:   active ? 'active' : 'inactive',
                  trailing: _toggling.contains(id)
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5))
                      : Switch(
                          value:    active,
                          onChanged: (_) => _toggle(id),
                          activeColor: AppColors.success,
                        ),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL MANAGER — OVERVIEW
// Mirrors web ManagerDashboard.tsx exactly:
//   - Stats: total rooms, available rooms, pending payments, unread messages
//   - Pending payments section (most prominent — approve/reject)
//   - Rooms list
//   - Recent bookings
//   - Notifications
// APIs: GET /manager/dashboard + /manager/payments + /manager/notifications
// ─────────────────────────────────────────────────────────────────────────────
class _ManagerOverview extends StatefulWidget {
  const _ManagerOverview();
  @override State<_ManagerOverview> createState() => _ManagerOverviewState();
}
class _ManagerOverviewState extends State<_ManagerOverview> {
  Map<String, dynamic> _data         = {};
  List<dynamic>        _payments     = [];
  List<dynamic>        _notifications = [];
  bool                 _loading       = true;
  final Set<int>       _acting        = {};

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.adminGet(AdminEndpoints.managerDashboard),
        ApiService.instance.adminGet(AdminEndpoints.managerPayments),
        ApiService.instance.adminGet(AdminEndpoints.managerNotifications),
      ]);
      _data = (results[0]['data'] as Map<String, dynamic>?) ?? {};
      final p = results[1]['data'];
      _payments = p is List ? p : (p is Map ? (p['payments'] as List? ?? []) : []);
      final n = results[2]['data'];
      _notifications = n is List ? n :
          (n is Map ? (n['notifications'] as List? ?? []) : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _verify(int paymentId, String status) async {
    setState(() => _acting.add(paymentId));
    try {
      // POST /api/admin/manager/payments/:id/verify  { "status": "approved"|"rejected" }
      await ApiService.instance.adminDio.post(
          AdminEndpoints.managerVerifyPayment(paymentId),
          data: {'status': status});
      showSuccess(context,
          status == 'approved' ? 'Payment approved ✓' : 'Payment rejected');
      _load();
    } catch (_) {
      showError(context, 'Action failed');
    }
    setState(() => _acting.remove(paymentId));
  }

  Future<void> _markReadNotif(int id) async {
    try {
      await ApiService.instance.adminDio
          .post(AdminEndpoints.managerReadNotif(id));
      _load();
    } catch (_) {}
  }

  Future<void> _markAllNotifs() async {
    try {
      await ApiService.instance.adminDio
          .post(AdminEndpoints.managerReadAllNotifs);
      _load();
    } catch (_) {}
  }

  List<dynamic> get _pendingPayments =>
      _payments.where((p) => (p as Map)['status'] == 'submitted').toList();
  List<dynamic> get _rooms    => (_data['rooms']           as List?) ?? [];
  List<dynamic> get _bookings => (_data['recent_bookings'] as List?) ?? [];
  int           get _unreadMsg => _data['unread_messages'] as int? ?? 0;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));

    final availableRooms = _rooms.where((r) => (r as Map)['is_available'] == true).length;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Stats grid — matches web exactly
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _StatCard('Total Rooms',    '${_rooms.length}',       '🛏️', const Color(0xFF2563EB)),
              _StatCard('Available',      '$availableRooms',        '✅', const Color(0xFF059669)),
              _StatCard('Pending Pay.',   '${_pendingPayments.length}','💳', const Color(0xFFD97706)),
              _StatCard('Unread Msgs',    '$_unreadMsg',            '📨', const Color(0xFF7C3AED)),
            ],
          ),
          const SizedBox(height: 20),

          // ── PAYMENT VERIFICATION — most important for manager (full width) ──
          Row(children: [
            const Icon(Icons.credit_card_rounded,
                color: Color(0xFFD97706), size: 18),
            const SizedBox(width: 8),
            const Text('Payment Verification',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            if (_pendingPayments.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A))),
                child: Text('${_pendingPayments.length} pending',
                    style: const TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706))),
              ),
          ]),
          const SizedBox(height: 10),

          if (_pendingPayments.isEmpty)
            _emptyMsg('No payments pending verification')
          else
            ..._pendingPayments.take(5).map((p) {
              final pm  = p as Map<String, dynamic>;
              final id  = pm['id'] as int? ?? 0;
              final act = _acting.contains(id);
              return _PaymentVerifyCard(
                pm:         pm,
                acting:     act,
                onApprove: () => _verify(id, 'approved'),
                onReject:  () => _verify(id, 'rejected'),
              );
            }),
          const SizedBox(height: 20),

          // Rooms
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _gridTitle('My Rooms'),
          ]),
          const SizedBox(height: 10),
          if (_rooms.isEmpty)
            _emptyMsg('No rooms added yet')
          else
            ..._rooms.take(5).map((r) {
              final rm = r as Map<String, dynamic>;
              return _AdminCard(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      color: (rm['is_available'] == true)
                          ? AppColors.successLight : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.bed_rounded,
                      color: (rm['is_available'] == true)
                          ? AppColors.success : AppColors.error, size: 22),
                ),
                title:    rm['name']?.toString() ?? '',
                subtitle: '${rm['bed_type'] ?? ''} · ETB ${_fmt(rm['price_per_night'])} · max ${rm['max_guests']} guests',
                status:   (rm['is_available'] == true) ? 'available' : 'inactive',
              );
            }),
          const SizedBox(height: 20),

          // Recent bookings
          _gridTitle('Recent Bookings'),
          const SizedBox(height: 10),
          if (_bookings.isEmpty)
            _emptyMsg('No bookings yet')
          else
            ..._bookings.take(5).map((b) =>
                _BookingRow(b as Map<String, dynamic>, role: 'hotel_manager')),
          const SizedBox(height: 20),

          // Notifications
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Row(children: [
              Icon(Icons.notifications_rounded, color: Color(0xFF7C3AED), size: 18),
              SizedBox(width: 8),
              Text('Notifications', style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ]),
            if (_notifications.any((n) => (n as Map)['is_read'] != true))
              TextButton(
                onPressed: _markAllNotifs,
                child: const Text('Mark all read',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7C3AED))),
              ),
          ]),
          const SizedBox(height: 10),
          if (_notifications.isEmpty)
            _emptyMsg('No notifications yet')
          else
            ..._notifications.take(8).map((n) {
              final notif   = n as Map<String, dynamic>;
              final isRead  = notif['is_read'] as bool? ?? false;
              final nType   = notif['type']?.toString() ?? '';
              final nId     = notif['id'] as int? ?? 0;
              return GestureDetector(
                onTap: () { if (!isRead) _markReadNotif(nId); },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isRead ? AppColors.border : AppColors.primary.withOpacity(0.3))),
                  child: Row(children: [
                    Icon(
                      nType == 'booking_new'
                          ? Icons.calendar_month_rounded
                          : Icons.credit_card_rounded,
                      color: nType == 'booking_new'
                          ? AppColors.primary : AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(notif['title']?.toString() ?? '',
                          style: TextStyle(fontSize: 13,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              color: AppColors.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(notif['message']?.toString() ?? '',
                          style: const TextStyle(fontSize: 11,
                              color: AppColors.textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    if (!isRead)
                      Container(width: 8, height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle)),
                  ]),
                ),
              );
            }),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL MANAGER — ROOMS TAB
// API: GET /api/admin/manager/rooms
//      POST /api/admin/manager/rooms/:rid/status  { status }
//      POST /api/admin/manager/rooms/:rid/toggle
// ─────────────────────────────────────────────────────────────────────────────
class _ManagerRoomsTab extends StatefulWidget {
  const _ManagerRoomsTab();
  @override State<_ManagerRoomsTab> createState() => _ManagerRoomsTabState();
}
class _ManagerRoomsTabState extends State<_ManagerRoomsTab> {
  List<dynamic> _rooms   = [];
  bool          _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.managerRooms);
      final d = r['data'];
      setState(() => _rooms = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _setStatus(int rid, String status) async {
    try {
      await ApiService.instance.adminDio.post(
          AdminEndpoints.managerRoomStatus(rid),
          data: {'status': status});
      showSuccess(context, 'Room status → $status');
      _load();
    } catch (_) { showError(context, 'Failed'); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));
    return RefreshIndicator(
      onRefresh: _load,
      child: _rooms.isEmpty
          ? _EmptyState('No rooms added yet', '🛏️')
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _rooms.length,
              itemBuilder: (_, i) {
                final r      = _rooms[i] as Map<String, dynamic>;
                final avail  = r['is_available'] as bool? ?? false;
                final status = r['room_status']?.toString() ?? 'available';
                final rid    = r['id'] as int? ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border:       Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                          color: avail ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.bed_rounded,
                          color: avail ? AppColors.success : AppColors.error, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r['name']?.toString() ?? '',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('${r['bed_type']} · max ${r['max_guests']} · ETB ${_fmt(r['price_per_night'])}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      _statusBadge(status),
                    ])),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
                      onSelected: (s) => _setStatus(rid, s),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'available',   child: Text('✅ Available')),
                        PopupMenuItem(value: 'maintenance', child: Text('🔧 Maintenance')),
                        PopupMenuItem(value: 'unavailable', child: Text('🚫 Unavailable')),
                      ],
                    ),
                  ]),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL MANAGER — PAYMENTS TAB
// API: GET /api/admin/manager/payments
//      POST /api/admin/manager/payments/:id/verify  { "status": "approved"|"rejected" }
// ─────────────────────────────────────────────────────────────────────────────
class _ManagerPaymentsTab extends StatefulWidget {
  const _ManagerPaymentsTab();
  @override State<_ManagerPaymentsTab> createState() => _ManagerPaymentsTabState();
}
class _ManagerPaymentsTabState extends State<_ManagerPaymentsTab> {
  List<dynamic> _payments = [];
  bool          _loading  = true;
  String        _filter   = 'all';
  final Set<int> _acting  = {};

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.managerPayments);
      final d = r['data'];
      setState(() => _payments = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _verify(int id, String status) async {
    setState(() => _acting.add(id));
    try {
      await ApiService.instance.adminDio.post(
          AdminEndpoints.managerVerifyPayment(id),
          data: {'status': status});
      showSuccess(context,
          status == 'approved' ? 'Payment approved ✓' : 'Payment rejected');
      _load();
    } catch (_) { showError(context, 'Action failed'); }
    setState(() => _acting.remove(id));
  }

  List<dynamic> get _filtered => _filter == 'all'
      ? _payments
      : _payments.where((p) => (p as Map)['status'] == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Filter chips
      Container(
        color:   Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final f in ['all', 'submitted', 'completed', 'failed'])
              GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _filter == f ? const Color(0xFFD97706) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _filter == f ? const Color(0xFFD97706) : AppColors.border),
                  ),
                  child: Text(
                    f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: _filter == f ? Colors.white : AppColors.textSecondary),
                  ),
                ),
              ),
          ]),
        ),
      ),
      const Divider(height: 1),

      Expanded(
        child: _loading
            ? const Center(child: AppSpinner(size: SpinnerSize.large))
            : _filtered.isEmpty
                ? _EmptyState('No payments found', '💳')
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final p  = _filtered[i] as Map<String, dynamic>;
                        final id = p['id'] as int? ?? 0;
                        return _PaymentVerifyCard(
                          pm:        p,
                          acting:    _acting.contains(id),
                          onApprove: () => _verify(id, 'approved'),
                          onReject:  () => _verify(id, 'rejected'),
                        );
                      },
                    ),
                  ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BROKER — OVERVIEW
// API: GET /api/admin/broker/dashboard  → { unread_messages, inbox }
// ─────────────────────────────────────────────────────────────────────────────
class _BrokerOverview extends StatefulWidget {
  const _BrokerOverview();
  @override State<_BrokerOverview> createState() => _BrokerOverviewState();
}
class _BrokerOverviewState extends State<_BrokerOverview> {
  Map<String, dynamic> _data   = {};
  bool                 _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.brokerDashboard);
      setState(() => _data = (r['data'] as Map<String, dynamic>?) ?? {});
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));
    final unread = _data['unread_messages'] as int? ?? 0;
    final inbox  = (_data['inbox'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _StatCard('Unread Msgs', '$unread', '📨', const Color(0xFFD97706))),
            const SizedBox(width: 10),
            Expanded(child: _StatCard('Inbox',       '${inbox.length}', '📬', const Color(0xFF2563EB))),
          ]),
          const SizedBox(height: 20),

          _gridTitle('Inbox Messages'),
          const SizedBox(height: 10),
          if (inbox.isEmpty)
            _emptyMsg('No messages yet')
          else
            ...inbox.take(8).map((m) {
              final msg    = m as Map<String, dynamic>;
              final isRead = msg['is_read'] as bool? ?? true;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color:        isRead ? Colors.white : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(
                        color: isRead ? AppColors.border
                            : AppColors.primary.withOpacity(0.3))),
                child: Row(children: [
                  _avatar(msg['from_name'], const Color(0xFFD97706)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(msg['subject']?.toString() ?? '(no subject)',
                        style: TextStyle(fontSize: 13,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('From: ${msg['from_name'] ?? '—'}',
                        style: const TextStyle(fontSize: 11,
                            color: AppColors.textSecondary)),
                  ])),
                  if (!isRead)
                    Container(width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle)),
                ]),
              );
            }),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED BOOKINGS TAB (all roles)
// canUpdateStatus=true → hotel manager can confirm/cancel bookings
// ─────────────────────────────────────────────────────────────────────────────
class _BookingsTab extends StatefulWidget {
  final String endpoint;
  final String role;
  final bool   canUpdateStatus;
  const _BookingsTab({required this.endpoint, required this.role,
    this.canUpdateStatus = false});
  @override State<_BookingsTab> createState() => _BookingsTabState();
}
class _BookingsTabState extends State<_BookingsTab> {
  List<dynamic> _bookings = [];
  bool          _loading  = true;
  String        _filter   = 'all';

  static const _statusFg = <String, Color>{
    'pending':   Color(0xFFD97706),
    'confirmed': Color(0xFF059669),
    'completed': Color(0xFF2563EB),
    'cancelled': Color(0xFFDC2626),
  };
  static const _statusBg = <String, Color>{
    'pending':   Color(0xFFFFFBEB),
    'confirmed': Color(0xFFECFDF5),
    'completed': Color(0xFFEFF6FF),
    'cancelled': Color(0xFFFEF2F2),
  };

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final params = _filter == 'all' ? null : {'status': _filter};
      final r = await ApiService.instance.adminGet(widget.endpoint,
          params: params?.cast<String, dynamic>());
      final d = r['data'];
      setState(() => _bookings = d is List ? d :
          (d is Map ? (d['bookings'] as List? ?? []) : []));
    } catch (_) { setState(() => _bookings = []); }
    setState(() => _loading = false);
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await ApiService.instance.adminDio.post(
          AdminEndpoints.managerBookingStatus(id),
          data: {'status': status});
      showSuccess(context, 'Booking $status');
      _load();
    } catch (_) { showError(context, 'Failed'); }
  }

  List<dynamic> get _filtered => _filter == 'all'
      ? _bookings
      : _bookings.where((b) => (b as Map)['status'] == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final f in ['all', 'pending', 'confirmed', 'completed', 'cancelled'])
              GestureDetector(
                onTap: () { setState(() => _filter = f); _load(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _filter == f
                        ? (_statusFg[f] ?? AppColors.primary)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _filter == f
                            ? (_statusFg[f] ?? AppColors.primary)
                            : AppColors.border),
                  ),
                  child: Text(
                    f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: _filter == f ? Colors.white : AppColors.textSecondary),
                  ),
                ),
              ),
          ]),
        ),
      ),
      const Divider(height: 1),

      Expanded(
        child: _loading
            ? const Center(child: AppSpinner(size: SpinnerSize.large))
            : _filtered.isEmpty
                ? _EmptyState('No bookings found', '📅')
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final b  = _filtered[i] as Map<String, dynamic>;
                        final st = b['status']?.toString() ?? 'pending';
                        final fg = _statusFg[st] ?? AppColors.textHint;
                        final bg = _statusBg[st] ?? AppColors.surfaceGray;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:        Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border:       Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(child: Text(
                                    b['hotel_name']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: bg, borderRadius: BorderRadius.circular(8)),
                                  child: Text(st[0].toUpperCase() + st.substring(1),
                                      style: TextStyle(fontSize: 10,
                                          fontWeight: FontWeight.w700, color: fg)),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Text(
                                '${b['guest_name'] ?? ''} · '
                                '${b['check_in']} → ${b['check_out']} · '
                                '${b['rooms']} room${(b['rooms'] as int? ?? 1) > 1 ? "s" : ""}',
                                style: const TextStyle(fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 6),
                              Row(children: [
                                Text('ETB ${_fmt(b['total_price'])}',
                                    style: const TextStyle(fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary)),
                                const Spacer(),
                                Text(
                                  (b['payment_method']?.toString() ?? '')
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  style: const TextStyle(fontSize: 10,
                                      color: AppColors.textHint),
                                ),
                              ]),
                              if (widget.canUpdateStatus && st == 'pending') ...[
                                const SizedBox(height: 10),
                                Row(children: [
                                  Expanded(child: OutlinedButton(
                                    onPressed: () => _updateStatus(
                                        b['id'] as int? ?? 0, 'confirmed'),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.success,
                                        side: const BorderSide(color: AppColors.success),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8))),
                                    child: const Text('Confirm', style: TextStyle(fontSize: 12)),
                                  )),
                                  const SizedBox(width: 8),
                                  Expanded(child: OutlinedButton(
                                    onPressed: () => _updateStatus(
                                        b['id'] as int? ?? 0, 'cancelled'),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(color: AppColors.error),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8))),
                                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                                  )),
                                ]),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT VERIFY CARD — used in both Overview and Payments tab
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentVerifyCard extends StatelessWidget {
  final Map<String, dynamic> pm;
  final bool          acting;
  final VoidCallback  onApprove, onReject;

  const _PaymentVerifyCard({
    required this.pm, required this.acting,
    required this.onApprove, required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = pm['status']?.toString() ?? 'pending';
    final isPending = status == 'submitted';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: isPending ? const Color(0xFFFFFBEB) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isPending ? const Color(0xFFFDE68A) : AppColors.border,
              width: isPending ? 1.5 : 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Payment #${pm['id']} — ${pm['guest_name'] ?? pm['guest_full_name'] ?? ''}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            Text(
              '${pm['method'] ?? pm['payment_method'] ?? ''} · '
              '${pm['check_in'] ?? ''} → ${pm['check_out'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            if ((pm['transaction_id'] ?? '').toString().isNotEmpty)
              Text('TXN: ${pm['transaction_id']}',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace',
                      color: AppColors.textHint)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('ETB ${_fmt(pm['amount'])}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
            _statusBadge(status),
          ]),
        ]),

        if (isPending) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: acting ? null : onReject,
              icon: acting
                  ? const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
                  : const Icon(Icons.close_rounded, size: 16),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: acting ? null : onApprove,
              icon: acting
                  ? const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded, size: 16),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
          ]),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value, emoji;
  final Color  color;
  const _StatCard(this.label, this.value, this.emoji, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(14),
      border:       Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w900, color: color)),
      ]),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11,
          color: AppColors.textSecondary)),
    ]),
  );
}

class _ActionCard extends StatelessWidget {
  final String emoji, label, desc;
  final Color  color;
  final VoidCallback onTap;
  const _ActionCard(this.emoji, this.label, this.desc, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color:        color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700, color: color)),
          Text(desc, style: const TextStyle(fontSize: 11,
              color: AppColors.textSecondary)),
        ])),
      ]),
    ),
  );
}

class _DetailCard extends StatelessWidget {
  final List<Map<String, String>> items;
  const _DetailCard({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
    child: Column(children: items.map((item) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Text(item['label']!, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(item['value']!, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
      ]),
    )).toList()),
  );
}

class _AdminCard extends StatelessWidget {
  final Widget  leading;
  final String  title, subtitle;
  final String? status;
  final Widget? trailing;
  const _AdminCard({required this.leading, required this.title,
    required this.subtitle, this.status, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
    child: Row(children: [
      leading,
      const SizedBox(width: 12),
      Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(subtitle, style: const TextStyle(fontSize: 12,
            color: AppColors.textSecondary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      if (status != null) ...[
        const SizedBox(width: 8),
        _statusBadge(status!),
      ],
      if (trailing != null) ...[
        const SizedBox(width: 8),
        trailing!,
      ],
    ]),
  );
}

class _BookingRow extends StatelessWidget {
  final Map<String, dynamic> b;
  final String role;
  const _BookingRow(this.b, {required this.role});

  @override
  Widget build(BuildContext context) {
    final st = b['status']?.toString() ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b['hotel_name']?.toString() ?? '',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            '${b['guest_name'] ?? ''} · ${b['check_in'] ?? ''} → ${b['check_out'] ?? ''}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _statusBadge(st),
          const SizedBox(height: 3),
          Text('ETB ${_fmt(b['total_price'])}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
        ]),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String msg, emoji;
  const _EmptyState(this.msg, this.emoji);

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 48)),
      const SizedBox(height: 14),
      Text(msg, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary), textAlign: TextAlign.center),
    ]),
  ));
}

Widget _avatar(dynamic name, Color color) => CircleAvatar(
  radius: 20,
  backgroundColor: color.withOpacity(0.12),
  child: Text(
    (name?.toString() ?? 'A').isNotEmpty
        ? (name?.toString() ?? 'A')[0].toUpperCase() : 'A',
    style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15),
  ),
);

Widget _gridTitle(String t) => Text(t, style: const TextStyle(
    fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary));

Widget _emptyMsg(String msg) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 20),
  child: Center(child: Text(msg, style: const TextStyle(
      fontSize: 13, color: AppColors.textSecondary))),
);

Widget _statusBadge(String status) {
  const fg = <String, Color>{
    'active':     Color(0xFF059669),
    'available':  Color(0xFF059669),
    'inactive':   Color(0xFF6B7280),
    'pending':    Color(0xFFD97706),
    'submitted':  Color(0xFF7C3AED),
    'confirmed':  Color(0xFF059669),
    'completed':  Color(0xFF2563EB),
    'cancelled':  Color(0xFFDC2626),
    'failed':     Color(0xFFDC2626),
    'suspended':  Color(0xFFDC2626),
  };
  const bg = <String, Color>{
    'active':     Color(0xFFECFDF5),
    'available':  Color(0xFFECFDF5),
    'inactive':   Color(0xFFF3F4F6),
    'pending':    Color(0xFFFFFBEB),
    'submitted':  Color(0xFFEDE9FE),
    'confirmed':  Color(0xFFECFDF5),
    'completed':  Color(0xFFEFF6FF),
    'cancelled':  Color(0xFFFEF2F2),
    'failed':     Color(0xFFFEF2F2),
    'suspended':  Color(0xFFFEF2F2),
  };
  final f = fg[status] ?? AppColors.textHint;
  final b = bg[status] ?? AppColors.surfaceGray;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: b, borderRadius: BorderRadius.circular(8)),
    child: Text(status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: f)),
  );
}

String _fmt(dynamic v) {
  if (v == null) return '0';
  final d = v is double ? v : (v is int ? v.toDouble() :
      double.tryParse(v.toString()) ?? 0.0);
  return d.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');
}

// Language toggle for admin dark bar
class _AdminLangToggle extends StatelessWidget {
  final Color color;
  const _AdminLangToggle({required this.color});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return GestureDetector(
      onTap: lang.toggle,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color:        Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border:       Border.all(color: Colors.white.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(lang.isAmharic ? '🇬🇧' : '🇪🇹',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(lang.isAmharic ? 'EN' : 'አማ',
              style: const TextStyle(color: Colors.white,
                  fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
