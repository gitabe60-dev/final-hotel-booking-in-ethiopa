/// super_admin_screen.dart
///
/// Super Admin Dashboard — exactly matches the web system.
/// Backend: /api/admin/super/*
///
/// Tabs:
///   1. Overview    — platform stats + recent bookings
///   2. Sub-Admins  — CRUD: create, edit, delete, assign/revoke city
///   3. Cities      — CRUD: add, delete
///   4. Hotels      — list all hotels, toggle active
///   5. Users       — view all registered users
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/admin_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/snack_helper.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../../providers/language_provider.dart';
import 'admin_profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL
// ─────────────────────────────────────────────────────────────────────────────
class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});
  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final user  = auth.user;
    final lang  = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation:       0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.22),
            child: Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName[0].toUpperCase() : 'S',
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user?.fullName ?? 'Super Admin',
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w800, color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('Super Admin',
                    style: TextStyle(fontSize: 10,
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          )),
        ]),
        actions: [
          // Language toggle
          GestureDetector(
            onTap: lang.toggle,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(lang.isAmharic ? '🇬🇧' : '🇪🇹',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(lang.isAmharic ? 'EN' : 'አማ',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
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
          isScrollable:         true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded,      size: 17), text: 'Overview'),
            Tab(icon: Icon(Icons.manage_accounts_rounded, size: 17), text: 'Sub-Admins'),
            Tab(icon: Icon(Icons.location_city_rounded,  size: 17), text: 'Cities'),
            Tab(icon: Icon(Icons.hotel_rounded,           size: 17), text: 'Hotels'),
            Tab(icon: Icon(Icons.people_rounded,          size: 17), text: 'Users'),
            Tab(icon: Icon(Icons.person_rounded,          size: 17), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _SuperOverviewTab(),
          _SubAdminsCrudTab(),
          _CitiesCrudTab(),
          _HotelsListTab(),
          _UsersListTab(),
          AdminProfileScreen(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. OVERVIEW
// API: GET /api/admin/super/dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _SuperOverviewTab extends StatefulWidget {
  const _SuperOverviewTab();
  @override State<_SuperOverviewTab> createState() => _SuperOverviewTabState();
}
class _SuperOverviewTabState extends State<_SuperOverviewTab> {
  Map<String, dynamic> _data   = {};
  bool                 _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.superDashboard);
      setState(() => _data = (r['data'] as Map<String, dynamic>?) ?? {});
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));
    final o  = (_data['overview'] as Map<String, dynamic>?) ?? {};
    final bk = (_data['recent_bookings'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // 8-stat grid
          GridView.count(
            shrinkWrap: true,
            physics:    const NeverScrollableScrollPhysics(),
            crossAxisCount:   2,
            crossAxisSpacing: 10,
            mainAxisSpacing:  10,
            childAspectRatio: 1.5,
            children: [
              _S('Sub-Admins',       _v(o['sub_admins']),         '👥', const Color(0xFF2563EB)),
              _S('Hotel Managers',   _v(o['hotel_managers']),     '👨‍💼', const Color(0xFF059669)),
              _S('Active Hotels',    _v(o['active_hotels']),      '🏨', const Color(0xFF7C3AED)),
              _S('Total Revenue',    'ETB ${_f(o['total_revenue'])}','💰',const Color(0xFFD97706)),
              _S('Total Guests',     _v(o['total_guests']),       '👤', const Color(0xFF0891B2)),
              _S('Confirmed Bk.',    _v(o['confirmed_bookings']), '✅', const Color(0xFF059669)),
              _S('Pending Bk.',      _v(o['pending_bookings']),   '⏳', const Color(0xFFD97706)),
              _S('Brokers',          _v(o['brokers']),            '🤝', const Color(0xFF4F46E5)),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Recent Bookings (last 8)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          if (bk.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No bookings yet',
                  style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ...bk.take(8).map((b) => _BookingTile(b as Map<String, dynamic>)),
        ]),
      ),
    );
  }

  Widget _S(String label, String value, String emoji, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
      ]),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SUB-ADMINS — full CRUD matching the web
