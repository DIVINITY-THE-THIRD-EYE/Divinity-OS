import 'package:flutter/animation.dart';

/// Centralized motion design tokens for the Divinity app.
///
/// Every animation in the app references these constants instead of
/// using hardcoded values. This ensures consistency across all screens
/// and makes global timing adjustments trivial.
///
/// Token values are synchronized with the web platform (Next.js).
abstract final class AppMotion {
  // ─── Duration Tokens ─────────────────────────────────────────────────
  /// Micro-interactions: hover, toggle, click feedback
  static const fast = Duration(milliseconds: 150);

  /// Cards, nav transitions, list reorder
  static const medium = Duration(milliseconds: 250);

  /// Page transitions, shared-element, hero reveals
  static const slow = Duration(milliseconds: 400);

  /// Cinematic entrance sequences
  static const glacial = Duration(milliseconds: 800);

  // ─── Curve Tokens ────────────────────────────────────────────────────
  /// General purpose — Material 3 standard
  static const standard = Curves.fastOutSlowIn;

  /// Elements entering view — smooth deceleration
  static const decelerate = Curves.easeOutCubic;

  /// Elements leaving view — quick acceleration
  static const accelerate = Curves.easeInCubic;

  /// Playful elastic overshoot
  static const bouncy = Curves.elasticOut;

  /// Signature Divinity easing — matches web cubic-bezier(0.16, 1, 0.3, 1)
  static const expoOut = Cubic(0.16, 1, 0.3, 1);

  /// For symmetric enter/exit — matches web cubic-bezier(0.76, 0, 0.24, 1)
  static const expoInOut = Cubic(0.76, 0, 0.24, 1);

  // ─── Spring Physics ──────────────────────────────────────────────────
  /// Standard spring — snappy and responsive
  static const standardSpring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 30,
  );

  /// Bouncy spring — playful with overshoot
  static const bouncySpring = SpringDescription(
    mass: 1,
    stiffness: 220,
    damping: 15,
  );

  /// Gentle spring — soft and fluid
  static const gentleSpring = SpringDescription(
    mass: 1,
    stiffness: 200,
    damping: 26,
  );

  // ─── Stagger Delays ──────────────────────────────────────────────────
  /// Default delay between staggered list items
  static const staggerDelay = Duration(milliseconds: 50);

  /// Delay between staggered grid items
  static const gridStaggerDelay = Duration(milliseconds: 80);
}
