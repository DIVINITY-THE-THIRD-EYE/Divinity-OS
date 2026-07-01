import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A shimmer loading placeholder that matches the web's skeleton-shimmer.
///
/// Replaces bare [CircularProgressIndicator] in loading states with a
/// polished gradient sweep animation.
///
/// Usage:
/// ```dart
/// ShimmerLoading(width: double.infinity, height: 48)
/// ShimmerLoading(width: 200, height: 16, borderRadius: 4) // text placeholder
/// ShimmerLoading.circular(size: 48) // avatar placeholder
/// ```
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  /// Circular shimmer for avatar placeholders
  factory ShimmerLoading.circular({Key? key, required double size}) {
    return ShimmerLoading(
      key: key,
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceAltLight;

    if (MediaQuery.of(context).disableAnimations) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: baseColor,
        ),
      );
    }

    final highlightColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A pre-built shimmer layout for common card loading states.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading.circular(size: 40),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: 120, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    ShimmerLoading(width: 80, height: 10, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerLoading(
            width: double.infinity,
            height: 12,
            borderRadius: 4,
          ),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 200, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
