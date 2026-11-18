import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Small inline rating badge: ★ 4.5  (23)
class StarRatingSmall extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;

  const StarRatingSmall({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.star, size: size),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size - 1,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size - 2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Full interactive 5-star row used in the review form
class StarRatingInteractive extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const StarRatingInteractive({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: filled ? AppColors.star : AppColors.border,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

/// Display-only row of filled stars
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled   = i < rating.floor();
        final halfFill = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : halfFill
                  ? Icons.star_half_rounded
                  : Icons.star_border_rounded,
          color: (filled || halfFill) ? AppColors.star : AppColors.border,
          size: size,
        );
      }),
    );
  }
}
