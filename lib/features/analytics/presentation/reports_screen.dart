import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../notifications/domain/app_notification.dart' show NotificationKind;
import '../../notifications/presentation/notification_provider.dart' show notificationRepositoryProvider;
import '../domain/reports_data.dart';
import 'reports_export_utils.dart';
import 'reports_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _FiltersBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsDataProvider);
    final filters = ref.watch(reportsFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: Icon(
              filters.isEmpty ? Icons.filter_alt_outlined : Icons.filter_alt,
              color: filters.isEmpty ? null : AppColors.accentGold,
            ),
            tooltip: 'Filter Reports',
            onPressed: _showFilters,
          ),
          reportsAsync.maybeWhen(
            data: (data) => PopupMenuButton<String>(
              icon: const Icon(Icons.download_outlined),
              tooltip: 'Export CSV',
              onSelected: (val) async {
                try {
                  switch (val) {
                    case 'attendance':
                      await ReportsExportUtils.exportAttendance(context, data);
                    case 'revenue':
                      await ReportsExportUtils.exportRevenue(context, data);
                    case 'memberships':
                      await ReportsExportUtils.exportMemberships(context, data);
                    case 'students':
                      await ReportsExportUtils.exportStudents(context, data);
                    case 'trainers':
                      await ReportsExportUtils.exportTrainers(context, data);
                    case 'events':
                      await ReportsExportUtils.exportEvents(context, data);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'attendance', child: Text('Export Attendance')),
                const PopupMenuItem(value: 'revenue', child: Text('Export Revenue')),
                const PopupMenuItem(value: 'memberships', child: Text('Export Memberships')),
                const PopupMenuItem(value: 'students', child: Text('Export Student Demographics')),
                const PopupMenuItem(value: 'trainers', child: Text('Export Trainer Reports')),
                const PopupMenuItem(value: 'events', child: Text('Export Event Analytics')),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Attendance', icon: Icon(Icons.check_circle_outline)),
            Tab(text: 'Financials', icon: Icon(Icons.payments_outlined)),
            Tab(text: 'Memberships', icon: Icon(Icons.card_membership_outlined)),
            Tab(text: 'Trainers', icon: Icon(Icons.badge_outlined)),
            Tab(text: 'Events', icon: Icon(Icons.celebration_outlined)),
            Tab(text: 'Holidays', icon: Icon(Icons.event_outlined)),
          ],
        ),
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading reports: $e'),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => ref.refresh(reportsDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => TabBarView(
          controller: _tabController,
          children: [
            _AttendanceTab(data: data),
            _FinancialsTab(data: data),
            _MembershipsTab(data: data),
            _TrainersTab(data: data),
            _EventsTab(data: data),
            _HolidaysTab(data: data),
          ],
        ),
      ),
    );
  }
}

// ── FILTER BOTTOM SHEET ────────────────────────────────────────────────────────

