import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/dashboard_stats.dart';

abstract interface class DashboardRepository {
  Future<DashboardStats> fetchStats();
}

class SupabaseDashboardRepository implements DashboardRepository {
  SupabaseDashboardRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<DashboardStats> fetchStats() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5);

    final results = await Future.wait([
      _client
          .from('payments')
          .select('amount, paid_at')
          .eq('status', 'PAID')
          .gte('paid_at', sixMonthsAgo.toIso8601String()),
      _client
          .from('users')
          .select('plan_status, created_at')
          .eq('role', 'STUDENT'),
      _client.from('payments').select('amount').eq('status', 'PENDING'),
    ]);

    final paymentRows = results[0] as List<dynamic>;
    final studentRows = results[1] as List<dynamic>;
    final pendingRows = results[2] as List<dynamic>;

    return DashboardStats(
      totalStudents: studentRows.length,
      activeStudents:
          studentRows.where((r) => r['plan_status'] == 'ACTIVE').length,
      totalRevenue: paymentRows.fold<double>(
        0,
        (s, r) => s + (r['amount'] as num).toDouble(),
      ),
      pendingAmount: pendingRows.fold<double>(
        0,
        (s, r) => s + (r['amount'] as num).toDouble(),
      ),
      monthlyRevenue: _aggregateRevenue(paymentRows, now),
      monthlyEnrolments: _aggregateEnrolments(studentRows, now),
    );
  }

  List<MonthlyValue> _aggregateRevenue(List<dynamic> rows, DateTime now) =>
      List.generate(6, (i) {
        final month = DateTime(now.year, now.month - 5 + i);
        final total = rows
            .where((r) {
              final d = DateTime.parse(r['paid_at'] as String);
              return d.year == month.year && d.month == month.month;
            })
            .fold<double>(0, (s, r) => s + (r['amount'] as num).toDouble());
        return MonthlyValue(month: month, value: total);
      });

  List<MonthlyValue> _aggregateEnrolments(List<dynamic> rows, DateTime now) =>
      List.generate(6, (i) {
        final month = DateTime(now.year, now.month - 5 + i);
        final count = rows.where((r) {
          final d = DateTime.parse(r['created_at'] as String);
          return d.year == month.year && d.month == month.month;
        }).length;
        return MonthlyValue(month: month, value: count.toDouble());
      });
}
