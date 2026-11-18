/// app_bar_widgets.dart
/// Shared AppBar widgets — DallolAppBar, language dropdown, back arrow.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/language_provider.dart';
import 'app_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE DROPDOWN — flag + name, used in ALL AppBars
// ─────────────────────────────────────────────────────────────────────────────

/// Light version (white background AppBar)
class LangToggleLight extends StatelessWidget {
  const LangToggleLight({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return _LangDropdown(
      lang:       lang,
      bgColor:    AppColors.surfaceGray,
      textColor:  AppColors.textSecondary,
      borderColor: AppColors.border,
    );
  }
}

/// Dark version (gradient/colored AppBar)
class LangToggleDark extends StatelessWidget {
  const LangToggleDark({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return _LangDropdown(
      lang:       lang,
      bgColor:    Colors.white.withOpacity(0.15),
      textColor:  Colors.white,
      borderColor: Colors.white.withOpacity(0.3),
      dark:        true,
    );
  }
}

class _LangDropdown extends StatelessWidget {
  final LanguageProvider lang;
  final Color bgColor, textColor, borderColor;
  final bool  dark;

  const _LangDropdown({
    required this.lang,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    this.dark = false,
  });

  static const _languages = [
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English',  'short': 'EN'},
    {'code': 'am', 'flag': '🇪🇹', 'name': 'አማርኛ',   'short': 'አማ'},
  ];

  @override
  Widget build(BuildContext context) {
    final current = _languages.firstWhere(
      (l) => l['code'] == lang.locale.languageCode,
      orElse: () => _languages.first,
    );

    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:        bgColor,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: borderColor),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(current['flag']!, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 5),
          Text(current['short']!,
              style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(width: 3),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: textColor),
        ]),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),
          Row(children: [
            const Icon(Icons.language_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            const Text('Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 6),
          const Text('Choose your preferred language for the app.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ..._languages.map((l) {
            final selected = lang.locale.languageCode == l['code'];
            return GestureDetector(
              onTap: () {
                if (l['code'] == 'am') {
                  lang.setAmharic();
                } else {
                  lang.setEnglish();
                }
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surfaceGray,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.border,
                      width: selected ? 2 : 1),
                  boxShadow: selected ? [BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8, offset: const Offset(0, 3))] : null,
                ),
                child: Row(children: [
                  Text(l['flag']!,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l['name']!,
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white : AppColors.textPrimary,
                        )),
                    Text(l['code'] == 'en'
                        ? 'App language: English'
                        : 'የመተግበሪያ ቋንቋ: አማርኛ',
                        style: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? Colors.white70 : AppColors.textSecondary,
                        )),
                  ])),
                  if (selected)
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 15),
                    ),
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
// STANDARD DALLOLBOOK APP BAR
// ─────────────────────────────────────────────────────────────────────────────
class DallolAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String       title;
  final bool         showBack;
  final bool         dark;
  final Color?       backgroundColor;
  final List<Widget> extraActions;

  const DallolAppBar({
    super.key,
    required this.title,
    this.showBack      = true,
    this.dark          = false,
    this.backgroundColor,
    this.extraActions  = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        (dark ? AppColors.primary : AppColors.surface);
    final fg = dark ? Colors.white : AppColors.textPrimary;

    return AppBar(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation:       0,
      centerTitle:     true,
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w800,
              fontSize: 17, color: fg)),
      // Show logo on left when no back button (e.g., top-level screens)
      leading: showBack && Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: fg),
              onPressed: () => Navigator.pop(context),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: AppLogoIcon(size: 28),
            ),
      actions: [
        ...extraActions,
        dark
            ? const LangToggleDark()
            : const LangToggleLight(),
        const SizedBox(width: 4),
      ],
    );
  }
}
