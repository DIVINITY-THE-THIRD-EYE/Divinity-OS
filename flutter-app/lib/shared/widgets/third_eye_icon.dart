import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThirdEyeIcon extends StatelessWidget {
  const ThirdEyeIcon({
    super.key,
    this.size = 48,
    this.color,
    this.useAsset = true,
  });

  final double size;
  final Color? color;
  final bool useAsset;

  @override
  Widget build(BuildContext context) {
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (useAsset && !isTest) {
      return Image.asset(
        'assets/brand/logo-mark.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    final c = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ThirdEyePainter(c)),
    );
  }
}

class _ThirdEyePainter extends CustomPainter {
  const _ThirdEyePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;

    // Outer lotus petals
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final px = center.dx + r * 0.7 * math.cos(angle);
      final py = center.dy + r * 0.7 * math.sin(angle);
      canvas.drawCircle(Offset(px, py), r * 0.28, strokePaint);
    }

    // Middle ring
    canvas.drawCircle(center, r * 0.45, strokePaint);

    // Inner eye
    canvas.drawCircle(center, r * 0.18, fillPaint);
  }

  @override
  bool shouldRepaint(_ThirdEyePainter old) => old.color != color;
}
