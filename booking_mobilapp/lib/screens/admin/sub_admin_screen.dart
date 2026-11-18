/// sub_admin_screen.dart
///
/// Sub-Admin Dashboard — exactly matches the web SubAdmin system.
/// Backend base: /api/admin/subadmin/*
///
/// Tabs:
///   1. Overview    — assigned city banner, stats, hotels, managers, bookings
///   2. Hotels      — CRUD: add, edit, toggle, rooms CRUD, payment methods
///   3. Managers    — create/delete hotel managers
///   4. Brokers     — create/list brokers
///   5. Bookings    — view + filter
///   6. Settings    — profile
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/admin_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/snack_helper.dart';
import '../auth/login_screen.dart';
import 'admin_profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL
// ─────────────────────────────────────────────────────────────────────────────
class SubAdminScreen extends StatefulWidget {
  const SubAdminScreen({super.key});
  @override
  State<SubAdminScreen> createState() => _SubAdminScreenState();
}

class _SubAdminScreenState extends State<SubAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.22),
            child: Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user?.fullName ?? 'Sub Admin',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('Sub Admin',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ]),
        actions: [
          GestureDetector(
            onTap: lang.toggle,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(lang.isAmharic ? '🇬🇧' : '🇪🇹',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(lang.isAmharic ? 'EN' : 'አማ',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: Colors.white70, size: 22),
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
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(
                icon: Icon(Icons.dashboard_rounded, size: 17),
                text: 'Overview'),
            Tab(
                icon: Icon(Icons.hotel_rounded, size: 17),
                text: 'Hotels'),
            Tab(
                icon: Icon(Icons.manage_accounts_rounded, size: 17),
                text: 'Managers'),
            Tab(
                icon: Icon(Icons.book_online_rounded, size: 17),
                text: 'Bookings'),
            Tab(
                icon: Icon(Icons.person_rounded, size: 17),
                text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _SubOverviewTab(),
          _SubHotelsTab(),
          _SubManagersTab(),
          _SubBookingsTab(),
          AdminProfileScreen(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. OVERVIEW
// API: GET /api/admin/subadmin/dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _SubOverviewTab extends StatefulWidget {
  const _SubOverviewTab();
  @override
  State<_SubOverviewTab> createState() => _SubOverviewTabState();
}

class _SubOverviewTabState extends State<_SubOverviewTab> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r =
          await ApiService.instance.adminGet(AdminEndpoints.subDashboard);
      setState(() =>
          _data = (r['data'] as Map<String, dynamic>?) ?? {});
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(child: AppSpinner(size: SpinnerSize.large));

    final city = _data['city']?.toString() ?? 'Not assigned';
    final hotels = (_data['hotels'] as List<dynamic>?) ?? [];
    final managers = (_data['managers'] as List<dynamic>?) ?? [];
    final bookings = (_data['recent_bookings'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // City banner
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
                    style: TextStyle(
                        color: Colors.white70, fontSize: 11)),
                Text(city,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          // Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _stat('Hotels', '${hotels.length}', '🏨',
                  const Color(0xFF2563EB)),
              _stat('Managers', '${managers.length}', '👨‍💼',
                  const Color(0xFF059669)),
              _stat('Bookings', '${bookings.length}', '📅',
                  const Color(0xFFD97706)),
            ],
          ),
          const SizedBox(height: 20),

          _sectionTitle('Hotels in $city'),
          const SizedBox(height: 10),
          if (hotels.isEmpty)
            _empty('No hotels yet')
          else
            ...hotels.take(5).map((h) {
              final ho = h as Map<String, dynamic>;
              return _card(
                icon: Icons.hotel_rounded,
                iconColor: (ho['is_active'] == true)
                    ? AppColors.success
                    : AppColors.textHint,
                title: ho['name']?.toString() ?? '',
                subtitle:
                    '${ho['type'] ?? ''} · ETB ${_fmt(ho['price_per_night'])}',
                status: (ho['is_active'] == true) ? 'active' : 'inactive',
              );
            }),
          const SizedBox(height: 20),

          _sectionTitle('Hotel Managers'),
          const SizedBox(height: 10),
          if (managers.isEmpty)
            _empty('No managers yet')
          else
            ...managers.take(5).map((m) {
              final mg = m as Map<String, dynamic>;
              return _card(
                icon: Icons.person_rounded,
                iconColor: const Color(0xFF059669),
                title: mg['full_name']?.toString() ?? '',
                subtitle: mg['hotel_name']?.toString() ?? '',
                status: mg['status']?.toString() ?? 'active',
              );
            }),
          const SizedBox(height: 20),

          _sectionTitle('Recent Bookings'),
          const SizedBox(height: 10),
          if (bookings.isEmpty)
            _empty('No bookings yet')
          else
            ...bookings.take(6).map((b) =>
                _BookingTile(b as Map<String, dynamic>)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. HOTELS  — full CRUD
// APIs:
//   GET    /api/admin/subadmin/hotels
//   POST   /api/admin/subadmin/hotels/create
//   PUT    /api/admin/subadmin/hotels/:id
//   POST   /api/admin/subadmin/hotels/:id/toggle
//   GET    /api/admin/subadmin/hotels/:id/rooms          (expand per hotel)
//   POST   /api/admin/subadmin/hotels/:id/rooms
//   PUT    /api/admin/subadmin/hotels/:id/rooms/:rid
//   DELETE /api/admin/subadmin/hotels/:id/rooms/:rid
//   GET    /api/admin/subadmin/hotels/:id/payment-methods
//   POST   /api/admin/subadmin/hotels/:id/payment-methods
//   PUT    /api/admin/subadmin/payment-methods/:id
// ─────────────────────────────────────────────────────────────────────────────
class _SubHotelsTab extends StatefulWidget {
  const _SubHotelsTab();
  @override
  State<_SubHotelsTab> createState() => _SubHotelsTabState();
}

class _SubHotelsTabState extends State<_SubHotelsTab> {
  List<dynamic> _hotels = [];
  bool _loading = true;
  final Set<int> _toggling = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r =
          await ApiService.instance.adminGet(AdminEndpoints.subHotels);
      final d = r['data'];
      setState(() => _hotels = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _toggle(int id) async {
    setState(() => _toggling.add(id));
    try {
      await ApiService.instance
          .adminDio
          .post(AdminEndpoints.subToggleHotel(id));
      showSuccess(context, 'Hotel status toggled');
      _load();
    } catch (_) {
      showError(context, 'Failed');
    }
    setState(() => _toggling.remove(id));
  }

  void _showAdd() {
    final nameCtrl  = TextEditingController();
    final addrCtrl  = TextEditingController();
    final descCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();
    final imgCtrl   = TextEditingController();
    final latCtrl   = TextEditingController();
    final lngCtrl   = TextEditingController();
    String type        = 'hotel';
    bool   isFeatured  = false;
    final _hotelAddKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Add Hotel',
        color: const Color(0xFF2563EB),
        onSave: () async {
          if (!_hotelAddKey.currentState!.validate()) return;
          try {
            await ApiService.instance
                .adminPost(AdminEndpoints.subCreateHotel, data: {
              'name':            nameCtrl.text.trim(),
              'address':         addrCtrl.text.trim(),
              'description':     descCtrl.text.trim(),
              'type':            type,
              'price_per_night': double.tryParse(priceCtrl.text) ?? 0,
              'image_url':       imgCtrl.text.trim(),
              'latitude':        double.tryParse(latCtrl.text) ?? 0,
              'longitude':       double.tryParse(lngCtrl.text) ?? 0,
              'is_featured':     isFeatured,
            });
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Hotel created!');
            _load();
          } on ApiException catch (e) {
            showError(ctx, e.message);
          }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Form(
            key: _hotelAddKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tf('Hotel Name *', nameCtrl, validator: (v) => V.required(v, label: 'Hotel name')),
              _tf('Address *', addrCtrl, validator: (v) => V.required(v, label: 'Address')),
              _tf('Description (optional)', descCtrl, maxLines: 3),
              _tf('Price per Night (ETB) *', priceCtrl,
                  type: TextInputType.number, validator: V.price),
              _tf('Image URL (optional)', imgCtrl, validator: V.urlOptional),
              // Show live image preview if URL is set
              StatefulBuilder(builder: (_, setImg) => imgCtrl.text.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imgCtrl.text,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox()),
                      ),
                    )
                  : const SizedBox()),
              const SizedBox(height: 4),
              _dropLabel('Hotel Type'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: type,
                onChanged: (v) => setSt(() => type = v ?? type),
                items: const [
                  DropdownMenuItem(value: 'hotel',    child: Text('Hotel')),
                  DropdownMenuItem(value: 'resort',   child: Text('Resort')),
                  DropdownMenuItem(value: 'boutique', child: Text('Boutique')),
                  DropdownMenuItem(value: 'lodge',    child: Text('Lodge')),
                ],
                decoration: _inputDeco,
              ),
              const SizedBox(height: 14),

              // Latitude / Longitude row
              Row(children: [
                Expanded(child: _tf('Latitude (optional)', latCtrl,
                    type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                const SizedBox(width: 10),
                Expanded(child: _tf('Longitude (optional)', lngCtrl,
                    type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
              ]),

              // Google Maps help panel — mirrors the web exactly
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📍 How to get Google Maps coordinates:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8))),
                    const SizedBox(height: 6),
                    for (final step in const [
                      '1. Open maps.google.com',
                      '2. Search for the hotel location',
                      '3. Right-click → "What\'s here?" → copy coordinates',
                      '4. Paste latitude and longitude above',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(step,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF2563EB))),
                      ),
                    // Preview link when both coords are entered
                    StatefulBuilder(builder: (_, __) {
                      final lat = double.tryParse(latCtrl.text) ?? 0;
                      final lng = double.tryParse(lngCtrl.text) ?? 0;
                      if (lat == 0 || lng == 0) return const SizedBox();
                      return GestureDetector(
                        onTap: () {
                          // Open in browser — url_launcher not required,
                          // show coordinates as confirmation
                          showSuccess(sCtx,
                              'Coordinates set: $lat, $lng');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                              '→ Preview: $lat, $lng (tap to confirm)',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline)),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Featured checkbox
              GestureDetector(
                onTap: () => setSt(() => isFeatured = !isFeatured),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                        color: isFeatured
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: isFeatured
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1.5)),
                    child: isFeatured
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  const Text('Mark as Featured Hotel',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textPrimary)),
                ]),
              ),
            ],
            ),
          ),
        ),
      ),
  );
  }

  void _showEdit(Map<String, dynamic> hotel) {
    final nameCtrl  = TextEditingController(text: hotel['name']?.toString() ?? '');
    final addrCtrl  = TextEditingController(text: hotel['address']?.toString() ?? '');
    final descCtrl  = TextEditingController(text: hotel['description']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: hotel['price_per_night']?.toString() ?? '');
    final latCtrl   = TextEditingController(
        text: (hotel['latitude']  ?? 0).toString() == '0' ? '' : hotel['latitude'].toString());
    final lngCtrl   = TextEditingController(
        text: (hotel['longitude'] ?? 0).toString() == '0' ? '' : hotel['longitude'].toString());
    String type       = hotel['type']?.toString() ?? 'hotel';
    bool   isFeatured = hotel['is_featured'] as bool? ?? false;
    final _hotelEditKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Edit Hotel',
        color: const Color(0xFF2563EB),
        onSave: () async {
          if (!_hotelEditKey.currentState!.validate()) return;
          try {
            await ApiService.instance.adminDio.put(
              AdminEndpoints.subHotelById(hotel['id'] as int),
              data: {
                'name':            nameCtrl.text.trim(),
                'address':         addrCtrl.text.trim(),
                'description':     descCtrl.text.trim(),
                'type':            type,
                'price_per_night': double.tryParse(priceCtrl.text) ?? 0,
                'is_active':       hotel['is_active'] ?? true,
                'latitude':        double.tryParse(latCtrl.text) ?? 0,
                'longitude':       double.tryParse(lngCtrl.text) ?? 0,
                'is_featured':     isFeatured,
              },
            );
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Hotel updated!');
            _load();
          } catch (_) {
            showError(ctx, 'Failed to update hotel');
          }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Form(
            key: _hotelEditKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tf('Hotel Name *', nameCtrl, validator: (v) => V.required(v, label: 'Hotel name')),
              _tf('Address', addrCtrl),
              _tf('Description', descCtrl, maxLines: 3),
              _tf('Price per Night (ETB) *', priceCtrl,
                  type: TextInputType.number, validator: V.price),
              const SizedBox(height: 4),
              _dropLabel('Hotel Type'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: type,
                onChanged: (v) => setSt(() => type = v ?? type),
                items: const [
                  DropdownMenuItem(value: 'hotel',    child: Text('Hotel')),
                  DropdownMenuItem(value: 'resort',   child: Text('Resort')),
                  DropdownMenuItem(value: 'boutique', child: Text('Boutique')),
                  DropdownMenuItem(value: 'lodge',    child: Text('Lodge')),
                ],
                decoration: _inputDeco,
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _tf('Latitude (optional)', latCtrl,
                    type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                const SizedBox(width: 10),
                Expanded(child: _tf('Longitude (optional)', lngCtrl,
                    type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
              ]),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE))),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📍 Google Maps coordinates:',
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8))),
                    SizedBox(height: 4),
                    Text('Open maps.google.com → find hotel → right-click → copy coordinates',
                        style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setSt(() => isFeatured = !isFeatured),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                        color: isFeatured ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: isFeatured ? AppColors.primary : AppColors.border,
                            width: 1.5)),
                    child: isFeatured
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  const Text('Mark as Featured Hotel',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                ]),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRooms(Map<String, dynamic> hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _HotelRoomsPage(hotel: hotel)),
    );
  }

  void _showPayMethods(Map<String, dynamic> hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _HotelPayMethodsPage(hotel: hotel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Hotel'),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _hotels.isEmpty
                  ? const Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text('🏨',
                              style: TextStyle(fontSize: 48)),
                          SizedBox(height: 10),
                          Text('No hotels in your city',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary)),
                        ]))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: _hotels.length,
                      itemBuilder: (_, i) {
                        final h = _hotels[i] as Map<String, dynamic>;
                        final active =
                            h['is_active'] as bool? ?? false;
                        final id = h['id'] as int? ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.border)),
                          child: Column(children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                      color: active
                                          ? AppColors.successLight
                                          : AppColors.surfaceGray,
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  child: Icon(Icons.hotel_rounded,
                                      color: active
                                          ? AppColors.success
                                          : AppColors.textHint,
                                      size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                  Text(h['name']?.toString() ?? '',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                      '${h['type'] ?? ''} · ${h['city'] ?? ''} · ETB ${_fmt(h['price_per_night'])}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppColors.textSecondary)),
                                ])),
                                Switch(
                                  value: active,
                                  onChanged: _toggling.contains(id)
                                      ? null
                                      : (_) => _toggle(id),
                                  activeColor: AppColors.success,
                                ),
                              ]),
                            ),
                            const Divider(height: 1),
                            // Actions
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Row(children: [
                                _iconBtn(
                                    Icons.edit_rounded,
                                    'Edit',
                                    AppColors.primary,
                                    () => _showEdit(h)),
                                _iconBtn(
                                    Icons.bed_rounded,
                                    'Rooms',
                                    const Color(0xFF059669),
                                    () => _showRooms(h)),
                                _iconBtn(
                                    Icons.payment_rounded,
                                    'Pay Methods',
                                    const Color(0xFFD97706),
                                    () => _showPayMethods(h)),
                              ]),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL ROOMS PAGE (pushed from Hotels tab)
