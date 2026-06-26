import 'package:divinity_app/features/transformation/data/transformation_repository.dart';
import 'package:divinity_app/features/transformation/domain/transformation_score.dart';
import 'package:divinity_app/features/transformation/presentation/transformation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockTransformationRepository extends Mock implements TransformationRepository {}

// ── Helpers ──────────────────────────────────────────────────────────────────

TransformationScore _fakeScore({
  String id = 'ts-1',
  String studentId = 'student-1',
  double consistency = 8.0,
  double intensity = 7.5,
  double mindfulness = 9.0,
  double recovery = 8.5,
  double score = 8.25,
}) =>
    TransformationScore(
      id: id,
      studentId: studentId,
      recordedBy: 'trainer-1',
      consistency: consistency,
      intensity: intensity,
      mindfulness: mindfulness,
      recovery: recovery,
      score: score,
      weekStartDate: DateTime(2026, 6, 15),
      createdAt: DateTime(2026, 6, 15, 12),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(_fakeScore());
  });

  group('TransformationScore.fromMap', () {
    test('parses correctly', () {
      final ts = TransformationScore.fromMap({
        'id': 'ts-99',
        'student_id': 'student-123',
        'recorded_by': 'trainer-456',
        'consistency': 9.0,
        'intensity': 8.5,
        'mindfulness': 7.0,
        'recovery': 8.0,
        'score': 8.125,
        'week_start_date': '2026-06-15',
        'created_at': '2026-06-15T12:00:00.000Z',
      });

      expect(ts.id, 'ts-99');
      expect(ts.studentId, 'student-123');
      expect(ts.recordedBy, 'trainer-456');
      expect(ts.consistency, 9.0);
      expect(ts.intensity, 8.5);
      expect(ts.mindfulness, 7.0);
      expect(ts.recovery, 8.0);
      expect(ts.score, 8.125);
      expect(ts.weekStartDate.year, 2026);
      expect(ts.weekStartDate.month, 6);
      expect(ts.weekStartDate.day, 15);
    });

    test('handles null or missing optional fields', () {
      final ts = TransformationScore.fromMap({
        'student_id': 'student-1',
        'consistency': 5,
        'intensity': 6.0,
        'mindfulness': 7,
        'recovery': 8,
        'score': 6.5,
        'week_start_date': '2026-06-15',
      });

      expect(ts.id, '');
      expect(ts.recordedBy, isNull);
      expect(ts.createdAt, isNull);
      expect(ts.consistency, 5.0);
    });
  });

  group('TransformationScore.toMap', () {
    test('serializes correctly', () {
      final ts = _fakeScore();
      final map = ts.toMap();

      expect(map['id'], 'ts-1');
      expect(map['student_id'], 'student-1');
      expect(map['recorded_by'], 'trainer-1');
      expect(map['consistency'], 8.0);
      expect(map['intensity'], 7.5);
      expect(map['mindfulness'], 9.0);
      expect(map['recovery'], 8.5);
      expect(map['score'], 8.25);
      expect(map['week_start_date'], '2026-06-15');
    });
  });

  group('RecordScoreNotifier', () {
    late MockTransformationRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockTransformationRepository();
      container = ProviderContainer(
        overrides: [
          transformationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('saveScore invokes setWeeklyScore on repository', () async {
      final score = _fakeScore();
      when(() => mockRepo.setWeeklyScore(any())).thenAnswer((_) async => {});

      await container
          .read(recordScoreNotifierProvider.notifier)
          .saveScore(score);

      verify(() => mockRepo.setWeeklyScore(score)).called(1);
    });
  });
}
