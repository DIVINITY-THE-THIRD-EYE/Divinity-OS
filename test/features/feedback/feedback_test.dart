import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/feedback/data/feedback_repository.dart';
import 'package:divinity_app/features/feedback/domain/student_feedback.dart';
import 'package:divinity_app/features/feedback/presentation/feedback_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

StudentFeedback _fakeFeedback({
  String id = 'fb-1',
  String studentId = 'student-1',
  String? studentName,
  String? trainerId,
  String? trainerName,
  String? batchId,
  String? batchName,
  int rating = 5,
  String comments = 'Awesome!',
}) =>
    StudentFeedback(
      id: id,
      studentId: studentId,
      studentName: studentName,
      trainerId: trainerId,
      trainerName: trainerName,
      batchId: batchId,
      batchName: batchName,
      rating: rating,
      comments: comments,
      createdAt: DateTime(2026, 6, 20),
    );

void main() {
  group('StudentFeedback Model', () {
    test('fromMap parses correctly with flat fields', () {
      final fb = StudentFeedback.fromMap({
        'id': 'fb-1',
        'student_id': 'stud-1',
        'trainer_id': 'train-1',
        'batch_id': 'batch-1',
        'rating': 4,
        'comments': 'Good job',
        'created_at': '2026-06-20T10:00:00Z',
      });
      expect(fb.id, 'fb-1');
      expect(fb.studentId, 'stud-1');
      expect(fb.trainerId, 'train-1');
      expect(fb.batchId, 'batch-1');
      expect(fb.rating, 4);
      expect(fb.comments, 'Good job');
      expect(fb.createdAt.year, 2026);
    });

    test('fromMap parses joins correctly', () {
      final fb = StudentFeedback.fromMap({
        'id': 'fb-1',
        'student_id': 'stud-1',
        'student': {'name': 'Arjun'},
        'trainer_id': 'train-1',
        'trainer': {'name': 'Guru'},
        'batch_id': 'batch-1',
        'batches': {'name': 'Batch Alpha'},
        'rating': 5,
        'comments': 'Excellent',
        'created_at': '2026-06-20T10:00:00Z',
      });
      expect(fb.studentName, 'Arjun');
      expect(fb.trainerName, 'Guru');
      expect(fb.batchName, 'Batch Alpha');
    });
  });

  group('MyFeedbackNotifier', () {
    late MockFeedbackRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockFeedbackRepository();
      container = ProviderContainer(
        overrides: [
          feedbackRepositoryProvider.overrideWithValue(mockRepo),
          currentUserIdProvider.overrideWithValue('student-1'),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads my feedback on build', () async {
      final list = [_fakeFeedback()];
      when(() => mockRepo.fetchMyFeedback('student-1'))
          .thenAnswer((_) async => list);

      await container.read(myFeedbackProvider.future);
      final state = container.read(myFeedbackProvider).value!;
      expect(state.length, 1);
      expect(state.first.id, 'fb-1');
    });

    test('submit adds feedback to state', () async {
      final list = [_fakeFeedback()];
      when(() => mockRepo.fetchMyFeedback('student-1'))
          .thenAnswer((_) async => list);

      await container.read(myFeedbackProvider.future);

      final created = _fakeFeedback(id: 'fb-2', rating: 4, comments: 'New feedback');
      when(() => mockRepo.submitFeedback(
            studentId: 'student-1',
            trainerId: 'train-1',
            batchId: 'batch-1',
            rating: 4,
            comments: 'New feedback',
          )).thenAnswer((_) async => created);

      await container.read(myFeedbackProvider.notifier).submit(
            trainerId: 'train-1',
            batchId: 'batch-1',
            rating: 4,
            comments: 'New feedback',
          );

      final state = container.read(myFeedbackProvider).value!;
      expect(state.length, 2);
      expect(state.first.id, 'fb-2');
    });
  });

  group('AllFeedbackNotifier', () {
    late MockFeedbackRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockFeedbackRepository();
      container = ProviderContainer(
        overrides: [
          feedbackRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads all feedback on build', () async {
      final list = [_fakeFeedback()];
      when(() => mockRepo.fetchAllFeedback()).thenAnswer((_) async => list);

      await container.read(allFeedbackProvider.future);
      final state = container.read(allFeedbackProvider).value!;
      expect(state.length, 1);
    });

    test('refresh reloads feedback list', () async {
      when(() => mockRepo.fetchAllFeedback()).thenAnswer((_) async => [_fakeFeedback()]);
      await container.read(allFeedbackProvider.future);
      expect(container.read(allFeedbackProvider).value!.length, 1);

      when(() => mockRepo.fetchAllFeedback()).thenAnswer((_) async => [
            _fakeFeedback(),
            _fakeFeedback(id: 'fb-2'),
          ]);
      await container.read(allFeedbackProvider.notifier).refresh();
      expect(container.read(allFeedbackProvider).value!.length, 2);
    });
  });

  group('BatchFeedbackNotifier', () {
    late MockFeedbackRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockFeedbackRepository();
      container = ProviderContainer(
        overrides: [
          feedbackRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads batch feedback on build', () async {
      final list = [_fakeFeedback(batchId: 'batch-1')];
      when(() => mockRepo.fetchBatchFeedback('batch-1'))
          .thenAnswer((_) async => list);

      await container.read(batchFeedbackProvider('batch-1').future);
      final state = container.read(batchFeedbackProvider('batch-1')).value!;
      expect(state.length, 1);
      expect(state.first.batchId, 'batch-1');
    });
  });
}
