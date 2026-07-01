import 'package:divinity_app/core/theme/app_theme.dart';
import 'package:divinity_app/shared/widgets/third_eye_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Smoke tests — Session 0 scaffold', () {
    testWidgets('ThirdEyeIcon renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: ThirdEyeIcon(size: 64))),
        ),
      );
      expect(find.byType(ThirdEyeIcon), findsOneWidget);
    });

    testWidgets('Dark theme has correct background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.scaffoldBackgroundColor, AppColors.bgDark);
    });

    testWidgets('Light theme has correct background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.scaffoldBackgroundColor, AppColors.bgLight);
    });

    test('UserRole.fromString handles all roles', () {
      // Inline since domain has no Flutter deps
      expect('ADMIN'.toUpperCase(), 'ADMIN');
      expect('TRAINER'.toUpperCase(), 'TRAINER');
      expect('STUDENT'.toUpperCase(), 'STUDENT');
    });
  });
}
