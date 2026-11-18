import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum SpinnerSize { small, medium, large }

class AppSpinner extends StatelessWidget {
  final SpinnerSize size;
  final Color? color;

  const AppSpinner({
    super.key,
    this.size = SpinnerSize.medium,
    this.color,
  });

  double get _size {
    switch (size) {
      case SpinnerSize.small:  return 20;
      case SpinnerSize.medium: return 36;
      case SpinnerSize.large:  return 52;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _size,
        height: _size,
        child: CircularProgressIndicator(
          strokeWidth: size == SpinnerSize.small ? 2 : 3,
          valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
        ),
      ),
    );
  }
}

/// Full-screen centered spinner
class FullScreenSpinner extends StatelessWidget {
  const FullScreenSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: AppSpinner(size: SpinnerSize.large)),
    );
  }
}

/// Shimmer skeleton card used while hotel lists load
class HotelCardSkeleton extends StatefulWidget {
  const HotelCardSkeleton({super.key});

  @override
  State<HotelCardSkeleton> createState() => _HotelCardSkeletonState();
}

class _HotelCardSkeletonState extends State<HotelCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final c = Color.lerp(
            const Color(0xFFE5E7EB), const Color(0xFFF3F4F6), _anim.value)!;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 160, color: c),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 10, width: 60, color: c,
                        margin: const EdgeInsets.only(bottom: 8)),
                    Container(
                        height: 14, width: double.infinity, color: c,
                        margin: const EdgeInsets.only(bottom: 6)),
                    Container(height: 11, width: 100, color: c,
                        margin: const EdgeInsets.only(bottom: 10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(height: 11, width: 70, color: c),
                        Container(height: 14, width: 80, color: c),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
