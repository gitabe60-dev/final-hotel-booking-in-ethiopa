import 'package:flutter/material.dart';
import 'app_en.dart';
import 'app_am.dart';

/// Simple in-code localizations — no code generation needed.
/// Usage: AppLocalizations.of(context).t('key')
///
/// FIX: shouldReload now returns true so locale changes rebuild text everywhere.
/// FIX: t() falls back gracefully — never returns null, never throws.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  /// Safe lookup — returns null if the widget tree has no localizations yet.
  static AppLocalizations? maybeOf(BuildContext context) {
    try {
      return Localizations.of<AppLocalizations>(context, AppLocalizations);
    } catch (_) {
      return null;
    }
  }

  /// Standard lookup — returns a fallback instance if not yet loaded.
  static AppLocalizations of(BuildContext context) {
    return maybeOf(context) ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> get _strings =>
      locale.languageCode == 'am' ? amStrings : enStrings;

  /// Translate a key. Falls back: Amharic map → English map → key itself.
  /// Never throws, never returns empty string for a valid key.
  String t(String key) {
    final s = _strings[key];
    if (s != null && s.isNotEmpty) return s;
    // Cross-language fallback
    final fallback = enStrings[key];
    if (fallback != null && fallback.isNotEmpty) return fallback;
    // Last resort: return the key so UI always shows *something*
    return key;
  }

  bool get isAmharic => locale.languageCode == 'am';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'am'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  /// CRITICAL FIX: return true so the framework re-calls load() on every
  /// locale change, which propagates new translations throughout the widget tree.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
