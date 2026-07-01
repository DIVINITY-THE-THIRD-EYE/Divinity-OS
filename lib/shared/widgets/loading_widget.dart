import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Chakra ring loader — spins a gradient arc in brand violet.
class ChakraLoader extends StatefulWidget {
  const ChakraLoader({super.key, this.size = 48});

  final double size;

  @override
  State<ChakraLoader> createState() => _ChakraLoaderState();
}

class _ChakraLoaderState extends State<ChakraLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ChakraPainter(_ctrl.value, color),
      ),
    );
  }
}

class _ChakraPainter extends CustomPainter {
  const _ChakraPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 8) / 2;

    final bg = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, r, bg);

    final arc = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.0), color],
        transform: GradientRotation(t * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      t * math.pi * 2,
      math.pi * 1.5,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_ChakraPainter old) => old.t != t;
}

/// Full-screen loading overlay.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ChakraLoader(size: 56),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
