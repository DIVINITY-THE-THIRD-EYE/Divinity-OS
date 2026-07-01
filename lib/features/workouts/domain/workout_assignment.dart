import 'package:intl/intl.dart';

import 'workout.dart';

/// A workout assigned to a batch. From the student's perspective this carries
/// the embedded [workout] plus their own completion state ([completedAt]).
class WorkoutAssignment {
  const WorkoutAssignment({
    required this.id,
    required this.workoutId,
    required this.batchId,
    this.batchName,
    this.workout,
    this.assignedBy,
    required this.assignedAt,
    this.completedAt,
    this.completionNotes,
  });

  final String id;
  final String workoutId;
  final String batchId;
  final String? batchName;
  final Workout? workout;
  final String? assignedBy;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? completionNotes;

  bool get isCompleted => completedAt != null;

  factory WorkoutAssignment.fromMap(
    Map<String, dynamic> m, {
    String? currentStudentId,
  }) {
    final batchRow = m['batches'] as Map<String, dynamic>?;
    final workoutRow = m['workouts'] as Map<String, dynamic>?;

    // Completions may arrive as an embedded list (student view) — pick the row
    // belonging to the current student, if any.
    DateTime? completedAt;
    String? completionNotes;
    final completions = m['workout_completions'] as List<dynamic>?;
    if (completions != null) {
      for (final c in completions.cast<Map<String, dynamic>>()) {
        if (currentStudentId == null || c['student_id'] == currentStudentId) {
          completedAt = DateTime.parse(c['completed_at'] as String);
          completionNotes = c['notes'] as String?;
          break;
        }
      }
    }

    return WorkoutAssignment(
      id: m['id'] as String,
      workoutId: m['workout_id'] as String,
      batchId: m['batch_id'] as String,
      batchName: batchRow?['name'] as String?,
      workout: workoutRow == null ? null : Workout.fromMap(workoutRow),
      assignedBy: m['assigned_by'] as String?,
      assignedAt: DateTime.parse(m['assigned_at'] as String),
      completedAt: completedAt,
      completionNotes: completionNotes,
    );
  }

  String get assignedLabel =>
      DateFormat('d MMM yyyy').format(assignedAt.toLocal());
}
