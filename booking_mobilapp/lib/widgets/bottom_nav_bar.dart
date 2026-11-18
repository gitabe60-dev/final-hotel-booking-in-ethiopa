import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            _NavItem(
              index: 0, current: currentIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: l10n.t('home'),
              onTap: onTap,
            ),
            _NavItem(
              index: 1, current: currentIndex,
              icon: Icons.search_outlined,
              activeIcon: Icons.search_rounded,
              label: l10n.t('explore'),
              onTap: onTap,
            ),
            _NavItem(
              index: 2, current: currentIndex,
              icon: Icons.favorite_outline_rounded,
              activeIcon: Icons.favorite_rounded,
              label: l10n.t('wishlist'),
              onTap: onTap,
            ),
            _NavItem(
              index: 3, current: currentIndex,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: l10n.t('profile'),
              onTap: onTap,
            ),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index, current;
  final IconData icon, activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index, required this.current,
    required this.icon,  required this.activeIcon,
    required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sel = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              sel ? activeIcon : icon,
              key: ValueKey(sel),
              color: sel ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              color:      sel ? AppColors.primary : AppColors.textHint,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width:  sel ? 20 : 0,
            height: 3,
            decoration: BoxDecoration(
              color:        AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ]),
      ),
    );
  }
}
