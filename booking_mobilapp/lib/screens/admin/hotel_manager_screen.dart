/// hotel_manager_screen.dart
///
/// Hotel Manager Dashboard — exactly matches the web ManagerDashboard.
/// Backend base: /api/admin/manager/*
///
/// Tabs:
///   1. Overview    — stats, pending payments (approve/reject), rooms, bookings, notifications
///   2. Rooms       — CRUD: add, edit, toggle, set status
///   3. Bookings    — view + confirm/cancel
///   4. Payments    — verify (approve/reject) + filter
///   5. Pay Methods — CRUD: add, edit, delete
///   6. Inbox       — messages
///   7. Settings    — profile
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
class HotelManagerScreen extends StatefulWidget {
  const HotelManagerScreen({super.key});
  @override
  State<HotelManagerScreen> createState() => _HotelManagerScreenState();
}

class _HotelManagerScreenState extends State<HotelManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 7, vsync: this);
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
        backgroundColor: const Color(0xFF059669),
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
                  : 'M',
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
                Text(user?.fullName ?? 'Hotel Manager',
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
                  child: const Text('Hotel Manager',
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
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
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
            Tab(icon: Icon(Icons.bed_rounded, size: 17), text: 'Rooms'),
            Tab(
                icon: Icon(Icons.book_online_rounded, size: 17),
                text: 'Bookings'),
            Tab(
                icon: Icon(Icons.payment_rounded, size: 17),
                text: 'Payments'),
            Tab(
                icon: Icon(Icons.credit_card_rounded, size: 17),
                text: 'Pay Methods'),
            Tab(
                icon: Icon(Icons.inbox_rounded, size: 17),
                text: 'Inbox'),
            Tab(
                icon: Icon(Icons.person_rounded, size: 17),
                text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _MgrOverviewTab(),
          _MgrRoomsTab(),
          _MgrBookingsTab(),
          _MgrPaymentsTab(),
          _MgrPayMethodsTab(),
          _MgrInboxTab(),
          AdminProfileScreen(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. OVERVIEW
// APIs: GET /manager/dashboard + /manager/payments + /manager/notifications
// ─────────────────────────────────────────────────────────────────────────────
class _MgrOverviewTab extends StatefulWidget {
  const _MgrOverviewTab();
  @override
  State<_MgrOverviewTab> createState() => _MgrOverviewTabState();
}

class _MgrOverviewTabState extends State<_MgrOverviewTab> {
  Map<String, dynamic> _data = {};
  List<dynamic> _payments = [];
  List<dynamic> _notifications = [];
  bool _loading = true;
  final Set<int> _acting = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.adminGet(AdminEndpoints.managerDashboard),
        ApiService.instance.adminGet(AdminEndpoints.managerPayments),
        ApiService.instance.adminGet(AdminEndpoints.managerNotifications),
      ]);
      _data =
          (results[0]['data'] as Map<String, dynamic>?) ?? {};
      final p = results[1]['data'];
      _payments = p is List ? p : [];
      final n = results[2]['data'];
      _notifications = n is List
          ? n
          : (n is Map ? (n['notifications'] as List? ?? []) : []);
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
    } catch (_) {
      showError(context, 'Action failed');
    }
    setState(() => _acting.remove(id));
  }

  Future<void> _markRead(int id) async {
    try {
      await ApiService.instance.adminDio
          .post(AdminEndpoints.managerReadNotif(id));
      _load();
    } catch (_) {}
  }

  List<dynamic> get _pending =>
      _payments.where((p) => (p as Map)['status'] == 'submitted').toList();
  List<dynamic> get _rooms =>
      (_data['rooms'] as List<dynamic>?) ?? [];
  List<dynamic> get _bookings =>
      (_data['recent_bookings'] as List<dynamic>?) ?? [];
  int get _unread => _data['unread_messages'] as int? ?? 0;

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(child: AppSpinner(size: SpinnerSize.large));

    final availRooms =
        _rooms.where((r) => (r as Map)['is_available'] == true).length;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _stat('Total Rooms', '${_rooms.length}', '🛏️',
                  const Color(0xFF2563EB)),
              _stat('Available', '$availRooms', '✅',
                  const Color(0xFF059669)),
              _stat('Pending Payments', '${_pending.length}', '💳',
                  const Color(0xFFD97706)),
              _stat('Unread Msgs', '$_unread', '📨',
                  const Color(0xFF7C3AED)),
            ],
          ),
          const SizedBox(height: 20),

          // Pending payments — most prominent section
          Row(children: [
            const Icon(Icons.credit_card_rounded,
                color: Color(0xFFD97706), size: 18),
            const SizedBox(width: 8),
            const Text('Payment Verification',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            if (_pending.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFFDE68A))),
                child: Text('${_pending.length} pending',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706))),
              ),
            ],
          ]),
          const SizedBox(height: 10),

          if (_pending.isEmpty)
            _emptyMsg('No payments pending verification')
          else
            ..._pending.take(5).map((p) {
              final pm = p as Map<String, dynamic>;
              final id = pm['id'] as int? ?? 0;
              return _PayCard(
                pm: pm,
                acting: _acting.contains(id),
                onApprove: () => _verify(id, 'approved'),
                onReject: () => _verify(id, 'rejected'),
              );
            }),
          const SizedBox(height: 20),

          _sectionTitle('My Rooms'),
          const SizedBox(height: 10),
          if (_rooms.isEmpty)
            _emptyMsg('No rooms yet')
          else
            ..._rooms.take(5).map((r) {
              final rm = r as Map<String, dynamic>;
              final avail = rm['is_available'] as bool? ?? true;
              return _infoRow(
                icon: Icons.bed_rounded,
                iconColor: avail ? AppColors.success : AppColors.error,
                title: rm['name']?.toString() ?? '',
                subtitle: '${_normalizeBed(rm['bed_type']?.toString())} · max ${rm['max_guests']} · ETB ${_fmt(rm['price_per_night'])}',
              );
            }),
          const SizedBox(height: 20),

          _sectionTitle('Recent Bookings'),
          const SizedBox(height: 10),
          if (_bookings.isEmpty)
            _emptyMsg('No bookings yet')
          else
            ..._bookings.take(5).map((b) =>
                _BookingCard(b as Map<String, dynamic>)),
          const SizedBox(height: 20),

          // Notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.notifications_rounded,
                    color: Color(0xFF7C3AED), size: 18),
                const SizedBox(width: 8),
                _sectionTitle('Notifications'),
              ]),
              if (_notifications
                  .any((n) => (n as Map)['is_read'] != true))
                TextButton(
                  onPressed: () async {
                    await ApiService.instance.adminDio
                        .post(AdminEndpoints.managerReadAllNotifs);
                    _load();
                  },
                  child: const Text('Mark all read',
                      style: TextStyle(fontSize: 12,
                          color: Color(0xFF7C3AED))),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_notifications.isEmpty)
            _emptyMsg('No notifications yet')
          else
            ..._notifications.take(8).map((n) {
              final notif = n as Map<String, dynamic>;
              final isRead = notif['is_read'] as bool? ?? false;
              final nId = notif['id'] as int? ?? 0;
              return GestureDetector(
                onTap: () {
                  if (!isRead) _markRead(nId);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: isRead
                          ? Colors.white
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isRead
                              ? AppColors.border
                              : AppColors.primary.withOpacity(0.3))),
                  child: Row(children: [
                    Icon(
                      (notif['type'] ?? '') == 'booking_new'
                          ? Icons.calendar_month_rounded
                          : Icons.credit_card_rounded,
                      color: (notif['type'] ?? '') == 'booking_new'
                          ? AppColors.primary
                          : AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                      Text(notif['title']?.toString() ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(notif['message']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ])),
                    if (!isRead)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle)),
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
// 2. ROOMS — view + edit + status (NO Add — rooms are added by sub-admin only)
// APIs:
//   GET    /manager/rooms
//   PUT    /manager/rooms/:rid
//   DELETE /manager/rooms/:rid
//   POST   /manager/rooms/:rid/toggle
//   POST   /manager/rooms/:rid/status  { status }
// ─────────────────────────────────────────────────────────────────────────────
class _MgrRoomsTab extends StatefulWidget {
  const _MgrRoomsTab();
  @override
  State<_MgrRoomsTab> createState() => _MgrRoomsTabState();
}

class _MgrRoomsTabState extends State<_MgrRoomsTab> {
  List<dynamic> _rooms = [];
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
          await ApiService.instance.adminGet(AdminEndpoints.managerRooms);
      final d = r['data'];
      setState(() => _rooms = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  // Edit room — includes image URL + Form validation
  void _showEdit(Map<String, dynamic> room) {
    final nameCtrl  = TextEditingController(text: room['name']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: room['price_per_night']?.toString() ?? '');
    final guestsCtrl= TextEditingController(text: room['max_guests']?.toString() ?? '');
    final imgCtrl   = TextEditingController(text: room['image_url']?.toString() ?? '');
    // Normalize to capitalized web values — prevents assertion error
    String bed = _normalizeBed(room['bed_type']?.toString());
    const bedTypes = ['Single', 'Double', 'Twin', 'Queen', 'King'];
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
              AdminEndpoints.managerRoomById(room['id'] as int),
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
              // Live image preview — rebuilds when URL changes
              StatefulBuilder(builder: (_, setImg) {
                return imgCtrl.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => setImg(() {}),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imgCtrl.text,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Invalid image URL',
                                    style: TextStyle(
                                        fontSize: 12, color: AppColors.error)),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox();
              }),
              _dropLabel('Bed Type'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: bed,
                onChanged: (v) => setSt(() => bed = v ?? bed),
                // Capitalized values matching web frontend exactly
                items: bedTypes.map((b) =>
                  DropdownMenuItem(value: b, child: Text(b))
                ).toList(),
                decoration: _inputDeco,
              ),
              const SizedBox(height: 14),
              // Current room status info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'To add or delete rooms, contact your city sub-admin.',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primary,
                          height: 1.4),
                    ),
                  ),
                ]),
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
        content: Text('Delete "${room['name']}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.instance.adminDio
          .delete(AdminEndpoints.managerRoomById(room['id'] as int));
      showSuccess(context, 'Room deleted');
      _load();
    } catch (_) { showError(context, 'Failed'); }
  }

  Future<void> _setStatus(int rid, String status) async {
    try {
      await ApiService.instance.adminDio.post(
          AdminEndpoints.managerRoomStatus(rid),
          data: {'status': status});
      showSuccess(context, 'Status → $status');
      _load();
    } catch (_) { showError(context, 'Failed'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ── NO floatingActionButton — rooms are added by sub-admin ──
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _rooms.isEmpty
                  ? const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('🛏️', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 10),
                        Text('No rooms yet',
                            style: TextStyle(fontSize: 15,
                                color: AppColors.textSecondary)),
                        SizedBox(height: 8),
                        Text('Rooms are added by the sub-admin.',
                            style: TextStyle(fontSize: 12,
                                color: AppColors.textHint)),
                      ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _rooms.length,
                      itemBuilder: (_, i) {
                        final r  = _rooms[i] as Map<String, dynamic>;
                        final avail = r['is_available'] as bool? ?? true;
                        final rid   = r['id'] as int? ?? 0;
                        final imgUrl = r['image_url']?.toString() ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border)),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Room image (if present)
                              if (imgUrl.isNotEmpty)
                                SizedBox(
                                  height: 110,
                                  width: double.infinity,
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                          height: 110,
                                          color: AppColors.surfaceGray,
                                          child: const Center(
                                            child: Icon(Icons.bed_rounded,
                                                color: AppColors.textHint,
                                                size: 32),
                                          ),
                                        ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(children: [
                                  if (imgUrl.isEmpty)
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                          color: avail
                                              ? AppColors.successLight
                                              : AppColors.errorLight,
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Icon(Icons.bed_rounded,
                                          color: avail
                                              ? AppColors.success
                                              : AppColors.error,
                                          size: 22),
                                    ),
                                  if (imgUrl.isEmpty) const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                      Text(r['name']?.toString() ?? '',
                                          style: const TextStyle(fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${_normalizeBed(r['bed_type']?.toString())} · max ${r['max_guests']} guests · ETB ${_fmt(r['price_per_night'])}',
                                          style: const TextStyle(fontSize: 12,
                                              color: AppColors.textSecondary)),
                                      const SizedBox(height: 4),
                                      _statusBadge(r['room_status']?.toString() ??
                                          (avail ? 'available' : 'unavailable')),
                                    ]),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded,
                                        color: AppColors.textHint),
                                    onSelected: (s) {
                                      if (s == 'edit')    _showEdit(r);
                                      if (s == 'delete')  _delete(r);
                                      if (s == 'available' || s == 'maintenance' || s == 'unavailable') {
                                        _setStatus(rid, s);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'edit',        child: Text('✏️  Edit Room')),
                                      PopupMenuItem(value: 'available',   child: Text('✅  Set Available')),
                                      PopupMenuItem(value: 'maintenance', child: Text('🔧  Maintenance')),
                                      PopupMenuItem(value: 'unavailable', child: Text('🚫  Unavailable')),
                                      PopupMenuItem(value: 'delete',      child: Text('🗑️  Delete')),
                                    ],
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. BOOKINGS
// API: GET /manager/bookings?status=
//      POST /manager/bookings/:id/status  { status }
// ─────────────────────────────────────────────────────────────────────────────
class _MgrBookingsTab extends StatefulWidget {
  const _MgrBookingsTab();
  @override
  State<_MgrBookingsTab> createState() => _MgrBookingsTabState();
}

class _MgrBookingsTabState extends State<_MgrBookingsTab> {
  List<dynamic> _bookings = [];
  bool _loading = true;
  String _filter = 'all';

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
          AdminEndpoints.managerBookings,
          params: params?.cast<String, dynamic>());
      final d = r['data'];
      setState(() => _bookings = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await ApiService.instance.adminDio.post(
          AdminEndpoints.managerBookingStatus(id),
          data: {'status': status});
      showSuccess(context, 'Booking $status');
      _load();
    } catch (_) {
      showError(context, 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _filterBar(_filter, (f) {
        setState(() => _filter = f);
        _load();
      }),
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
                        final st =
                            b['status']?.toString() ?? 'pending';
                        return _BookingCard(b,
                            onConfirm: st == 'pending'
                                ? () => _updateStatus(
                                    b['id'] as int, 'confirmed')
                                : null,
                            onCancel: st == 'pending'
                                ? () => _updateStatus(
                                    b['id'] as int, 'cancelled')
                                : null);
                      },
                    ),
                  ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. PAYMENTS
// API: GET /manager/payments
//      POST /manager/payments/:id/verify  { "status": "approved"|"rejected" }
// ─────────────────────────────────────────────────────────────────────────────
class _MgrPaymentsTab extends StatefulWidget {
  const _MgrPaymentsTab();
  @override
  State<_MgrPaymentsTab> createState() => _MgrPaymentsTabState();
}

class _MgrPaymentsTabState extends State<_MgrPaymentsTab> {
  List<dynamic> _payments = [];
  bool _loading = true;
  String _filter = 'all';
  final Set<int> _acting = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance
          .adminGet(AdminEndpoints.managerPayments);
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
    } catch (_) {
      showError(context, 'Action failed');
    }
    setState(() => _acting.remove(id));
  }

  List<dynamic> get _filtered => _filter == 'all'
      ? _payments
      : _payments
          .where((p) => (p as Map)['status'] == _filter)
          .toList();

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
                'submitted',
                'completed',
                'failed'
              ])
                GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _filter == f
                          ? const Color(0xFFD97706)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _filter == f
                              ? const Color(0xFFD97706)
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
            : _filtered.isEmpty
                ? const Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Text('💳',
                            style: TextStyle(fontSize: 48)),
                        SizedBox(height: 10),
                        Text('No payments found',
                            style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary)),
                      ]))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final p =
                            _filtered[i] as Map<String, dynamic>;
                        final id = p['id'] as int? ?? 0;
                        return _PayCard(
                          pm: p,
                          acting: _acting.contains(id),
                          onApprove: () => _verify(id, 'approved'),
                          onReject: () => _verify(id, 'rejected'),
                        );
                      },
                    ),
                  ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. PAYMENT METHODS CRUD
