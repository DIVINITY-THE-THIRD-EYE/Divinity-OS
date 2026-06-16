import 'package:divinity_app/features/leave/data/leave_repository.dart';
import 'package:divinity_app/features/leave/domain/leave_request.dart';
import 'package:divinity_app/features/leave/presentation/leave_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockLeaveRepository extends Mock implements LeaveRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

LeaveRequest _fakeRequest({
  String id = 'lr-1',
  LeaveStatus status = LeaveStatus.pending,
  String? studentName,
}) =>
    LeaveRequest(
      id: id,
      studentId: 'user-1',
      studentName: studentName,
      startDate: DateTime(2026, 6, 20),
      endDate: DateTime(2026, 6, 22),
      reason: 'Family event',
      status: status,
      createdAt: DateTime(2026, 6, 16),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(LeaveStatus.pending);
  });

  // ── LeaveStatus parsing ────────────────────────────────────────────────────

  group('LeaveStatus.fromString', () {
    test('parses known values', () {
      expect(LeaveStatus.fromString('PENDING'), LeaveStatus.pending);
      expect(LeaveStatus.fromString('APPROVED'), LeaveStatus.approved);
      expect(LeaveStatus.fromString('REJECTED'), LeaveStatus.rejected);
    });

    test('defaults to pending for unknown', () {
      expect(LeaveStatus.fromString('TYPO'), LeaveStatus.pending);
      expect(LeaveStatus.fromString(''), LeaveStatus.pending);
    });

    test('dbValue round-trips', () {
      for (final s in LeaveStatus.values) {
        expect(LeaveStatus.fromString(s.dbValue), s);
      }
    });
  });

  // ── LeaveRequest model ─────────────────────────────────────────────────────

  group('LeaveRequest', () {
    test('durationDays calculates correctly', () {
      final req = _fakeRequest();
      expect(req.durationDays, 3); // 20–22 = 3 days
    });

    test('dateRangeLabel formats correctly', () {
      final req = _fakeRequest();
      expect(req.dateRangeLabel, '20 Jun – 22 Jun');
    });

    test('fromMap parses correctly', () {
      final req = LeaveRequest.fromMap({
        'id': 'lr-99',
        'student_id': 'u-1',
        'start_date': '2026-07-01',
        'end_date': '2026-07-03',
        'reason': 'Vacation',
        'status': 'APPROVED',
        'approved_by': 'admin-1',
        'created_at': '2026-06-16T00:00:00.000Z',
      });
      expect(req.id, 'lr-99');
      expect(req.status, LeaveStatus.approved);
      expect(req.durationDays, 3);
      expect(req.reason, 'Vacation');
    });

    test('fromMap parses student name from joined users row', () {
      final req = LeaveRequest.fromMap({
        'id': 'lr-1',
        'student_id': 'u-1',
        'users': {'id': 'u-1', 'name': 'Arjun Sharma'},
        'start_date': '2026-06-20',
        'end_date': '2026-06-20',
        'status': 'PENDING',
        'created_at': '2026-06-16T00:00:00.000Z',
      });
      expect(req.studentName, 'Arjun Sharma');
    });

    test('fromMap handles null optional fields', () {
      final req = LeaveRequest.fromMap({
        'id': 'lr-1',
        'student_id': 'u-1',
        'start_date': '2026-06-20',
        'end_date': '2026-06-20',
        'status': 'PENDING',
        'created_at': '2026-06-16T00:00:00.000Z',
      });
      expect(req.reason, isNull);
      expect(req.approvedBy, isNull);
      expect(req.studentName, isNull);
    });
  });

  // ── PendingLeaveNotifier ───────────────────────────────────────────────────

  group('PendingLeaveNotifier', () {
    late MockLeaveRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockLeaveRepository();
      container = ProviderContainer(
        overrides: [
          leaveRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('approve updates request status to approved', () async {
      final pending = [_fakeRequest()];
      when(() => mockRepo.fetchPendingRequests())
          .thenAnswer((_) async => pending);
      await container.read(pendingLeaveProvider.future);

      final approved = _fakeRequest(status: LeaveStatus.approved);
      when(() => mockRepo.updateStatus(any(), any(), any()))
          .thenAnswer((_) async => approved);

      await container.read(pendingLeaveProvider.notifier).approve('lr-1', approvedBy: 'admin-1');

      final state = container.read(pendingLeaveProvider).value!;
      expect(state.first.status, LeaveStatus.approved);
    });

    test('reject updates request status to rejected', () async {
      final pending = [_fakeRequest()];
      when(() => mockRepo.fetchPendingRequests())
          .thenAnswer((_) async => pending);
      await container.read(pendingLeaveProvider.future);

      final rejected = _fakeRequest(status: LeaveStatus.rejected);
      when(() => mockRepo.updateStatus(any(), any(), any()))
          .thenAnswer((_) async => rejected);

      await container.read(pendingLeaveProvider.notifier).reject('lr-1', approvedBy: 'admin-1');

      final state = container.read(pendingLeaveProvider).value!;
      expect(state.first.status, LeaveStatus.rejected);
    });

    test('refresh reloads list', () async {
      when(() => mockRepo.fetchPendingRequests())
          .thenAnswer((_) async => [_fakeRequest()]);
      await container.read(pendingLeaveProvider.future);
      expect(container.read(pendingLeaveProvider).value!.length, 1);

      when(() => mockRepo.fetchPendingRequests()).thenAnswer((_) async => [
            _fakeRequest(),
            _fakeRequest(id: 'lr-2'),
          ]);
      await container.read(pendingLeaveProvider.notifier).refresh();
      expect(container.read(pendingLeaveProvider).value!.length, 2);
    });
  });

  // ── MyLeaveNotifier ────────────────────────────────────────────────────────

  group('LeaveRepository.submitRequest', () {
    late MockLeaveRepository mockRepo;

    setUp(() {
      mockRepo = MockLeaveRepository();
    });

    test('submit returns new request', () async {
      final created = _fakeRequest();
      when(() => mockRepo.submitRequest(
            studentId: any(named: 'studentId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => created);

      final result = await mockRepo.submitRequest(
        studentId: 'user-1',
        startDate: DateTime(2026, 6, 20),
        endDate: DateTime(2026, 6, 22),
      );
      expect(result.id, 'lr-1');
      expect(result.status, LeaveStatus.pending);
    });
  });
}
