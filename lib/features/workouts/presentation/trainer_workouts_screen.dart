import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../batches/domain/batch.dart';
import '../../batches/presentation/batch_provider.dart';
import '../data/workout_repository.dart';
import '../domain/workout.dart';
import 'workout_provider.dart';

/// Trainer view: author structured workout plans and assign them to batches.
class TrainerWorkoutsScreen extends ConsumerWidget {
  const TrainerWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(trainerWorkoutsProvider);

    return Scaffold(
      body: workoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: 'Failed to load workouts: $e',
          onRetry: () => ref.read(trainerWorkoutsProvider.notifier).refresh(),
        ),
        data: (workouts) => workouts.isEmpty
            ? _EmptyState(onAdd: () => _openEditor(context))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(trainerWorkoutsProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  itemCount: workouts.length,
                  itemBuilder: (ctx, i) => _WorkoutCard(workout: workouts[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New Workout'),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _WorkoutEditorScreen()),
    );
  }
}

// ── Workout card ──────────────────────────────────────────────────────────────

class _WorkoutCard extends ConsumerWidget {
  const _WorkoutCard({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.accentViolet.withValues(alpha: 0.12),
            child: const Icon(Icons.fitness_center,
                color: AppColors.accentViolet, size: 20),
          ),
          title: Text(workout.title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${workout.exerciseCount} exercise'
            '${workout.exerciseCount == 1 ? '' : 's'} · ${workout.dateLabel}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            if (workout.description != null &&
                workout.description!.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(workout.description!, style: tt.bodyMedium),
              ),
              const SizedBox(height: 12),
            ],
            ...workout.exercises.map(
              (e) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.chevron_right, size: 18),
                title: Text(e.name),
                subtitle:
                    e.prescription.isEmpty ? null : Text(e.prescription),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  label:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _openAssignSheet(context, ref),
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('Assign'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Delete "${workout.title}"? This also removes it from '
            'any batch it was assigned to.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(trainerWorkoutsProvider.notifier).remove(workout.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _openAssignSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AssignSheet(workout: workout),
    );
  }
}

// ── Assign to batch sheet ─────────────────────────────────────────────────────

class _AssignSheet extends ConsumerStatefulWidget {
  const _AssignSheet({required this.workout});
  final Workout workout;

  @override
  ConsumerState<_AssignSheet> createState() => _AssignSheetState();
}

class _AssignSheetState extends ConsumerState<_AssignSheet> {
  String? _batchId;
  bool _saving = false;

  Future<void> _assign() async {
    if (_batchId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select a batch.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(trainerWorkoutsProvider.notifier).assign(
            workoutId: widget.workout.id,
            batchId: _batchId!,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout assigned. Students notified.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final batchesAsync = ref.watch(batchesProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Assign "${widget.workout.title}"', style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text('Every student enrolled in the batch receives it.',
                style: tt.bodyMedium),
            const SizedBox(height: 24),
            batchesAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (e, _) => Text('Could not load batches: $e'),
              data: (batches) {
                final active = batches
                    .where((b) => b.status == BatchStatus.active)
                    .toList();
                if (active.isEmpty) {
                  return const Text('No active batches to assign to.');
                }
                return DropdownButtonFormField<String>(
                  key: ValueKey(_batchId),
                  initialValue: _batchId,
                  decoration: const InputDecoration(
                    labelText: 'Batch *',
                    prefixIcon: Icon(Icons.groups_outlined),
                  ),
                  hint: const Text('Select batch'),
                  items: active
                      .map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text('${b.name} · ${b.scheduleTime}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _batchId = v),
                );
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _assign,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Assign Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Workout editor ────────────────────────────────────────────────────────────

class _WorkoutEditorScreen extends ConsumerStatefulWidget {
  const _WorkoutEditorScreen();

  @override
  ConsumerState<_WorkoutEditorScreen> createState() =>
      _WorkoutEditorScreenState();
}

class _ExerciseRow {
  _ExerciseRow();
  final nameCtrl = TextEditingController();
  final setsCtrl = TextEditingController();
  final repsCtrl = TextEditingController();
  final restCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    setsCtrl.dispose();
    repsCtrl.dispose();
    restCtrl.dispose();
  }

  bool get isBlank => nameCtrl.text.trim().isEmpty;

  ExerciseDraft toDraft() => ExerciseDraft(
        name: nameCtrl.text.trim(),
        sets: int.tryParse(setsCtrl.text.trim()),
        reps: int.tryParse(repsCtrl.text.trim()),
        restSec: int.tryParse(restCtrl.text.trim()),
      );
}

class _WorkoutEditorScreenState extends ConsumerState<_WorkoutEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rows = <_ExerciseRow>[_ExerciseRow()];
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_ExerciseRow()));

  void _removeRow(int i) {
    setState(() {
      _rows[i].dispose();
      _rows.removeAt(i);
      if (_rows.isEmpty) _rows.add(_ExerciseRow());
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Title is required.')));
      return;
    }
    final drafts =
        _rows.where((r) => !r.isBlank).map((r) => r.toDraft()).toList();
    if (drafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(trainerWorkoutsProvider.notifier).create(
            title: title,
            description: _descCtrl.text,
            exercises: drafts,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('New Workout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          TextField(
            controller: _titleCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Title *',
              hintText: 'e.g. Morning Core & Breath',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 24),
          Text('Exercises', style: tt.titleMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < _rows.length; i++) _exerciseCard(i),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 8, 20, 8 + MediaQuery.of(context).padding.bottom),
        child: SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Workout'),
          ),
        ),
      ),
    );
  }

  Widget _exerciseCard(int i) {
    final row = _rows[i];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: row.nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Exercise ${i + 1} *',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Remove',
                  onPressed: () => _removeRow(i),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numField(row.setsCtrl, 'Sets')),
                const SizedBox(width: 8),
                Expanded(child: _numField(row.repsCtrl, 'Reps')),
                const SizedBox(width: 8),
                Expanded(child: _numField(row.restCtrl, 'Rest (s)')),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label) => TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, isDense: true),
      );
}

// ── Shared small widgets ──────────────────────────────────────────────────────

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
          Icon(Icons.fitness_center,
              size: 72, color: AppColors.accentViolet.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No workouts yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text('Create a plan and assign it to your batches.',
              style: tt.bodyMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('New Workout'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
