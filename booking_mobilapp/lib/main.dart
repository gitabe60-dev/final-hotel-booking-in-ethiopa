import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/api_service.dart';
import 'core/themes/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/hotel_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Pre-warm: load SharedPreferences once, before anything else ──────────
  // This avoids multiple async gaps during startup.
  final prefs = await SharedPreferences.getInstance();

  // ── API service init (creates Dio instances — synchronous) ───────────────
  ApiService.instance.init();

  // ── Language: set synchronously from cached prefs — zero frame delay ─────
  final lang = LanguageProvider()..initSync(prefs);

  // ── System UI overlays ────────────────────────────────────────────────────
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness:     Brightness.light,
  ));

  runApp(DallolBookApp(lang: lang));
}

class DallolBookApp extends StatelessWidget {
  final LanguageProvider lang;
  const DallolBookApp({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Language provider is already initialised — reuse the instance
        ChangeNotifierProvider<LanguageProvider>.value(value: lang),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (_, langProv, __) => MaterialApp(
          title:                      'EthioStay',
          debugShowCheckedModeBanner: false,
          theme:                      AppTheme.lightTheme,
          locale:                     langProv.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('am'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
