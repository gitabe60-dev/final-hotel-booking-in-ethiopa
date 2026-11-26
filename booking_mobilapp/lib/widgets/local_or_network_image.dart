/// local_or_network_image.dart
///
/// Priority (same on BOTH mobile and web):
///   1. Local asset (bundled in APK/web build — your images from the city folders)
///   2. Network URL (only used if local asset fails or is not provided)
///   3. Placeholder (grey box with icon — always works)
///
/// The city images you put in assets/images/cities/*/city.jpg
/// are ALWAYS shown first. Network URL is only the backup.
library;

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'hotel_image.dart';

class LocalOrNetworkImage extends StatelessWidget {
  final String? localPath;   // asset path e.g. 'assets/images/cities/addis_ababa/city.jpg'
  final String? networkUrl;  // https:// URL — only used if local asset fails
  final double? width;
  final double? height;
  final BoxFit  fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LocalOrNetworkImage({
    super.key,
    this.localPath,
    this.networkUrl,
    this.width,
    this.height,
    this.fit          = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // LOCAL ASSET FIRST — works on mobile and web
    // These are your images from assets/images/cities/ and assets/images/hotels/
    if (localPath != null && localPath!.isNotEmpty) {
      return Image.asset(
        localPath!,
        width:  width,
        height: height,
        fit:    fit,
        errorBuilder: (_, __, ___) {
          // Local asset failed → try network URL
          return _network();
        },
      );
    }
    // No local path provided → go straight to network
    return _network();
  }

  /// Load from network URL (only used as fallback).
  Widget _network() {
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return HotelImage(
        imageUrl:    networkUrl,
        width:       width,
        height:      height,
        fit:         fit,
        errorWidget: errorWidget ?? _fallback(),
      );
    }
    return errorWidget ?? _fallback();
  }

  Widget _fallback() => Container(
    width:  width,
    height: height,
    color:  AppColors.surfaceGray,
    child: placeholder ?? const Center(
        child: Icon(Icons.image_outlined, color: AppColors.textHint, size: 36)),
  );
}