// ─────────────────────────────────────────────────────────────────────────────
class _HotelRoomsPage extends StatefulWidget {
  final Map<String, dynamic> hotel;
  const _HotelRoomsPage({required this.hotel});
  @override
  State<_HotelRoomsPage> createState() => _HotelRoomsPageState();
}

class _HotelRoomsPageState extends State<_HotelRoomsPage> {
  List<dynamic> _rooms = [];
  bool _loading = true;

  int get _hotelId => widget.hotel['id'] as int;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance
          .adminGet(AdminEndpoints.subRooms(_hotelId));
      final d = r['data'];
      setState(() => _rooms = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showAdd() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final guestsCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    String bed = 'Single';
    final _roomAddKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Add Room',
        color: const Color(0xFF059669),
        onSave: () async {
          if (!_roomAddKey.currentState!.validate()) return;
          try {
            await ApiService.instance.adminPost(
                AdminEndpoints.subRooms(_hotelId),
                data: {
                  'name': nameCtrl.text.trim(),
                  'bed_type': bed,
                  'price_per_night':
                      double.tryParse(priceCtrl.text) ?? 0,
                  'max_guests': int.tryParse(guestsCtrl.text) ?? 1,
                  'image_url': imgCtrl.text.trim(),
                  'room_status': 'available',
                });
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Room added!');
            _load();
          } on ApiException catch (e) {
            showError(ctx, e.message);
          }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Form(
            key: _roomAddKey,
            child: Column(children: [
            _tf('Room Name *', nameCtrl, validator: (v) => V.required(v, label: 'Room name')),
            _tf('Price per Night (ETB) *', priceCtrl,
                type: TextInputType.number, validator: V.price),
            _tf('Max Guests', guestsCtrl,
                type: TextInputType.number, validator: (v) => V.positiveInt(v, label: 'Max guests')),
            _tf('Image URL (optional)', imgCtrl,
                validator: V.urlOptional),
            const SizedBox(height: 10),
            _dropLabel('Bed Type'),
            DropdownButtonFormField<String>(
              value: bed,
              onChanged: (v) => setSt(() => bed = v ?? bed),
              items: const [
                DropdownMenuItem(value: 'Single', child: Text('Single')),
                DropdownMenuItem(value: 'Double', child: Text('Double')),
                DropdownMenuItem(value: 'Twin',   child: Text('Twin')),
                DropdownMenuItem(value: 'King',   child: Text('King')),
                DropdownMenuItem(value: 'Queen',  child: Text('Queen')),
                DropdownMenuItem(value: 'Suite',  child: Text('Suite')),
              ],
              decoration: _inputDeco,
            ),
          ])),
        ),
      ),
  );
  }

  void _showEdit(Map<String, dynamic> room) {
    final nameCtrl =
        TextEditingController(text: room['name']?.toString() ?? '');
    final priceCtrl = TextEditingController(
        text: room['price_per_night']?.toString() ?? '');
    final guestsCtrl = TextEditingController(
        text: room['max_guests']?.toString() ?? '');
    final imgCtrl = TextEditingController(
        text: room['image_url']?.toString() ?? '');
    // Normalize bed_type to match capitalized web values (web + mobile aligned)
    // Web uses: Single, Double, Twin, Queen, King (no Suite)
    // We keep Suite for backward compat but normalize everything else
    const bedDropdownItems = ['Single','Double','Twin','Queen','King','Suite'];
    final rawBed = room['bed_type']?.toString() ?? '';
    String bed = rawBed.isEmpty ? 'Single' : () {
      final cap = rawBed[0].toUpperCase() + rawBed.substring(1).toLowerCase();
      return bedDropdownItems.contains(cap) ? cap : 'Single';
    }();
    final editKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Edit Room',
        color: const Color(0xFF059669),
        onSave: () async {
          if (!editKey.currentState!.validate()) return;
          try {
            await ApiService.instance.adminDio.put(
              AdminEndpoints.subRoomById(
                  _hotelId, room['id'] as int),
              data: {
                'name':            nameCtrl.text.trim(),
                'bed_type':        bed,
                'price_per_night': double.tryParse(priceCtrl.text) ?? 0,
                'max_guests':      int.tryParse(guestsCtrl.text) ?? 1,
                'image_url':       imgCtrl.text.trim(),
              },
            );
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Room updated!');
            _load();
          } catch (_) {
            showError(ctx, 'Failed to update room');
          }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Form(
            key: editKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _tf('Room Name *', nameCtrl,
                  validator: (v) => V.required(v, label: 'Room name')),
              _tf('Price per Night (ETB) *', priceCtrl,
                  type: TextInputType.number, validator: V.price),
              _tf('Max Guests *', guestsCtrl,
                  type: TextInputType.number,
                  validator: (v) => V.positiveInt(v, label: 'Max guests')),
              _tf('Image URL (optional)', imgCtrl,
                  validator: V.urlOptional),
              // Live image preview
              if (imgCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imgCtrl.text,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 36,
                        alignment: Alignment.center,
                        color: AppColors.errorLight,
                        child: const Text('Invalid image URL',
                            style: TextStyle(fontSize: 11, color: AppColors.error)),
                      ),
                    ),
                  ),
                ),
              _dropLabel('Bed Type'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: bed,
                onChanged: (v) => setSt(() => bed = v ?? bed),
                items: bedDropdownItems
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                decoration: _inputDeco,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> room) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Room'),
        content:
            Text('Delete "${room['name']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.instance.adminDio
          .delete(AdminEndpoints.subRoomById(_hotelId, room['id'] as int));
      showSuccess(context, 'Room deleted');
      _load();
    } catch (_) {
      showError(context, 'Failed');
    }
  }

  Future<void> _toggle(int rid) async {
    try {
      await ApiService.instance.adminDio
          .post(AdminEndpoints.subToggleRoom(_hotelId, rid));
      showSuccess(context, 'Room availability toggled');
      _load();
    } catch (_) {
      showError(context, 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Rooms — ${widget.hotel['name']}'),
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
        backgroundColor: const Color(0xFF059669),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _rooms.isEmpty
                  ? const Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text('🛏️',
                              style: TextStyle(fontSize: 48)),
                          SizedBox(height: 10),
                          Text('No rooms yet',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary)),
                        ]))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: _rooms.length,
                      itemBuilder: (_, i) {
                        final r = _rooms[i] as Map<String, dynamic>;
                        final avail =
                            r['is_available'] as bool? ?? true;
                        final rid = r['id'] as int? ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.border)),
                          child: Row(children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                  color: avail
                                      ? AppColors.successLight
                                      : AppColors.errorLight,
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              child: Icon(Icons.bed_rounded,
                                  color: avail
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                              Text(r['name']?.toString() ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                  '${r['bed_type'] ?? ''} · max ${r['max_guests']} guests · ETB ${_fmt(r['price_per_night'])}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ])),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded,
                                  color: AppColors.textHint),
                              onSelected: (s) {
                                if (s == 'edit') _showEdit(r);
                                if (s == 'toggle') _toggle(rid);
                                if (s == 'delete') _delete(r);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'edit',
                                    child: Text('✏️ Edit')),
                                PopupMenuItem(
                                    value: 'toggle',
                                    child: Text('🔄 Toggle Availability')),
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Text('🗑️ Delete')),
                              ],
                            ),
                          ]),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTEL PAYMENT METHODS PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _HotelPayMethodsPage extends StatefulWidget {
  final Map<String, dynamic> hotel;
  const _HotelPayMethodsPage({required this.hotel});
  @override
  State<_HotelPayMethodsPage> createState() =>
      _HotelPayMethodsPageState();
}

