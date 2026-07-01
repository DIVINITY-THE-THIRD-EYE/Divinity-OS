import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/workouts/data/workout_repository.dart';
import 'package:divinity_app/features/workouts/domain/workout.dart';
import 'package:divinity_app/features/workouts/domain/workout_assignment.dart';
import 'package:divinity_app/features/workouts/presentation/workout_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

Workout _fakeWorkout({
  String id = 'w-1',
  String title = 'Core & Breath',
  int exercises = 2,
}) =>
    Workout.fromMap({
      'id': id,
      'trainer_id': 'trainer-1',
      'trainer': {'name': 'Guru'},
      'title': title,
      'description': 'Foundational',
      'created_at': '2026-06-16T10:00:00.000Z',
      'workout_exercises': [
        for (var i = 0; i < exercises; i++)
          {
            'id': 'e-$i',
            'workout_id': id,
            'name': 'Exercise $i',
            'sets': 3,
            'reps': 12,
            'rest_sec': 30,
            'position': exercises - i, // reversed to test sorting
          },
      ],
    });

void main() {
  // ── Model parsing ───────────────────────────────────────────────────────────

  group('Workout.fromMap', () {
    test('parses fields and sorts exercises by position', () {
      final w = _fakeWorkout();
      expect(w.id, 'w-1');
      expect(w.trainerName, 'Guru');
      expect(w.exerciseCount, 2);
      // positions were reversed on input; must be ascending after parse
      expect(w.exercises.first.position, 1);
      expect(w.exercises.last.position, 2);
    });

    test('prescription formats sets/reps/rest', () {
      final w = _fakeWorkout();
      expect(w.exercises.first.prescription, '3 × 12  ·  rest 30s');
    });

    test('prescription handles duration-only exercise', () {
      final ex = WorkoutExercise.fromMap({
        'id': 'e',
        'workout_id': 'w',
        'name': 'Plank',
        'duration_sec': 45,
        'position': 0,
      });
      expect(ex.prescription, '45s');
    });
  });

  group('WorkoutAssignment.fromMap', () {
    test('marks completed when a matching completion row is present', () {
      final a = WorkoutAssignment.fromMap({
        'id': 'a-1',
        'workout_id': 'w-1',
        'batch_id': 'b-1',
        'batches': {'name': 'Morning Flow'},
        'assigned_at': '2026-06-16T10:00:00.000Z',
        'workout_completions': [
          {
            'student_id': 'student-1',
            'completed_at': '2026-06-17T07:00:00.000Z',
            'notes': 'done',
          },
        ],
      }, currentStudentId: 'student-1');
      expect(a.isCompleted, isTrue);
      expect(a.batchName, 'Morning Flow');
      expect(a.completionNotes, 'done');
    });

    test('is not completed when no completion for this student', () {
      final a = WorkoutAssignment.fromMap({
        'id': 'a-1',
        'workout_id': 'w-1',
        'batch_id': 'b-1',
        'assigned_at': '2026-06-16T10:00:00.000Z',
        'workout_completions': <dynamic>[],
      }, currentStudentId: 'student-1');
      expect(a.isCompleted, isFalse);
    });
  });

  group('ExerciseDraft.toRow', () {
    test('omits null/blank fields and sets position', () {
      final row = const ExerciseDraft(name: 'Squat', sets: 3).toRow('w-1', 2);
      expect(row['workout_id'], 'w-1');
      expect(row['name'], 'Squat');
      expect(row['sets'], 3);
      expect(row['position'], 2);
      expect(row.containsKey('reps'), isFalse);
      expect(row.containsKey('notes'), isFalse);
    });
  });

  // ── TrainerWorkoutsNotifier ─────────────────────────────────────────────────

  group('TrainerWorkoutsNotifier', () {
    late MockWorkoutRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = MockWorkoutRepository();
      container = ProviderContainer(overrides: [
        currentUserIdProvider.overrideWithValue('trainer-1'),
        workoutRepositoryProvider.overrideWithValue(repo),
      ]);
    });

    tearDown(() => container.dispose());

    test('loads workouts on build', () async {
      when(() => repo.fetchByTrainer(any()))
          .thenAnswer((_) async => [_fakeWorkout()]);
      final result = await container.read(trainerWorkoutsProvider.future);
      expect(result.length, 1);
      expect(result.first.title, 'Core & Breath');
    });

    test('create prepends new workout', () async {
      when(() => repo.fetchByTrainer(any())).thenAnswer((_) async => []);
      await container.read(trainerWorkoutsProvider.future);

      final created = _fakeWorkout(id: 'w-2', title: 'Mobility');
      when(() => repo.createWorkout(
            trainerId: any(named: 'trainerId'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            exercises: any(named: 'exercises'),
          )).thenAnswer((_) async => created);

      await container.read(trainerWorkoutsProvider.notifier).create(
        title: 'Mobility',
        exercises: const [ExerciseDraft(name: 'Hip opener')],
      );

      final state = container.read(trainerWorkoutsProvider).value!;
      expect(state.first.id, 'w-2');
      expect(state.length, 1);
    });

    test('remove deletes workout from list', () async {
      when(() => repo.fetchByTrainer(any()))
          .thenAnswer((_) async => [_fakeWorkout()]);
      await container.read(trainerWorkoutsProvider.future);
      when(() => repo.deleteWorkout(any())).thenAnswer((_) async {});

      await container.read(trainerWorkoutsProvider.notifier).remove('w-1');
      expect(container.read(trainerWorkoutsProvider).value!, isEmpty);
    });

    test('assign delegates to repository with trainer id', () async {
      when(() => repo.fetchByTrainer(any())).thenAnswer((_) async => []);
      await container.read(trainerWorkoutsProvider.future);
      when(() => repo.assignToBatch(
            workoutId: any(named: 'workoutId'),
            batchId: any(named: 'batchId'),
            assignedBy: any(named: 'assignedBy'),
          )).thenAnswer((_) async {});

      await container
          .read(trainerWorkoutsProvider.notifier)
          .assign(workoutId: 'w-1', batchId: 'b-1');

      verify(() => repo.assignToBatch(
            workoutId: 'w-1',
            batchId: 'b-1',
            assignedBy: 'trainer-1',
          )).called(1);
    });
  });

  // ── StudentWorkoutsNotifier ─────────────────────────────────────────────────

  group('StudentWorkoutsNotifier', () {
    late MockWorkoutRepository repo;
    late ProviderContainer container;

    WorkoutAssignment assignment({bool completed = false}) =>
        WorkoutAssignment.fromMap({
          'id': 'a-1',
          'workout_id': 'w-1',
          'batch_id': 'b-1',
          'assigned_at': '2026-06-16T10:00:00.000Z',
          'workout_completions': completed
              ? [
                  {
                    'student_id': 'student-1',
                    'completed_at': '2026-06-17T07:00:00.000Z',
                  }
                ]
              : <dynamic>[],
        }, currentStudentId: 'student-1');

    setUp(() {
      repo = MockWorkoutRepository();
      container = ProviderContainer(overrides: [
        currentUserIdProvider.overrideWithValue('student-1'),
        workoutRepositoryProvider.overrideWithValue(repo),
      ]);
    });

    tearDown(() => container.dispose());

    test('loads assignments on build', () async {
      when(() => repo.fetchAssignmentsForStudent(any()))
          .thenAnswer((_) async => [assignment()]);
      final result = await container.read(studentWorkoutsProvider.future);
      expect(result.length, 1);
      expect(result.first.isCompleted, isFalse);
    });

    test('toggleComplete marks complete when not done', () async {
      when(() => repo.fetchAssignmentsForStudent(any()))
          .thenAnswer((_) async => [assignment()]);
      await container.read(studentWorkoutsProvider.future);
      when(() => repo.markComplete(
            assignmentId: any(named: 'assignmentId'),
            studentId: any(named: 'studentId'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async {});
      when(() => repo.fetchAssignmentsForStudent(any()))
          .thenAnswer((_) async => [assignment(completed: true)]);

      await container
          .read(studentWorkoutsProvider.notifier)
          .toggleComplete(assignment());

      verify(() => repo.markComplete(
            assignmentId: 'a-1',
            studentId: 'student-1',
          )).called(1);
    });

    test('toggleComplete marks incomplete when already done', () async {
      when(() => repo.fetchAssignmentsForStudent(any()))
          .thenAnswer((_) async => [assignment(completed: true)]);
      await container.read(studentWorkoutsProvider.future);
      when(() => repo.markIncomplete(
            assignmentId: any(named: 'assignmentId'),
            studentId: any(named: 'studentId'),
          )).thenAnswer((_) async {});

      await container
          .read(studentWorkoutsProvider.notifier)
          .toggleComplete(assignment(completed: true));

      verify(() => repo.markIncomplete(
            assignmentId: 'a-1',
            studentId: 'student-1',
          )).called(1);
    });
  });
}
