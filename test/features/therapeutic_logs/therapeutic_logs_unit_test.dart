import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/therapeutic_logs/data/therapeutic_log_repository.dart';
import 'package:divinity_app/features/therapeutic_logs/domain/therapeutic_log.dart';
import 'package:divinity_app/features/therapeutic_logs/presentation/therapeutic_log_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockTherapeuticLogRepository extends Mock
    implements TherapeuticLogRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

TherapeuticLog _fakeLog({
  String id = 'log-1',
  String studentId = 'student-1',
  String? studentName = 'Arjun Patel',
  String trainerId = 'trainer-1',
  String note = 'Good progress today.',
}) => TherapeuticLog.fromMap({
  'id': id,
  'student_id': studentId,
  'trainer_id': trainerId,
  'student': {'name': studentName},
  'note': note,
  'created_at': '2026-06-16T10:00:00.000Z',
});

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── TherapeuticLog.fromMap ────────────────────────────────────────────────

  group('TherapeuticLog.fromMap', () {
    test('parses all fields', () {
      final log = _fakeLog();
      expect(log.id, 'log-1');
      expect(log.studentId, 'student-1');
      expect(log.trainerId, 'trainer-1');
      expect(log.studentName, 'Arjun Patel');
      expect(log.note, 'Good progress today.');
    });

    test('handles null trainer and student rows', () {
      final log = TherapeuticLog.fromMap({
        'id': 'log-2',
        'student_id': 'student-1',
        'trainer_id': null,
        'note': 'Note',
        'created_at': '2026-06-16T10:00:00.000Z',
      });
      expect(log.trainerId, isNull);
      expect(log.trainerName, isNull);
      expect(log.studentName, isNull);
    });

    test('dateLabel includes date and time', () {
      final log = _fakeLog();
      // Created at 10:00 UTC — local offset may vary; just check it contains a date portion
      expect(log.dateLabel, contains('16 Jun 2026'));
    });
  });

  // ── TrainerLogsNotifier ───────────────────────────────────────────────────

  group('TrainerLogsNotifier', () {
    late MockTherapeuticLogRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockTherapeuticLogRepository();
      container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue('trainer-1'),
          therapeuticLogRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads logs by trainer on build', () async {
      when(
        () => mockRepo.fetchByTrainer(any()),
      ).thenAnswer((_) async => [_fakeLog()]);

      final result = await container.read(trainerLogsProvider.future);
      expect(result.length, 1);
      expect(result.first.note, 'Good progress today.');
    });

    test('add prepends new log to list', () async {
      when(
        () => mockRepo.fetchByTrainer(any()),
      ).thenAnswer((_) async => [_fakeLog()]);
      await container.read(trainerLogsProvider.future);

      final newLog = _fakeLog(id: 'log-2', note: 'Improving stamina.');
      when(
        () => mockRepo.addLog(
          studentId: any(named: 'studentId'),
          trainerId: any(named: 'trainerId'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => newLog);

      await container
          .read(trainerLogsProvider.notifier)
          .add(studentId: 'student-1', note: 'Improving stamina.');

      final state = container.read(trainerLogsProvider).value!;
      expect(state.first.id, 'log-2');
      expect(state.length, 2);
    });

    test('remove deletes log from list', () async {
      when(
        () => mockRepo.fetchByTrainer(any()),
      ).thenAnswer((_) async => [_fakeLog()]);
      await container.read(trainerLogsProvider.future);

      when(() => mockRepo.deleteLog(any())).thenAnswer((_) async {});

      await container.read(trainerLogsProvider.notifier).remove('log-1');

      expect(container.read(trainerLogsProvider).value!, isEmpty);
    });
  });
}