class _HotelPayMethodsPageState extends State<_HotelPayMethodsPage> {
  List<dynamic> _methods = [];
  bool _loading = true;

  int get _hotelId => widget.hotel['id'] as int;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance
          .adminGet(AdminEndpoints.subHotelPayMethods(_hotelId));
      final d = r['data'];
      setState(() => _methods = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showAdd() {
    String method = 'telebirr';
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final instrCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Add Payment Method',
        color: const Color(0xFFD97706),
        onSave: () async {
          try {
            await ApiService.instance.adminPost(
                AdminEndpoints.subHotelPayMethods(_hotelId),
                data: {
                  'method': method,
                  'account_name': nameCtrl.text.trim(),
                  'account_number': numCtrl.text.trim(),
                  'phone_number': phoneCtrl.text.trim(),
                  'instructions': instrCtrl.text.trim(),
                });
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Payment method added!');
            _load();
          } on ApiException catch (e) {
            showError(ctx, e.message);
          }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Column(children: [
            _dropLabel('Payment Method *'),
            DropdownButtonFormField<String>(
              value: method,
              onChanged: (v) => setSt(() => method = v ?? method),
              items: const [
                DropdownMenuItem(
                    value: 'telebirr', child: Text('Telebirr')),
                DropdownMenuItem(
                    value: 'cbe', child: Text('CBE (Commercial Bank)')),
                DropdownMenuItem(
                    value: 'abyssinia',
                    child: Text('Bank of Abyssinia')),
                DropdownMenuItem(
                    value: 'awash', child: Text('Awash Bank')),
                DropdownMenuItem(
                    value: 'dashen', child: Text('Dashen Bank')),
                DropdownMenuItem(
                    value: 'chapa', child: Text('Chapa')),
                DropdownMenuItem(
                    value: 'mpesa', child: Text('M-Pesa')),
                DropdownMenuItem(
                    value: 'cash', child: Text('Cash on Arrival')),
              ],
              decoration: _inputDeco,
            ),
            _tf('Account Name', nameCtrl),
            _tf('Account Number', numCtrl),
            _tf('Phone Number', phoneCtrl,
                type: TextInputType.phone),
            _tf('Instructions', instrCtrl, maxLines: 3),
          ]),
        ),
      ),
    );
  }

  void _showEdit(Map<String, dynamic> pm) {
    final nameCtrl = TextEditingController(
        text: pm['account_name']?.toString() ?? '');
    final numCtrl = TextEditingController(
        text: pm['account_number']?.toString() ?? '');
    final phoneCtrl = TextEditingController(
        text: pm['phone_number']?.toString() ?? '');
    final instrCtrl = TextEditingController(
        text: pm['instructions']?.toString() ?? '');
    bool isActive = pm['is_active'] as bool? ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Edit ${pm['method']}',
        color: const Color(0xFFD97706),
        onSave: () async {
          try {
            await ApiService.instance.adminDio.put(
              AdminEndpoints.subPayMethodById(pm['id'] as int),
              data: {
                'account_name': nameCtrl.text.trim(),
                'account_number': numCtrl.text.trim(),
                'phone_number': phoneCtrl.text.trim(),
                'instructions': instrCtrl.text.trim(),
                'is_active': isActive,
              },
            );
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Updated!');
            _load();
          } catch (_) {
            showError(ctx, 'Failed');
          }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Column(children: [
            _tf('Account Name', nameCtrl),
            _tf('Account Number', numCtrl),
            _tf('Phone Number', phoneCtrl,
                type: TextInputType.phone),
            _tf('Instructions', instrCtrl, maxLines: 3),
            const SizedBox(height: 10),
            SwitchListTile(
              value: isActive,
              onChanged: (v) => setSt(() => isActive = v),
              title: const Text('Active'),
              activeColor: AppColors.success,
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment Methods — ${widget.hotel['name']}'),
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Method'),
        backgroundColor: const Color(0xFFD97706),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _methods.isEmpty
                  ? const Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text('💳',
                              style: TextStyle(fontSize: 48)),
                          SizedBox(height: 10),
                          Text('No payment methods yet',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary)),
                        ]))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: _methods.length,
                      itemBuilder: (_, i) {
                        final pm =
                            _methods[i] as Map<String, dynamic>;
                        final active =
                            pm['is_active'] as bool? ?? true;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.border)),
                          child: Row(children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFD97706)
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              child: const Icon(
                                  Icons.payment_rounded,
                                  color: Color(0xFFD97706),
                                  size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                              Text(
                                  _methodLabel(
                                      pm['method']?.toString() ??
                                          ''),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              if ((pm['account_name'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                    '${pm['account_name']} · ${pm['account_number'] ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            AppColors.textSecondary)),
                            ])),
                            _statusBadge(
                                active ? 'active' : 'inactive'),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded,
                                  color: AppColors.primary, size: 18),
                              onPressed: () => _showEdit(pm),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. MANAGERS
// APIs:
//   GET    /api/admin/subadmin/managers
//   POST   /api/admin/subadmin/managers
//   DELETE /api/admin/subadmin/managers/:id
// ─────────────────────────────────────────────────────────────────────────────
class _SubManagersTab extends StatefulWidget {
  const _SubManagersTab();
  @override
  State<_SubManagersTab> createState() => _SubManagersTabState();
}

class _SubManagersTabState extends State<_SubManagersTab> {
  List<dynamic> _managers = [];
  List<dynamic> _hotels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.adminGet(AdminEndpoints.subManagers),
        ApiService.instance.adminGet(AdminEndpoints.subHotels),
      ]);
      final d = results[0]['data'];
      final h = results[1]['data'];
      setState(() {
        _managers = d is List ? d : [];
        _hotels = h is List ? h : [];
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showCreate() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    int? selHotelId;

    final _mgrKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Create Hotel Manager',
        color: const Color(0xFF059669),
        onSave: () async {
          if (!_mgrKey.currentState!.validate()) return;
          if (selHotelId == null) {
            showError(ctx, 'Please select a hotel');
            return;
          }
          try {
            await ApiService.instance
                .adminPost(AdminEndpoints.subManagers, data: {
              'full_name': nameCtrl.text.trim(),
              'email': emailCtrl.text.trim(),
              'phone': phoneCtrl.text.trim(),
              'password': passCtrl.text,
              'hotel_id': selHotelId,
            });
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Manager created!');
            _load();
          } on ApiException catch (e) {
            showError(ctx, e.message);
          }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Form(
            key: _mgrKey,
            child: Column(children: [
            _tf('Full Name *', nameCtrl, validator: V.fullName),
            _tf('Email *', emailCtrl,
                type: TextInputType.emailAddress, validator: V.email),
            _tf('Phone', phoneCtrl, type: TextInputType.phone, validator: V.phoneOptional),
            _tf('Password *', passCtrl, obscure: true, validator: V.password),
            const SizedBox(height: 10),
            _dropLabel('Assign to Hotel *'),
            DropdownButtonFormField<int>(
              value: selHotelId,
              hint: const Text('Select hotel'),
              onChanged: (v) => setSt(() => selHotelId = v),
              items: _hotels
                  .map((h) => DropdownMenuItem<int>(
                      value: (h as Map)['id'] as int,
                      child: Text(
                          h['name']?.toString() ?? '')))
                  .toList(),
              decoration: _inputDeco,
            ),
          ])),
        ),
      ),
  );

  }
  Future<void> _delete(Map<String, dynamic> mg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Manager'),
        content: Text(
            'Remove "${mg['full_name']}"? They will lose access.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.instance.adminDio
          .delete(AdminEndpoints.subManagerById(mg['id'] as int));
      showSuccess(context, 'Manager removed');
      _load();
    } catch (_) {
      showError(context, 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add Manager'),
        backgroundColor: const Color(0xFF059669),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _managers.isEmpty
                  ? const Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text('👨‍💼',
                              style: TextStyle(fontSize: 48)),
                          SizedBox(height: 10),
                          Text('No managers yet',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary)),
                        ]))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: _managers.length,
                      itemBuilder: (_, i) {
                        final m =
                            _managers[i] as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.border)),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFF059669)
                                  .withOpacity(0.1),
                              child: Text(
                                (m['full_name']?.toString() ?? 'M')
                                    .isNotEmpty
                                    ? m['full_name']
                                            .toString()[0]
                                            .toUpperCase()
                                    : 'M',
                                style: const TextStyle(
                                    color: Color(0xFF059669),
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                              Text(m['full_name']?.toString() ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              Text(m['email']?.toString() ?? '',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              if ((m['hotel_name'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text('Hotel: ${m['hotel_name']}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                            ])),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded,
                                  color: AppColors.error, size: 20),
                              onPressed: () => _delete(m),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. BROKERS
// APIs:
//   GET  /api/admin/subadmin/brokers
//   POST /api/admin/subadmin/brokers
// ─────────────────────────────────────────────────────────────────────────────
class _SubBrokersTab extends StatefulWidget {
  const _SubBrokersTab();
  @override
  State<_SubBrokersTab> createState() => _SubBrokersTabState();
}

class _SubBrokersTabState extends State<_SubBrokersTab> {
  List<dynamic> _brokers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r =
          await ApiService.instance.adminGet(AdminEndpoints.subBrokers);
      final d = r['data'];
      setState(() => _brokers = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showCreate() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final commCtrl = TextEditingController();

    final _brkKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Create Broker',
        color: const Color(0xFF4F46E5),
        onSave: () async {
          if (!_brkKey.currentState!.validate()) return;
          try {
            await ApiService.instance
                .adminPost(AdminEndpoints.subBrokers, data: {
              'full_name': nameCtrl.text.trim(),
              'email': emailCtrl.text.trim(),
              'phone': phoneCtrl.text.trim(),
              'password': passCtrl.text,
              'city': cityCtrl.text.trim(),
              'commission_pct':
                  double.tryParse(commCtrl.text) ?? 0,
            });
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Broker created!');
            _load();
          } on ApiException catch (e) {
            showError(ctx, e.message);
          }
        },
        child: Column(children: [
          _tf('Full Name *', nameCtrl),
          _tf('Email *', emailCtrl,
              type: TextInputType.emailAddress),
          _tf('Phone', phoneCtrl, type: TextInputType.phone),
          _tf('Password *', passCtrl, obscure: true),
          _tf('City', cityCtrl),
          _tf('Commission % (e.g. 5)', commCtrl,
              type: TextInputType.number),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add Broker'),
        backgroundColor: const Color(0xFF4F46E5),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _brokers.isEmpty
                  ? const Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text('🤝',
                              style: TextStyle(fontSize: 48)),
                          SizedBox(height: 10),
                          Text('No brokers yet',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary)),
                        ]))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: _brokers.length,
                      itemBuilder: (_, i) {
                        final b =
                            _brokers[i] as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.border)),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFF4F46E5)
                                  .withOpacity(0.1),
                              child: Text(
                                (b['full_name']?.toString() ?? 'B')
                                    .isNotEmpty
                                    ? b['full_name']
                                            .toString()[0]
                                            .toUpperCase()
                                    : 'B',
                                style: const TextStyle(
                                    color: Color(0xFF4F46E5),
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                              Text(b['full_name']?.toString() ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              Text(b['email']?.toString() ?? '',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              if ((b['city'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                    'City: ${b['city']} · ${b['commission_pct'] ?? 0}% commission',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                            ])),
                            _statusBadge(
                                b['status']?.toString() ?? 'active'),
                          ]),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. BOOKINGS
// API: GET /api/admin/subadmin/bookings?status=
// ─────────────────────────────────────────────────────────────────────────────
class _SubBookingsTab extends StatefulWidget {
  const _SubBookingsTab();
  @override
  State<_SubBookingsTab> createState() => _SubBookingsTabState();
}

class _SubBookingsTabState extends State<_SubBookingsTab> {
  List<dynamic> _bookings = [];
  bool _loading = true;
  String _filter = 'all';

  static const _statusColors = <String, Color>{
    'pending': Color(0xFFD97706),
    'confirmed': Color(0xFF059669),
    'completed': Color(0xFF2563EB),
    'cancelled': Color(0xFFDC2626),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final params =
          _filter == 'all' ? null : {'status': _filter};
      final r = await ApiService.instance.adminGet(
          AdminEndpoints.subBookings,
          params: params?.cast<String, dynamic>());
      final d = r['data'];
      setState(() => _bookings = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in [
                'all',
                'pending',
                'confirmed',
                'completed',
                'cancelled'
              ])
                GestureDetector(
                  onTap: () {
                    setState(() => _filter = f);
                    _load();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _filter == f
                          ? (_statusColors[f] ??
                              AppColors.primary)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _filter == f
                              ? (_statusColors[f] ??
                                  AppColors.primary)
                              : AppColors.border),
                    ),
                    child: Text(
                      f == 'all'
                          ? 'All'
                          : f[0].toUpperCase() + f.substring(1),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _filter == f
                              ? Colors.white
                              : AppColors.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      const Divider(height: 1),
      Expanded(
        child: _loading
            ? const Center(child: AppSpinner(size: SpinnerSize.large))
            : _bookings.isEmpty
                ? const Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Text('📅',
                            style: TextStyle(fontSize: 48)),
                        SizedBox(height: 10),
                        Text('No bookings found',
                            style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary)),
                      ]))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _bookings.length,
                      itemBuilder: (_, i) {
                        final b =
                            _bookings[i] as Map<String, dynamic>;
                        return _BookingTile(b);
                      },
                    ),
                  ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _BookingTile extends StatefulWidget {
  final Map<String, dynamic> b;
  const _BookingTile(this.b);
  @override
  State<_BookingTile> createState() => _BookingTileState();
}

class _BookingTileState extends State<_BookingTile> {
  bool _showId = false;

  @override
  Widget build(BuildContext context) {
    final b   = widget.b;
    final st  = b['status']?.toString() ?? 'pending';
    final idFront = b['national_id_front']?.toString() ?? '';
    final idBack  = b['national_id_back']?.toString()  ?? '';
    final hasId   = idFront.isNotEmpty || idBack.isNotEmpty;

    const statusFg = <String, Color>{
      'pending':   Color(0xFFD97706),
      'confirmed': Color(0xFF059669),
      'completed': Color(0xFF2563EB),
      'cancelled': Color(0xFFDC2626),
    };
    const statusBg = <String, Color>{
      'pending':   Color(0xFFFFFBEB),
      'confirmed': Color(0xFFECFDF5),
      'completed': Color(0xFFEFF6FF),
      'cancelled': Color(0xFFFEF2F2),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Main info ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Hotel + status
            Row(children: [
              Expanded(child: Text(b['hotel_name']?.toString() ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: statusBg[st] ?? AppColors.surfaceGray,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(st[0].toUpperCase() + st.substring(1),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: statusFg[st] ?? AppColors.textHint)),
              ),
            ]),
            const SizedBox(height: 6),

            // Guest name
            Row(children: [
              const Icon(Icons.person_outline_rounded,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(child: Text(
                b['guest_name']?.toString().isNotEmpty == true
                    ? b['guest_name'].toString()
                    : (b['guest_full_name']?.toString() ?? ''),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
            ]),

            // Phone
            if ((b['guest_phone'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.phone_outlined,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(b['guest_phone'].toString(),
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.textSecondary)),
              ]),
            ],

            const SizedBox(height: 8),

            // Dates
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.calendar_month_rounded,
                    size: 13, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(child: Text(
                  '${b['check_in'] ?? ''} → ${b['check_out'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                )),
                if ((b['rooms'] ?? 0) > 0)
                  Text('${b['rooms']} room${(b['rooms'] as int? ?? 1) > 1 ? "s" : ""}',
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 8),

            // Price
            Row(children: [
              Text('ETB ${_fmt(b['total_price'])}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.surfaceGray,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  (b['payment_method']?.toString() ?? '')
                      .replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 9, color: AppColors.textHint,
                      fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ),
            ]),
          ]),
        ),

        // ── National ID section ─────────────────────────────────────────────
        if (hasId) ...[
          const Divider(height: 1),
          GestureDetector(
            onTap: () => setState(() => _showId = !_showId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFFF0F9FF),
              child: Row(children: [
                const Icon(Icons.badge_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('National ID / Passport',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                const Spacer(),
                Icon(_showId ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary, size: 20),
              ]),
            ),
          ),
          if (_showId)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (idFront.isNotEmpty)
                    Expanded(child: _IdImageCard(
                        label: 'Front Side', dataUrl: idFront)),
                  if (idFront.isNotEmpty && idBack.isNotEmpty)
                    const SizedBox(width: 10),
                  if (idBack.isNotEmpty)
                    Expanded(child: _IdImageCard(
                        label: 'Back Side', dataUrl: idBack)),
                ],
              ),
            ),
        ],
      ]),
    );
  }
}

/// Reusable national ID photo widget — handles base64 and URL images
class _IdImageCard extends StatelessWidget {
  final String label, dataUrl;
  const _IdImageCard({required this.label, required this.dataUrl});

  Uint8List? _decode(String url) {
    try {
      final b64 = url.contains(',') ? url.split(',').last : url;
      return base64Decode(b64);
    } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    final isB64 = dataUrl.startsWith('data:');
    Widget img;
    if (isB64) {
      final bytes = _decode(dataUrl);
      img = bytes != null
          ? Image.memory(bytes, fit: BoxFit.cover)
          : const Center(child: Icon(Icons.broken_image_outlined,
              color: AppColors.textHint, size: 24));
    } else {
      img = Image.network(dataUrl, fit: BoxFit.cover,
          loadingBuilder: (_, child, prog) => prog == null
              ? child
              : const Center(child: SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))),
          errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined,
                  color: AppColors.textHint, size: 24)));
    }

    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          height: 100, width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          clipBehavior: Clip.hardEdge,
          child: img,
        ),
        const SizedBox(height: 4),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.zoom_out_map_rounded, size: 10, color: AppColors.textHint),
          SizedBox(width: 3),
          Text('Tap to enlarge',
              style: TextStyle(fontSize: 10, color: AppColors.textHint)),
        ]),
      ]),
    );
  }

  void _showFullscreen(BuildContext ctx) {
    final isB64 = dataUrl.startsWith('data:');
    Widget full;
    if (isB64) {
      final bytes = _decode(dataUrl);
      full = bytes != null
          ? Image.memory(bytes, fit: BoxFit.contain)
          : const Icon(Icons.broken_image_outlined, color: Colors.white, size: 60);
    } else {
      full = Image.network(dataUrl, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image_outlined, color: Colors.white, size: 60));
    }
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(children: [
          Center(child: InteractiveViewer(child: full)),
          Positioned(top: 8, right: 8,
            child: GestureDetector(
              onTap: () => Navigator.pop(_),
              child: Container(
                width: 34, height: 34,
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(bottom: 12, left: 0, right: 0,
            child: Center(child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)))),
        ]),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _stat(String label, String value, String emoji, Color color) =>
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ]),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );

