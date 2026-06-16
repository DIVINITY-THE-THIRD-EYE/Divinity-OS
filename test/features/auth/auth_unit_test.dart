import 'package:divinity_app/features/auth/data/auth_repository.dart';
import 'package:divinity_app/features/auth/domain/auth_state.dart' as app_auth;
import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Returns a notifier wired to [repo] after its async _init() resolves.
Future<AuthNotifier> buildNotifier(AuthRepository repo) async {
  final notifier = AuthNotifier(repo);
  await Future<void>.microtask(() {});
  return notifier;
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);
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

    test('resolves to AuthAuthenticated for active user', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-1');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-1')).thenAnswer(
        (_) async => {'role': 'STUDENT', 'plan_status': 'ACTIVE'},
      );

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthAuthenticated>());
      final s = n.state as app_auth.AuthAuthenticated;
      expect(s.role, app_auth.UserRole.student);
    });

    test('resolves to AuthPendingApproval for pending user', () async {
      final user = MockUser();
      when(() => user.id).thenReturn('uid-2');
      when(() => repo.currentUser).thenReturn(user);
      when(() => repo.fetchProfile('uid-2')).thenAnswer(
        (_) async => {'role': 'STUDENT', 'plan_status': 'PENDING_ADMIN'},
      );

      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthPendingApproval>());
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
      when(() => repo.fetchProfile('uid-3')).thenAnswer(
        (_) async => {'role': 'TRAINER', 'plan_status': 'ACTIVE'},
      );

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
      when(() => repo.fetchProfile('uid-4')).thenAnswer(
        (_) async => {'role': 'ADMIN', 'plan_status': 'ACTIVE'},
      );

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
      // currentUser still null after verify (unusual but guard it)
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
      when(() => repo.fetchProfile('uid-5')).thenAnswer(
        (_) async => {'role': 'STUDENT', 'plan_status': 'ACTIVE'},
      );
      final n = await buildNotifier(repo);
      expect(n.state, isA<app_auth.AuthAuthenticated>());

      when(() => repo.signOut()).thenAnswer((_) async {});
      await n.signOut();

      expect(n.state, isA<app_auth.AuthUnauthenticated>());
    });
  });
}
