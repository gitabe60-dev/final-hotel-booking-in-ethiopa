/// local_or_network_image.dart
///
/// Priority: local asset → network URL → placeholder
/// Used for city cards and hotel cards to show real local photos.
library;

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