// APIs:
//   GET    /api/admin/super/sub-admins
//   POST   /api/admin/super/sub-admins          { full_name, email, phone, password, city }
//   PUT    /api/admin/super/sub-admins/:id      { full_name, email, phone, status }
//   DELETE /api/admin/super/sub-admins/:id
//   POST   /api/admin/super/sub-admins/:id/assign-city   { city }
//   DELETE /api/admin/super/sub-admins/:id/revoke-city/:city
// ─────────────────────────────────────────────────────────────────────────────
class _SubAdminsCrudTab extends StatefulWidget {
  const _SubAdminsCrudTab();
  @override State<_SubAdminsCrudTab> createState() => _SubAdminsCrudTabState();
}
class _SubAdminsCrudTabState extends State<_SubAdminsCrudTab> {
  List<dynamic> _list    = [];
  List<dynamic> _cities  = [];
  bool          _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.adminGet(AdminEndpoints.superSubAdmins),
        ApiService.instance.adminGet(AdminEndpoints.superCities),
      ]);
      final d = results[0]['data'];
      final c = results[1]['data'];
      setState(() {
        _list   = d is List ? d : [];
        _cities = c is List ? c : [];
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  // ── Create sub-admin ──────────────────────────────────────────────────────
  void _showCreate() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    String? selCity;
    final _createKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title:    'Create Sub-Admin',
        subtitle: 'POST /api/admin/super/sub-admins',
        onSave: () async {
          if (!_createKey.currentState!.validate()) return;
          try {
            await ApiService.instance.adminPost(AdminEndpoints.superSubAdmins, data: {
              'full_name': nameCtrl.text.trim(),
              'email':     emailCtrl.text.trim(),
              'phone':     phoneCtrl.text.trim(),
              'password':  passCtrl.text,
              if (selCity != null && selCity!.isNotEmpty) 'city': selCity,
            });
            Navigator.pop(ctx);
            showSuccess(context, 'Sub-admin created!');
            _load();
          } on ApiException catch (e) { showError(ctx, e.message); }
        },
        child: StatefulBuilder(builder: (sCtx, setSt) => Form(
          key: _createKey,
          child: Column(children: [
          _tf('Full Name *', nameCtrl, validator: V.fullName),
          _tf('Email *', emailCtrl, type: TextInputType.emailAddress, validator: V.email),
          _tf('Phone', phoneCtrl, type: TextInputType.phone, validator: V.phoneOptional),
          _tf('Password *', passCtrl, obscure: true, validator: V.password),
          const SizedBox(height: 10),
          const Align(alignment: Alignment.centerLeft,
              child: Text('Assign City (optional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary))),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value:     selCity,
            hint:      const Text('Select city'),
            onChanged: (v) => setSt(() => selCity = v),
            items: _cities.map((c) => DropdownMenuItem<String>(
                value: (c as Map)['name']?.toString() ?? '',
                child: Text((c)['name']?.toString() ?? ''))).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ])),
      ),
      ),
    );
  }

  // ── Edit sub-admin ────────────────────────────────────────────────────────
  void _showEdit(Map<String, dynamic> admin) {
    final nameCtrl  = TextEditingController(text: admin['full_name'] ?? '');
    final emailCtrl = TextEditingController(text: admin['email'] ?? '');
    final phoneCtrl = TextEditingController(text: admin['phone'] ?? '');
    String status   = admin['status'] ?? 'active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title:    'Edit Sub-Admin',
        subtitle: 'PUT /api/admin/super/sub-admins/${admin['id']}',
        onSave: () async {
          try {
            await ApiService.instance.adminDio.put(
              AdminEndpoints.superSubAdminById(admin['id'] as int),
              data: {
                'full_name': nameCtrl.text.trim(),
                'email':     emailCtrl.text.trim(),
                'phone':     phoneCtrl.text.trim(),
                'status':    status,
              },
            );
            Navigator.pop(ctx);
            showSuccess(context, 'Sub-admin updated!');
            _load();
          } catch (_) { showError(ctx, 'Failed to update'); }
        },
        child: StatefulBuilder(builder: (sCtx, setSt) => Column(children: [
          _tf('Full Name', nameCtrl),
          _tf('Email', emailCtrl, type: TextInputType.emailAddress),
          _tf('Phone', phoneCtrl, type: TextInputType.phone),
          const SizedBox(height: 10),
          const Align(alignment: Alignment.centerLeft,
              child: Text('Status', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: status,
            onChanged: (v) => setSt(() => status = v ?? status),
            items: const [
              DropdownMenuItem(value: 'active',   child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ])),
      ),
    );
  }

  // ── Assign city ───────────────────────────────────────────────────────────
  void _showAssignCity(Map<String, dynamic> admin) {
    String? selCity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title:    'Assign City to ${admin['full_name']}',
        subtitle: 'POST /api/admin/super/sub-admins/${admin['id']}/assign-city',
        onSave: () async {
          if (selCity == null || selCity!.isEmpty) {
            showError(ctx, 'Select a city'); return;
          }
          try {
            await ApiService.instance.adminDio.post(
              AdminEndpoints.superAssignCity(admin['id'] as int),
              data: {'city': selCity},
            );
            Navigator.pop(ctx);
            showSuccess(context, 'City "$selCity" assigned!');
            _load();
          } catch (_) { showError(ctx, 'Failed to assign city'); }
        },
        child: StatefulBuilder(builder: (sCtx, setSt) => Column(children: [
          const Align(alignment: Alignment.centerLeft,
              child: Text('Select City *', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selCity,
            hint: const Text('Choose a city'),
            onChanged: (v) => setSt(() => selCity = v),
            items: _cities.map((c) => DropdownMenuItem<String>(
                value: (c as Map)['name']?.toString() ?? '',
                child: Text((c)['name']?.toString() ?? ''))).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ])),
      ),
    );
  }

  // ── Delete (soft) ─────────────────────────────────────────────────────────
  Future<void> _delete(Map<String, dynamic> admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deactivate Sub-Admin'),
        content: Text('Deactivate "${admin['full_name']}"? They will lose access.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService.instance.adminDio
          .delete(AdminEndpoints.superSubAdminById(admin['id'] as int));
      showSuccess(context, 'Sub-admin deactivated');
      _load();
    } catch (_) { showError(context, 'Failed'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed:  _showCreate,
        icon:       const Icon(Icons.add),
        label:      const Text('Add Sub-Admin'),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _list.isEmpty
                  ? const Center(child: Column(
                      mainAxisSize: MainAxisSize.min, children: [
                      Text('👥', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 10),
                      Text('No sub-admins yet',
                          style: TextStyle(fontSize: 15,
                              color: AppColors.textSecondary)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: _list.length,
                      itemBuilder: (_, i) {
                        final a      = _list[i] as Map<String, dynamic>;
                        final active = a['status'] == 'active';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            // Name + status
                            Row(children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                                child: Text(
                                  (a['full_name']?.toString() ?? 'A').isNotEmpty
                                      ? a['full_name'].toString()[0].toUpperCase() : 'A',
                                  style: const TextStyle(color: Color(0xFF7C3AED),
                                      fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(a['full_name']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                                Text(a['email']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ])),
                              _statusBadge(a['status']?.toString() ?? 'active'),
                            ]),

                            // City assignment
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(children: [
                                const Icon(Icons.location_city_rounded,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'City: ${a['city'] ?? 'Not assigned'}',
                                  style: const TextStyle(fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ]),
                            ),

                            // Action buttons
                            const SizedBox(height: 10),
                            Wrap(spacing: 8, children: [
                              _ActionBtn('Edit', Icons.edit_rounded,
                                  AppColors.primary, () => _showEdit(a)),
                              _ActionBtn('Assign City',
                                  Icons.location_on_rounded,
                                  const Color(0xFF059669),
                                  () => _showAssignCity(a)),
                              if (active)
                                _ActionBtn('Deactivate',
                                    Icons.person_off_rounded,
                                    AppColors.error,
                                    () => _delete(a)),
                            ]),
                          ]),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. CITIES — full CRUD
// APIs:
//   GET    /api/admin/super/cities
//   POST   /api/admin/super/cities          { name, region }
//   DELETE /api/admin/super/cities/:id
// ─────────────────────────────────────────────────────────────────────────────
class _CitiesCrudTab extends StatefulWidget {
  const _CitiesCrudTab();
  @override State<_CitiesCrudTab> createState() => _CitiesCrudTabState();
}
class _CitiesCrudTabState extends State<_CitiesCrudTab> {
  List<dynamic> _cities  = [];
  bool          _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.superCities);
      final d = r['data'];
      setState(() => _cities = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showAdd() {
    final nameCtrl   = TextEditingController();
    final regionCtrl = TextEditingController();
    final _cityKey   = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title:    'Add City',
        subtitle: 'POST /api/admin/super/cities',
        onSave: () async {
          if (!_cityKey.currentState!.validate()) return;
          try {
            await ApiService.instance.adminPost(AdminEndpoints.superCities, data: {
              'name':   nameCtrl.text.trim(),
              'region': regionCtrl.text.trim(),
            });
            Navigator.pop(ctx);
            showSuccess(context, 'City "${nameCtrl.text.trim()}" added!');
            _load();
          } on ApiException catch (e) { showError(ctx, e.message); }
        },
        child: Form(
          key: _cityKey,
          child: Column(children: [
          _tf('City Name *', nameCtrl, validator: (v) => V.required(v, label: 'City name')),
          _tf('Region', regionCtrl),
        ])),
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> city) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete City'),
        content: Text('Delete "${city['name']}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService.instance.adminDio
          .delete(AdminEndpoints.superCityById(city['id'] as int));
      showSuccess(context, 'City deleted');
      _load();
    } catch (_) { showError(context, 'Failed to delete city'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed:       _showAdd,
        icon:            const Icon(Icons.add),
        label:           const Text('Add City'),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _cities.isEmpty
                  ? const Center(child: Column(
                      mainAxisSize: MainAxisSize.min, children: [
                      Text('📍', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 10),
                      Text('No cities yet',
                          style: TextStyle(fontSize: 15,
                              color: AppColors.textSecondary)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: _cities.length,
                      itemBuilder: (_, i) {
                        final c = _cities[i] as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border)),
                          child: Row(children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.location_city_rounded,
                                  color: Color(0xFF7C3AED), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(c['name']?.toString() ?? '',
                                  style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                              if ((c['region']?.toString() ?? '').isNotEmpty)
                                Text(c['region']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 12,
                                        color: AppColors.textSecondary)),
                              if ((c['hotel_count'] ?? 0) > 0)
                                Text('${c['hotel_count']} hotel${c['hotel_count'] > 1 ? 's' : ''}',
                                    style: const TextStyle(fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                            ])),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.error, size: 20),
                              onPressed: () => _delete(c),
                              tooltip: 'Delete city',
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
// 4. HOTELS — list all, toggle active
// APIs: GET /api/admin/super/hotels
//       POST /api/admin/super/hotels/:id/toggle
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// 4. HOTELS — list all, toggle, ADD, EDIT
// APIs:
//   GET  /api/admin/super/hotels
//   POST /api/admin/super/hotels        { name, city, address, description, type, price, lat, lng, is_featured, image_url }
//   PUT  /api/admin/super/hotels/:id    { name, city, address, description, type, price, is_active }
//   POST /api/admin/super/hotels/:id/toggle
// ─────────────────────────────────────────────────────────────────────────────
class _HotelsListTab extends StatefulWidget {
  const _HotelsListTab();
  @override State<_HotelsListTab> createState() => _HotelsListTabState();
}
class _HotelsListTabState extends State<_HotelsListTab> {
  List<dynamic> _hotels  = [];
  List<dynamic> _cities  = [];
  bool          _loading = true;
  final Set<int> _toggling = {};

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.adminGet(AdminEndpoints.superHotels),
        ApiService.instance.adminGet(AdminEndpoints.superCities),
      ]);
      final d = results[0]['data'];
      final c = results[1]['data'];
      setState(() {
        _hotels = d is List ? d : [];
        _cities = c is List ? c : [];
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _toggle(int id) async {
    setState(() => _toggling.add(id));
    try {
      await ApiService.instance.adminDio
          .post(AdminEndpoints.superToggleHotel(id));
      showSuccess(context, 'Hotel status toggled');
      _load();
    } catch (_) { showError(context, 'Failed'); }
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
    String  selCity    = _cities.isNotEmpty
        ? (_cities.first as Map)['name']?.toString() ?? ''
        : '';
    String  type       = 'hotel';
    bool    isFeatured = false;
    final   _addKey    = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title:    'Add Hotel',
        subtitle: 'POST /api/admin/super/hotels',
        onSave: () async {
          if (!_addKey.currentState!.validate()) return;
          if (selCity.isEmpty) {
            showError(ctx, 'Please select a city');
            return;
          }
          try {
            await ApiService.instance.adminPost(AdminEndpoints.superHotels, data: {
              'name':            nameCtrl.text.trim(),
              'city':            selCity,
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
          } on ApiException catch (e) { showError(ctx, e.message); }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Form(
            key: _addKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _saLabel('Hotel Name *'),
              const SizedBox(height: 6),
              _saField(nameCtrl, 'e.g. Sheraton Addis', validator: (v) => V.required(v, label: 'Hotel name')),
              const SizedBox(height: 12),
              _saLabel('City *'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selCity.isEmpty ? null : selCity,
                hint: const Text('Select city'),
                onChanged: (v) => setSt(() => selCity = v ?? selCity),
                items: _cities.map((c) => DropdownMenuItem<String>(
                    value: (c as Map)['name']?.toString() ?? '',
                    child: Text((c)['name']?.toString() ?? ''))).toList(),
                decoration: _saDeco,
              ),
              const SizedBox(height: 12),
              _saLabel('Hotel Type'),
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
                decoration: _saDeco,
              ),
              const SizedBox(height: 12),
              _saLabel('Price per Night (ETB) *'),
              const SizedBox(height: 6),
              _saField(priceCtrl, '0', type: TextInputType.number, validator: V.price),
              const SizedBox(height: 12),
              _saLabel('Address'),
              const SizedBox(height: 6),
              _saField(addrCtrl, 'e.g. Taitu St, Addis Ababa'),
              const SizedBox(height: 12),
              _saLabel('Description (optional)'),
              const SizedBox(height: 6),
              _saField(descCtrl, '', maxLines: 3),
              const SizedBox(height: 12),
              _saLabel('Image URL (optional)'),
              const SizedBox(height: 6),
              _saField(imgCtrl, 'https://example.com/image.jpg'),
              const SizedBox(height: 12),
              // Lat / Lng row
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _saLabel('Latitude (optional)'),
                    const SizedBox(height: 6),
                    _saField(latCtrl, 'e.g. 9.0192',
                        type: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        validator: V.latitude),
                  ],
                )),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _saLabel('Longitude (optional)'),
                    const SizedBox(height: 6),
                    _saField(lngCtrl, 'e.g. 38.7525',
                        type: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        validator: V.longitude),
                  ],
                )),
              ]),
              const SizedBox(height: 12),
              // Google Maps help
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE))),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📍 How to get Google Maps coordinates:',
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8))),
                    SizedBox(height: 6),
                    Text('1. Open maps.google.com\n'
                         '2. Search for the hotel location\n'
                         '3. Right-click → "What\'s here?" → copy coordinates\n'
                         '4. Paste latitude and longitude above',
                        style: TextStyle(fontSize: 11,
                            color: Color(0xFF2563EB), height: 1.6)),
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
                            ? const Color(0xFF7C3AED)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: isFeatured
                                ? const Color(0xFF7C3AED)
                                : AppColors.border,
                            width: 1.5)),
                    child: isFeatured
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  const Text('Mark as Featured Hotel',
                      style: TextStyle(fontSize: 13,
                          color: AppColors.textPrimary)),
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
    String selCity  = hotel['city']?.toString() ?? '';
    String type     = hotel['type']?.toString() ?? 'hotel';
    final  _editKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title:    'Edit Hotel',
        subtitle: 'PUT /api/admin/super/hotels/${hotel['id']}',
        onSave: () async {
          if (!_editKey.currentState!.validate()) return;
          try {
            await ApiService.instance.adminDio.put(
              AdminEndpoints.superHotelById(hotel['id'] as int),
              data: {
                'name':            nameCtrl.text.trim(),
                'city':            selCity,
                'address':         addrCtrl.text.trim(),
                'description':     descCtrl.text.trim(),
                'type':            type,
                'price_per_night': double.tryParse(priceCtrl.text) ?? 0,
                'is_active':       hotel['is_active'] ?? true,
              },
            );
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Hotel updated!');
            _load();
          } catch (_) { showError(ctx, 'Failed to update'); }
        },
        child: StatefulBuilder(
          builder: (sCtx, setSt) => Form(
            key: _editKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _saLabel('Hotel Name *'),
              const SizedBox(height: 6),
              _saField(nameCtrl, '', validator: (v) => V.required(v, label: 'Hotel name')),
              const SizedBox(height: 12),
              _saLabel('City'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selCity.isEmpty ? null : selCity,
                hint: const Text('Select city'),
                onChanged: (v) => setSt(() => selCity = v ?? selCity),
                items: _cities.map((c) => DropdownMenuItem<String>(
                    value: (c as Map)['name']?.toString() ?? '',
                    child: Text((c)['name']?.toString() ?? ''))).toList(),
                decoration: _saDeco,
              ),
              const SizedBox(height: 12),
              _saLabel('Hotel Type'),
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
                decoration: _saDeco,
              ),
              const SizedBox(height: 12),
              _saLabel('Price per Night (ETB) *'),
              const SizedBox(height: 6),
              _saField(priceCtrl, '0', type: TextInputType.number, validator: V.price),
              const SizedBox(height: 12),
              _saLabel('Address'),
              const SizedBox(height: 6),
              _saField(addrCtrl, ''),
              const SizedBox(height: 12),
              _saLabel('Description'),
              const SizedBox(height: 6),
              _saField(descCtrl, '', maxLines: 3),
            ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: AppSpinner(size: SpinnerSize.large));
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Hotel'),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _hotels.isEmpty
            ? const Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏨', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 10),
                  Text('No hotels yet',
                      style: TextStyle(fontSize: 15,
                          color: AppColors.textSecondary)),
                ]))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                itemCount: _hotels.length,
                itemBuilder: (_, i) {
                  final h      = _hotels[i] as Map<String, dynamic>;
                  final active = h['is_active'] as bool? ?? false;
                  final id     = h['id'] as int? ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: Column(children: [
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                              color: active
                                  ? AppColors.successLight
                                  : AppColors.surfaceGray,
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.hotel_rounded,
                              color: active
                                  ? AppColors.success
                                  : AppColors.textHint,
                              size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(h['name']?.toString() ?? '',
                              style: const TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          Text(
                              '${h['city'] ?? ''} · ${h['type'] ?? ''} · ETB ${_f(h['price_per_night'])}',
                              style: const TextStyle(fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ])),
                        if (_toggling.contains(id))
                          const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5))
                        else
                          Switch(
                            value:     active,
                            onChanged: (_) => _toggle(id),
                            activeColor: AppColors.success,
                          ),
                      ]),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(children: [
                        TextButton.icon(
                          onPressed: () => _showEdit(h),
                          icon: const Icon(Icons.edit_rounded,
                              size: 15, color: AppColors.primary),
                          label: const Text('Edit',
                              style: TextStyle(fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: active
                                  ? AppColors.successLight
                                  : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            active ? 'Active' : 'Inactive',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? AppColors.success
                                    : AppColors.error),
                          ),
                        ),
                      ]),
                    ]),
                  );
                },
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. USERS
// API: GET /api/admin/super/users?search=
// ─────────────────────────────────────────────────────────────────────────────
class _UsersListTab extends StatefulWidget {
  const _UsersListTab();
  @override State<_UsersListTab> createState() => _UsersListTabState();
}
class _UsersListTabState extends State<_UsersListTab> {
  List<dynamic>  _users   = [];
  bool           _loading = true;
  final _searchCtrl = TextEditingController();

