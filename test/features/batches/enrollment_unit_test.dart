import 'package:divinity_app/features/batches/data/enrollment_repository.dart';
import 'package:divinity_app/features/batches/domain/enrollment.dart';
import 'package:divinity_app/features/batches/presentation/enrollment_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockEnrollmentRepository extends Mock implements EnrollmentRepository {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Enrollment _fakeEnrollment({
  String id = 'e-1',
  String studentId = 's-1',
  String studentName = 'Alice',
  String batchId = 'b-1',
}) =>
    Enrollment(
      id: id,
      studentId: studentId,
      studentName: studentName,
      batchId: batchId,
      assignedAt: DateTime(2026),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Enrollment.fromMap', () {
    test('parses correctly with nested user', () {
      final e = Enrollment.fromMap({
        'id': 'e-99',
        'student_id': 's-99',
        'batch_id': 'b-99',
        'assigned_at': '2026-01-01T00:00:00.000Z',
        'users': {
          'id': 's-99',
          'name': 'Bob',
          'phone': '+911234567890',
          'email': 'bob@example.com',
        },
      });

      expect(e.id, 'e-99');
      expect(e.studentId, 's-99');
      expect(e.studentName, 'Bob');
      expect(e.studentPhone, '+911234567890');
      expect(e.batchId, 'b-99');
    });

    test('handles missing users gracefully', () {
      final e = Enrollment.fromMap({
        'id': 'e-1',
        'student_id': 's-1',
        'batch_id': 'b-1',
        'assigned_at': '2026-06-01T00:00:00.000Z',
      });

      expect(e.studentName, 'Unnamed');
      expect(e.studentPhone, isNull);
    });
  });

  group('EnrollmentNotifier', () {
    late MockEnrollmentRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockEnrollmentRepository();
      container = ProviderContainer(
        overrides: [
          enrollmentRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads enrollments for batch on build', () async {
      final enrollments = [
        _fakeEnrollment(),
        _fakeEnrollment(id: 'e-2', studentName: 'Charlie'),
      ];
      when(() => mockRepo.fetchByBatch('b-1'))
          .thenAnswer((_) async => enrollments);

      final state =
          await container.read(batchEnrollmentsProvider('b-1').future);
      expect(state.length, 2);
      expect(state.first.studentName, 'Alice');
    });

    test('unenroll removes from list optimistically', () async {
      final enrollments = [
        _fakeEnrollment(),
        _fakeEnrollment(id: 'e-2', studentId: 's-2', studentName: 'Charlie'),
      ];
      when(() => mockRepo.fetchByBatch('b-1'))
          .thenAnswer((_) async => enrollments);
      await container.read(batchEnrollmentsProvider('b-1').future);

      when(() => mockRepo.unenroll('e-1'))
          .thenAnswer((_) async {});

      await container
          .read(batchEnrollmentsProvider('b-1').notifier)
          .unenroll('e-1');

      final updated =
          container.read(batchEnrollmentsProvider('b-1')).value!;
      expect(updated.length, 1);
      expect(updated.first.studentName, 'Charlie');
    });
  });
}
