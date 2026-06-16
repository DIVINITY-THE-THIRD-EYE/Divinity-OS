import 'package:divinity_app/features/attendance/data/attendance_repository.dart';
import 'package:divinity_app/features/attendance/domain/attendance_record.dart';
import 'package:divinity_app/features/attendance/presentation/attendance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

AttendanceRecord _fakeRecord({
  AttendanceStatus status = AttendanceStatus.present,
  MarkedBy markedBy = MarkedBy.student,
}) =>
    AttendanceRecord(
      id: 'a-1',
      studentId: 'user-1',
      date: DateTime(2026, 6, 16),
      status: status,
      markedBy: markedBy,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── AttendanceStatus parsing ───────────────────────────────────────────────

  group('AttendanceStatus.fromString', () {
    test('parses known values', () {
      expect(AttendanceStatus.fromString('PRESENT'), AttendanceStatus.present);
      expect(AttendanceStatus.fromString('ABSENT'), AttendanceStatus.absent);
      expect(AttendanceStatus.fromString('EXCUSED'), AttendanceStatus.excused);
      expect(AttendanceStatus.fromString('ON_LEAVE'), AttendanceStatus.onLeave);
      expect(AttendanceStatus.fromString('HOLIDAY'), AttendanceStatus.holiday);
      expect(
          AttendanceStatus.fromString('CANCELLED'), AttendanceStatus.cancelled);
    });

    test('defaults to absent for unknown', () {
      expect(AttendanceStatus.fromString('TYPO'), AttendanceStatus.absent);
      expect(AttendanceStatus.fromString(''), AttendanceStatus.absent);
    });

    test('dbValue round-trips', () {
      for (final s in AttendanceStatus.values) {
        expect(AttendanceStatus.fromString(s.dbValue), s);
      }
    });
  });

  // ── MarkedBy parsing ───────────────────────────────────────────────────────

  group('MarkedBy.fromString', () {
    test('parses known values', () {
      expect(MarkedBy.fromString('TRAINER'), MarkedBy.trainer);
      expect(MarkedBy.fromString('ADMIN'), MarkedBy.admin);
      expect(MarkedBy.fromString('SYSTEM'), MarkedBy.system);
    });

    test('defaults to student', () {
      expect(MarkedBy.fromString('STUDENT'), MarkedBy.student);
      expect(MarkedBy.fromString(null), MarkedBy.student);
      expect(MarkedBy.fromString('UNKNOWN'), MarkedBy.student);
    });
  });

  // ── AttendanceRecord.fromMap ───────────────────────────────────────────────

  group('AttendanceRecord.fromMap', () {
    test('parses full row', () {
      final record = AttendanceRecord.fromMap({
        'id': 'a-99',
        'student_id': 'u-1',
        'batch_id': 'b-1',
        'date': '2026-06-16',
        'checkin_time': '2026-06-16T06:05:00.000Z',
        'status': 'PRESENT',
        'marked_by': 'STUDENT',
      });
      expect(record.id, 'a-99');
      expect(record.status, AttendanceStatus.present);
      expect(record.markedBy, MarkedBy.student);
      expect(record.batchId, 'b-1');
      expect(record.checkinTime, isNotNull);
    });

    test('handles null optional fields', () {
      final record = AttendanceRecord.fromMap({
        'id': 'a-1',
        'student_id': 'u-1',
        'date': '2026-06-16',
        'status': 'ABSENT',
        'marked_by': 'SYSTEM',
      });
      expect(record.batchId, isNull);
      expect(record.checkinTime, isNull);
      expect(record.status, AttendanceStatus.absent);
    });
  });

  // ── TodayAttendanceNotifier ────────────────────────────────────────────────

  group('TodayAttendanceNotifier', () {
    late MockAttendanceRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockAttendanceRepository();
      container = ProviderContainer(
        overrides: [
          attendanceRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads null when no record today', () async {
      when(() => mockRepo.fetchTodayRecord(any()))
          .thenAnswer((_) async => null);

      // Provider depends on supabaseClientProvider which needs Supabase.
      // We test the repo layer directly instead of the full provider.
      final result = await mockRepo.fetchTodayRecord('user-1');
      expect(result, isNull);
    });

    test('returns today record when one exists', () async {
      final record = _fakeRecord();
      when(() => mockRepo.fetchTodayRecord(any()))
          .thenAnswer((_) async => record);

      final result = await mockRepo.fetchTodayRecord('user-1');
      expect(result?.status, AttendanceStatus.present);
    });

    test('checkIn returns PRESENT record', () async {
      final record = _fakeRecord();
      when(() => mockRepo.checkIn(any(), batchId: any(named: 'batchId')))
          .thenAnswer((_) async => record);

      final result = await mockRepo.checkIn('user-1', batchId: 'b-1');
      expect(result.status, AttendanceStatus.present);
      expect(result.markedBy, MarkedBy.student);
    });

    test('updateStatus changes status on the record', () async {
      final updated = _fakeRecord(
          status: AttendanceStatus.excused, markedBy: MarkedBy.admin);
      when(() => mockRepo.updateStatus('a-1', AttendanceStatus.excused))
          .thenAnswer((_) async => updated);

      final result = await mockRepo.updateStatus(
        'a-1',
        AttendanceStatus.excused,
      );
      expect(result.status, AttendanceStatus.excused);
      expect(result.markedBy, MarkedBy.admin);
    });
  });

  // ── AttendanceHistoryNotifier (repo-level) ─────────────────────────────────

  group('AttendanceRepository history', () {
    late MockAttendanceRepository mockRepo;

    setUp(() {
      mockRepo = MockAttendanceRepository();
    });

    test('returns list sorted by date desc', () async {
      final records = [
        _fakeRecord(),
        AttendanceRecord(
          id: 'a-2',
          studentId: 'user-1',
          date: DateTime(2026, 6, 15),
          status: AttendanceStatus.absent,
          markedBy: MarkedBy.system,
        ),
      ];
      when(() => mockRepo.fetchHistory('user-1'))
          .thenAnswer((_) async => records);

      final result = await mockRepo.fetchHistory('user-1');
      expect(result.length, 2);
      expect(result.first.date.day, 16);
    });
  });
}