  @override void initState() { super.initState(); _load(); }
  @override void dispose()   { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance.adminGet(AdminEndpoints.superUsers,
          params: search.isEmpty ? null : {'search': search});
      final d = r['data'];
      setState(() => _users = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _searchCtrl,
          onSubmitted: (v) => _load(search: v),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search users by name or email…',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textHint, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      _load();
                    })
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ),
      const Divider(height: 1),

      Expanded(
        child: _loading
            ? const Center(child: AppSpinner(size: SpinnerSize.large))
            : RefreshIndicator(
                onRefresh: _load,
                child: _users.isEmpty
                    ? const Center(child: Text('No users found',
                        style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _users.length,
                        itemBuilder: (_, i) {
                          final u     = _users[i] as Map<String, dynamic>;
                          final name  = '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
                          final email = u['email']?.toString() ?? '—';
                          final bk    = u['booking_count'] ?? 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border)),
                            child: Row(children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'G',
                                  style: const TextStyle(color: AppColors.primary,
                                      fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(name.isEmpty ? email : name,
                                    style: const TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                                Text(email,
                                    style: const TextStyle(fontSize: 11,
                                        color: AppColors.textSecondary),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ])),
                              Column(crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                _statusBadge(u['status']?.toString() ?? 'active'),
                                const SizedBox(height: 4),
                                Text('$bk booking${bk != 1 ? "s" : ""}',
                                    style: const TextStyle(fontSize: 10,
                                        color: AppColors.textHint)),
                              ]),
                            ]),
                          );
                        },
                      ),
              ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _FormSheet extends StatelessWidget {
  final String    title, subtitle;
  final Widget    child;
  final VoidCallback onSave;

  const _FormSheet({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18,
              fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11,
              color: AppColors.textHint, fontFamily: 'monospace')),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              child: Text(title.startsWith('Edit') ? 'Save Changes' : 'Create',
                  style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

Widget _tf(String label, TextEditingController ctrl, {
  TextInputType type = TextInputType.text,
  bool obscure = false,
  String? Function(String?)? validator,
}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
        text: TextSpan(
          text: label.replaceAll(' *', ''),
          style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          children: label.contains('*')
              ? const [TextSpan(text: ' *',
                  style: TextStyle(color: AppColors.error))]
              : [],
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller:   ctrl,
        keyboardType: type,
        obscureText:  obscure,
        validator:    validator,
        autovalidateMode: validator != null
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: label.replaceAll(' *', ''),
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
          errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
          border:         OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      const SizedBox(height: 10),
    ]);

Widget _ActionBtn(String label, IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color:        color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border:       Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );

Widget _statusBadge(String status) {
  const fg = <String, Color>{
    'active': Color(0xFF059669), 'inactive': Color(0xFF6B7280),
    'suspended': Color(0xFFDC2626),
  };
  const bg = <String, Color>{
    'active': Color(0xFFECFDF5), 'inactive': Color(0xFFF3F4F6),
    'suspended': Color(0xFFFEF2F2),
  };
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
        color: bg[status] ?? AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(8)),
    child: Text(status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
            color: fg[status] ?? AppColors.textHint)),
  );
}

