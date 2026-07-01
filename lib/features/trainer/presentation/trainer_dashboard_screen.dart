import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../attendance/data/attendance_repository.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../batches/domain/batch.dart';
import '../../batches/presentation/batch_provider.dart';
import 'trainer_check_in_screen.dart';

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);
    final uid = ref.watch(currentUserIdProvider);
    final tt = Theme.of(context).textTheme;

    return batchesAsync.when(
      loading: () => const Center(child: ChakraLoader()),
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

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(batchesProvider);
            ref.invalidate(trainerAttendanceTodayProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: myBatches.length,
            itemBuilder: (ctx, i) =>
                _BatchCard(batch: myBatches[i]),
          ),
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
    final attendanceAsync = ref.watch(trainerAttendanceTodayProvider);
    final tt = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TrainerCheckInScreen(batch: batch),
              ),
            ),
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
                data: (records) {
                  final batchRecords = records.where((r) => r['batch_id'] == batch.id).toList();
                  return _AttendanceSummaryRow(records: batchRecords);
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Tap to mark attendance',
                    style: tt.bodySmall?.copyWith(
                        color: colors.primary, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
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

// ── Provider for today's attendance across all trainer batches (optimised) ─────

final trainerAttendanceTodayProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  final batchesAsync = ref.watch(batchesProvider);
  
  final batches = batchesAsync.value ?? [];
  final myBatches = uid == null
      ? batches
      : batches.where((b) => b.trainerId == uid).toList();
      
  final batchIds = myBatches.map((b) => b.id).toList();
  if (batchIds.isEmpty) return [];

  final repo = SupabaseAttendanceRepository(ref.watch(supabaseClientProvider));
  return repo.fetchBatchesAttendanceToday(batchIds);
});
