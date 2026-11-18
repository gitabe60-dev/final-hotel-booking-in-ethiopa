import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

void showSuccess(BuildContext context, String message) {
  _show(context, message, AppColors.success, Icons.check_circle_outline_rounded);
}

void showError(BuildContext context, String message) {
  _show(context, message, AppColors.error, Icons.error_outline_rounded);
}

void showInfo(BuildContext context, String message) {
  _show(context, message, AppColors.primary, Icons.info_outline_rounded);
}

void _show(
    BuildContext context, String message, Color color, IconData icon) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
}