class _FiltersBottomSheet extends ConsumerWidget {
  const _FiltersBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportsFilterProvider);
    final reportsAsync = ref.watch(reportsDataProvider);
    final notifier = ref.read(reportsFilterProvider.notifier);

    final df = DateFormat('yyyy-MM-dd');

    return reportsAsync.maybeWhen(
      data: (data) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      notifier.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Date Range pickers
              Text('Date Range', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: filters.startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) notifier.setStartDate(picked);
                      },
                      child: Text(filters.startDate != null ? df.format(filters.startDate!) : 'Start Date'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: filters.endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) notifier.setEndDate(picked);
                      },
                      child: Text(filters.endDate != null ? df.format(filters.endDate!) : 'End Date'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Trainer dropdown
              DropdownButtonFormField<String>(
                initialValue: filters.trainerId,
                decoration: const InputDecoration(labelText: 'Trainer'),
                items: [
                  const DropdownMenuItem(child: Text('All Trainers')),
                  ...data.trainers.map((t) => DropdownMenuItem(value: t.trainerId, child: Text(t.trainerName))),
                ],
                onChanged: (val) => notifier.setTrainerId(val),
              ),
              const SizedBox(height: 12),
              // Batch dropdown
              DropdownButtonFormField<String>(
                initialValue: filters.batchId,
                decoration: const InputDecoration(labelText: 'Batch'),
                items: [
                  const DropdownMenuItem(child: Text('All Batches')),
                  ...data.batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                ],
                onChanged: (val) => notifier.setBatchId(val),
              ),
              const SizedBox(height: 12),
              // Membership Plan
              DropdownButtonFormField<String>(
                initialValue: filters.membershipPlan,
                decoration: const InputDecoration(labelText: 'Membership Plan'),
                items: const [
                  DropdownMenuItem(child: Text('All Plans')),
                  DropdownMenuItem(value: 'Monthly Plan', child: Text('Monthly Plan')),
                  DropdownMenuItem(value: 'Quarterly Plan', child: Text('Quarterly Plan')),
                  DropdownMenuItem(value: 'Annual Plan', child: Text('Annual Plan')),
                ],
                onChanged: (val) => notifier.setMembershipPlan(val),
              ),
              const SizedBox(height: 12),
              // Student Status
              DropdownButtonFormField<String>(
                initialValue: filters.studentStatus,
                decoration: const InputDecoration(labelText: 'Student Status'),
                items: const [
                  DropdownMenuItem(child: Text('All Statuses')),
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                  DropdownMenuItem(value: 'EXPIRED', child: Text('Expired')),
                  DropdownMenuItem(value: 'UNPAID', child: Text('Unpaid')),
                  DropdownMenuItem(value: 'PAUSED', child: Text('Paused')),
                ],
                onChanged: (val) => notifier.setStudentStatus(val),
              ),
              const SizedBox(height: 12),
              // Event
              DropdownButtonFormField<String>(
                initialValue: filters.eventId,
                decoration: const InputDecoration(labelText: 'Event'),
                items: [
                  const DropdownMenuItem(child: Text('All Events')),
                  ...data.events.map((e) => DropdownMenuItem(value: e.eventId, child: Text(e.title))),
                ],
                onChanged: (val) => notifier.setEventId(val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ── ATTENDANCE TAB ─────────────────────────────────────────────────────────────

class _AttendanceTab extends ConsumerStatefulWidget {
  const _AttendanceTab({required this.data});
  final ReportsData data;

  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab> {
  bool _sendingAlert = false;

  Future<void> _alertStudent(LowAttendanceAlert alert) async {
    setState(() => _sendingAlert = true);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.sendNotification(
        userId: alert.studentId,
        kind: NotificationKind.general,
        title: '⚠️ Attendance Warning',
        body: 'Hello ${alert.studentName}, your attendance rate has dropped to ${alert.attendanceRate.toStringAsFixed(0)}%. Consistency is key in yoga and wellness. See you in the next session!',
        metadata: {'type': 'low_attendance', 'rate': alert.attendanceRate},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Warning notification sent to ${alert.studentName}.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to alert: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingAlert = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final avgRate = widget.data.attendance.studentAttendancePercentage.isEmpty
        ? 0.0
        : widget.data.attendance.studentAttendancePercentage.values.reduce((a, b) => a + b) /
            widget.data.attendance.studentAttendancePercentage.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.percent, color: AppColors.accentViolet, size: 28),
                      const SizedBox(height: 8),
                      Text('${avgRate.toStringAsFixed(1)}%', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const Text('Avg Attendance', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                      const SizedBox(height: 8),
                      Text('${widget.data.attendance.lowAttendanceAlerts.length}', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const Text('Low Attendance Alerts', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attendance Trend', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: widget.data.attendance.dailyAttendance.isEmpty
                      ? const Center(child: Text('No attendance data available'))
                      : LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  widget.data.attendance.dailyAttendance.length,
                                  (i) => FlSpot(i.toDouble(), widget.data.attendance.dailyAttendance[i].value),
                                ),
                                color: AppColors.accentViolet,
                                isCurved: true,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    final idx = val.toInt();
                                    if (idx < 0 || idx >= widget.data.attendance.dailyAttendance.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        DateFormat('dd MMM').format(widget.data.attendance.dailyAttendance[idx].date),
                                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attendance by Batch', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...widget.data.attendance.perBatchAttendance.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: tt.bodyMedium),
                              Text('${e.value.toStringAsFixed(1)}%', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: e.value / 100,
                            color: AppColors.accentViolet,
                            backgroundColor: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        if (widget.data.attendance.lowAttendanceAlerts.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Low Attendance Alerts (< 75%)', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.data.attendance.lowAttendanceAlerts.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (ctx, idx) {
                      final alert = widget.data.attendance.lowAttendanceAlerts[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(alert.studentName, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('Rate: ${alert.attendanceRate.toStringAsFixed(1)}% (${alert.attendedClasses}/${alert.totalClasses} classes)'),
                        trailing: OutlinedButton.icon(
                          onPressed: _sendingAlert ? null : () => _alertStudent(alert),
                          icon: const Icon(Icons.flash_on, size: 16),
                          label: const Text('Alert Student', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── FINANCIALS TAB ─────────────────────────────────────────────────────────────

class _FinancialsTab extends StatelessWidget {
  const _FinancialsTab({required this.data});
  final ReportsData data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final totalRev = data.revenue.dailyRevenue.fold<double>(0.0, (s, r) => s + r.value);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: AppColors.success, size: 28),
                      const SizedBox(height: 8),
                      Text('₹${totalRev.toStringAsFixed(0)}', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)),
                      const Text('Total Revenue', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.money_off, color: AppColors.error, size: 28),
                      const SizedBox(height: 8),
                      Text('₹${data.revenue.outstandingFees.toStringAsFixed(0)}', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)),
                      const Text('Outstanding Fees', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Revenue Statement', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: data.revenue.monthlyRevenue.isEmpty
                      ? const Center(child: Text('No revenue data available'))
                      : BarChart(
                          BarChartData(
                            barGroups: List.generate(
                              data.revenue.monthlyRevenue.length,
                              (i) => BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: data.revenue.monthlyRevenue[i].value,
                                    color: AppColors.success,
                                    width: 18,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ],
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    final idx = val.toInt();
                                    if (idx < 0 || idx >= data.revenue.monthlyRevenue.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        DateFormat('MMM yy').format(data.revenue.monthlyRevenue[idx].month),
                                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenue by Plan', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...data.revenue.revenueByPlan.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: tt.bodyMedium),
                          Text('₹${e.value.toStringAsFixed(0)}', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── MEMBERSHIPS TAB ─────────────────────────────────────────────────────────────

class _MembershipsTab extends StatelessWidget {
  const _MembershipsTab({required this.data});
  final ReportsData data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: [
            _MiniCard(label: 'Active', value: '${data.membership.activeMemberships}', color: AppColors.success),
            _MiniCard(label: 'Expiring', value: '${data.membership.expiringMemberships}', color: AppColors.warning),
            _MiniCard(label: 'Expired', value: '${data.membership.expiredMemberships}', color: AppColors.error),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Membership Growth', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: data.membership.membershipGrowth.isEmpty
                      ? const Center(child: Text('No membership growth data'))
                      : LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  data.membership.membershipGrowth.length,
                                  (i) => FlSpot(i.toDouble(), data.membership.membershipGrowth[i].value),
                                ),
                                color: AppColors.accentGold,
                                isCurved: true,
                                barWidth: 3,
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    final idx = val.toInt();
                                    if (idx < 0 || idx >= data.membership.membershipGrowth.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        DateFormat('MMM').format(data.membership.membershipGrowth[idx].month),
                                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gender Distribution', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...data.students.genderDistribution.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: tt.bodyMedium),
                          Text('${e.value}', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── TRAINERS TAB ───────────────────────────────────────────────────────────────

class _TrainersTab extends StatelessWidget {
  const _TrainersTab({required this.data});
  final ReportsData data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (data.trainers.isEmpty) {
      return const Center(child: Text('No trainer stats available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.trainers.length,
      itemBuilder: (ctx, idx) {
        final t = data.trainers[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.trainerName, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TrainerStatMini(label: 'Active Batches', value: '${t.activeBatchesCount}'),
                    _TrainerStatMini(label: 'Students Enrolled', value: '${t.studentCount}'),
                    _TrainerStatMini(label: 'Classes Conducted', value: '${t.classesConducted}'),
                    _TrainerStatMini(label: 'Attendance Handled', value: '${t.attendanceHandled}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrainerStatMini extends StatelessWidget {
  const _TrainerStatMini({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
      ],
    );
  }
}

// ── EVENTS TAB ─────────────────────────────────────────────────────────────────

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.data});
  final ReportsData data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (data.events.isEmpty) {
      return const Center(child: Text('No events data available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.events.length,
      itemBuilder: (ctx, idx) {
        final e = data.events[idx];
        final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(e.startsAt);
        
        final statusLabel = e.isCancelled ? 'Cancelled' : (e.isFull ? 'Full' : 'Open');
        final statusColor = e.isCancelled ? AppColors.error : (e.isFull ? AppColors.warning : AppColors.success);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(
                      label: Text(statusLabel, style: TextStyle(fontSize: 10, color: statusColor)),
                      side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
                      backgroundColor: statusColor.withValues(alpha: 0.1),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(height: 4),
                    Text('RSVP: ${e.registrationsCount}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── HOLIDAYS TAB ───────────────────────────────────────────────────────────────

class _HolidaysTab extends StatelessWidget {
  const _HolidaysTab({required this.data});
  final ReportsData data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (data.holidays.isEmpty) {
      return const Center(child: Text('No holidays registered'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.holidays.length,
      itemBuilder: (ctx, idx) {
        final h = data.holidays[idx];
        final dateStr = DateFormat('dd MMMM yyyy').format(h.date);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.event_available, color: AppColors.accentGold),
            title: Text(h.name, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(dateStr),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${h.overlapCount}', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Text('Attendance Overlaps', style: TextStyle(fontSize: 8, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── HELPER WIDGETS ─────────────────────────────────────────────────────────────

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
