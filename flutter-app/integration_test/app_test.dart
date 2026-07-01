import 'package:divinity_app/features/certificates/domain/certificate.dart';
import 'package:divinity_app/features/certificates/presentation/certificate_provider.dart';
import 'package:divinity_app/features/certificates/presentation/certificates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration tests run the real widget tree + navigation + Riverpod state.
/// Backend providers are overridden so the test is hermetic (no Supabase /
/// device needed) and can run with:  flutter test integration_test/app_test.dart
/// On a device/emulator the same suite runs with: flutter test integration_test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Student views a certificate and opens its detail', (tester) async {
    final sample = Certificate(
      id: 'c1',
      studentId: 's1',
      code: 'DIV-7K2A-9QF3',
      title: 'Certificate of Completion',
      programme: '200-Hour Foundation',
      issuedOn: DateTime(2026, 6, 12),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myCertificatesProvider.overrideWith((ref) async => [sample]),
        ],
        child: const MaterialApp(home: CertificatesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The list shows the programme and the verification code.
    expect(find.text('200-Hour Foundation'), findsOneWidget);
    expect(find.textContaining('DIV-7K2A-9QF3'), findsWidgets);

    // Opening the certificate navigates to the full, shareable view.
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('DIVINITY — THE THIRD EYE'), findsOneWidget);
    expect(find.text('Share certificate'), findsOneWidget);
  });

  testWidgets('Empty state shows trust assurances', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myCertificatesProvider.overrideWith((ref) async => <Certificate>[]),
        ],
        child: const MaterialApp(home: CertificatesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No certificates yet'), findsOneWidget);
    expect(find.text('Secure UPI payments'), findsOneWidget);
  });
}
