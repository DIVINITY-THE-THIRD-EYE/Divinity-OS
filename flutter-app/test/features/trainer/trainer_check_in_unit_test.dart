import 'package:divinity_app/features/attendance/data/attendance_repository.dart';
import 'package:divinity_app/features/attendance/domain/attendance_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(AttendanceStatus.present);
  });

  group('trainerMark', () {
    late MockAttendanceRepository mockRepo;

    setUp(() {
      mockRepo = MockAttendanceRepository();
    });

    test('calls trainerMark with correct params for PRESENT', () async {
      when(
        () => mockRepo.trainerMark(
          studentId: any(named: 'studentId'),
          batchId: any(named: 'batchId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async {});

      await mockRepo.trainerMark(
        studentId: 's-1',
        batchId: 'b-1',
        status: AttendanceStatus.present,
      );

      verify(
        () => mockRepo.trainerMark(
          studentId: 's-1',
          batchId: 'b-1',
          status: AttendanceStatus.present,
        ),
      ).called(1);
    });

    test('calls trainerMark with ON_LEAVE status', () async {
      when(
        () => mockRepo.trainerMark(
          studentId: any(named: 'studentId'),
          batchId: any(named: 'batchId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async {});

      await mockRepo.trainerMark(
        studentId: 's-2',
        batchId: 'b-1',
        status: AttendanceStatus.onLeave,
      );

      verify(
        () => mockRepo.trainerMark(
          studentId: 's-2',
          batchId: 'b-1',
          status: AttendanceStatus.onLeave,
        ),
      ).called(1);
    });
  });

  group('AttendanceStatus', () {
    test('dbValue maps correctly for trainer-relevant statuses', () {
      expect(AttendanceStatus.present.dbValue, 'PRESENT');
      expect(AttendanceStatus.absent.dbValue, 'ABSENT');
      expect(AttendanceStatus.onLeave.dbValue, 'ON_LEAVE');
    });

    test('fromString handles ON_LEAVE', () {
      expect(AttendanceStatus.fromString('ON_LEAVE'), AttendanceStatus.onLeave);
      expect(AttendanceStatus.fromString('PRESENT'), AttendanceStatus.present);
      expect(AttendanceStatus.fromString('ABSENT'), AttendanceStatus.absent);
    });
  });
}
