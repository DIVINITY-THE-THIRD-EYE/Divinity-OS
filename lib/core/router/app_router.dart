import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_state.dart' as app_auth;
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_wizard.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/pending_approval_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/shells/role_shell.dart';
import 'app_transitions.dart';

abstract final class Routes {
  static const String login = '/login';
  static const String otp = '/otp';
  static const String onboarding = '/onboarding';
  static const String pendingApproval = '/pending';
  static const String resetPassword = '/reset-password';
  static const String home = '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    routes: [
      // Auth flow — shared axis horizontal for sequential progression
      GoRoute(
        path: Routes.login,
        pageBuilder: (_, s) =>
            AppTransitions.sharedAxisX(child: const LoginScreen(), state: s),
      ),
      GoRoute(
        path: Routes.otp,
        pageBuilder: (_, s) =>
            AppTransitions.sharedAxisX(child: const OtpScreen(), state: s),
      ),
      GoRoute(
        path: Routes.onboarding,
        pageBuilder: (_, s) => AppTransitions.sharedAxisX(
            child: const OnboardingWizard(), state: s),
      ),
      // Modal-style routes — slide up
      GoRoute(
        path: Routes.pendingApproval,
        pageBuilder: (_, s) => AppTransitions.slideUp(
            child: const PendingApprovalScreen(), state: s),
      ),
      GoRoute(
        path: Routes.resetPassword,
        pageBuilder: (_, s) => AppTransitions.sharedAxisX(
            child: const ResetPasswordScreen(), state: s),
      ),
      // Main dashboard — fade through for shell/tab transitions
      GoRoute(
        path: Routes.home,
        pageBuilder: (_, s) =>
            AppTransitions.fadeThrough(child: const RoleShell(), state: s),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<app_auth.AuthState>(
      authStateProvider,
      (_, next) => notifyListeners(),
    );
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    final loc = state.matchedLocation;

    return switch (authState) {
      app_auth.AuthInitial() || app_auth.AuthLoading() => null,
      app_auth.AuthUnauthenticated() || app_auth.AuthError() =>
        loc == Routes.login ? null : Routes.login,
      app_auth.AuthOtpSent() =>
        loc == Routes.otp ? null : Routes.otp,
      app_auth.AuthNeedsOnboarding() =>
        loc == Routes.onboarding ? null : Routes.onboarding,
      app_auth.AuthPendingApproval() =>
        loc == Routes.pendingApproval ? null : Routes.pendingApproval,
      app_auth.AuthPasswordRecovery() =>
        loc == Routes.resetPassword ? null : Routes.resetPassword,
      app_auth.AuthAuthenticated() =>
        (loc == Routes.login ||
                loc == Routes.otp ||
                loc == Routes.pendingApproval ||
                loc == Routes.resetPassword)
            ? Routes.home
            : null,
    };
  }
}
