import 'package:divinity_app/features/holidays/data/holiday_repository.dart';
import 'package:divinity_app/features/holidays/domain/holiday.dart';
import 'package:divinity_app/features/holidays/presentation/holiday_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockHolidayRepository extends Mock implements HolidayRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

Holiday _fakeHoliday({
  String id = 'h-1',
  String name = 'Diwali',
  String date = '2026-10-20',
}) => Holiday.fromMap({
  'id': id,
  'date': date,
  'name': name,
  'created_at': '2026-06-16T00:00:00.000Z',
});

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Holiday.fromMap ────────────────────────────────────────────────────────

  group('Holiday.fromMap', () {
    test('parses required fields', () {
      final h = _fakeHoliday();
      expect(h.id, 'h-1');
      expect(h.name, 'Diwali');
      expect(h.date, DateTime(2026, 10, 20));
    });

    test('dateLabel formats as "d MMM yyyy"', () {
      final h = Holiday.fromMap({
        'id': 'h-1',
        'date': '2026-10-20',
        'name': 'Diwali',
        'created_at': '2026-06-16T00:00:00.000Z',
      });
      expect(h.dateLabel, '20 Oct 2026');
    });

    test('dayLabel returns full weekday name', () {
      // 2026-10-20 is a Tuesday
      final h = Holiday.fromMap({
        'id': 'h-1',
        'date': '2026-10-20',
        'name': 'Diwali',
        'created_at': '2026-06-16T00:00:00.000Z',
      });
      expect(h.dayLabel, 'Tuesday');
    });
  });

  // ── HolidayNotifier ────────────────────────────────────────────────────────

  group('HolidayNotifier', () {
    late MockHolidayRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockHolidayRepository();
      container = ProviderContainer(
        overrides: [holidayRepositoryProvider.overrideWithValue(mockRepo)],
      );
    });

    tearDown(() => container.dispose());

    test('loads holidays on build', () async {
      when(
        () => mockRepo.fetchUpcoming(),
      ).thenAnswer((_) async => [_fakeHoliday()]);

      final result = await container.read(holidaysProvider.future);
      expect(result.length, 1);
      expect(result.first.name, 'Diwali');
    });

    test('add inserts and sorts by date', () async {
      when(() => mockRepo.fetchUpcoming()).thenAnswer((_) async => []);

      final nov = _fakeHoliday(
        id: 'h-2',
        name: 'Christmas',
        date: '2026-12-25',
      );
      when(
        () => mockRepo.addHoliday(
          date: any(named: 'date'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => nov);

      await container.read(holidaysProvider.future);
      await container
          .read(holidaysProvider.notifier)
          .add(date: DateTime(2026, 12, 25), name: 'Christmas');

      final state = container.read(holidaysProvider).value!;
      expect(state.length, 1);
      expect(state.first.name, 'Christmas');
    });

    test('remove deletes holiday from list', () async {
      when(
        () => mockRepo.fetchUpcoming(),
      ).thenAnswer((_) async => [_fakeHoliday()]);

      await container.read(holidaysProvider.future);

      when(() => mockRepo.deleteHoliday(any())).thenAnswer((_) async {});

      await container.read(holidaysProvider.notifier).remove('h-1');

      final state = container.read(holidaysProvider).value!;
      expect(state, isEmpty);
    });

    test('refresh reloads the list', () async {
      when(
        () => mockRepo.fetchUpcoming(),
      ).thenAnswer((_) async => [_fakeHoliday()]);
      await container.read(holidaysProvider.future);

      final h2 = _fakeHoliday(id: 'h-2', name: 'Holi', date: '2026-03-05');
      when(
        () => mockRepo.fetchUpcoming(),
      ).thenAnswer((_) async => [_fakeHoliday(), h2]);
      await container.read(holidaysProvider.notifier).refresh();

      expect(container.read(holidaysProvider).value!.length, 2);
    });
  });
}