// APIs:
//   GET    /manager/payment-methods
//   POST   /manager/payment-methods
//   PUT    /manager/payment-methods/:id
//   DELETE /manager/payment-methods/:id
// ─────────────────────────────────────────────────────────────────────────────
class _MgrPayMethodsTab extends StatefulWidget {
  const _MgrPayMethodsTab();
  @override
  State<_MgrPayMethodsTab> createState() => _MgrPayMethodsTabState();
}

class _MgrPayMethodsTabState extends State<_MgrPayMethodsTab> {
  List<dynamic> _methods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance
          .adminGet(AdminEndpoints.managerPayMethods);
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
    final _pmAddKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Add Payment Method',
        color: const Color(0xFF059669),
        onSave: () async {
          if (!_pmAddKey.currentState!.validate()) return;
          try {
            await ApiService.instance
                .adminPost(AdminEndpoints.managerPayMethods, data: {
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
                    value: 'cbe',
                    child: Text('CBE (Commercial Bank)')),
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
                type: TextInputType.phone, validator: V.phoneOptional),
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
        color: const Color(0xFF059669),
        onSave: () async {
          try {
            await ApiService.instance.adminDio.put(
              AdminEndpoints.managerPayMethodById(pm['id'] as int),
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

  Future<void> _delete(Map<String, dynamic> pm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Remove this payment method?'),
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
          .delete(AdminEndpoints.managerPayMethodById(pm['id'] as int));
      showSuccess(context, 'Payment method deleted');
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
        onPressed: _showAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Method'),
        backgroundColor: const Color(0xFF059669),
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
                                  color: const Color(0xFF059669)
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              child: const Icon(Icons.payment_rounded,
                                  color: Color(0xFF059669), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                              Text(_methodLabel(
                                      pm['method']?.toString() ?? ''),
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
                            IconButton(
                              icon: const Icon(Icons.delete_rounded,
                                  color: AppColors.error, size: 18),
                              onPressed: () => _delete(pm),
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
// 6. INBOX
// API: GET /manager/inbox
//      GET /manager/messages/:id
//      POST /manager/messages  { to_admin, subject, body }
// ─────────────────────────────────────────────────────────────────────────────
class _MgrInboxTab extends StatefulWidget {
  const _MgrInboxTab();
  @override
  State<_MgrInboxTab> createState() => _MgrInboxTabState();
}

class _MgrInboxTabState extends State<_MgrInboxTab> {
  List<dynamic> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.instance
          .adminGet(AdminEndpoints.managerInbox);
      final d = r['data'];
      setState(() => _messages = d is List ? d : []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showCompose() {
    final toCtrl = TextEditingController();
    final subjCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Compose Message',
        color: const Color(0xFF059669),
        onSave: () async {
          if (subjCtrl.text.trim().isEmpty ||
              bodyCtrl.text.trim().isEmpty) {
            showError(ctx, 'Subject and body required');
            return;
          }
          try {
            await ApiService.instance.adminPost(
                AdminEndpoints.managerSendMessage,
                data: {
                  'to_admin': int.tryParse(toCtrl.text) ?? 0,
                  'subject': subjCtrl.text.trim(),
                  'body': bodyCtrl.text.trim(),
                });
            if (ctx.mounted) Navigator.pop(ctx);
            showSuccess(context, 'Message sent!');
            _load();
          } on ApiException catch (e) {
            showError(ctx, e.message);
          }
        },
        child: Column(children: [
          _tf('To (Admin ID)', toCtrl,
              type: TextInputType.number),
          _tf('Subject', subjCtrl),
          _tf('Message', bodyCtrl, maxLines: 5),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCompose,
        icon: const Icon(Icons.send_rounded),
        label: const Text('Compose'),
        backgroundColor: const Color(0xFF059669),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : RefreshIndicator(
              onRefresh: _load,
              child: _messages.isEmpty
                  ? const Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text('📬',
                              style: TextStyle(fontSize: 48)),
                          SizedBox(height: 10),
                          Text('No messages yet',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary)),
                        ]))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final m =
                            _messages[i] as Map<String, dynamic>;
                        final isRead =
                            m['is_read'] as bool? ?? true;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: isRead
                                  ? Colors.white
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: isRead
                                      ? AppColors.border
                                      : AppColors.primary
                                          .withOpacity(0.3))),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  const Color(0xFF059669)
                                      .withOpacity(0.1),
                              child: Text(
                                (m['from_name']
                                            ?.toString() ??
                                        'A')
                                    .isNotEmpty
                                    ? (m['from_name']
                                            ?.toString() ??
                                        'A')[0]
                                        .toUpperCase()
                                    : 'A',
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
                              Text(
                                  m['subject']?.toString() ??
                                      '(no subject)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isRead
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                      color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(
                                  'From: ${m['from_name'] ?? '—'}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color:
                                          AppColors.textSecondary)),
                            ])),
                            if (!isRead)
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle)),
                          ]),
                        );
                      },
                    ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Booking card — shows guest details, check-in/out, total price,
/// confirm/cancel buttons (when pending), and collapsible national ID images.
class _BookingCard extends StatefulWidget {
  final Map<String, dynamic> b;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  const _BookingCard(this.b, {this.onConfirm, this.onCancel});
  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Main info ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel + status
              Row(children: [
                Expanded(
                  child: Text(b['hotel_name']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: statusBg[st] ?? AppColors.surfaceGray,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(st[0].toUpperCase() + st.substring(1),
                      style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusFg[st] ?? AppColors.textHint)),
                ),
              ]),
              const SizedBox(height: 6),

              // Guest name + phone/email
              Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    b['guest_name']?.toString().isNotEmpty == true
                        ? b['guest_name'].toString()
                        : (b['guest_full_name']?.toString() ?? ''),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
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
              if ((b['guest_email'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.mail_outline_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(b['guest_email'].toString(),
                        style: const TextStyle(fontSize: 11,
                            color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ],
              const SizedBox(height: 8),

              // Dates + room
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.calendar_month_rounded,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${b['check_in'] ?? ''} → ${b['check_out'] ?? ''}',
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  if ((b['rooms'] ?? 0) > 0)
                    Text('${b['rooms']} room${(b['rooms'] as int? ?? 1) > 1 ? "s" : ""}',
                        style: const TextStyle(fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 8),

              // Price + payment method
              Row(children: [
                Text('ETB ${_fmt(b['total_price'])}',
                    style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceGray,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    (b['payment_method']?.toString() ?? '')
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                    style: const TextStyle(fontSize: 10,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ]),

              // Special requests
              if ((b['special_requests'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(b['special_requests'].toString(),
                            style: const TextStyle(fontSize: 11,
                                color: Color(0xFF92400E), height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── National ID section ─────────────────────────────────────────────
        if (hasId) ...[
          const Divider(height: 1),
          GestureDetector(
            onTap: () => setState(() => _showId = !_showId),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              color: const Color(0xFFF0F9FF),
              child: Row(children: [
                const Icon(Icons.badge_outlined,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('National ID / Passport',
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                const Spacer(),
                Icon(_showId
                    ? Icons.keyboard_arrow_up_rounded
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
                    Expanded(child: _IdPhoto(
                        label: 'Front Side', dataUrl: idFront)),
                  if (idFront.isNotEmpty && idBack.isNotEmpty)
                    const SizedBox(width: 10),
                  if (idBack.isNotEmpty)
                    Expanded(child: _IdPhoto(
                        label: 'Back Side', dataUrl: idBack)),
                ],
              ),
            ),
        ],

        // ── Confirm / Cancel buttons ────────────────────────────────────────
        if (widget.onConfirm != null || widget.onCancel != null) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              if (widget.onCancel != null)
                Expanded(child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Cancel',
                      style: TextStyle(fontSize: 12)),
                )),
              if (widget.onCancel != null && widget.onConfirm != null)
                const SizedBox(width: 8),
              if (widget.onConfirm != null)
                Expanded(child: ElevatedButton(
                  onPressed: widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Confirm',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white)),
                )),
            ]),
          ),
        ],
      ]),
    );
  }
}

/// Shows a base64 or URL ID photo with a label and full-screen tap.
class _IdPhoto extends StatelessWidget {
  final String label;
  final String dataUrl; // base64 data URL or https:// URL
  const _IdPhoto({required this.label, required this.dataUrl});

  @override
  Widget build(BuildContext context) {
    final isBase64 = dataUrl.startsWith('data:');
    Widget img;
    if (isBase64) {
      try {
        final b64 = dataUrl.contains(',')
            ? dataUrl.split(',').last
            : dataUrl;
        final bytes = base64Decode(b64);
        img = Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        img = const Center(
            child: Icon(Icons.broken_image_outlined,
                color: AppColors.textHint, size: 32));
      }
    } else {
      img = Image.network(dataUrl, fit: BoxFit.cover,
          loadingBuilder: (_, child, prog) =>
              prog == null ? child :
              const Center(child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))),
          errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined,
                  color: AppColors.textHint, size: 32)));
    }

    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border)),
            clipBehavior: Clip.hardEdge,
            child: img,
          ),
          const SizedBox(height: 4),
          const Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.zoom_out_map_rounded,
                    size: 11, color: AppColors.textHint),
                SizedBox(width: 3),
                Text('Tap to enlarge',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textHint)),
              ]),
        ],
      ),
    );
  }

  void _showFullscreen(BuildContext ctx) {
    final isBase64 = dataUrl.startsWith('data:');
    Widget full;
    if (isBase64) {
      try {
        final b64 = dataUrl.contains(',')
            ? dataUrl.split(',').last
            : dataUrl;
        // Can't use import inline — handled in separate widget below
        full = _Base64FullImage(b64: b64);
      } catch (_) {
        full = const Icon(Icons.broken_image_outlined,
            color: Colors.white, size: 60);
      }
    } else {
      full = Image.network(dataUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image_outlined,
                  color: Colors.white, size: 60));
    }

    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(children: [
          Center(child: InteractiveViewer(child: full)),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () => Navigator.pop(_),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 12, left: 0, right: 0,
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Base64FullImage extends StatelessWidget {
  final String b64;
  const _Base64FullImage({required this.b64});
  @override
  Widget build(BuildContext context) {
    try {
      return Image.memory(base64Decode(b64), fit: BoxFit.contain);
    } catch (_) {
      return const Icon(Icons.broken_image_outlined,
          color: Colors.white, size: 60);
    }
  }
}

/// Payment card with transaction ID display, screenshot image, and approve/reject.
class _PayCard extends StatefulWidget {
  final Map<String, dynamic> pm;
  final bool acting;
  final VoidCallback onApprove, onReject;

  const _PayCard({
    required this.pm,
    required this.acting,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_PayCard> createState() => _PayCardState();
}

class _PayCardState extends State<_PayCard> {
  bool _showShot = false;

  @override
  Widget build(BuildContext context) {
    final pm        = widget.pm;
    final status    = pm['status']?.toString() ?? '';
    final isPending = status == 'submitted';
    final txnId     = pm['transaction_id']?.toString() ?? '';
    final shotUrl   = pm['screenshot_url']?.toString() ?? '';
    final hasShot   = shotUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: isPending ? const Color(0xFFFFFBEB) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isPending
                  ? const Color(0xFFFDE68A)
                  : AppColors.border,
              width: isPending ? 1.5 : 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Payment header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment #${pm['id']} — '
                          '${pm['guest_name'] ?? pm['guest_full_name'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(
                          '${_methodLabel(pm['method']?.toString() ?? pm['payment_method']?.toString() ?? '')} · '
                          '${pm['check_in'] ?? ''} → ${pm['check_out'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ETB ${_fmt(pm['amount'])}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      _statusBadge(status),
                    ],
                  ),
                ]),

                // Transaction ID
                if (txnId.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceGray,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      const Icon(Icons.receipt_long_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Transaction ID',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textHint)),
                            Text(txnId,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                      )
                    ]),
                  ),
                ],
              ],
            ),
          ),

          // ── Payment screenshot toggle ────────────────────────────────────
          if (hasShot) ...[
            const Divider(height: 1),
            GestureDetector(
              onTap: () => setState(() => _showShot = !_showShot),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                color: const Color(0xFFF0FDF4),
                child: Row(children: [
                  const Icon(Icons.image_outlined,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  const Text('Payment Screenshot',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success)),
                  const Spacer(),
                  Icon(
                    _showShot
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.success, size: 20),
                ]),
              ),
            ),
            if (_showShot)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: GestureDetector(
                  onTap: () => _viewFullscreen(context, shotUrl),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 240),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border)),
                    clipBehavior: Clip.hardEdge,
                    child: _buildImage(shotUrl),
                  ),
                ),
              ),
          ],

          // ── Approve / Reject buttons ─────────────────────────────────────
          if (isPending) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: widget.acting ? null : widget.onReject,
                  icon: widget.acting
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.error))
                      : const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  onPressed: widget.acting ? null : widget.onApprove,
                  icon: widget.acting
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('data:')) {
      try {
        final b64 = url.contains(',') ? url.split(',').last : url;
        final bytes = _safeDecode(b64);
        if (bytes != null) return Image.memory(bytes, fit: BoxFit.contain);
      } catch (_) {}
      return const Center(child: Icon(Icons.broken_image_outlined,
          color: AppColors.textHint, size: 32));
    }
    return Image.network(url, fit: BoxFit.contain,
        loadingBuilder: (_, child, prog) => prog == null
            ? child
            : const Center(
                child: SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image_outlined,
                color: AppColors.textHint, size: 32)));
  }

  void _viewFullscreen(BuildContext ctx, String url) {
    final imgWidget = url.startsWith('data:')
        ? (() {
            try {
              final b64 = url.contains(',') ? url.split(',').last : url;
              final bytes = _safeDecode(b64);
              if (bytes != null) return Image.memory(bytes, fit: BoxFit.contain);
            } catch (_) {}
            return const Icon(Icons.broken_image_outlined,
                color: Colors.white, size: 60);
          })()
        : Image.network(url, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image_outlined,
                    color: Colors.white, size: 60));

    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(children: [
          Center(child: InteractiveViewer(child: imgWidget)),
          Positioned(
            top: 8, right: 8,
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
        ]),
      ),
    );
  }

  static Uint8List? _safeDecode(String b64) {
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
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
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color)),
        ]),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );

