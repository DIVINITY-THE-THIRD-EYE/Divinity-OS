import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/workout_repository.dart';
import '../domain/workout.dart';
import '../domain/workout_assignment.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => SupabaseWorkoutRepository(ref.watch(supabaseClientProvider)),
);

// ── Trainer: workouts I authored ─────────────────────────────────────────────

class TrainerWorkoutsNotifier extends AsyncNotifier<List<Workout>> {
  @override
  Future<List<Workout>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref.read(workoutRepositoryProvider).fetchByTrainer(uid);
  }

  Future<void> refresh() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workoutRepositoryProvider).fetchByTrainer(uid),
    );
  }

  Future<void> create({
    required String title,
    String? description,
    required List<ExerciseDraft> exercises,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final workout = await ref
        .read(workoutRepositoryProvider)
        .createWorkout(
          trainerId: uid,
          title: title,
          description: description,
          exercises: exercises,
        );
    state = AsyncData([workout, ...state.value ?? []]);
  }

  Future<void> remove(String workoutId) async {
    await ref.read(workoutRepositoryProvider).deleteWorkout(workoutId);
    state = AsyncData(
      (state.value ?? []).where((w) => w.id != workoutId).toList(),
    );
  }

  Future<void> assign({
    required String workoutId,
    required String batchId,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ref
        .read(workoutRepositoryProvider)
        .assignToBatch(workoutId: workoutId, batchId: batchId, assignedBy: uid);
  }
}

final trainerWorkoutsProvider =
    AsyncNotifierProvider<TrainerWorkoutsNotifier, List<Workout>>(
      TrainerWorkoutsNotifier.new,
    );

// ── Trainer: where a workout is assigned (family) ────────────────────────────

final workoutAssignmentsProvider =
    FutureProvider.family<List<WorkoutAssignment>, String>((ref, workoutId) {
      return ref
          .read(workoutRepositoryProvider)
          .fetchAssignmentsForWorkout(workoutId);
    });

// ── Student: workouts assigned to my batches ─────────────────────────────────

class StudentWorkoutsNotifier extends AsyncNotifier<List<WorkoutAssignment>> {
  @override
  Future<List<WorkoutAssignment>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref.read(workoutRepositoryProvider).fetchAssignmentsForStudent(uid);
  }

  Future<void> refresh() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workoutRepositoryProvider).fetchAssignmentsForStudent(uid),
    );
  }

  Future<void> toggleComplete(
    WorkoutAssignment assignment, {
    String? notes,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final repo = ref.read(workoutRepositoryProvider);
    if (assignment.isCompleted) {
      await repo.markIncomplete(assignmentId: assignment.id, studentId: uid);
    } else {
      await repo.markComplete(
        assignmentId: assignment.id,
        studentId: uid,
        notes: notes,
      );
    }
    await refresh();
  }
}

final studentWorkoutsProvider =
    AsyncNotifierProvider<StudentWorkoutsNotifier, List<WorkoutAssignment>>(
      StudentWorkoutsNotifier.new,
    );
