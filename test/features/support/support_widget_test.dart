import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/support/data/support_repository.dart';
import 'package:divinity_app/features/support/domain/support_ticket.dart';
import 'package:divinity_app/features/support/presentation/student_support_screen.dart';
import 'package:divinity_app/features/support/presentation/support_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupportRepository extends Mock implements SupportRepository {}

void main() {
  late MockSupportRepository mockSupportRepo;

  setUpAll(() {
    registerFallbackValue(SupportTicketStatus.open);
  });

  setUp(() {
    mockSupportRepo = MockSupportRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('student-1'),
        supportRepositoryProvider.overrideWithValue(mockSupportRepo),
      ],
      child: const MaterialApp(
        home: StudentSupportScreen(),
      ),
    );
  }

  testWidgets('displays empty state when no tickets exist', (tester) async {
    when(() => mockSupportRepo.fetchMyTickets('student-1'))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump();

    expect(find.text('No support tickets created yet.'), findsOneWidget);
  });

  testWidgets('displays support ticket list and status chips when tickets exist', (tester) async {
    final ticketsList = [
      SupportTicket(
        id: 'tkt-1',
        studentId: 'student-1',
        subject: 'Payment failed',
        description: 'UPI transaction got declined twice.',
        status: SupportTicketStatus.open,
        createdAt: DateTime(2026, 6),
      ),
      SupportTicket(
        id: 'tkt-2',
        studentId: 'student-1',
        subject: 'App crash',
        description: 'App freezes on check-in screen.',
        status: SupportTicketStatus.resolved,
        createdAt: DateTime(2026, 6),
      ),
    ];

    when(() => mockSupportRepo.fetchMyTickets('student-1'))
        .thenAnswer((_) async => ticketsList);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump();

    expect(find.text('Payment failed'), findsOneWidget);
    expect(find.text('UPI transaction got declined twice.'), findsOneWidget);
    expect(find.text('App crash'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
  });

  testWidgets('opens creation dialog, validates, and creates a support ticket', (tester) async {
    when(() => mockSupportRepo.fetchMyTickets('student-1'))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Click FAB to open creation dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Support Ticket'), findsOneWidget);

    // Try submitting empty values to trigger validation
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Subject cannot be empty'), findsOneWidget);
    expect(find.text('Description cannot be empty'), findsOneWidget);

    // Enter short values to trigger min length validation
    await tester.enterText(find.byType(TextFormField).first, 'Bad');
    await tester.enterText(find.byType(TextFormField).last, 'Short');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Subject must be at least 5 characters'), findsOneWidget);
    expect(find.text('Description must be at least 10 characters'), findsOneWidget);

    // Enter valid values
    await tester.enterText(find.byType(TextFormField).first, 'Payment issue');
    await tester.enterText(find.byType(TextFormField).last, 'UPI payment transaction failed.');
    await tester.pumpAndSettle();

    final createdTicket = SupportTicket(
      id: 'tkt-3',
      studentId: 'student-1',
      subject: 'Payment issue',
      description: 'UPI payment transaction failed.',
      status: SupportTicketStatus.open,
      createdAt: DateTime(2026, 7),
    );

    when(() => mockSupportRepo.createTicket(
          studentId: 'student-1',
          subject: 'Payment issue',
          description: 'UPI payment transaction failed.',
        )).thenAnswer((_) async => createdTicket);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Check dialog is closed
    expect(find.text('Create Support Ticket'), findsNothing);
  });
}
