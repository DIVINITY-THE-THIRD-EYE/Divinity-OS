import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/batches/data/batch_repository.dart';
import 'package:divinity_app/features/batches/domain/batch.dart';
import 'package:divinity_app/features/batches/presentation/batch_provider.dart';
import 'package:divinity_app/features/feedback/data/feedback_repository.dart';
import 'package:divinity_app/features/feedback/domain/student_feedback.dart';
import 'package:divinity_app/features/feedback/presentation/feedback_provider.dart';
import 'package:divinity_app/features/feedback/presentation/student_feedback_screen.dart';
import 'package:divinity_app/features/home/data/home_repository.dart';
import 'package:divinity_app/features/home/domain/home_data.dart';
import 'package:divinity_app/features/home/presentation/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}
class MockHomeRepository extends Mock implements HomeRepository {}
class MockBatchRepository extends Mock implements BatchRepository {}

void main() {
  late MockFeedbackRepository mockFeedbackRepo;
  late MockHomeRepository mockHomeRepo;
  late MockBatchRepository mockBatchRepo;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockFeedbackRepo = MockFeedbackRepository();
    mockHomeRepo = MockHomeRepository();
    mockBatchRepo = MockBatchRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('student-1'),
        feedbackRepositoryProvider.overrideWithValue(mockFeedbackRepo),
        homeRepositoryProvider.overrideWithValue(mockHomeRepo),
        batchRepositoryProvider.overrideWithValue(mockBatchRepo),
      ],
      child: const MaterialApp(
        home: StudentFeedbackScreen(),
      ),
    );
  }

  testWidgets('displays empty state when no feedback exists', (tester) async {
    when(() => mockFeedbackRepo.fetchMyFeedback('student-1'))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump();

    expect(find.text('No feedback submitted yet.'), findsOneWidget);
  });

  testWidgets('displays feedback list when items exist', (tester) async {
    final feedbackList = [
      StudentFeedback(
        id: 'fb-1',
        studentId: 'student-1',
        rating: 4,
        comments: 'Great yoga class!',
        createdAt: DateTime(2026, 6),
        batchName: 'Morning Yoga',
        trainerName: 'Guru Dev',
      ),
    ];

    when(() => mockFeedbackRepo.fetchMyFeedback('student-1'))
        .thenAnswer((_) async => feedbackList);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump();

    expect(find.text('Great yoga class!'), findsOneWidget);
    expect(find.text('Morning Yoga'), findsOneWidget);
    expect(find.text('Trainer: Guru Dev'), findsOneWidget);
  });

  testWidgets('opens submission form and submits valid feedback', (tester) async {
    when(() => mockFeedbackRepo.fetchMyFeedback('student-1'))
        .thenAnswer((_) async => []);
    when(() => mockHomeRepo.fetchHomeData('student-1')).thenAnswer(
      (_) async => HomeData(
        firstName: 'Arjun',
        streak: 5,
        upcomingClasses: [
          UpcomingClass(
            batchId: 'batch-123',
            batchName: 'Morning Yoga',
            scheduleTime: '06:00 AM',
            nextDate: DateTime(2026, 7),
            trainerName: 'Guru Dev',
          ),
        ],
        recentActivity: [],
      ),
    );
    when(() => mockBatchRepo.fetchBatches()).thenAnswer(
      (_) async => [
        Batch(
          id: 'batch-123',
          name: 'Morning Yoga',
          scheduleTime: '06:00 AM',
          daysOfWeek: ['MON', 'WED', 'FRI'],
          capacity: 15,
          status: BatchStatus.active,
          trainerId: 'trainer-999',
          createdAt: DateTime(2026, 6),
        ),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Click FAB to open bottom sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Submit Feedback'), findsNWidgets(2));

    // Select batch from dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Morning Yoga').last);
    await tester.pumpAndSettle();

    // Tap the 4th star
    await tester.tap(find.byKey(const ValueKey('star_4')));
    await tester.pumpAndSettle();

    // Fill comments
    await tester.enterText(find.byType(TextFormField), 'Amazing teacher!');
    await tester.pumpAndSettle();

    // Mock submit response
    final submittedFb = StudentFeedback(
      id: 'fb-2',
      studentId: 'student-1',
      rating: 4,
      comments: 'Amazing teacher!',
      createdAt: DateTime(2026, 7),
      batchName: 'Morning Yoga',
      trainerName: 'Guru Dev',
    );
    when(() => mockFeedbackRepo.submitFeedback(
          studentId: 'student-1',
          batchId: 'batch-123',
          rating: 4,
          comments: 'Amazing teacher!',
          trainerId: any(named: 'trainerId'),
        )).thenAnswer((_) async => submittedFb);

    // Tap submit button
    await tester.tap(find.text('Submit Feedback').last);
    await tester.pumpAndSettle();

    // Verify it is submitted and bottom sheet is closed
    expect(find.text('Submit Feedback'), findsNothing);
  });
}
