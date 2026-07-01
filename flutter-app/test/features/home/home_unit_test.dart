import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/home/data/home_repository.dart';
import 'package:divinity_app/features/home/domain/home_data.dart';
import 'package:divinity_app/features/home/presentation/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  group('UpcomingClass', () {
    test('dayLabel returns Today for today', () {
      final today = DateTime.now();
      final cls = UpcomingClass(
        batchId: 'b1',
        batchName: 'Morning Yoga',
        scheduleTime: '06:00',
        nextDate: DateTime(today.year, today.month, today.day),
      );
      expect(cls.dayLabel, 'Today');
    });

    test('dayLabel returns Tomorrow for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final cls = UpcomingClass(
        batchId: 'b1',
        batchName: 'Evening Yoga',
        scheduleTime: '18:00',
        nextDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      );
      expect(cls.dayLabel, 'Tomorrow');
    });

    test('dayLabel formats future dates', () {
      final future = DateTime.now().add(const Duration(days: 5));
      final cls = UpcomingClass(
        batchId: 'b1',
        batchName: 'Power Yoga',
        scheduleTime: '07:00',
        nextDate: DateTime(future.year, future.month, future.day),
      );
      // Should not be Today or Tomorrow
      expect(cls.dayLabel, isNot('Today'));
      expect(cls.dayLabel, isNot('Tomorrow'));
      expect(cls.dayLabel, isNotEmpty);
    });

    test('trainerName is optional', () {
      final cls = UpcomingClass(
        batchId: 'b2',
        batchName: 'Meditation',
        scheduleTime: '06:30',
        nextDate: DateTime.now(),
      );
      expect(cls.trainerName, isNull);
    });
  });

  group('ActivityItem', () {
    test('dateLabel formats date correctly', () {
      final item = ActivityItem(
        date: DateTime(2025, 6, 16),
        label: 'Attended class',
        icon: '✅',
        isPositive: true,
      );
      expect(item.dateLabel, 'Mon, Jun 16');
    });

    test('isPositive false for absent', () {
      final item = ActivityItem(
        date: DateTime.now(),
        label: 'Absent',
        icon: '❌',
        isPositive: false,
      );
      expect(item.isPositive, false);
    });
  });

  group('HomeData', () {
    test('holds all fields correctly', () {
      const data = HomeData(
        firstName: 'Priya',
        streak: 7,
        upcomingClasses: [],
        recentActivity: [],
      );
      expect(data.firstName, 'Priya');
      expect(data.streak, 7);
      expect(data.upcomingClasses, isEmpty);
      expect(data.recentActivity, isEmpty);
    });
  });

  group('homeDataProvider', () {
    late MockHomeRepository repo;

    setUp(() {
      repo = MockHomeRepository();
    });

    test('loads home data from repository', () async {
      const userId = 'user-123';
      const expected = HomeData(
        firstName: 'Priya',
        streak: 5,
        upcomingClasses: [],
        recentActivity: [],
      );
      when(() => repo.fetchHomeData(userId)).thenAnswer((_) async => expected);

      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue(userId),
          homeRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(homeDataProvider.future);
      expect(result.firstName, 'Priya');
      expect(result.streak, 5);
      verify(() => repo.fetchHomeData(userId)).called(1);
    });

    test('throws when user is not authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue(null),
          homeRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(homeDataProvider.future),
        throwsA(isA<StateError>()),
      );
    });
  });
}
