/// hotel_image.dart
/// Smart image widget that handles all backend image formats:
///   1. Regular https:// URL           → CachedNetworkImage
///   2. http:// URL                    → CachedNetworkImage
///   3. data:image/jpeg;base64,...     → Image.memory (decode base64)
///   4. Google CDN URLs (lh3.google)   → CachedNetworkImage
///   5. null / empty                   → placeholder
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';

class HotelImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit  fit;
  final Widget? errorWidget;

  const HotelImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  bool get _isBase64 =>
      imageUrl != null &&
      (imageUrl!.startsWith('data:image') ||
       imageUrl!.startsWith('data:application'));

  bool get _isNetworkUrl =>
      imageUrl != null &&
      (imageUrl!.startsWith('http://') ||
       imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _Placeholder(width: width, height: height, errorWidget: errorWidget);
    }

    // ── Base64 image ───────────────────────────────────────────────────────
    if (_isBase64) {
      try {
        final b64 = imageUrl!.contains(',')
            ? imageUrl!.split(',').last
            : imageUrl!;
        final bytes = base64Decode(b64);
        return Image.memory(
          bytes,
          width:  width,
          height: height,
          fit:    fit,
          errorBuilder: (_, __, ___) =>
              _Placeholder(width: width, height: height, errorWidget: errorWidget),
        );
      } catch (_) {
        return _Placeholder(width: width, height: height, errorWidget: errorWidget);
      }
    }

    // ── Network URL ────────────────────────────────────────────────────────
    if (_isNetworkUrl) {
      return CachedNetworkImage(
        imageUrl:    imageUrl!,
        width:       width,
        height:      height,
        fit:         fit,
        placeholder: (_, __) => _Loading(width: width, height: height),
        errorWidget: (_, __, ___) =>
            _Placeholder(width: width, height: height, errorWidget: errorWidget),
      );
    }

    // ── Fallback placeholder ───────────────────────────────────────────────
    return _Placeholder(width: width, height: height, errorWidget: errorWidget);
  }
}

class _Loading extends StatelessWidget {
  final double? width, height;
  const _Loading({this.width, this.height});
  @override
  Widget build(BuildContext context) => Container(
    width:  width,
    height: height,
    color:  AppColors.surfaceGray,
    child: const Center(child: SizedBox(
      width: 24, height: 24,
      child: CircularProgressIndicator(
          strokeWidth: 2.5, color: AppColors.primary),
    )),
  );
}

class _Placeholder extends StatelessWidget {
  final double? width, height;
  final Widget? errorWidget;
  const _Placeholder({this.width, this.height, this.errorWidget});
  @override
  Widget build(BuildContext context) => errorWidget ?? Container(
    width:  width,
    height: height,
    color:  AppColors.surfaceGray,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.hotel_rounded, color: AppColors.textHint, size: 36),
      const SizedBox(height: 6),
      const Text('No Image', style: TextStyle(
          fontSize: 11, color: AppColors.textHint)),
    ]),
  );
}
