import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LanguageProvider — persists language choice and notifies the widget tree.
///
/// SPEED FIX: init() is called with a synchronous prefs instance passed from
/// main() so there's zero delay on first paint. The locale is immediately set
/// before any widgets build.
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale    => _locale;
  bool   get isAmharic => _locale.languageCode == 'am';

  /// Call this from main() AFTER SharedPreferences.getInstance() completes.
  /// Sets the locale immediately — no async gap.
  void initSync(SharedPreferences prefs) {
    final code = prefs.getString('language_code') ?? 'en';
    _locale = Locale(code);
    // Don't notify — called before any listeners are attached
  }

  /// Async variant used if prefs aren't available yet.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code  = prefs.getString('language_code') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setEnglish() async {
    if (_locale.languageCode == 'en') return; // already set
    _locale = const Locale('en');
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', 'en');
  }

  Future<void> setAmharic() async {
    if (_locale.languageCode == 'am') return; // already set
    _locale = const Locale('am');
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', 'am');
  }

  Future<void> toggle() async {
    if (isAmharic) {
      await setEnglish();
    } else {
      await setAmharic();
    }
  }
}
