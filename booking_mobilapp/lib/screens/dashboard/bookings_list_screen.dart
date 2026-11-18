import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/app_bar_widgets.dart';
import '../../widgets/app_spinner.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/snack_helper.dart';
import '../notifications/notifications_screen.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});
  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  String _filter      = 'all';
  bool   _initialized = false;
  final Set<int> _cancelling = {};

  static const _tabs = ['all', 'pending', 'confirmed', 'completed', 'cancelled'];

  static const _fg = <String, Color>{
    'pending':   Color(0xFFD97706),
    'confirmed': Color(0xFF059669),
    'completed': Color(0xFF2563EB),
    'cancelled': Color(0xFFDC2626),
  };
  static const _bg = <String, Color>{
    'pending':   Color(0xFFFFFBEB),
    'confirmed': Color(0xFFECFDF5),
    'completed': Color(0xFFEFF6FF),
    'cancelled': Color(0xFFFEF2F2),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        context.read<BookingProvider>().loadMyBookings();
      }
    });
  }

  // ── Cancel booking — POST /api/v1/bookings/:id/cancel ─────────────────────
  Future<void> _cancel(int bookingId) async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.warning_rounded, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Text(AppLocalizations.of(context).t('cancel_booking')),
        ]),
        content: Text(
          AppLocalizations.of(context).t('cancel_confirm') + '\n' +
          AppLocalizations.of(context).t('cancel_irr'),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).t('keep_booking'),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppLocalizations.of(context).t('cancel_booking')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling.add(bookingId));
    try {
      await ApiService.instance.post(ApiEndpoints.cancelBooking(bookingId));
      showSuccess(context, AppLocalizations.of(context).t('booking_cancelled'));
      if (mounted) context.read<BookingProvider>().loadMyBookings();
    } on ApiException catch (e) {
      showError(context, e.message);
    } catch (_) {
      showError(context, 'Failed to cancel booking. Try again.');
    } finally {
      if (mounted) setState(() => _cancelling.remove(bookingId));
    }
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context);
    final bp       = context.watch<BookingProvider>();
    final all      = bp.bookings;
    final filtered = _filter == 'all'
        ? all
        : all.where((b) => b.status == _filter).toList();
    final counts = {
      for (final t in _tabs)
        t: t == 'all' ? all.length : all.where((b) => b.status == t).length,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(
        title: l10n.t('my_bookings'),
        extraActions: [
          // Notifications bell
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary),
            tooltip: 'Notifications',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
      body: Column(children: [

        // ── Status filter tabs ──────────────────────────────────────────────
        Container(
          color:   Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.map((t) {
                final sel = _filter == t;
                final fg  = sel
                    ? Colors.white
                    : (_fg[t] ?? AppColors.textSecondary);
                final bg  = sel
                    ? (_fg[t] ?? AppColors.primary)
                    : (_bg[t] ?? AppColors.surfaceGray);
                return GestureDetector(
                  onTap: () => setState(() => _filter = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color:        bg,
                        borderRadius: BorderRadius.circular(20),
                        border:       Border.all(
                            color: sel ? bg : AppColors.border)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${counts[t]}',
                            style: TextStyle(
                                fontSize:   17,
                                fontWeight: FontWeight.w900,
                                color:      fg)),
                        Text(
                          t == 'all'
                              ? 'All'
                              : t[0].toUpperCase() + t.substring(1),
                          style: TextStyle(
                              fontSize:   10,
                              fontWeight: FontWeight.w600,
                              color:      fg),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1),

        // ── Booking list ────────────────────────────────────────────────────
        Expanded(
          child: bp.loading
              ? const Center(child: AppSpinner(size: SpinnerSize.large))
              : filtered.isEmpty
                  ? EmptyState(
                      title:    l10n.t('no_bookings'),
                      subtitle: l10n.isAmharic
                          ? 'ሆቴሎችን ያስሱ እና የመጀመሪያ ቦኪንጉን ያድርጉ!'
                          : 'Browse hotels and make your first booking!',
                      icon:     Icons.calendar_month_outlined,
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<BookingProvider>().loadMyBookings(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) => _BookingCard(
                          booking:      filtered[i],
                          statusFg:     _fg[filtered[i].status] ?? AppColors.textHint,
                          statusBg:     _bg[filtered[i].status] ?? AppColors.surfaceGray,
                          fmt:          _fmt,
                          cancelling:   _cancelling.contains(filtered[i].id),
                          onCancel:     (filtered[i].status == 'pending' ||
                                            filtered[i].status == 'confirmed')
                              ? () => _cancel(filtered[i].id)
                              : null,
                        ),
                      ),
                    ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING CARD
// ─────────────────────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final Booking  booking;
  final Color    statusFg, statusBg;
  final String Function(double) fmt;
  final bool     cancelling;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.booking,
    required this.statusFg,
    required this.statusBg,
    required this.fmt,
    required this.cancelling,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [

          // ── Image + main info ─────────────────────────────────────────────
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Hotel thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft:     Radius.circular(15),
                  bottomLeft:  Radius.circular(15)),
              child: booking.hotelImage != null
                  ? Image.network(
                      booking.hotelImage!,
                      width: 80, height: 110, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Hotel name + status badge
                  Row(children: [
                    Expanded(
                      child: Text(booking.hotelName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        booking.status[0].toUpperCase() +
                            booking.status.substring(1),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusFg),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),

                  // Detail chips
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    _chip(Icons.calendar_today_rounded,
                        '${booking.checkIn} → ${booking.checkOut}'),
                    _chip(Icons.bed_outlined,
                        '${booking.rooms} room${booking.rooms > 1 ? "s" : ""}'),
                    _chip(Icons.people_outline_rounded,
                        '${booking.adults} adult${booking.adults > 1 ? "s" : ""}'
                        '${booking.children > 0 ? " + ${booking.children} child${booking.children > 1 ? "ren" : ""}" : ""}'),
                    if (booking.roomTypeName != null)
                      _chip(Icons.king_bed_outlined, booking.roomTypeName!),
                  ]),
                ]),
              ),
            ),
          ]),

          // ── Bottom bar: payment method + price + actions ──────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border))),
            child: Column(children: [
              // Payment method + price row
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceGray,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    booking.paymentMethod
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5),
                  ),
                ),
                const Spacer(),
                Text('ETB ${fmt(booking.totalPrice)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
              ]),

              // Action buttons (only for pending/confirmed)
              if (onCancel != null) ...[
                const SizedBox(height: 10),
                Row(children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: cancelling ? null : onCancel,
                      icon: cancelling
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error))
                          : const Icon(Icons.cancel_outlined, size: 16),
                      label: Text(
                          cancelling ? l10n.t('processing') : l10n.t('cancel_booking'),
                          style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ]),
              ],
            ]),
          ),
        ]),
      );
  }

  Widget _placeholder() => Container(
      width: 80, height: 110, color: AppColors.surfaceGray,
      child: const Icon(Icons.hotel_outlined,
          color: AppColors.textHint, size: 32));

  Widget _chip(IconData icon, String text) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ]);
}
