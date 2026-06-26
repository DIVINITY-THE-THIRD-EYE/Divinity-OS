import 'dart:async';

import 'package:divinity_app/features/auth/data/auth_repository.dart';
import 'package:divinity_app/features/auth/domain/auth_state.dart' as app_auth;
import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Returns a notifier wired to [repo] after its async _init() resolves.
Future<AuthNotifier> buildNotifier(AuthRepository repo) async {
  final notifier = AuthNotifier(repo);
  await Future<void>.microtask(() {});
  return notifier;
}

Map<String, dynamic> activeProfile({String role = 'STUDENT'}) => {
      'role': role,
      'plan_status': 'ACTIVE',
      'onboarding_complete': true,
    };

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(MockRealtimeChannel());
  });

  setUp(() {
    repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);
    // Default: no external auth events. Tests needing them override with a
    // StreamController.
    when(() => repo.authEvents())
        .thenAnswer((_) => const Stream<AuthLifecycleEvent>.empty());

    final mockChannel = MockRealtimeChannel();
    when(() => repo.subscribeToUserProfile(any(), any()))
        .thenReturn(mockChannel);
    when(() => repo.unsubscribeFromChannel(any()))
        .thenAnswer((_) async {});
  });

  group('UserRole.fromString', () {
    test('maps all known values', () {
      expect(app_auth.UserRole.fromString('ADMIN'), app_auth.UserRole.admin);
      expect(app_auth.UserRole.fromString('TRAINER'), app_auth.UserRole.trainer);
      expect(app_auth.UserRole.fromString('STUDENT'), app_auth.UserRole.student);
    });

    test('unknown value defaults to student', () {
      expect(app_auth.UserRole.fromString('OWNER'), app_auth.UserRole.student);
      expect(app_auth.UserRole.fromString(''), app_auth.UserRole.student);
    });
  });

  group('AuthNotifier — initial state', () {
    test('is AuthUnauthenticated when no session', () async {
      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthUnauthenticated>());
    });

    test('resolves to AuthAuthenticated for fully active user', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-1');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-1'))
          .thenAnswer((_) async => activeProfile());

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthAuthenticated>());
      expect(
        (n.state as app_auth.AuthAuthenticated).role,
        app_auth.UserRole.student,
      );
    });

    test('resolves to AuthNeedsOnboarding when onboarding_complete is false',
        () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-ob');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-ob')).thenAnswer(
        (_) async => {
          'role': 'STUDENT',
          'plan_status': 'UNPAID',
          'onboarding_complete': false,
        },
      );

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthNeedsOnboarding>());
    });

    test('resolves to AuthNeedsOnboarding when onboarding_complete absent',
        () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-ob2');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-ob2')).thenAnswer(
        (_) async => {'role': 'STUDENT', 'plan_status': 'UNPAID'},
      );

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthNeedsOnboarding>());
    });

    test('resolves to AuthPendingApproval for pending user', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-2');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-2')).thenAnswer(
        (_) async => {
          'role': 'STUDENT',
          'plan_status': 'PENDING_ADMIN',
          'onboarding_complete': true,
        },
      );

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthPendingApproval>());
    });
  });

  group('AuthNotifier — completeOnboarding', () {
    test('calls updateProfile and resolves to AuthPendingApproval', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-onboard');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-onboard')).thenAnswer(
        (_) async => {'role': 'STUDENT', 'plan_status': 'UNPAID'},
      );

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthNeedsOnboarding>());

      when(() => repo.updateProfile('uid-onboard', any()))
          .thenAnswer((_) async {});
      // After update, re-fetch returns pending profile.
      when(() => repo.fetchProfile('uid-onboard')).thenAnswer(
        (_) async => {
          'role': 'STUDENT',
          'plan_status': 'PENDING_ADMIN',
          'onboarding_complete': true,
        },
      );

      await n.completeOnboarding({'name': 'Arjun', 'age': 28});

      expect(n.state, isA<app_auth.AuthPendingApproval>());
      verify(() => repo.updateProfile(
            'uid-onboard',
            any(that: predicate<Map<String, dynamic>>(
              (m) =>
                  m['onboarding_complete'] == true &&
                  m['plan_status'] == 'PENDING_ADMIN',
            )),
          )).called(1);
    });

    test('is a no-op when state is not AuthNeedsOnboarding', () async {
      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthUnauthenticated>());
      await n.completeOnboarding({'name': 'Test'});
      // Should still be unauthenticated, no repo calls made.
      expect(n.state, isA<app_auth.AuthUnauthenticated>());
      verifyNever(() => repo.updateProfile(any(), any()));
    });
  });

  group('AuthNotifier — signInWithPhone', () {
    test('transitions to AuthAuthenticated on success', () async {
      final n = await buildNotifier(repo);

      final user = MockUser();
      when(() => user.id).thenReturn('uid-3');
      when(() => repo.signInWithPhone(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-3'))
          .thenAnswer((_) async => activeProfile(role: 'TRAINER'));

      await n.signInWithPhone(phone: '+919876543210', password: 'secret');

      expect(n.state, isA<app_auth.AuthAuthenticated>());
      expect(
        (n.state as app_auth.AuthAuthenticated).role,
        app_auth.UserRole.trainer,
      );
    });

    test('sets AuthError on AuthException', () async {
      final n = await buildNotifier(repo);

      when(() => repo.signInWithPhone(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenThrow(const AuthException('Invalid login credentials'));

      await n.signInWithPhone(phone: '+919876543210', password: 'wrong');

      expect(n.state, isA<app_auth.AuthError>());
      expect(
        (n.state as app_auth.AuthError).message,
        contains('Invalid login'),
      );
    });
  });

  group('AuthNotifier — sendOtp / verifyOtp', () {
    test('sendOtp transitions to AuthOtpSent', () async {
      final n = await buildNotifier(repo);

      when(() => repo.signInWithOtp(phone: any(named: 'phone')))
          .thenAnswer((_) async {});

      await n.sendOtp(phone: '+919876543210');

      expect(n.state, isA<app_auth.AuthOtpSent>());
      expect((n.state as app_auth.AuthOtpSent).phone, '+919876543210');
    });

    test('sendOtp sets AuthError on AuthException', () async {
      final n = await buildNotifier(repo);

      when(() => repo.signInWithOtp(phone: any(named: 'phone')))
          .thenThrow(const AuthException('Phone not supported'));

      await n.sendOtp(phone: '+919876543210');

      expect(n.state, isA<app_auth.AuthError>());
    });

    test('verifyOtp resolves to AuthAuthenticated on success', () async {
      final n = await buildNotifier(repo);
      final user = MockUser();
      when(() => user.id).thenReturn('uid-4');

      when(() => repo.verifyOtp(
            phone: any(named: 'phone'),
            token: any(named: 'token'),
          )).thenAnswer((_) async {});
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-4'))
          .thenAnswer((_) async => activeProfile(role: 'ADMIN'));

      await n.verifyOtp(phone: '+919876543210', token: '123456');

      expect(n.state, isA<app_auth.AuthAuthenticated>());
      expect(
        (n.state as app_auth.AuthAuthenticated).role,
        app_auth.UserRole.admin,
      );
    });

    test('verifyOtp sets AuthError when currentUser is null after verify',
        () async {
      final n = await buildNotifier(repo);

      when(() => repo.verifyOtp(
            phone: any(named: 'phone'),
            token: any(named: 'token'),
          )).thenAnswer((_) async {});
      when(() => repo.currentUser).thenReturn(null);

      await n.verifyOtp(phone: '+919876543210', token: '999999');

      expect(n.state, isA<app_auth.AuthError>());
    });
  });

  group('AuthNotifier — signOut', () {
    test('transitions to AuthUnauthenticated', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-5');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-5'))
          .thenAnswer((_) async => activeProfile());
      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthAuthenticated>());

      when(() => repo.signOut()).thenAnswer((_) async {});
      await n.signOut();

      expect(n.state, isA<app_auth.AuthUnauthenticated>());
    });
  });

  group('AuthNotifier — external auth events (H1)', () {
    test('external signedOut forces AuthUnauthenticated', () async {
      final controller = StreamController<AuthLifecycleEvent>();
      final user = MockUser();
      when(() => user.id).thenReturn('uid-ext');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-ext'))
          .thenAnswer((_) async => activeProfile());
      when(() => repo.authEvents()).thenAnswer((_) => controller.stream);

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthAuthenticated>());

      // Simulate session loss / sign-out on another device.
      controller.add(AuthLifecycleEvent.signedOut);
      await Future<void>.delayed(Duration.zero);

      expect(n.state, isA<app_auth.AuthUnauthenticated>());
      await controller.close();
    });

    test('userUpdated re-resolves the profile (role change)', () async {
      final controller = StreamController<AuthLifecycleEvent>();
      final user = MockUser();
      when(() => user.id).thenReturn('uid-upd');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-upd'))
          .thenAnswer((_) async => activeProfile());
      when(() => repo.authEvents()).thenAnswer((_) => controller.stream);

      final n = await buildNotifier(repo);
      expect(
        (n.state as app_auth.AuthAuthenticated).role,
        app_auth.UserRole.student,
      );

      // Profile now resolves to ADMIN; userUpdated should re-resolve.
      when(() => repo.fetchProfile('uid-upd'))
          .thenAnswer((_) async => activeProfile(role: 'ADMIN'));
      controller.add(AuthLifecycleEvent.userUpdated);
      await Future<void>.delayed(Duration.zero);

      expect(
        (n.state as app_auth.AuthAuthenticated).role,
        app_auth.UserRole.admin,
      );
      await controller.close();
    });
  });

  group('AuthNotifier — Password Recovery & Reset', () {
    test('routes to AuthPasswordRecovery on passwordRecovery lifecycle event', () async {
      final controller = StreamController<AuthLifecycleEvent>();
      final user = MockUser();
      when(() => user.id).thenReturn('uid-rec');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-rec'))
          .thenAnswer((_) async => activeProfile());
      when(() => repo.authEvents()).thenAnswer((_) => controller.stream);

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthAuthenticated>());

      controller.add(AuthLifecycleEvent.passwordRecovery);
      await Future<void>.delayed(Duration.zero);

      expect(n.state, isA<app_auth.AuthPasswordRecovery>());
      expect((n.state as app_auth.AuthPasswordRecovery).user, user);
      await controller.close();
    });

    test('sendPasswordReset calls repo.sendPasswordResetEmail and goes to AuthUnauthenticated', () async {
      when(() => repo.sendPasswordResetEmail('test@divinity.local'))
          .thenAnswer((_) async {});

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthUnauthenticated>());

      await n.sendPasswordReset('test@divinity.local');
      verify(() => repo.sendPasswordResetEmail('test@divinity.local')).called(1);
      expect(n.state, isA<app_auth.AuthUnauthenticated>());
    });

    test('updatePassword calls repo.updatePassword and resolves user profile', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-reset');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.updatePassword('newsecurepass'))
          .thenAnswer((_) async {});
      when(() => repo.fetchProfile('uid-reset'))
          .thenAnswer((_) async => activeProfile());

      final n = await buildNotifier(repo);
      n.state = app_auth.AuthPasswordRecovery(user);

      await n.updatePassword('newsecurepass');
      verify(() => repo.updatePassword('newsecurepass')).called(1);
      expect(n.state, isA<app_auth.AuthAuthenticated>());
    });
  });
}
