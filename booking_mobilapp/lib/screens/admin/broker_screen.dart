/// broker_screen.dart
///
/// Broker Dashboard — matches the web BrokerDashboard.
/// Backend base: /api/admin/broker/*
///
/// Tabs:
///   1. Overview    — unread messages count + inbox preview
///   2. Bookings    — view + filter
///   3. Inbox       — full inbox + sent + compose
///   4. Settings    — profile
library;

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
class BrokerScreen extends StatefulWidget {
  const BrokerScreen({super.key});
  @override
  State<BrokerScreen> createState() => _BrokerScreenState();
}

class _BrokerScreenState extends State<BrokerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
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
        backgroundColor: const Color(0xFFD97706),
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
                  : 'B',
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
                Text(user?.fullName ?? 'Broker',
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
                  child: const Text('Broker',
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
          isScrollable: false,
          tabs: const [
            Tab(
                icon: Icon(Icons.dashboard_rounded, size: 17),
                text: 'Overview'),
            Tab(
                icon: Icon(Icons.book_online_rounded, size: 17),
                text: 'Bookings'),
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
          _BrkOverviewTab(),
          _BrkBookingsTab(),
          _BrkInboxTab(),
          AdminProfileScreen(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. OVERVIEW
// API: GET /api/admin/broker/dashboard  → { unread_messages, inbox }
// ─────────────────────────────────────────────────────────────────────────────
class _BrkOverviewTab extends StatefulWidget {
  const _BrkOverviewTab();
  @override
  State<_BrkOverviewTab> createState() => _BrkOverviewTabState();
}

class _BrkOverviewTabState extends State<_BrkOverviewTab> {
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
      final r = await ApiService.instance
          .adminGet(AdminEndpoints.brokerDashboard);
      setState(() =>
          _data = (r['data'] as Map<String, dynamic>?) ?? {});
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(child: AppSpinner(size: SpinnerSize.large));

    final unread = _data['unread_messages'] as int? ?? 0;
    final inbox = (_data['inbox'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Stats row
          Row(children: [
            Expanded(
                child: _stat('Unread Msgs', '$unread', '📨',
                    const Color(0xFFD97706))),
            const SizedBox(width: 10),
            Expanded(
                child: _stat('Inbox', '${inbox.length}', '📬',
                    const Color(0xFF2563EB))),
          ]),
          const SizedBox(height: 20),

          // Welcome banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFF59E0B)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Text('🤝', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Broker Dashboard',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text(
                      'View bookings, manage messages and communicate with hotels.',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12),
                      maxLines: 2),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Inbox Messages'),
          const SizedBox(height: 10),
          if (inbox.isEmpty)
            _emptyMsg('No messages yet')
          else
            ...inbox.take(8).map((m) {
              final msg = m as Map<String, dynamic>;
              final isRead = msg['is_read'] as bool? ?? true;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: isRead
                        ? Colors.white
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isRead
                            ? AppColors.border
                            : const Color(0xFFFDE68A))),
                child: Row(children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        const Color(0xFFD97706).withOpacity(0.1),
                    child: Text(
                      (msg['from_name']?.toString() ?? 'A').isNotEmpty
                          ? (msg['from_name']?.toString() ?? 'A')[0]
                              .toUpperCase()
                          : 'A',
                      style: const TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    Text(msg['subject']?.toString() ?? '(no subject)',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('From: ${msg['from_name'] ?? '—'}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ])),
                  if (!isRead)
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Color(0xFFD97706),
                            shape: BoxShape.circle)),
                ]),
              );
            }),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. BOOKINGS
// API: GET /api/admin/broker/bookings?status=
// ─────────────────────────────────────────────────────────────────────────────
class _BrkBookingsTab extends StatefulWidget {
  const _BrkBookingsTab();
  @override
  State<_BrkBookingsTab> createState() => _BrkBookingsTabState();
}

class _BrkBookingsTabState extends State<_BrkBookingsTab> {
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
          AdminEndpoints.brokerBookings,
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
// 3. INBOX / SENT / COMPOSE
// APIs:
//   GET  /api/admin/broker/inbox
//   GET  /api/admin/broker/sent
//   POST /api/admin/broker/messages  { to_admin, subject, body }
// ─────────────────────────────────────────────────────────────────────────────
class _BrkInboxTab extends StatefulWidget {
  const _BrkInboxTab();
  @override
  State<_BrkInboxTab> createState() => _BrkInboxTabState();
}

class _BrkInboxTabState extends State<_BrkInboxTab>
    with SingleTickerProviderStateMixin {
  late TabController _inner;
  List<dynamic> _inbox = [];
  List<dynamic> _sent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _inner = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _inner.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.adminGet(AdminEndpoints.brokerInbox),
        ApiService.instance.adminGet(AdminEndpoints.brokerSent),
      ]);
      final i = results[0]['data'];
      final s = results[1]['data'];
      setState(() {
        _inbox = i is List ? i : [];
        _sent = s is List ? s : [];
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showCompose() {
    final toCtrl = TextEditingController();
    final subjCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final _composeKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        title: 'Compose Message',
        color: const Color(0xFFD97706),
        onSave: () async {
          if (!_composeKey.currentState!.validate()) return;
          try {
            await ApiService.instance.adminPost(
                AdminEndpoints.brokerSendMessage,
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
        child: Form(
          key: _composeKey,
          child: Column(children: [
          _tf('To (Admin ID)', toCtrl,
              type: TextInputType.number),
          _tf('Subject *', subjCtrl, validator: (v) => V.required(v, label: 'Subject')),
          _tf('Message *', bodyCtrl, maxLines: 5, validator: (v) => V.required(v, label: 'Message')),
        ])),
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
        backgroundColor: const Color(0xFFD97706),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: TabBar(
          controller: _inner,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: const Color(0xFFD97706),
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Inbox'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : TabBarView(
              controller: _inner,
              children: [
                _msgList(_inbox, false),
                _msgList(_sent, true),
              ],
            ),
    );
  }

  Widget _msgList(List<dynamic> msgs, bool isSent) {
    if (msgs.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(isSent ? '📤' : '📬',
              style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Text(isSent ? 'No sent messages' : 'No inbox messages',
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
        itemCount: msgs.length,
        itemBuilder: (_, i) {
          final m = msgs[i] as Map<String, dynamic>;
          final isRead = m['is_read'] as bool? ?? true;
          final nameKey = isSent ? 'to_name' : 'from_name';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: isRead
                    ? Colors.white
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isRead
                        ? AppColors.border
                        : const Color(0xFFFDE68A))),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    const Color(0xFFD97706).withOpacity(0.1),
                child: Text(
                  (m[nameKey]?.toString() ?? 'A').isNotEmpty
                      ? (m[nameKey]?.toString() ?? 'A')[0]
                          .toUpperCase()
                      : 'A',
                  style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Text(m['subject']?.toString() ?? '(no subject)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    '${isSent ? "To" : "From"}: ${m[nameKey] ?? '—'}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ])),
              if (!isRead && !isSent)
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle)),
            ]),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _BookingTile extends StatelessWidget {
  final Map<String, dynamic> b;
  const _BookingTile(this.b);

  @override
  Widget build(BuildContext context) {
    final st = b['status']?.toString() ?? 'pending';
    final colors = <String, Color>{
      'pending': const Color(0xFFD97706),
      'confirmed': const Color(0xFF059669),
      'completed': const Color(0xFF2563EB),
      'cancelled': const Color(0xFFDC2626),
    };
    final bgs = <String, Color>{
      'pending': const Color(0xFFFFFBEB),
      'confirmed': const Color(0xFFECFDF5),
      'completed': const Color(0xFFEFF6FF),
      'cancelled': const Color(0xFFFEF2F2),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(b['hotel_name']?.toString() ?? '',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: bgs[st] ?? AppColors.surfaceGray,
                borderRadius: BorderRadius.circular(8)),
            child: Text(st[0].toUpperCase() + st.substring(1),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors[st] ?? AppColors.textHint)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
            '${b['guest_name'] ?? ''} · ${b['check_in'] ?? ''} → ${b['check_out'] ?? ''}',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('ETB ${_fmt(b['total_price'])}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.primary)),
      ]),
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

String _fmt(dynamic v) {
  if (v == null) return '0';
  final d = double.tryParse(v.toString()) ?? 0;
  if (d == d.truncateToDouble()) return d.truncate().toString();
  return d.toStringAsFixed(0);
}

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
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
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
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            child: Row(children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
            ]),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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

final _inputDeco = InputDecoration(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
);
