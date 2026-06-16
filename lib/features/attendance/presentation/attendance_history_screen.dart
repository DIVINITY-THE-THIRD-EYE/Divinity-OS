import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/attendance_record.dart';
import 'attendance_provider.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(attendanceHistoryProvider);
    return historyAsync.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) {
        if (records.isEmpty) {
          return const Center(child: Text('No attendance records yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: records.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (ctx, i) => buildTile(ctx, records[i]),
        );
      },
    );
  }

  static Widget buildTile(BuildContext context, AttendanceRecord record) {
    final color = _statusColor(record.status);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(_statusIcon(record.status), color: color, size: 20),
      ),
      title: Text(record.dateLabel),
      subtitle: Text(record.markedBy == MarkedBy.student
          ? 'Self check-in'
          : 'Marked by ${record.markedBy.name}'),
      trailing: Chip(
        label: Text(record.status.label, style: const TextStyle(fontSize: 11)),
        backgroundColor: color.withValues(alpha: 0.12),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  static Color _statusColor(AttendanceStatus s) => switch (s) {
        AttendanceStatus.present => Colors.green,
        AttendanceStatus.absent => Colors.red,
        AttendanceStatus.excused => Colors.orange,
        AttendanceStatus.onLeave => Colors.blue,
        AttendanceStatus.holiday => Colors.purple,
        AttendanceStatus.cancelled => Colors.grey,
      };

  static IconData _statusIcon(AttendanceStatus s) => switch (s) {
        AttendanceStatus.present => Icons.check_circle_outline,
        AttendanceStatus.absent => Icons.cancel_outlined,
        AttendanceStatus.excused => Icons.info_outline,
        AttendanceStatus.onLeave => Icons.beach_access_outlined,
        AttendanceStatus.holiday => Icons.celebration_outlined,
        AttendanceStatus.cancelled => Icons.do_not_disturb_outlined,
      };
}
