import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/analytics_service.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../attendance/domain/attendance_record.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../batches/domain/batch.dart';
import '../../batches/domain/enrollment.dart';
import '../../batches/presentation/enrollment_provider.dart';

// ── Merged view model ─────────────────────────────────────────────────────────

class _StudentRow {
  _StudentRow({
    required this.studentId,
    required this.studentName,
    this.studentPhone,
    this.attendanceId,
    required this.status,
  });

  final String studentId;
  final String studentName;
  final String? studentPhone;
  final String? attendanceId;
  AttendanceStatus status;
}

// ── Provider: today's attendance map keyed by studentId ──────────────────────

final _todayAttendanceMapProvider =
    FutureProvider.family<Map<String, Map<String, dynamic>>, String>(
  (ref, batchId) async {
    final repo = SupabaseAttendanceRepository(
      ref.watch(supabaseClientProvider),
    );
    final records = await repo.fetchBatchAttendanceToday(batchId);
    return {
      for (final r in records) r['student_id'] as String: r,
    };
  },
);

// ── Screen ────────────────────────────────────────────────────────────────────

class TrainerCheckInScreen extends ConsumerStatefulWidget {
  const TrainerCheckInScreen({super.key, required this.batch});

  final Batch batch;

  @override
  ConsumerState<TrainerCheckInScreen> createState() =>
      _TrainerCheckInScreenState();
}

class _TrainerCheckInScreenState
    extends ConsumerState<TrainerCheckInScreen> {
  // Local optimistic state: studentId → status (nullable = not yet set)
  final Map<String, AttendanceStatus?> _optimistic = {};
  final Set<String> _saving = {};

  Future<void> _mark(
    String studentId,
    AttendanceStatus status,
    String batchId,
  ) async {
    setState(() {
      _optimistic[studentId] = status;
      _saving.add(studentId);
    });
    try {
      final repo = SupabaseAttendanceRepository(
        ref.read(supabaseClientProvider),
      );
      await repo.trainerMark(
        studentId: studentId,
        batchId: batchId,
        status: status,
      );
      unawaited(AnalyticsService.logTrainerMarkAttendance(
        batchId: batchId,
        status: status.dbValue,
      ));
      // Invalidate the attendance map so next open is fresh.
      ref.invalidate(_todayAttendanceMapProvider(batchId));
    } catch (e) {
      // Roll back optimistic update
      setState(() => _optimistic.remove(studentId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(studentId));
    }
  }

  List<_StudentRow> _mergeRows(
    List<Enrollment> enrolled,
    Map<String, Map<String, dynamic>> todayMap,
  ) {
    return enrolled.map((e) {
      final att = todayMap[e.studentId];
      final statusStr =
          att?['status'] as String? ?? 'ABSENT';
      final current = _optimistic[e.studentId] ??
          AttendanceStatus.fromString(statusStr);
      return _StudentRow(
        studentId: e.studentId,
        studentName: e.studentName,
        studentPhone: e.studentPhone,
        attendanceId: att?['id'] as String?,
        status: current,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final batchId = widget.batch.id;
    final enrolledAsync = ref.watch(batchEnrollmentsProvider(batchId));
    final todayAsync =
        ref.watch(_todayAttendanceMapProvider(batchId));
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.batch.name),
            Text(
              "Today's Check-In",
              style: tt.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
      body: enrolledAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (enrolled) {
          if (enrolled.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64,
                      color: AppColors.accentViolet.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No students enrolled', style: tt.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Enrol students from the Admin Batches screen.',
                    style: tt.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return todayAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (todayMap) {
              final rows = _mergeRows(enrolled, todayMap);
              final present =
                  rows.where((r) => r.status == AttendanceStatus.present).length;
              final onLeave =
                  rows.where((r) => r.status == AttendanceStatus.onLeave).length;
              final absent = rows.length - present - onLeave;

              return Column(
                children: [
                  _SummaryBar(
                    present: present,
                    absent: absent,
                    onLeave: onLeave,
                    total: rows.length,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, i) => _StudentTile(
                        row: rows[i],
                        isSaving: _saving.contains(rows[i].studentId),
                        onMark: (s) =>
                            _mark(rows[i].studentId, s, batchId),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.present,
    required this.absent,
    required this.onLeave,
    required this.total,
  });

  final int present;
  final int absent;
  final int onLeave;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _Pill(label: 'Present', value: present, color: Colors.green),
          const SizedBox(width: 8),
          _Pill(label: 'Absent', value: absent, color: Colors.red),
          const SizedBox(width: 8),
          _Pill(label: 'Leave', value: onLeave, color: Colors.orange),
          const Spacer(),
          Text('$total total',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$value $label',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color),
      ),
    );
  }
}

// ── Student tile ──────────────────────────────────────────────────────────────

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    required this.row,
    required this.isSaving,
    required this.onMark,
  });

  final _StudentRow row;
  final bool isSaving;
  final ValueChanged<AttendanceStatus> onMark;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(row.status);

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Text(
              row.studentName[0].toUpperCase(),
              style: TextStyle(color: statusColor),
            ),
          ),
          if (isSaving)
            const Positioned.fill(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      title: Text(row.studentName),
      subtitle: row.studentPhone != null ? Text(row.studentPhone!) : null,
      trailing: isSaving
          ? const SizedBox(
              width: 80,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MarkButton(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  active: row.status == AttendanceStatus.present,
                  tooltip: 'Present',
                  onTap: () => onMark(AttendanceStatus.present),
                ),
                _MarkButton(
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                  active: row.status == AttendanceStatus.absent,
                  tooltip: 'Absent',
                  onTap: () => onMark(AttendanceStatus.absent),
                ),
                _MarkButton(
                  icon: Icons.event_busy_outlined,
                  color: Colors.orange,
                  active: row.status == AttendanceStatus.onLeave,
                  tooltip: 'On Leave',
                  onTap: () => onMark(AttendanceStatus.onLeave),
                ),
              ],
            ),
    );
  }

  Color _statusColor(AttendanceStatus s) => switch (s) {
        AttendanceStatus.present => Colors.green,
        AttendanceStatus.onLeave => Colors.orange,
        _ => Colors.red,
      };
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.icon,
    required this.color,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: active ? color : Colors.grey.withValues(alpha: 0.5),
        size: 22,
      ),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

// Silence the unawaited future lint for fire-and-forget analytics.
void unawaited(Future<void> future) {}