class _BookingTile extends StatelessWidget {
  final Map<String, dynamic> b;
  const _BookingTile(this.b);

  @override
  Widget build(BuildContext context) {
    final st = b['status']?.toString() ?? 'pending';
    const fg = <String, Color>{'pending': Color(0xFFD97706), 'confirmed': Color(0xFF059669),
        'completed': Color(0xFF2563EB), 'cancelled': Color(0xFFDC2626)};
    const bg = <String, Color>{'pending': Color(0xFFFFFBEB), 'confirmed': Color(0xFFECFDF5),
        'completed': Color(0xFFEFF6FF), 'cancelled': Color(0xFFFEF2F2)};
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(b['hotel_name']?.toString() ?? '',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${b['guest_name'] ?? ''} · ${b['check_in']} → ${b['check_out']}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: bg[st] ?? AppColors.surfaceGray,
                borderRadius: BorderRadius.circular(8)),
            child: Text(st[0].toUpperCase() + st.substring(1),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: fg[st] ?? AppColors.textHint)),
          ),
          const SizedBox(height: 3),
          Text('ETB ${_f(b['total_price'])}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
        ]),
      ]),
    );
  }
}

String _v(dynamic v) => '${v ?? 0}';
String _f(dynamic v) {
  if (v == null) return '0';
  final d = v is double ? v : (v is int ? v.toDouble() :
      double.tryParse(v.toString()) ?? 0.0);
  return d.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ── Super-admin hotel form helpers ────────────────────────────────────────────

Widget _saLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 0),
  child: RichText(
    text: TextSpan(
      text: text.replaceAll(' *', ''),
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      children: text.contains('*')
          ? const [TextSpan(text: ' *',
              style: TextStyle(color: AppColors.error))]
          : [],
    ),
  ),
);

Widget _saField(
  TextEditingController ctrl,
  String hint, {
  TextInputType type = TextInputType.text,
  int maxLines = 1,
  String? Function(String?)? validator,
}) =>
    TextFormField(
      controller:   ctrl,
      keyboardType: type,
      maxLines:     maxLines,
      validator:    validator,
      autovalidateMode: validator != null
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText:       hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
        errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
        border:         OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: AppColors.border)),
        enabledBorder:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: AppColors.border)),
        focusedBorder:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );

final InputDecoration _saDeco = InputDecoration(
  border:         OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: AppColors.border)),
  enabledBorder:  OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: AppColors.border)),
  focusedBorder:  OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: AppColors.primary, width: 1.5)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
);
