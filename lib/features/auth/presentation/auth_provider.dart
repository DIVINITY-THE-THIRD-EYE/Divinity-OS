import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../domain/auth_state.dart' as app_auth;

// ── Supabase client provider ─────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

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
    _init();
  }

  final AuthRepository _repo;

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
        state = app_auth.AuthUnauthenticated();
        return;
      }
      final onboardingComplete =
          profile['onboarding_complete'] as bool? ?? false;
      if (!onboardingComplete) {
        state = app_auth.AuthNeedsOnboarding(user);
        return;
      }
      final planStatus = profile['plan_status'] as String? ?? 'UNPAID';
      final role = app_auth.UserRole.fromString(
        profile['role'] as String? ?? 'STUDENT',
      );
      if (planStatus == 'PENDING_ADMIN' || planStatus == 'PENDING_TRAINER') {
        state = app_auth.AuthPendingApproval(user);
      } else {
        state = app_auth.AuthAuthenticated(user, role);
      }
    } catch (e) {
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

  Future<void> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    state = app_auth.AuthLoading();
    try {
      await _repo.signInWithPhone(phone: phone, password: password);
      final user = _repo.currentUser;
      if (user != null) await _resolveUserState(user);
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (e) {
      state = app_auth.AuthError('Unexpected error. Please try again.');
    }
  }

  Future<void> sendOtp({required String phone}) async {
    state = app_auth.AuthLoading();
    try {
      await _repo.signInWithOtp(phone: phone);
      state = app_auth.AuthOtpSent(phone);
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (_) {
      state = app_auth.AuthError('Failed to send OTP. Please try again.');
    }
  }

  Future<void> verifyOtp({
    required String phone,
    required String token,
  }) async {
    state = app_auth.AuthLoading();
    try {
      await _repo.verifyOtp(phone: phone, token: token);
      final user = _repo.currentUser;
      if (user != null) {
        await _resolveUserState(user);
      } else {
        state = app_auth.AuthError('Verification failed. Please try again.');
      }
    } on AuthException catch (e) {
      state = app_auth.AuthError(e.message);
    } catch (_) {
      state = app_auth.AuthError('Unexpected error. Please try again.');
    }
  }

  Future<void> resendOtp({required String phone}) => sendOtp(phone: phone);

  Future<void> signOut() async {
    await _repo.signOut();
    state = app_auth.AuthUnauthenticated();
  }
}
