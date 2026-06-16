import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_state.dart' as app_auth;
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_wizard.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/pending_approval_screen.dart';
import '../../features/shells/role_shell.dart';

abstract final class Routes {
  static const String login = '/login';
  static const String otp = '/otp';
  static const String onboarding = '/onboarding';
  static const String pendingApproval = '/pending';
  static const String home = '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: Routes.login,
        pageBuilder: (_, s) => const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: Routes.otp,
        pageBuilder: (_, s) => const NoTransitionPage(child: OtpScreen()),
      ),
      GoRoute(
        path: Routes.onboarding,
        pageBuilder: (_, s) =>
            const NoTransitionPage(child: OnboardingWizard()),
      ),
      GoRoute(
        path: Routes.pendingApproval,
        pageBuilder: (_, s) =>
            const NoTransitionPage(child: PendingApprovalScreen()),
      ),
      GoRoute(
        path: Routes.home,
        pageBuilder: (_, s) => const NoTransitionPage(child: RoleShell()),
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
      app_auth.AuthAuthenticated() =>
        (loc == Routes.login ||
                loc == Routes.otp ||
                loc == Routes.pendingApproval)
            ? Routes.home
            : null,
    };
  }
}
