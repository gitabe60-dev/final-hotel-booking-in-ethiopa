/// local_or_network_image.dart
///
/// Priority:
///   - Mobile: local asset → network URL → placeholder
///   - Web:    network URL → local asset → placeholder
///
/// On web, Image.asset still works for bundled assets, but on first load
/// the network URL is more reliable. On web we try network first so the
/// city/hotel images always show regardless of asset bundling behavior.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'hotel_image.dart';

class LocalOrNetworkImage extends StatelessWidget {
  final String? localPath;   // asset path e.g. 'assets/images/cities/addis_ababa/city.jpg'
  final String? networkUrl;  // https:// or data: URL fallback
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
    // On WEB: try network URL first (always reliable),
    // fall back to local asset if network fails
    if (kIsWeb) {
      if (networkUrl != null && networkUrl!.isNotEmpty) {
        return HotelImage(
          imageUrl:    networkUrl,
          width:       width,
          height:      height,
          fit:         fit,
          errorWidget: _localAsset() ?? errorWidget ?? _fallback(),
        );
      }
      return _localAsset() ?? errorWidget ?? _fallback();
    }

    // On MOBILE: try local asset first (bundled in APK — no internet needed),
    // fall back to network URL
    if (localPath != null && localPath!.isNotEmpty) {
      return Image.asset(
        localPath!,
        width:  width,
        height: height,
        fit:    fit,
        errorBuilder: (_, __, ___) => _network(),
      );
    }
    return _network();
  }

  /// Load local bundled asset (works on both mobile and web).
  Widget? _localAsset() {
    if (localPath == null || localPath!.isEmpty) return null;
    return Image.asset(
      localPath!,
      width:  width,
      height: height,
      fit:    fit,
      errorBuilder: (_, __, ___) => errorWidget ?? _fallback(),
    );
  }

  /// Load from network URL.
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
