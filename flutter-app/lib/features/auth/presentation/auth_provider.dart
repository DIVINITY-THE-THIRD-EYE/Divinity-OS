import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/analytics_service.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart' as app_auth;

// ── Auth Config ──────────────────────────────────────────────────────────────

class AuthConfig {
  const AuthConfig({
    required this.enableEmailPassword,
    required this.enableGoogleSignIn,
    required this.enableAppleSignIn,
    required this.enableAnonymous,
  });

  final bool enableEmailPassword;
  final bool enableGoogleSignIn;
  final bool enableAppleSignIn;
  final bool enableAnonymous;
}

final authConfigProvider = Provider<AuthConfig>((ref) {
  try {
    final rc = FirebaseRemoteConfig.instance;
    return AuthConfig(
      enableEmailPassword: rc.getBool('auth_enable_email'),
      enableGoogleSignIn: rc.getBool('auth_enable_google'),
      enableAppleSignIn: rc.getBool('auth_enable_apple'),
      enableAnonymous: rc.getBool('auth_enable_anonymous'),
    );
  } catch (_) {
    return const AuthConfig(
      enableEmailPassword: true,
      enableGoogleSignIn: true,
      enableAppleSignIn: true,
      enableAnonymous: false,
    );
  }
});

// ── Supabase client provider ─────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

/// The authenticated user's UUID, or null when signed out.
/// Derived from authStateProvider so all consumers rebuild reactively on
/// login/logout without watching the Supabase singleton directly.
/// Override in tests by overriding this provider — no Supabase needed.
final currentUserIdProvider = Provider<String?>((ref) {
  final state = ref.watch(authStateProvider);
  return state is app_auth.AuthAuthenticated ? state.user.id : null;
});

/// The authenticated user's role, or null when signed out.
final currentUserRoleProvider = Provider<app_auth.UserRole?>((ref) {
  final state = ref.watch(authStateProvider);
  return state is app_auth.AuthAuthenticated ? state.role : null;
});

// ── Auth repository ──────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);

// ── Auth state notifier ──────────────────────────────────────────────────────

