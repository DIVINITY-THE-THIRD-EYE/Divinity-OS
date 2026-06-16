import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/batch.dart';
import 'batch_provider.dart';

// ── Days chips helpers ────────────────────────────────────────────────────────

const _allDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

// ── Batches screen ────────────────────────────────────────────────────────────

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);

    return Scaffold(
      body: batchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load batches'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(batchesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (batches) => batches.isEmpty
            ? _EmptyState(
                onAdd: () => _showCreateSheet(context, ref),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(batchesProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: batches.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _BatchCard(batch: batches[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Batch'),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateBatchSheet(),
    );
  }
}

// ── Batch card ────────────────────────────────────────────────────────────────

class _BatchCard extends ConsumerWidget {
  const _BatchCard({required this.batch});
  final Batch batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final statusColor = switch (batch.status) {
      BatchStatus.active => AppColors.success,
      BatchStatus.paused => AppColors.warning,
      BatchStatus.cancelled => AppColors.error,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(batch.name, style: tt.titleMedium),
                ),
                _StatusChip(status: batch.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 16),
                const SizedBox(width: 4),
                Text(batch.scheduleTime, style: tt.bodySmall),
                const SizedBox(width: 16),
                const Icon(Icons.people_outline, size: 16),
                const SizedBox(width: 4),
                Text('Cap. ${batch.capacity}', style: tt.bodySmall),
              ],
            ),
            if (batch.daysOfWeek.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DaysRow(days: batch.daysOfWeek),
            ],
            if (batch.status == BatchStatus.active)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ref.read(batchesProvider.notifier).updateBatch(
                        batch.id,
                        {'status': 'PAUSED'},
                      ),
                  child: const Text('Pause'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});
  final BatchStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DaysRow extends StatelessWidget {
  const _DaysRow({required this.days});
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_allDays.length, (i) {
        final active = days.contains(_allDays[i]);
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: active
                ? AppColors.accentViolet
                : AppColors.accentViolet.withValues(alpha: 0.1),
            child: Text(
              _dayLabels[i],
              style: TextStyle(
                color: active ? Colors.white : AppColors.accentViolet,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 72,
            color: AppColors.accentViolet.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('No batches yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Create your first batch to get started.',
            style: tt.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Create batch'),
          ),
        ],
      ),
    );
  }
}

// ── Create batch sheet ────────────────────────────────────────────────────────

class _CreateBatchSheet extends ConsumerStatefulWidget {
  const _CreateBatchSheet();

  @override
  ConsumerState<_CreateBatchSheet> createState() => _CreateBatchSheetState();
}

class _CreateBatchSheetState extends ConsumerState<_CreateBatchSheet> {
  final _nameCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '06:00');
  final _capacityCtrl = TextEditingController(text: '20');
  final Set<String> _selectedDays = {};
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch name is required.')),
      );
      return;
    }
    final capacity = int.tryParse(_capacityCtrl.text.trim()) ?? 20;

    setState(() => _saving = true);
    try {
      final batch = Batch(
        id: '',
        name: name,
        scheduleTime: _timeCtrl.text.trim(),
        daysOfWeek: _selectedDays.toList(),
        capacity: capacity,
        status: BatchStatus.active,
        createdAt: DateTime.now(),
      );
      await ref.read(batchesProvider.notifier).createBatch(batch);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('New Batch', style: tt.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Batch name *',
                hintText: 'e.g. Morning Yoga',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Time (HH:MM)',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Days', style: tt.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(_allDays.length, (i) {
                final day = _allDays[i];
                final selected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(_dayLabels[i]),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  }),
                );
              }),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Batch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
