import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_images.dart';
import 'local_or_network_image.dart';
import 'star_rating.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC DISPATCHER
// compact=true  → _GridCard  (city hotels grid, search results)
// compact=false → _ListCard  (home featured horizontal scroll)
// ─────────────────────────────────────────────────────────────────────────────
class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback? onTap;
  final bool compact;

  const HotelCard({
    super.key,
    required this.hotel,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) =>
      compact
          ? _GridCard(hotel: hotel, onTap: onTap)
          : _ListCard(hotel: hotel, onTap: onTap);
}

// ─────────────────────────────────────────────────────────────────────────────
// _GridCard
// Smart image: fills full card width, 3:2 ratio (LayoutBuilder-driven),
// gradient scrim + badges. Info section below — name, city, rating, Book btn.
// ─────────────────────────────────────────────────────────────────────────────
class _GridCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback? onTap;
  const _GridCard({required this.hotel, this.onTap});
  @override
  State<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<_GridCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final h = widget.hotel;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown:   (_) => _ctrl.forward(),
        onTapUp:     (_) { _ctrl.reverse(); widget.onTap?.call(); },
        onTapCancel: ()  => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 14, offset: const Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image — 3:2 aspect ratio, full card width ──────────────
              AspectRatio(
                aspectRatio: 3 / 2,
                child: Stack(fit: StackFit.expand, children: [
                  LocalOrNetworkImage(
                    localPath:   AppImages.hotelCover(h.name),
                    networkUrl:  h.thumbnailUrl,
                    fit:         BoxFit.cover,
                    errorWidget: _HotelPlaceholder(name: h.name),
                  ),
                  // Bottom gradient scrim
                  Positioned.fill(child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.60),
                        ],
                        stops: const [0.42, 1.0],
                      ),
                    ),
                  )),
                  // Type badge — top left
                  if (h.type != null)
                    Positioned(top: 8, left: 8,
                        child: _TypeBadge(h.type!)),
                  // Featured badge — below type
                  if (h.isFeatured)
                    Positioned(
                        top: h.type != null ? 32 : 8, left: 8,
                        child: const _FeaturedBadge()),
                  // Rating — top right
                  Positioned(top: 8, right: 8,
                      child: _RatingBadge(rating: h.rating)),
                  // Price — bottom left
                  Positioned(bottom: 8, left: 8,
                      child: _PriceBadge(price: h.pricePerNight)),
                ]),
              ),

              // ── Info ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Expanded(child: Text(h.city,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      StarRatingSmall(rating: h.rating, size: 12),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            AppColors.primary, AppColors.primaryDark]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Book',
                            style: TextStyle(
                                fontSize: 10, color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ListCard
// Home featured horizontal scroll: fixed 200 wide, 4:3 image top, info below.
// ─────────────────────────────────────────────────────────────────────────────
class _ListCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback? onTap;
  const _ListCard({required this.hotel, this.onTap});
  @override
  State<_ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<_ListCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final h = widget.hotel;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown:   (_) => _ctrl.forward(),
        onTapUp:     (_) { _ctrl.reverse(); widget.onTap?.call(); },
        onTapCancel: ()  => _ctrl.reverse(),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.11),
                blurRadius: 16, offset: const Offset(0, 5)),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image — 4:3 aspect, full card width ──────────────────
              SizedBox(
                width: 200,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(fit: StackFit.expand, children: [
                    LocalOrNetworkImage(
                      localPath:   AppImages.hotelCover(h.name),
                      networkUrl:  h.thumbnailUrl,
                      fit:         BoxFit.cover,
                      errorWidget: _HotelPlaceholder(name: h.name),
                    ),
                    Positioned.fill(child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end:   Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.52),
                          ],
                          stops: const [0.40, 1.0],
                        ),
                      ),
                    )),
                    if (h.isFeatured)
                      const Positioned(top: 8, left: 8,
                          child: _FeaturedBadge()),
                    Positioned(top: 8, right: 8,
                        child: _RatingBadge(rating: h.rating)),
                    Positioned(bottom: 8, left: 8,
                        child: _PriceBadge(price: h.pricePerNight)),
                  ]),
                ),
              ),
              // ── Info ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Expanded(child: Text(h.city,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 5),
                    StarRatingSmall(
                        rating: h.rating, reviewCount: h.reviewCount, size: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge(this.type);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(20)),
    child: Text(type.toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontSize: 9,
            fontWeight: FontWeight.w700, letterSpacing: 0.5)),
  );
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 6)]),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, color: Colors.white, size: 10),
      SizedBox(width: 2),
      Text('Featured',
          style: TextStyle(color: Colors.white,
              fontSize: 9, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star_rounded, color: AppColors.star, size: 11),
      const SizedBox(width: 2),
      Text(rating.toStringAsFixed(1),
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
    ]),
  );
}

class _PriceBadge extends StatelessWidget {
  final double price;
  const _PriceBadge({required this.price});

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]),
    child: RichText(
      text: TextSpan(children: [
        TextSpan(
            text: 'ETB ${_fmt(price)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
        const TextSpan(
            text: '/nt',
            style: TextStyle(color: Colors.white70, fontSize: 9)),
      ]),
    ),
  );
}

class _HotelPlaceholder extends StatelessWidget {
  final String name;
  const _HotelPlaceholder({required this.name});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryDark,
          AppColors.primary.withValues(alpha: 0.7)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.hotel_rounded, color: Colors.white38, size: 36),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(name,
            textAlign: TextAlign.center, maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}
