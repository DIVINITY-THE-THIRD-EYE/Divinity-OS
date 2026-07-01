import 'package:intl/intl.dart';

/// A single exercise inside a [Workout], displayed in [position] order.
class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.name,
    this.sets,
    this.reps,
    this.durationSec,
    this.restSec,
    this.notes,
    required this.position,
  });

  final String id;
  final String workoutId;
  final String name;
  final int? sets;
  final int? reps;
  final int? durationSec;
  final int? restSec;
  final String? notes;
  final int position;

  factory WorkoutExercise.fromMap(Map<String, dynamic> m) => WorkoutExercise(
    id: m['id'] as String,
    workoutId: m['workout_id'] as String,
    name: m['name'] as String,
    sets: (m['sets'] as num?)?.toInt(),
    reps: (m['reps'] as num?)?.toInt(),
    durationSec: (m['duration_sec'] as num?)?.toInt(),
    restSec: (m['rest_sec'] as num?)?.toInt(),
    notes: m['notes'] as String?,
    position: (m['position'] as num?)?.toInt() ?? 0,
  );

  /// Human-readable prescription, e.g. "3 × 12  ·  rest 30s" or "45s hold".
  String get prescription {
    final parts = <String>[];
    if (sets != null && reps != null) {
      parts.add('$sets × $reps');
    } else if (sets != null) {
      parts.add('$sets sets');
    } else if (reps != null) {
      parts.add('$reps reps');
    }
    if (durationSec != null) parts.add('${durationSec}s');
    if (restSec != null && restSec! > 0) parts.add('rest ${restSec}s');
    return parts.join('  ·  ');
  }
}

/// A reusable workout plan authored by a trainer (or admin).
class Workout {
  const Workout({
    required this.id,
    required this.trainerId,
    this.trainerName,
    required this.title,
    this.description,
    this.exercises = const [],
    required this.createdAt,
  });

  final String id;
  final String trainerId;
  final String? trainerName;
  final String title;
  final String? description;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;

  factory Workout.fromMap(Map<String, dynamic> m) {
    final trainerRow = m['trainer'] as Map<String, dynamic>?;
    final rawExercises =
        (m['workout_exercises'] as List<dynamic>? ?? [])
            .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
    return Workout(
      id: m['id'] as String,
      trainerId: m['trainer_id'] as String,
      trainerName: trainerRow?['name'] as String?,
      title: m['title'] as String,
      description: m['description'] as String?,
      exercises: rawExercises,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }

  int get exerciseCount => exercises.length;

  String get dateLabel => DateFormat('d MMM yyyy').format(createdAt.toLocal());
}