Widget _infoRow({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
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
      ]),
    );

Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary));

Widget _emptyMsg(String msg) => Padding(
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
    'unavailable': Color(0xFFDC2626),
    'maintenance': Color(0xFFD97706),
    'submitted': Color(0xFFD97706),
    'completed': Color(0xFF059669),
    'failed': Color(0xFFDC2626),
    'pending': Color(0xFFD97706),
    'confirmed': Color(0xFF059669),
    'cancelled': Color(0xFFDC2626),
  };
  const bg = <String, Color>{
    'active': Color(0xFFECFDF5),
    'inactive': Color(0xFFFEF2F2),
    'available': Color(0xFFECFDF5),
    'unavailable': Color(0xFFFEF2F2),
    'maintenance': Color(0xFFFFFBEB),
    'submitted': Color(0xFFFFFBEB),
    'completed': Color(0xFFECFDF5),
    'failed': Color(0xFFFEF2F2),
    'pending': Color(0xFFFFFBEB),
    'confirmed': Color(0xFFECFDF5),
    'cancelled': Color(0xFFFEF2F2),
  };
  final f = fg[status] ?? AppColors.textHint;
  final b = bg[status] ?? AppColors.surfaceGray;
  final label = status.isEmpty ? 'Unknown' : status[0].toUpperCase() + status.substring(1);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
        color: b, borderRadius: BorderRadius.circular(8)),
    child: Text(label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: f)),
  );
}

Widget _filterBar(
        String current, void Function(String) onChanged) =>
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
                onTap: () => onChanged(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: current == f
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: current == f
                            ? AppColors.primary
                            : AppColors.border),
                  ),
                  child: Text(
                    f == 'all'
                        ? 'All'
                        : f[0].toUpperCase() + f.substring(1),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: current == f
                            ? Colors.white
                            : AppColors.textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

String _normalizeBed(String? raw) {
  if (raw == null || raw.isEmpty) return 'Single';
  const opts = ['Single', 'Double', 'Twin', 'Queen', 'King', 'Suite'];
  final cap = raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  return opts.contains(cap) ? cap : raw;
}

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
  return labels[m] ?? (m.isEmpty ? m : m[0].toUpperCase() + m.substring(1));
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
    final mq          = MediaQuery.of(context);
    final maxContent  = mq.size.height * 0.75 - mq.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        // ── fixed structure: drag handle + header + scroll area + save btn ──
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          // Drag handle
          Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
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
          // ── Scrollable content (constrained so it never overflows) ─────
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
          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity, height: 50,
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
