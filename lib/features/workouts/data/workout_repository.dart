import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/workout.dart';
import '../domain/workout_assignment.dart';

/// A draft exercise used when creating/editing a workout (no id yet).
class ExerciseDraft {
  const ExerciseDraft({
    required this.name,
    this.sets,
    this.reps,
    this.durationSec,
    this.restSec,
    this.notes,
  });

  final String name;
  final int? sets;
  final int? reps;
  final int? durationSec;
  final int? restSec;
  final String? notes;

  Map<String, dynamic> toRow(String workoutId, int position) => {
    'workout_id': workoutId,
    'name': name,
    if (sets != null) 'sets': sets,
    if (reps != null) 'reps': reps,
    if (durationSec != null) 'duration_sec': durationSec,
    if (restSec != null) 'rest_sec': restSec,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    'position': position,
  };
}

abstract interface class WorkoutRepository {
  /// Workouts authored by [trainerId], newest first, with exercises embedded.
  Future<List<Workout>> fetchByTrainer(String trainerId);

  /// Creates a workout owned by [trainerId] and its ordered [exercises].
  Future<Workout> createWorkout({
    required String trainerId,
    required String title,
    String? description,
    required List<ExerciseDraft> exercises,
  });

  Future<void> deleteWorkout(String workoutId);

  /// Assigns [workoutId] to [batchId]. Idempotent per (workout, batch).
  Future<void> assignToBatch({
    required String workoutId,
    required String batchId,
    required String assignedBy,
  });

  /// Batches a workout is currently assigned to (batch id + name).
  Future<List<WorkoutAssignment>> fetchAssignmentsForWorkout(String workoutId);

  Future<void> unassign(String assignmentId);

  /// Workouts assigned to the batches [studentId] is enrolled in, with the
  /// student's own completion state embedded.
  Future<List<WorkoutAssignment>> fetchAssignmentsForStudent(String studentId);

  Future<void> markComplete({
    required String assignmentId,
    required String studentId,
    String? notes,
  });

  Future<void> markIncomplete({
    required String assignmentId,
    required String studentId,
  });
}

class SupabaseWorkoutRepository implements WorkoutRepository {
  SupabaseWorkoutRepository(this._client);

  final SupabaseClient _client;

  static const _workoutSelect =
      '*, trainer:trainer_id(name), workout_exercises(*)';

  @override
  Future<List<Workout>> fetchByTrainer(String trainerId) async {
    final rows = await _client
        .from('workouts')
        .select(_workoutSelect)
        .eq('trainer_id', trainerId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => Workout.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Workout> createWorkout({
    required String trainerId,
    required String title,
    String? description,
    required List<ExerciseDraft> exercises,
  }) async {
    final inserted = await _client
        .from('workouts')
        .insert({
          'trainer_id': trainerId,
          'title': title.trim(),
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
        })
        .select('id')
        .single();
    final workoutId = inserted['id'] as String;

    if (exercises.isNotEmpty) {
      final rows = <Map<String, dynamic>>[
        for (var i = 0; i < exercises.length; i++)
          exercises[i].toRow(workoutId, i),
      ];
      await _client.from('workout_exercises').insert(rows);
    }

    final row = await _client
        .from('workouts')
        .select(_workoutSelect)
        .eq('id', workoutId)
        .single();
    return Workout.fromMap(row);
  }

  @override
  Future<void> deleteWorkout(String workoutId) async {
    await _client.from('workouts').delete().eq('id', workoutId);
  }

  @override
  Future<void> assignToBatch({
    required String workoutId,
    required String batchId,
    required String assignedBy,
  }) async {
    await _client
        .from('workout_assignments')
        .upsert(
          {
            'workout_id': workoutId,
            'batch_id': batchId,
            'assigned_by': assignedBy,
          },
          onConflict: 'workout_id,batch_id',
          ignoreDuplicates: true,
        );
  }

  @override
  Future<List<WorkoutAssignment>> fetchAssignmentsForWorkout(
    String workoutId,
  ) async {
    final rows = await _client
        .from('workout_assignments')
        .select('*, batches(name)')
        .eq('workout_id', workoutId)
        .order('assigned_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => WorkoutAssignment.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> unassign(String assignmentId) async {
    await _client.from('workout_assignments').delete().eq('id', assignmentId);
  }

  @override
  Future<List<WorkoutAssignment>> fetchAssignmentsForStudent(
    String studentId,
  ) async {
    final rows = await _client
        .from('workout_assignments')
        .select(
          '*, batches(name), '
          'workouts(*, trainer:trainer_id(name), workout_exercises(*)), '
          'workout_completions(*)',
        )
        .order('assigned_at', ascending: false);
    return (rows as List<dynamic>)
        .map(
          (r) => WorkoutAssignment.fromMap(
            r as Map<String, dynamic>,
            currentStudentId: studentId,
          ),
        )
        .toList();
  }

  @override
  Future<void> markComplete({
    required String assignmentId,
    required String studentId,
    String? notes,
  }) async {
    await _client.from('workout_completions').upsert({
      'assignment_id': assignmentId,
      'student_id': studentId,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    }, onConflict: 'assignment_id,student_id');
  }

  @override
  Future<void> markIncomplete({
    required String assignmentId,
    required String studentId,
  }) async {
    await _client
        .from('workout_completions')
        .delete()
        .eq('assignment_id', assignmentId)
        .eq('student_id', studentId);
  }
}
