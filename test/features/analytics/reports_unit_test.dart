import 'package:divinity_app/features/analytics/data/reports_repository.dart';
import 'package:divinity_app/features/analytics/domain/reports_data.dart';
import 'package:divinity_app/features/analytics/presentation/reports_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

ReportsData _fakeReportsData() {
  return ReportsData(
    attendance: AttendanceReport(
      dailyAttendance: [DailyTrend(date: DateTime(2026, 6), value: 5)],
      monthlyAttendance: [MonthlyTrend(month: DateTime(2026, 6), value: 100)],
      perBatchAttendance: {'Morning Yoga': 85.0},
      perTrainerAttendance: {'Trainer A': 90.0},
      studentAttendancePercentage: {'Student X': 80.0},
      lowAttendanceAlerts: [
        const LowAttendanceAlert(
          studentId: 'student_1',
          studentName: 'Student Low',
          attendanceRate: 60.0,
          totalClasses: 10,
          attendedClasses: 6,
        )
      ],
    ),
    revenue: RevenueReport(
      dailyRevenue: [DailyTrend(date: DateTime(2026, 6), value: 1500)],
      monthlyRevenue: [MonthlyTrend(month: DateTime(2026, 6), value: 45000)],
      yearlyRevenue: [MonthlyTrend(month: DateTime(2026), value: 500000)],
      outstandingFees: 2000.0,
      paidCount: 15,
      unpaidCount: 2,
      membershipSales: {'Monthly Plan': 10},
      revenueByPlan: {'Monthly Plan': 15000.0},
    ),
    membership: MembershipReport(
      activeMemberships: 15,
      expiringMemberships: 3,
      expiredMemberships: 5,
      renewals: 4,
      newRegistrations: 2,
      membershipGrowth: [MonthlyTrend(month: DateTime(2026, 6), value: 15)],
    ),
    students: StudentReport(
      totalStudents: 20,
      activeStudents: 15,
      inactiveStudents: 5,
      newStudents: 2,
      studentGrowth: [MonthlyTrend(month: DateTime(2026, 6), value: 20)],
      genderDistribution: {'MALE': 10, 'FEMALE': 10},
    ),
    trainers: [
      const TrainerReportItem(
        trainerId: 'trainer_1',
        trainerName: 'Trainer A',
        classesConducted: 20,
        attendanceHandled: 150,
        activeBatchesCount: 2,
        studentCount: 12,
      )
    ],
    events: [
      EventReportItem(
        eventId: 'event_1',
        title: 'Meditation Workshop',
        startsAt: DateTime(2026, 7, 10),
        registrationsCount: 15,
        attendanceCount: 15,
        isFull: false,
        isCancelled: false,
      )
    ],
    holidays: [
      HolidayReportItem(
        holidayId: 'holiday_1',
        name: 'Independence Day',
        date: DateTime(2026, 8, 15),
        overlapCount: 0,
      )
    ],
    batches: [
      const BatchReportItem(id: 'batch_1', name: 'Morning Yoga'),
    ],
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ReportFilters());
  });

  group('ReportFilters', () {
    test('copyWith updates filters correctly', () {
      var filters = const ReportFilters();
      expect(filters.isEmpty, true);

      filters = filters.copyWith(
        startDate: () => DateTime(2026, 6),
        trainerId: () => 'trainer_123',
      );

      expect(filters.isEmpty, false);
      expect(filters.startDate, DateTime(2026, 6));
      expect(filters.trainerId, 'trainer_123');
      expect(filters.batchId, null);
    });

    test('clear resets filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(reportsFilterProvider.notifier);
      notifier.setTrainerId('trainer_1');
      notifier.setBatchId('batch_1');

      expect(container.read(reportsFilterProvider).trainerId, 'trainer_1');
      expect(container.read(reportsFilterProvider).batchId, 'batch_1');

      notifier.clear();
      expect(container.read(reportsFilterProvider).trainerId, null);
      expect(container.read(reportsFilterProvider).batchId, null);
    });
  });

  group('reportsDataProvider', () {
    late MockReportsRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockReportsRepository();
      container = ProviderContainer(
        overrides: [
          reportsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads reports data successfully', () async {
      final fakeData = _fakeReportsData();
      when(() => mockRepo.fetchReports(any())).thenAnswer((_) async => fakeData);

      final data = await container.read(reportsDataProvider.future);
      expect(data.attendance.perBatchAttendance['Morning Yoga'], 85.0);
      expect(data.revenue.outstandingFees, 2000.0);
      expect(data.trainers.first.trainerName, 'Trainer A');
      expect(data.batches.first.name, 'Morning Yoga');
    });

    test('propagates errors from repository', () async {
      when(() => mockRepo.fetchReports(any())).thenThrow(Exception('database error'));

      await expectLater(
        container.read(reportsDataProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
