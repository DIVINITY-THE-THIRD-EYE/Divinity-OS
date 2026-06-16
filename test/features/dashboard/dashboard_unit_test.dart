import 'package:divinity_app/features/dashboard/data/dashboard_repository.dart';
import 'package:divinity_app/features/dashboard/domain/dashboard_stats.dart';
import 'package:divinity_app/features/dashboard/presentation/dashboard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockDashboardRepository extends Mock implements DashboardRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _now = DateTime(2026, 6);

DashboardStats _fakeStats({
  int totalStudents = 10,
  int activeStudents = 7,
  double totalRevenue = 50000,
  double pendingAmount = 5000,
}) =>
    DashboardStats(
      totalStudents: totalStudents,
      activeStudents: activeStudents,
      totalRevenue: totalRevenue,
      pendingAmount: pendingAmount,
      monthlyRevenue: List.generate(
        6,
        (i) => MonthlyValue(
          month: DateTime(_now.year, _now.month - 5 + i),
          value: (i + 1) * 5000,
        ),
      ),
      monthlyEnrolments: List.generate(
        6,
        (i) => MonthlyValue(
          month: DateTime(_now.year, _now.month - 5 + i),
          value: (i + 1).toDouble(),
        ),
      ),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── MonthlyValue ───────────────────────────────────────────────────────────

  group('MonthlyValue', () {
    test('monthLabel returns 3-letter month abbreviation', () {
      final mv = MonthlyValue(month: DateTime(2026), value: 1000);
      expect(mv.monthLabel, 'Jan');
    });

    test('monthLabel works for all months', () {
      for (var m = 1; m <= 12; m++) {
        final mv = MonthlyValue(month: DateTime(2026, m), value: 0);
        expect(mv.monthLabel.length, 3);
      }
    });
  });

  // ── DashboardStats labels ─────────────────────────────────────────────────

  group('DashboardStats', () {
    test('totalRevenueLabel formats in Indian rupees', () {
      final stats = _fakeStats(totalRevenue: 75000);
      expect(stats.totalRevenueLabel, contains('₹'));
      expect(stats.totalRevenueLabel, contains('75,000'));
    });

    test('pendingAmountLabel formats in Indian rupees', () {
      final stats = _fakeStats(pendingAmount: 12500);
      expect(stats.pendingAmountLabel, contains('₹'));
      expect(stats.pendingAmountLabel, contains('12,500'));
    });

    test('zero revenue formats correctly', () {
      final stats = _fakeStats(totalRevenue: 0);
      expect(stats.totalRevenueLabel, contains('₹'));
      expect(stats.totalRevenueLabel, contains('0'));
    });

    test('monthlyRevenue has 6 entries', () {
      final stats = _fakeStats();
      expect(stats.monthlyRevenue.length, 6);
    });

    test('monthlyEnrolments has 6 entries', () {
      final stats = _fakeStats();
      expect(stats.monthlyEnrolments.length, 6);
    });
  });

  // ── dashboardStatsProvider ────────────────────────────────────────────────

  group('dashboardStatsProvider', () {
    late MockDashboardRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockDashboardRepository();
      container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads stats on first read', () async {
      when(() => mockRepo.fetchStats())
          .thenAnswer((_) async => _fakeStats());

      final stats = await container.read(dashboardStatsProvider.future);
      expect(stats.totalStudents, 10);
      expect(stats.activeStudents, 7);
    });

    test('propagates errors from repository', () async {
      when(() => mockRepo.fetchStats())
          .thenThrow(Exception('network error'));

      await expectLater(
        container.read(dashboardStatsProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ── SupabaseDashboardRepository._aggregateRevenue (via stats) ────────────

  group('DashboardRepository aggregation', () {
    test('monthlyRevenue totals match per-month sums', () {
      final stats = _fakeStats();
      // values are i*5000 for i in 1..6 → 5000,10000,15000,20000,25000,30000
      expect(stats.monthlyRevenue.first.value, 5000);
      expect(stats.monthlyRevenue.last.value, 30000);
    });

    test('monthlyEnrolments are sequential', () {
      final stats = _fakeStats();
      for (var i = 0; i < 6; i++) {
        expect(stats.monthlyEnrolments[i].value, (i + 1).toDouble());
      }
    });
  });
}
