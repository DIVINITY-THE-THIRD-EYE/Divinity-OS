import 'package:flutter/material.dart';
import '../../core/theme/app_motion.dart';

/// A wrapper widget that animates the entrance of a list item.
///
/// Features a premium fade-in and slide-up transition, with an optional
/// stagger delay based on the item's index.
///
/// Automatically respects [MediaQuery.disableAnimations] for reduced-motion settings.
///
/// Usage:
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) {
///     return AnimatedListItem(
///       index: index,
///       child: MyListTile(data: items[index]),
///     );
///   },
/// )
/// ```
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? duration;
  final Curve? curve;
  final double slideOffset;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.index = 0,
    this.duration,
    this.curve,
    this.slideOffset = 30.0,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppMotion.medium,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: widget.curve ?? AppMotion.decelerate),
      ),
    );

    _slideAnimation = Tween<double>(begin: widget.slideOffset, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: widget.curve ?? AppMotion.expoOut),
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (mounted) {
      final disableAnimations = MediaQuery.of(context).disableAnimations;
      if (disableAnimations) {
        _controller.value = 1.0;
        return;
      }

      // Calculate stagger delay based on index
      final delay = AppMotion.staggerDelay * widget.index;
      await Future.delayed(delay);

      if (mounted) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0.0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
