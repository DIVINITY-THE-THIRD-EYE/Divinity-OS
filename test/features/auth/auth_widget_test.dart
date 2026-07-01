import 'package:divinity_app/core/theme/app_theme.dart';
import 'package:divinity_app/features/auth/data/auth_repository.dart';
import 'package:divinity_app/features/auth/domain/auth_state.dart' as app_auth;
import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/auth/presentation/login_screen.dart';
import 'package:divinity_app/features/auth/presentation/onboarding/steps/step_consent.dart';
import 'package:divinity_app/features/auth/presentation/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeRealtimeChannel extends Fake implements RealtimeChannel {}

class _FakeAuthRepository implements AuthRepository {
  @override
  User? get currentUser => null;

  @override
  Stream<AuthLifecycleEvent> authEvents() =>
      const Stream<AuthLifecycleEvent>.empty();

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metaData,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithPhone({
    required String phone,
    required String password,
  }) async {}

  @override
  Future<void> signInWithOtp({required String phone}) async {}

  @override
  Future<void> verifyOtp({
    required String phone,
    required String token,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<Map<String, dynamic>?> fetchProfile(String userId) async => null;

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  RealtimeChannel subscribeToUserProfile(String userId, void Function(Map<String, dynamic> record) callback) {
    return _FakeRealtimeChannel();
  }

  @override
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {}
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith(
        (ref) => AuthNotifier(_FakeAuthRepository()),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: child,
    ),
  );
}

// ── LoginScreen tests ─────────────────────────────────────────────────────────

void main() {
  group('LoginScreen', () {
    testWidgets('renders provider buttons by default', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Email'), findsOneWidget);
      expect(find.text('Continue with Phone'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('toggles to Email Sign In form', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.text('Continue with Email'));
      await tester.pump();

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Use another sign-in method'), findsOneWidget);
    });

    testWidgets('toggles to Phone Sign In form', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.text('Continue with Phone'));
      await tester.pump();

      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Use OTP instead'), findsOneWidget);
      expect(find.text('Use another sign-in method'), findsOneWidget);
    });

    testWidgets('validates empty email on email sign-in submit', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.text('Continue with Email'));
      await tester.pump();

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows Divinity branding', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();

      expect(find.text('Divinity'), findsOneWidget);
      expect(find.text('THE THIRD EYE'), findsOneWidget);
    });
  });

  group('OtpScreen', () {
    Widget wrapOtp() {
      return ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => _OtpSentNotifier(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const OtpScreen(),
        ),
      );
    }

    testWidgets('renders OTP input and Verify button', (tester) async {
      await tester.pumpWidget(wrapOtp());
      await tester.pump();

      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.text('Resend OTP'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
    });

    testWidgets('shows phone from AuthOtpSent state', (tester) async {
      await tester.pumpWidget(wrapOtp());
      await tester.pump();

      expect(find.text('+919876543210'), findsOneWidget);
    });
  });

  group('StepConsent', () {
    testWidgets('renders title, text and bullet points', (tester) async {
      bool consent = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StepConsent(
              consent: consent,
              onConsentChanged: (v) => consent = v,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Data privacy & consent'), findsOneWidget);
      expect(find.textContaining('DPDP Act Compliance'), findsOneWidget);
      expect(find.textContaining('Location coordinates to verify presence'), findsOneWidget);
    });

    testWidgets('taps checkbox and invokes onConsentChanged', (tester) async {
      bool consent = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => StepConsent(
                consent: consent,
                onConsentChanged: (v) {
                  setState(() => consent = v);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pump();

      expect(consent, isTrue);
    });
  });
}

// Notifier that starts in AuthOtpSent for OtpScreen widget tests.
class _OtpSentNotifier extends AuthNotifier {
  _OtpSentNotifier() : super(_FakeAuthRepository()) {
    state = app_auth.AuthOtpSent('+919876543210');
  }
}
