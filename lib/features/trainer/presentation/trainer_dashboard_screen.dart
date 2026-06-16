import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../attendance/domain/attendance_record.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../batches/domain/batch.dart';
import '../../batches/presentation/batch_provider.dart';

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);
    final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final tt = Theme.of(context).textTheme;

    return batchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (batches) {
        // Filter to only this trainer's batches.
        final myBatches = uid == null
            ? batches
            : batches.where((b) => b.trainerId == uid).toList();

        if (myBatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups_outlined,
                    size: 64,
                    color: AppColors.accentViolet.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text('No batches assigned', style: tt.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Contact admin to assign batches to you.',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: myBatches.length,
          itemBuilder: (ctx, i) =>
              _BatchCard(batch: myBatches[i]),
        );
      },
    );
  }
}

// ── Batch card with today's attendance stats ──────────────────────────────────

class _BatchCard extends ConsumerWidget {
  const _BatchCard({required this.batch});
  final Batch batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync =
        ref.watch(_batchAttendanceTodayProvider(batch.id));
    final tt = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailSheet(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(batch.name,
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  _BatchStatusChip(status: batch.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${batch.scheduleTime} · ${batch.daysOfWeek.join(', ')}',
                style: tt.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              attendanceAsync.when(
                loading: () =>
                    const LinearProgressIndicator(minHeight: 2),
                error: (e, _) =>
                    Text('Error loading attendance', style: tt.bodySmall),
                data: (records) => _AttendanceSummaryRow(records: records),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Tap to see student list',
                    style: tt.bodySmall?.copyWith(
                        color: colors.primary, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDetailSheet(
      BuildContext context, WidgetRef ref) async {
    final records =
        await ref.read(_batchAttendanceTodayProvider(batch.id).future);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BatchDetailSheet(
          batchName: batch.name, records: records),
    );
  }
}

// ── Summary row: Present / Absent / Leave ─────────────────────────────────────

class _AttendanceSummaryRow extends StatelessWidget {
  const _AttendanceSummaryRow({required this.records});
  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) {
    final present = records
        .where((r) => r['status'] == 'PRESENT')
        .length;
    final onLeave = records
        .where((r) => r['status'] == 'ON_LEAVE')
        .length;
    final absent = records.length - present - onLeave;

    return Row(
      children: [
        _StatChip(label: 'Present', count: present, color: Colors.green),
        const SizedBox(width: 8),
        _StatChip(label: 'Absent', count: absent, color: Colors.red),
        const SizedBox(width: 8),
        _StatChip(label: 'Leave', count: onLeave, color: Colors.orange),
        const Spacer(),
        Text('Total: ${records.length}',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$count $label',
        style: tt.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _BatchStatusChip extends StatelessWidget {
  const _BatchStatusChip({required this.status});
  final BatchStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BatchStatus.active => Colors.green,
      BatchStatus.paused => Colors.orange,
      BatchStatus.cancelled => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}

// ── Batch detail bottom sheet ─────────────────────────────────────────────────

class _BatchDetailSheet extends StatelessWidget {
  const _BatchDetailSheet(
      {required this.batchName, required this.records});
  final String batchName;
  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text("$batchName — Today's Attendance",
                    style: tt.titleMedium),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Text('No check-ins yet today.',
                        style: tt.bodyMedium),
                  )
                : ListView.builder(
                    controller: controller,
                    itemCount: records.length,
                    itemBuilder: (ctx, i) {
                      final r = records[i];
                      final user =
                          r['users'] as Map<String, dynamic>?;
                      final name =
                          user?['name'] as String? ?? 'Unknown';
                      final phone = user?['phone'] as String?;
                      final status = r['status'] as String? ?? 'ABSENT';
                      final statusEnum =
                          AttendanceStatus.fromString(status);

                      final statusColor = switch (statusEnum) {
                        AttendanceStatus.present => Colors.green,
                        AttendanceStatus.onLeave => Colors.orange,
                        _ => Colors.red,
                      };

                      return ListTile(
                        leading:
                            CircleAvatar(child: Text(name[0].toUpperCase())),
                        title: Text(name),
                        subtitle: phone != null ? Text(phone) : null,
                        trailing: Chip(
                          label: Text(statusEnum.label,
                              style: TextStyle(
                                  fontSize: 11, color: statusColor)),
                          backgroundColor:
                              statusColor.withValues(alpha: 0.1),
                          side: BorderSide(
                              color: statusColor.withValues(alpha: 0.3)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Provider for today's attendance per batch ─────────────────────────────────

final _batchAttendanceTodayProvider = FutureProvider.family<
    List<Map<String, dynamic>>, String>((ref, batchId) {
  final repo = SupabaseAttendanceRepository(
      ref.watch(supabaseClientProvider));
  return repo.fetchBatchAttendanceToday(batchId);
});
