import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import 'home/home_screen.dart';
import 'admin/super_admin_screen.dart';
import 'admin/sub_admin_screen.dart';
import 'admin/hotel_manager_screen.dart';
import 'admin/broker_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)));
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)));

    _ctrl.forward();

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      // Restore auth session
      context.read<AuthProvider>().init(),
      // Min splash duration for branding
      Future.delayed(const Duration(milliseconds: 2000)),
    ]);

    if (!mounted) return;

    // Route based on saved session role
    final auth = context.read<AuthProvider>();
    final role = auth.isAuthenticated ? (auth.user?.role ?? '') : '';

    Widget dest;
    switch (role) {
      case 'super_admin':
        dest = const SuperAdminScreen();
        break;
      case 'sub_admin':
        dest = const SubAdminScreen();
        break;
      case 'hotel_manager':
        dest = const HotelManagerScreen();
        break;
      case 'broker':
        dest = const BrokerScreen();
        break;
      default:
        dest = const HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => dest,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.heroStart,
              AppColors.heroMid,
              AppColors.heroEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (ctx, __) {
                final l10n = AppLocalizations.of(ctx);
                return Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // EthioStay logo
                        AppLogo(size: 108, showText: false),
                        const SizedBox(height: 20),
                        // App name — EthioStay in gold/white gradient
                        RichText(
                          text: const TextSpan(children: [
                            TextSpan(
                              text: 'Ethio',
                              style: TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.w900,
                                  color: Colors.white, letterSpacing: 0.5),
                            ),
                            TextSpan(
                              text: 'Stay',
                              style: TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.w900,
                                  color: Color(0xFFD4AF37), letterSpacing: 0.5),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 8),
                        // Tagline — switches with language
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            l10n.t('tagline'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Loading indicator
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(
                                Colors.white.withOpacity(0.8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              },
            ),
          ),
        ),
      ),
    );
  }
}