Widget _card({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required String status,
  Widget? trailing,
}) =>
    Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ])),
        if (trailing != null) trailing else _statusBadge(status),
      ]),
    );

Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary));

Widget _empty(String msg) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
          child: Text(msg,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary))),
    );

Widget _statusBadge(String status) {
  const fg = <String, Color>{
    'active': Color(0xFF059669),
    'inactive': Color(0xFFDC2626),
    'available': Color(0xFF059669),
    'pending': Color(0xFFD97706),
    'confirmed': Color(0xFF059669),
    'completed': Color(0xFF2563EB),
    'cancelled': Color(0xFFDC2626),
  };
  const bg = <String, Color>{
    'active': Color(0xFFECFDF5),
    'inactive': Color(0xFFFEF2F2),
    'available': Color(0xFFECFDF5),
    'pending': Color(0xFFFFFBEB),
    'confirmed': Color(0xFFECFDF5),
    'completed': Color(0xFFEFF6FF),
    'cancelled': Color(0xFFFEF2F2),
  };
  final f = fg[status] ?? AppColors.textHint;
  final b = bg[status] ?? AppColors.surfaceGray;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
        color: b, borderRadius: BorderRadius.circular(8)),
    child: Text(status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: f)),
  );
}

Widget _iconBtn(
        IconData icon, String label, Color color, VoidCallback onTap) =>
    TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: color),
      label: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
    );

