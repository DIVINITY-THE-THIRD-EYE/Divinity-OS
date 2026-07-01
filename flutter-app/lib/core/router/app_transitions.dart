import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_motion.dart';

/// Reusable page transition builders for GoRouter's CustomTransitionPage.
///
/// Three transition styles matching Apple HIG and Material 3 guidelines:
/// - [fadeThrough]: For tab/shell transitions — subtle fade + scale
/// - [sharedAxisX]: For sequential flows (auth) — slide + fade
/// - [slideUp]: For modal/detail screens — vertical slide + fade
///
/// All transitions respect [MediaQueryData.disableAnimations] for
/// reduced motion accessibility.
abstract final class AppTransitions {
  /// Fade-through transition — for tab switches and shell transitions.
  ///
  /// Enter: fade in + scale from 0.96 to 1.0
  /// Exit: fade out
  static CustomTransitionPage<void> fadeThrough({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.medium,
      reverseTransitionDuration: AppMotion.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Respect reduced motion preference
        if (MediaQuery.of(context).disableAnimations) {
          return child;
        }

        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppMotion.standard),
        );

        final scaleIn = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppMotion.standard),
        );

        return FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(scale: scaleIn, child: child),
        );
      },
    );
  }

  /// Shared-axis horizontal transition — for sequential auth flows.
  ///
  /// Enter: slide from right (30px) + fade in
  /// Exit: slide to left (-30px) + fade out
  static CustomTransitionPage<void> sharedAxisX({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.slow,
      reverseTransitionDuration: AppMotion.slow,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.of(context).disableAnimations) {
          return child;
        }

        final slideIn =
            Tween<Offset>(
              begin: const Offset(0.08, 0), // ~30px on a 375px screen
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: AppMotion.decelerate),
            );

        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppMotion.decelerate),
        );

        // Secondary (outgoing page) slides left
        final slideOut =
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.08, 0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: AppMotion.accelerate,
              ),
            );

        final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: AppMotion.accelerate,
          ),
        );

        return SlideTransition(
          position: slideOut,
          child: FadeTransition(
            opacity: fadeOut,
            child: SlideTransition(
              position: slideIn,
              child: FadeTransition(opacity: fadeIn, child: child),
            ),
          ),
        );
      },
    );
  }

  /// Slide-up transition — for modal and detail screens.
  ///
  /// Enter: slide up from bottom (50px) + fade in
  /// Exit: slide down + fade out
  static CustomTransitionPage<void> slideUp({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.slow,
      reverseTransitionDuration: AppMotion.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.of(context).disableAnimations) {
          return child;
        }

        final slideIn = Tween<Offset>(
          begin: const Offset(0, 0.12), // ~50px slide
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AppMotion.expoOut));

        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppMotion.decelerate),
        );

        return SlideTransition(
          position: slideIn,
          child: FadeTransition(opacity: fadeIn, child: child),
        );
      },
    );
  }
}
