import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — blue (matches web)
  static const Color primary      = Color(0xFF2563EB); // blue-600
  static const Color primaryDark  = Color(0xFF1D4ED8); // blue-700
  static const Color primaryLight = Color(0xFFEFF6FF); // blue-50

  // Accent — amber
  static const Color accent       = Color(0xFFF59E0B); // amber-500
  static const Color accentDark   = Color(0xFFD97706); // amber-600

  // Emerald / success
  static const Color success      = Color(0xFF059669); // emerald-600
  static const Color successLight = Color(0xFFECFDF5); // emerald-50

  // Error / red
  static const Color error        = Color(0xFFDC2626); // red-600
  static const Color errorLight   = Color(0xFFFEF2F2); // red-50

  // Neutrals
  static const Color textPrimary   = Color(0xFF111827); // gray-900
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color textHint      = Color(0xFF9CA3AF); // gray-400
  static const Color border        = Color(0xFFE5E7EB); // gray-200
  static const Color background    = Color(0xFFF9FAFB); // gray-50
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceGray   = Color(0xFFF3F4F6); // gray-100

  // Hero gradient colors
  static const Color heroStart  = Color(0xFF1D4ED8); // blue-700
  static const Color heroMid    = Color(0xFF2563EB); // blue-600
  static const Color heroEnd    = Color(0xFF4338CA); // indigo-700

  // Dark hero (login screen)
  static const Color darkStart  = Color(0xFF0F172A); // slate-900
  static const Color darkMid    = Color(0xFF1E3A8A); // blue-900
  static const Color darkEnd    = Color(0xFF312E81); // indigo-900

  // Star rating
  static const Color star       = Color(0xFFF59E0B); // amber-400
}
