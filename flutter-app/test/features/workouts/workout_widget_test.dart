import 'package:divinity_app/core/theme/app_theme.dart';
import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/workouts/data/workout_repository.dart';
import 'package:divinity_app/features/workouts/domain/workout.dart';
import 'package:divinity_app/features/workouts/domain/workout_assignment.dart';
import 'package:divinity_app/features/workouts/presentation/student_workouts_screen.dart';
import 'package:divinity_app/features/workouts/presentation/trainer_workouts_screen.dart';
import 'package:divinity_app/features/workouts/presentation/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake repo whose behaviour is driven by the closures passed in.
class _FakeWorkoutRepository implements WorkoutRepository {
  _FakeWorkoutRepository({
    this.byTrainer = const [],
    this.forStudent = const [],
  });

  final List<Workout> byTrainer;
  final List<WorkoutAssignment> forStudent;

  @override
  Future<List<Workout>> fetchByTrainer(String trainerId) async => byTrainer;

  @override
  Future<List<WorkoutAssignment>> fetchAssignmentsForStudent(
    String studentId,
  ) async => forStudent;

  @override
  Future<Workout> createWorkout({
    required String trainerId,
    required String title,
    String? description,
    required List<ExerciseDraft> exercises,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteWorkout(String workoutId) async {}

  @override
  Future<void> assignToBatch({
    required String workoutId,
    required String batchId,
    required String assignedBy,
  }) async {}

  @override
  Future<List<WorkoutAssignment>> fetchAssignmentsForWorkout(
    String workoutId,
  ) async => [];

  @override
  Future<void> unassign(String assignmentId) async {}

  @override
  Future<void> markComplete({
    required String assignmentId,
    required String studentId,
    String? notes,
  }) async {}

  @override
  Future<void> markIncomplete({
    required String assignmentId,
    required String studentId,
  }) async {}
}

Workout _workout() => Workout.fromMap({
  'id': 'w-1',
  'trainer_id': 'trainer-1',
  'title': 'Core & Breath',
  'description': 'Foundational',
  'created_at': '2026-06-16T10:00:00.000Z',
  'workout_exercises': [
    {
      'id': 'e-1',
      'workout_id': 'w-1',
      'name': 'Cat-Cow',
      'sets': 3,
      'reps': 10,
      'position': 0,
    },
  ],
});

WorkoutAssignment _assignment() => WorkoutAssignment.fromMap({
  'id': 'a-1',
  'workout_id': 'w-1',
  'batch_id': 'b-1',
  'batches': {'name': 'Morning Flow'},
  'workouts': {
    'id': 'w-1',
    'trainer_id': 'trainer-1',
    'title': 'Core & Breath',
    'created_at': '2026-06-16T10:00:00.000Z',
    'workout_exercises': <dynamic>[],
  },
  'assigned_at': '2026-06-16T10:00:00.000Z',
  'workout_completions': <dynamic>[],
}, currentStudentId: 'student-1');

Widget _wrap(Widget child, {required WorkoutRepository repo, String? uid}) {
  return ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue(uid ?? 'trainer-1'),
      workoutRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(theme: AppTheme.dark(), home: child),
  );
}

void main() {
  group('TrainerWorkoutsScreen', () {
    testWidgets('shows empty state and CTA when no workouts', (tester) async {
      await tester.pumpWidget(
        _wrap(const TrainerWorkoutsScreen(), repo: _FakeWorkoutRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No workouts yet'), findsOneWidget);
      expect(
        find.widgetWithText(FloatingActionButton, 'New Workout'),
        findsOneWidget,
      );
    });

    testWidgets('renders a workout card with exercise count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TrainerWorkoutsScreen(),
          repo: _FakeWorkoutRepository(byTrainer: [_workout()]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Core & Breath'), findsOneWidget);
      expect(find.textContaining('1 exercise'), findsOneWidget);
    });
  });

  group('StudentWorkoutsScreen', () {
    testWidgets('shows empty state when nothing assigned', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StudentWorkoutsScreen(),
          repo: _FakeWorkoutRepository(),
          uid: 'student-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No workouts assigned yet'), findsOneWidget);
    });

    testWidgets('renders an assigned workout with batch name', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StudentWorkoutsScreen(),
          repo: _FakeWorkoutRepository(forStudent: [_assignment()]),
          uid: 'student-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Core & Breath'), findsOneWidget);
      expect(find.textContaining('Morning Flow'), findsOneWidget);
    });
  });
}
