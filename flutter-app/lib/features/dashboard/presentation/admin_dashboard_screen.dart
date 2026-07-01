import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/presentation/auth_provider.dart' show supabaseClientProvider;
import '../../events/presentation/admin_events_screen.dart';
import '../../holidays/presentation/holidays_screen.dart';
import '../../notifications/domain/app_notification.dart' show NotificationKind;
import '../../notifications/presentation/notification_provider.dart'
    show notificationRepositoryProvider;
import '../../trainer/presentation/admin_trainers_screen.dart';
import '../domain/dashboard_stats.dart';
import 'dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardStatsProvider.future),
      child: statsAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load dashboard',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => ref.refresh(dashboardStatsProvider.future),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (stats) => _DashboardBody(stats: stats),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _QuickAccessRow(),
        const SizedBox(height: 16),
        _StatGrid(stats: stats),
        const SizedBox(height: 24),
        _ChartSection(
          title: 'Monthly Revenue',
          subtitle: 'last 6 months · ₹',
          child: _RevenueChart(data: stats.monthlyRevenue),
        ),
        const SizedBox(height: 24),
        _ChartSection(
          title: 'New Enrolments',
          subtitle: 'last 6 months',
          child: _EnrolmentChart(data: stats.monthlyEnrolments),
        ),
        const SizedBox(height: 16),
        const _AdminActionsCard(),
      ],
    );
  }
}

// ── Quick-access row (Events / Holidays) ─────────────────────────────────────

class _QuickAccessRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickTile(
            icon: Icons.celebration_outlined,
            label: 'Events',
            color: AppColors.accentViolet,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminEventsScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickTile(
            icon: Icons.event_outlined,
            label: 'Holidays',
            color: AppColors.accentGold,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HolidaysScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickTile(
            icon: Icons.badge_outlined,
            label: 'Trainers',
            color: AppColors.success,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminTrainersScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: color.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat grid ─────────────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          label: 'Total Students',
          value: '${stats.totalStudents}',
          icon: Icons.people_outline,
          color: AppColors.accentViolet,
        ),
        _StatCard(
          label: 'Active Members',
          value: '${stats.activeStudents}',
          icon: Icons.verified_outlined,
          color: AppColors.success,
        ),
        _StatCard(
          label: 'Total Revenue',
          value: stats.totalRevenueLabel,
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.accentGold,
        ),
        _StatCard(
          label: 'Pending',
          value: stats.pendingAmountLabel,
          icon: Icons.pending_actions_outlined,
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const Spacer(),
            Text(
              value,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chart section wrapper ─────────────────────────────────────────────────────

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Text(
                  subtitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Revenue bar chart ─────────────────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.data});
  final List<MonthlyValue> data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rawMax = data.isEmpty
        ? 0.0
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final chartMax = rawMax == 0 ? 10000.0 : rawMax * 1.25;

    return SizedBox(
      height: 170,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => cs.surface,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                NumberFormat.compactCurrency(
                  locale: 'en_IN',
                  symbol: '₹',
                  decimalDigits: 0,
                ).format(rod.toY),
                TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      data[idx].monthLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    NumberFormat.compactCurrency(
                      locale: 'en_IN',
                      symbol: '₹',
                      decimalDigits: 0,
                    ).format(value),
                    style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: cs.outlineVariant.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          barGroups: List.generate(
            data.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].value,
                  color: AppColors.accentGold,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Enrolment line chart ──────────────────────────────────────────────────────

class _EnrolmentChart extends StatelessWidget {
  const _EnrolmentChart({required this.data});
  final List<MonthlyValue> data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rawMax = data.isEmpty
        ? 0.0
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final chartMax = rawMax == 0 ? 10.0 : rawMax * 1.35;

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          maxY: chartMax,
          minY: 0,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => cs.surface,
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      '${s.y.toInt()} new',
                      TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      data[idx].monthLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == 0 ||
                      value == meta.max ||
                      value != value.floorToDouble()) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: cs.outlineVariant.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i].value),
              ),
              isCurved: true,
              color: AppColors.accentViolet,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.accentViolet,
                  strokeWidth: 2,
                  strokeColor: cs.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accentViolet.withValues(alpha: 0.22),
                    AppColors.accentViolet.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Admin Actions Card ────────────────────────────────────────────────────────

class _AdminActionsCard extends ConsumerStatefulWidget {
  const _AdminActionsCard();

  @override
  ConsumerState<_AdminActionsCard> createState() => _AdminActionsCardState();
}

class _AdminActionsCardState extends ConsumerState<_AdminActionsCard> {
  bool _sending = false;

  Future<void> _triggerLowStreakAlerts() async {
    setState(() => _sending = true);
    try {
      final client = ref.read(supabaseClientProvider);

      final students = await client
          .from('users')
          .select('id, name, current_streak')
          .eq('role', 'STUDENT')
          .eq('plan_status', 'ACTIVE')
          .lt('current_streak', 3);

      if (students.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active students with low streaks (< 3 days).'),
            ),
          );
        }
        return;
      }

      final repo = ref.read(notificationRepositoryProvider);
      var count = 0;

      for (final s in (students as List)) {
        final studentId = s['id'] as String;
        final name = s['name'] as String? ?? 'Student';
        final streak = s['current_streak'] as int? ?? 0;

        await repo.sendNotification(
          userId: studentId,
          kind: NotificationKind.general,
          title: '🔥 Keep up your streak, $name!',
          body: streak == 0
              ? 'You don\'t have an active streak. Join a class today to start your journey!'
              : 'Your current streak is $streak days. Show up today to keep the fire burning!',
          metadata: {'type': 'low_streak', 'streak': streak},
        );
        count++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sent low streak alert notifications to $count students.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending alerts: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Operations',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.flash_on, color: AppColors.accentGold),
                label: const Text('Send Low Streak Alerts (FCM)'),
                onPressed: _sending ? null : _triggerLowStreakAlerts,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