String _fmt(dynamic v) {
  if (v == null) return '0';
  final d = double.tryParse(v.toString()) ?? 0;
  if (d == d.truncateToDouble()) return d.truncate().toString();
  return d.toStringAsFixed(0);
}

String _methodLabel(String m) {
  const labels = <String, String>{
    'telebirr': 'Telebirr',
    'cbe': 'CBE (Commercial Bank)',
    'abyssinia': 'Bank of Abyssinia',
    'awash': 'Awash Bank',
    'dashen': 'Dashen Bank',
    'chapa': 'Chapa',
    'mpesa': 'M-Pesa',
    'cash': 'Cash on Arrival',
  };
  return labels[m] ?? m[0].toUpperCase() + m.substring(1);
}

// ── Bottom sheet scaffold ─────────────────────────────────────────────────────
class _Sheet extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onSave;
  final Widget child;
  const _Sheet({
    required this.title,
    required this.color,
    required this.onSave,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mq         = MediaQuery.of(context);
    final maxContent = mq.size.height * 0.75 - mq.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
            ]),
          ),
          const Divider(height: 1),
          // Constrained scroll area — prevents "bottom overflowed by X pixels"
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxContent > 100 ? maxContent : 300,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: child,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: const Text('Save',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
// ── Text field helper ─────────────────────────────────────────────────────────
Widget _tf(
  String label,
  TextEditingController ctrl, {
  TextInputType type = TextInputType.text,
  bool obscure = false,
  int maxLines = 1,
  String? Function(String?)? validator,
}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
            children: label.contains('*')
                ? const [TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error))]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller:  ctrl,
          keyboardType: type,
          obscureText:  obscure,
          maxLines:     maxLines,
          validator:    validator,
          autovalidateMode: validator != null
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          decoration: _inputDeco.copyWith(
            errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ]),
    );

Widget _dropLabel(String label) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
    );

final _inputDeco = InputDecoration(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
);
