import 'package:divinity_app/core/theme/app_theme.dart';
import 'package:divinity_app/features/analytics/data/reports_repository.dart';
import 'package:divinity_app/features/analytics/domain/reports_data.dart';
import 'package:divinity_app/features/analytics/presentation/reports_provider.dart';
import 'package:divinity_app/features/analytics/presentation/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReportsRepository implements ReportsRepository {
  _FakeReportsRepository(this.data);
  final ReportsData data;

  @override
  Future<ReportsData> fetchReports(ReportFilters filters) async => data;
}

ReportsData _fakeData() {
  return ReportsData(
    attendance: AttendanceReport(
      dailyAttendance: [
        DailyTrend(date: DateTime(2026, 6), value: 5),
        DailyTrend(date: DateTime(2026, 6, 2), value: 7),
      ],
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

Widget _wrap(Widget child, {required ReportsRepository repo}) {
  return ProviderScope(
    overrides: [
      reportsRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(theme: AppTheme.dark(), home: child),
  );
}

void main() {
  testWidgets('ReportsScreen renders tabs and metrics', (tester) async {
    // Set screen size larger to avoid rendering/clipping limitations
    tester.view.physicalSize = const Size(1200, 1024);
    tester.view.devicePixelRatio = 1.0;

    final fakeRepo = _FakeReportsRepository(_fakeData());
    await tester.pumpWidget(_wrap(const ReportsScreen(), repo: fakeRepo));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Reports & Analytics'), findsOneWidget);

    // Verify Tabs are present
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Financials'), findsOneWidget);
    expect(find.text('Memberships'), findsOneWidget);

    // Verify Metric on Attendance Tab
    expect(find.text('80.0%'), findsOneWidget); // student X rate
    expect(find.text('Student Low'), findsOneWidget);
  });

  testWidgets('ReportsScreen tab switching shows correct contents', (tester) async {
    final fakeRepo = _FakeReportsRepository(_fakeData());
    await tester.pumpWidget(_wrap(const ReportsScreen(), repo: fakeRepo));
    await tester.pumpAndSettle();

    // Switch to Financials Tab
    await tester.tap(find.text('Financials'));
    await tester.pumpAndSettle();

    // Verify outstanding fees is displayed
    expect(find.text('₹2000'), findsOneWidget);
    expect(find.text('Monthly Revenue Statement'), findsOneWidget);
  });
}