final authStateProvider =
    StateNotifierProvider<AuthNotifier, app_auth.AuthState>(
      (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
    );

class AuthNotifier extends StateNotifier<app_auth.AuthState> {
  AuthNotifier(this._repo) : super(app_auth.AuthInitial()) {
    _sub = _repo.authEvents().listen(_onAuthEvent);
    _init();
  }

  final AuthRepository _repo;
  StreamSubscription<AuthLifecycleEvent>? _sub;
  RealtimeChannel? _realtimeChannel;
  // Suppresses external-event handling while a local sign-in/out/verify is in
  // flight, so the stream does not double-resolve what the method already set.
  bool _handlingLocal = false;

  @override
  void dispose() {
    _sub?.cancel();
    _cleanupRealtime();
    super.dispose();
  }

  void _cleanupRealtime() {
    if (_realtimeChannel != null) {
      _repo.unsubscribeFromChannel(_realtimeChannel!).ignore();
      _realtimeChannel = null;
    }
  }

  void _setupRealtime(String userId, User user) {
    if (_realtimeChannel != null) return;
    _realtimeChannel = _repo.subscribeToUserProfile(userId, (record) {
      _resolveUserState(user).ignore();
    });
  }

  Future<void> _onAuthEvent(AuthLifecycleEvent event) async {
    if (_handlingLocal) return; // local flow owns the transition
    try {
      switch (event) {
        case AuthLifecycleEvent.signedOut:
          // Covers terminal token-refresh failure AND sign-out on another
          // device — Supabase emits signedOut when the session is lost.
          _cleanupRealtime();
          if (state is! app_auth.AuthUnauthenticated) {
            state = app_auth.AuthUnauthenticated();
          }
        case AuthLifecycleEvent.signedIn:
          final user = _repo.currentUser;
          if (user != null && state is! app_auth.AuthAuthenticated) {
            await _resolveUserState(user);
          }
        case AuthLifecycleEvent.userUpdated:
          // auth.user changed (email/metadata). Does NOT fire for public.users
          // row changes (e.g. admin sets plan_status) — that needs Realtime.
          final user = _repo.currentUser;
          if (user != null) await _resolveUserState(user);
        case AuthLifecycleEvent.tokenRefreshed:
          // Self-heal: refresh succeeded but we believed we were signed out.
          final user = _repo.currentUser;
          if (user != null && state is app_auth.AuthUnauthenticated) {
            await _resolveUserState(user);
          }
        case AuthLifecycleEvent.passwordRecovery:
          final user = _repo.currentUser;
          if (user != null) {
            state = app_auth.AuthPasswordRecovery(user);
          }
          break;
      }
    } catch (_) {
      // Never let an event handler crash the notifier; fail safe to login.
      _cleanupRealtime();
      state = app_auth.AuthUnauthenticated();
    }
  }

  Future<void> _init() async {
    final user = _repo.currentUser;
    if (user == null) {
      state = app_auth.AuthUnauthenticated();
      return;
    }
    await _resolveUserState(user);
  }

  Future<void> _resolveUserState(User user) async {
    state = app_auth.AuthLoading();
    try {
      final profile = await _repo.fetchProfile(user.id);
      if (profile == null) {
        _cleanupRealtime();
        state = app_auth.AuthUnauthenticated();
        return;
      }
      final onboardingComplete =
          profile['onboarding_complete'] as bool? ?? false;
      if (!onboardingComplete) {
        _cleanupRealtime();
        state = app_auth.AuthNeedsOnboarding(user);
        return;
      }
      final planStatus = profile['plan_status'] as String? ?? 'UNPAID';
      final role = app_auth.UserRole.fromString(
        profile['role'] as String? ?? 'STUDENT',
      );
      if (planStatus == 'PENDING_ADMIN' || planStatus == 'PENDING_TRAINER') {
        state = app_auth.AuthPendingApproval(user);
        _setupRealtime(user.id, user);
      } else {
        state = app_auth.AuthAuthenticated(user, role);
        _setupRealtime(user.id, user);
      }
    } catch (e) {
      _cleanupRealtime();
      state = app_auth.AuthError(e.toString());
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> profileData) async {
    final currentState = state;
    if (currentState is! app_auth.AuthNeedsOnboarding) return;
    state = app_auth.AuthLoading();
    try {
      await _repo.updateProfile(currentState.user.id, {
        ...profileData,
        'onboarding_complete': true,
        'plan_status': 'PENDING_ADMIN',
      });
      await _resolveUserState(currentState.user);
    } catch (e) {
      state = app_auth.AuthError(e.toString());
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _handlingLocal = true;
    state = app_auth.AuthLoading();
    try {
      await _repo.signInWithEmail(email: email, password: password);
      final user = _repo.currentUser;
      if (user != null) {
        await _resolveUserState(user);
        if (state is app_auth.AuthAuthenticated) {
          // Fire-and-forget; must never affect auth flow.
          try {
            AnalyticsService.logLogin().ignore();
          } catch (_) {}
        }
      }
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (e) {
      state = app_auth.AuthError('Unexpected error. Please try again.');
    } finally {
      _handlingLocal = false;
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _handlingLocal = true;
    state = app_auth.AuthLoading();
    try {
      await _repo.signUpWithEmail(
        email: email,
        password: password,
        metaData: {
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      final user = _repo.currentUser;
      if (user != null) {
        await _resolveUserState(user);
      } else {
        // Verification email sent, require verification
        state = app_auth.AuthUnauthenticated();
      }
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (e) {
      state = app_auth.AuthError('Unexpected error. Please try again.');
    } finally {
      _handlingLocal = false;
    }
  }

  Future<void> signInWithGoogle() async {
    _handlingLocal = true;
    state = app_auth.AuthLoading();
    try {
      await _repo.signInWithGoogle();
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (e) {
      state = app_auth.AuthError('Google sign-in failed. Please try again.');
    } finally {
      _handlingLocal = false;
    }
  }

  Future<void> signInWithApple() async {
    _handlingLocal = true;
    state = app_auth.AuthLoading();
    try {
      await _repo.signInWithApple();
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (e) {
      state = app_auth.AuthError('Apple sign-in failed. Please try again.');
    } finally {
      _handlingLocal = false;
    }
  }

  Future<void> signOut() async {
    _handlingLocal = true;
    _cleanupRealtime();
    try {
      await _repo.signOut();
      // currentUserIdProvider (watching this provider) returns null, so every
      // feature provider rebuilds to empty. No per-provider invalidation needed.
      state = app_auth.AuthUnauthenticated();
    } finally {
      _handlingLocal = false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _handlingLocal = true;
    state = app_auth.AuthLoading();
    try {
      await _repo.sendPasswordResetEmail(email);
      state = app_auth.AuthUnauthenticated();
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (_) {
      state = app_auth.AuthError('Unexpected error. Please try again.');
    } finally {
      _handlingLocal = false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    _handlingLocal = true;
    state = app_auth.AuthLoading();
    try {
      await _repo.updatePassword(newPassword);
      final user = _repo.currentUser;
      if (user != null) {
        await _resolveUserState(user);
      } else {
        state = app_auth.AuthUnauthenticated();
      }
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (_) {
      state = app_auth.AuthError('Unexpected error. Please try again.');
    } finally {
      _handlingLocal = false;
    }
  }
}
