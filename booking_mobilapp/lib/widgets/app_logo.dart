/// app_logo.dart
///
/// Reusable EthioStay logo widget.
/// Falls back to a styled text badge if the PNG asset isn't found.
library;

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkBackground;

  const AppLogo({
    super.key,
    this.size        = 56,
    this.showText    = false,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image — falls back to styled container if PNG not found
        SizedBox(
          width:  size,
          height: size,
          child: Image.asset(
            'assets/images/app/logo.png',
            width:  size,
            height: size,
            fit:    BoxFit.contain,
            errorBuilder: (_, __, ___) => _FallbackLogo(size: size),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: 'Ethio',
                style: TextStyle(
                  fontSize:   size * 0.42,
                  fontWeight: FontWeight.w900,
                  color:      darkBackground ? Colors.white : AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              TextSpan(
                text: 'Stay',
                style: TextStyle(
                  fontSize:   size * 0.42,
                  fontWeight: FontWeight.w900,
                  color:      const Color(0xFFD4AF37), // gold
                  letterSpacing: 0.3,
                ),
              ),
            ]),
          ),
        ],
      ],
    );
  }
}

/// Shown if logo.png hasn't been placed in assets yet.
/// Renders a green square with gold "ES" — matching the logo's style.
class _FallbackLogo extends StatelessWidget {
  final double size;
  const _FallbackLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'E',
              style: TextStyle(
                fontSize:   size * 0.40,
                fontWeight: FontWeight.w900,
                color:      const Color(0xFFD4AF37),
                letterSpacing: -1,
              ),
            ),
            TextSpan(
              text: 'S',
              style: TextStyle(
                fontSize:   size * 0.40,
                fontWeight: FontWeight.w900,
                color:      Colors.white,
                letterSpacing: -1,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Compact inline logo for AppBar titles — just the icon, 32px.
class AppLogoIcon extends StatelessWidget {
  final double size;
  const AppLogoIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) => SizedBox(
    width:  size,
    height: size,
    child: Image.asset(
      'assets/images/app/logo.png',
      width:  size,
      height: size,
      fit:    BoxFit.contain,
      errorBuilder: (_, __, ___) => _FallbackLogo(size: size),
    ),
  );
}
