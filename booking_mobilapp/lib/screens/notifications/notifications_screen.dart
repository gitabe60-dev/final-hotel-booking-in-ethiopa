import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/snack_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res  = await ApiService.instance.get(ApiEndpoints.notifications);
      final data = res['data'];
      final list = data is List
          ? data
          : (data is Map ? (data['notifications'] as List? ?? []) : []);
      setState(() {
        _notifs = list.map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (_) {
      setState(() => _notifs = []);
    }
    setState(() => _loading = false);
  }

  Future<void> _markRead(int id) async {
    try {
      await ApiService.instance.post(ApiEndpoints.notificationRead(id));
      setState(() {
        final idx = _notifs.indexWhere((n) => n['id'] == id);
        if (idx != -1) _notifs[idx] = {..._notifs[idx], 'is_read': true};
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await ApiService.instance.post(ApiEndpoints.notificationsReadAll);
      setState(() {
        _notifs = _notifs.map((n) => {...n, 'is_read': true}).toList();
      });
      if (mounted) {
        showSuccess(context, AppLocalizations.of(context).t('mark_all_read'));
      }
    } catch (_) {
      if (mounted) {
        showError(context, AppLocalizations.of(context).isAmharic
            ? 'ሁሉንም እንደ ተነበቡ ምልክት ማድረግ አልተሳካም'
            : 'Failed to mark all read');
      }
    }
  }

  // Notification type → icon + color
  Map<String, dynamic> _typeMeta(String? type) {
    switch (type) {
      case 'booking_new':
        return {'icon': Icons.book_online_rounded, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)};
      case 'payment_approved':
        return {'icon': Icons.check_circle_rounded, 'color': const Color(0xFF059669), 'bg': const Color(0xFFECFDF5)};
      case 'payment_rejected':
        return {'icon': Icons.cancel_rounded, 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEF2F2)};
      default:
        return {'icon': Icons.notifications_rounded, 'color': const Color(0xFFD97706), 'bg': const Color(0xFFFFFBEB)};
    }
  }

  String _timeAgo(String? raw) {
    if (raw == null) return '';
    try {
      final dt   = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      // Use l10n for "Just now" only — relative times are universal
      if (diff.inSeconds < 60)  return AppLocalizations.of(_ctx!).t('just_now');
      if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
      if (diff.inHours   < 24)  return '${diff.inHours}h ago';
      if (diff.inDays    < 7)   return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return ''; }
  }

  // Keep a ref to context for _timeAgo (set in build)
  BuildContext? _ctx;

  int get _unreadCount => _notifs.where((n) => n['is_read'] != true).length;

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(
        title: '${l10n.t('notifications')}${_unreadCount > 0 ? " ($_unreadCount)" : ""}',
        extraActions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(l10n.t('mark_all_read'),
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: AppSpinner(size: SpinnerSize.large))
          : _notifs.isEmpty
              ? _EmptyNotifs()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _notifs.length,
                    itemBuilder: (_, i) {
                      final n     = _notifs[i];
                      final id    = n['id'] as int? ?? 0;
                      final read  = n['is_read'] as bool? ?? false;
                      final type  = n['type']    as String?;
                      final meta  = _typeMeta(type);
                      final color = meta['color'] as Color;
                      final bg    = meta['bg']    as Color;
                      final icon  = meta['icon']  as IconData;

                      return GestureDetector(
                        onTap: read ? null : () => _markRead(id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:  read ? Colors.white : color.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: read ? AppColors.border : color.withOpacity(0.3),
                              width: read ? 1 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(read ? 0.03 : 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon badge
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Icon(icon, color: color, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                      child: Text(
                                        n['title']?.toString() ?? l10n.t('notifications'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: read ? FontWeight.w600 : FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (!read)
                                      Container(
                                        width: 8, height: 8,
                                        decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle),
                                      ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                    n['message']?.toString() ?? '',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 11, color: AppColors.textHint),
                                    const SizedBox(width: 4),
                                    Text(
                                      _timeAgo(n['created_at']?.toString()),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textHint),
                                    ),
                                    if (!read) ...[
                                      const SizedBox(width: 10),
                                      Text(
                                        l10n.t('mark_read'),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: color,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ]),
                                ],
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _EmptyNotifs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
                color: AppColors.surfaceGray, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded,
                size: 40, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),
          Text(l10n.t('no_notifications'),
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            l10n.isAmharic
                ? 'ስለ ቦኪንጎ ማረጋገጫ እና የክፍያ ዝማኔዎች እዚህ ያሳውቅዎታል።'
                : "You'll be notified about booking confirmations\nand payment updates here.",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5),
          ),
        ]),
      ),
    );
  }
}
