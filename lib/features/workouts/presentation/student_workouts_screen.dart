import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/workout.dart';
import '../domain/workout_assignment.dart';
import 'workout_provider.dart';

/// Student view: workouts assigned to their batches, with completion tracking.
class StudentWorkoutsScreen extends ConsumerWidget {
  const StudentWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studentWorkoutsProvider);

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load workouts: $e'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(studentWorkoutsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(studentWorkoutsProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) =>
                      _AssignmentCard(assignment: items[i]),
                ),
              ),
      ),
    );
  }
}

class _AssignmentCard extends ConsumerWidget {
  const _AssignmentCard({required this.assignment});
  final WorkoutAssignment assignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final workout = assignment.workout;
    final done = assignment.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: done
                ? Colors.green.withValues(alpha: 0.15)
                : AppColors.accentViolet.withValues(alpha: 0.12),
            child: Icon(
              done ? Icons.check : Icons.fitness_center,
              color: done ? Colors.green : AppColors.accentViolet,
              size: 20,
            ),
          ),
          title: Text(
            workout?.title ?? 'Workout',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            [
              if (assignment.batchName != null) assignment.batchName!,
              'Assigned ${assignment.assignedLabel}',
            ].join(' · '),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            if (workout?.description != null &&
                workout!.description!.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(workout.description!, style: tt.bodyMedium),
              ),
              const SizedBox(height: 8),
            ],
            ...?workout?.exercises.map(
              (WorkoutExercise e) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.chevron_right, size: 18),
                title: Text(e.name),
                subtitle:
                    e.prescription.isEmpty ? null : Text(e.prescription),
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: done
                  ? OutlinedButton.icon(
                      onPressed: () => _toggle(context, ref),
                      icon: const Icon(Icons.undo, size: 18),
                      label: const Text('Mark not done'),
                    )
                  : FilledButton.icon(
                      onPressed: () => _toggle(context, ref),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Mark complete'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(studentWorkoutsProvider.notifier)
          .toggleComplete(assignment);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.self_improvement,
              size: 72, color: AppColors.accentViolet.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No workouts assigned yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your trainer will assign workouts to your batch. '
              'They will appear here.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
