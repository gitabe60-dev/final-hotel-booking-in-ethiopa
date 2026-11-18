import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_bar_widgets.dart';
import '../home/home_screen.dart';
import '../dashboard/bookings_list_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final int? bookingId;
  const PaymentSuccessScreen({super.key, this.bookingId});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _checkScale;
  late Animation<double> _checkFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _checkFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _contentFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DallolAppBar(
        title:    AppLocalizations.of(context).t('booking_submitted'),
        showBack: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFECFDF5), Color(0xFFEFF6FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Animated check circle ──────────────────────────────────
                  ScaleTransition(
                    scale: _checkScale,
                    child: FadeTransition(
                      opacity: _checkFade,
                      child: Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 52,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Content ────────────────────────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          const Text(
                            'Booking Submitted!',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your booking and payment proof have been\nsubmitted successfully.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // ── Status steps ─────────────────────────────────────
                          _StatusStep(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: AppColors.success,
                            bgColor: AppColors.successLight,
                            title: 'Booking Created',
                            subtitle: 'Your room has been reserved',
                          ),
                          const SizedBox(height: 10),
                          _StatusStep(
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFFD97706),
                            bgColor: const Color(0xFFFFFBEB),
                            title: 'Payment Under Verification',
                            subtitle: 'Hotel manager is reviewing your payment proof',
                          ),
                          const SizedBox(height: 10),
                          _StatusStep(
                            icon: Icons.notifications_outlined,
                            iconColor: AppColors.primary,
                            bgColor: AppColors.primaryLight,
                            title: 'Notification Coming',
                            subtitle: "You'll be notified once payment is approved",
                          ),
                          const SizedBox(height: 32),

                          // ── Booking ID badge (if available) ──────────────────
                          if (widget.bookingId != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.receipt_long_outlined,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Booking #${widget.bookingId}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ── Action buttons ───────────────────────────────────
                          Row(children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const BookingsListScreen()),
                                  (route) => false,
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('My Bookings',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 12),

                          // Browse more
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                (_) => false,
                              ),
                              child: const Text(
                                'Browse more hotels →',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final Color iconColor, bgColor;
  final String title, subtitle;

  const _StatusStep({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withOpacity(0.15)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: iconColor)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(fontSize: 11, color: iconColor.withOpacity(0.7), height: 1.4)),
        ])),
      ]),
    );
  }
}
