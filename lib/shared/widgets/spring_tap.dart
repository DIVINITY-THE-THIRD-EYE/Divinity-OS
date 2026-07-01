import 'package:flutter/material.dart';
import '../../core/theme/app_motion.dart';

/// A wrapper that provides spring-based tap feedback for any tappable element.
///
/// On tap-down, the child scales to [scaleDown] (default 0.97) using
/// the standard spring physics from [AppMotion]. On release, it springs
/// back to 1.0.
///
/// Respects [MediaQuery.disableAnimations] — when true, no scale animation
/// is applied and the tap callback fires immediately.
///
/// Includes full [Semantics] screen reader accessibility support.
///
/// Usage:
/// ```dart
/// SpringTap(
///   onTap: () => doSomething(),
///   semanticsLabel: "Confirm payment receipt",
///   child: MyCard(),
/// )
/// ```
class SpringTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final String? semanticsLabel;
  final String? semanticsHint;

  const SpringTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.97,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  State<SpringTap> createState() => _SpringTapState();
}

class _SpringTapState extends State<SpringTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      reverseDuration: AppMotion.medium,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.standard,
        reverseCurve: AppMotion.decelerate,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!MediaQuery.of(context).disableAnimations) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final Widget childWidget;

    // Skip animation wrapper if reduced motion is enabled
    if (MediaQuery.of(context).disableAnimations) {
      childWidget = GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: widget.child,
      );
    } else {
      childWidget = GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: widget.child,
        ),
      );
    }

    return Semantics(
      label: widget.semanticsLabel,
      hint: widget.semanticsHint,
      button: true,
      enabled: widget.onTap != null || widget.onLongPress != null,
      child: childWidget,
    );
  }
}
