import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/events/data/event_repository.dart';
import 'package:divinity_app/features/events/domain/event.dart';
import 'package:divinity_app/features/events/presentation/event_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

Event _fakeEvent({
  String id = 'e-1',
  String title = 'Sunrise Camp',
  int? capacity,
  int registrationCount = 0,
  bool isRegistered = false,
  String status = 'PUBLISHED',
}) =>
    Event.fromMap({
      'id': id,
      'title': title,
      'location': 'Rishikesh',
      'starts_at': '2026-08-01T06:00:00.000Z',
      'capacity': capacity,
      'status': status,
      'created_at': '2026-06-16T10:00:00.000Z',
      'event_registrations': [
        {'count': registrationCount}
      ],
      'is_registered': isRegistered,
    });

void main() {
  setUpAll(() {
    // Required by mocktail to use any() on Event-typed parameters.
    registerFallbackValue(_fakeEvent());
  });

  // ── Model ───────────────────────────────────────────────────────────────────

  group('Event.fromMap', () {
    test('parses aggregate registration count and status', () {
      final e = _fakeEvent(capacity: 10, registrationCount: 3);
      expect(e.registrationCount, 3);
      expect(e.capacity, 10);
      expect(e.status, EventStatus.published);
      expect(e.seatsLeft, 7);
      expect(e.isFull, isFalse);
    });

    test('isFull when registrations reach capacity', () {
      final e = _fakeEvent(capacity: 2, registrationCount: 2);
      expect(e.isFull, isTrue);
      expect(e.seatsLeft, 0);
    });

    test('unlimited capacity is never full', () {
      final e = _fakeEvent(registrationCount: 999);
      expect(e.capacity, isNull);
      expect(e.isFull, isFalse);
      expect(e.seatsLeft, isNull);
    });

    test('isRegistered reflects flag', () {
      expect(_fakeEvent(isRegistered: true).isRegistered, isTrue);
      expect(_fakeEvent().isRegistered, isFalse);
    });

    test('toInsertMap omits blanks and serialises status', () {
      final e = _fakeEvent(capacity: 5, status: 'DRAFT');
      final map = e.toInsertMap();
      expect(map['title'], 'Sunrise Camp');
      expect(map['status'], 'DRAFT');
      expect(map['capacity'], 5);
      expect(map.containsKey('description'), isFalse);
    });
  });

  // ── StudentEventsNotifier ───────────────────────────────────────────────────

  group('StudentEventsNotifier', () {
    late MockEventRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = MockEventRepository();
      container = ProviderContainer(overrides: [
        currentUserIdProvider.overrideWithValue('student-1'),
        eventRepositoryProvider.overrideWithValue(repo),
      ]);
    });

    tearDown(() => container.dispose());

    test('loads published events on build', () async {
      when(() => repo.fetchPublishedForStudent(any()))
          .thenAnswer((_) async => [_fakeEvent()]);
      final result = await container.read(studentEventsProvider.future);
      expect(result.length, 1);
      expect(result.first.title, 'Sunrise Camp');
    });

    test('toggleRegistration registers when not registered', () async {
      when(() => repo.fetchPublishedForStudent(any()))
          .thenAnswer((_) async => [_fakeEvent()]);
      await container.read(studentEventsProvider.future);
      when(() => repo.register(
            eventId: any(named: 'eventId'),
            studentId: any(named: 'studentId'),
          )).thenAnswer((_) async {});
      when(() => repo.fetchPublishedForStudent(any()))
          .thenAnswer((_) async => [_fakeEvent(isRegistered: true)]);

      await container
          .read(studentEventsProvider.notifier)
          .toggleRegistration(_fakeEvent());

      verify(() => repo.register(eventId: 'e-1', studentId: 'student-1'))
          .called(1);
    });

    test('toggleRegistration unregisters when already registered', () async {
      when(() => repo.fetchPublishedForStudent(any()))
          .thenAnswer((_) async => [_fakeEvent(isRegistered: true)]);
      await container.read(studentEventsProvider.future);
      when(() => repo.unregister(
            eventId: any(named: 'eventId'),
            studentId: any(named: 'studentId'),
          )).thenAnswer((_) async {});

      await container
          .read(studentEventsProvider.notifier)
          .toggleRegistration(_fakeEvent(isRegistered: true));

      verify(() => repo.unregister(eventId: 'e-1', studentId: 'student-1'))
          .called(1);
    });
  });

  // ── AdminEventsNotifier ─────────────────────────────────────────────────────

  group('AdminEventsNotifier', () {
    late MockEventRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = MockEventRepository();
      container = ProviderContainer(overrides: [
        currentUserIdProvider.overrideWithValue('admin-1'),
        eventRepositoryProvider.overrideWithValue(repo),
      ]);
    });

    tearDown(() => container.dispose());

    test('create prepends the created event', () async {
      when(() => repo.fetchAllForAdmin()).thenAnswer((_) async => []);
      await container.read(adminEventsProvider.future);

      final created = _fakeEvent(id: 'e-2', title: 'Retreat');
      when(() => repo.createEvent(any(), createdBy: any(named: 'createdBy')))
          .thenAnswer((_) async => created);

      await container
          .read(adminEventsProvider.notifier)
          .create(_fakeEvent(id: '', title: 'Retreat'));

      final state = container.read(adminEventsProvider).value!;
      expect(state.first.id, 'e-2');
      verify(() => repo.createEvent(any(), createdBy: 'admin-1')).called(1);
    });

    test('remove deletes the event from state', () async {
      when(() => repo.fetchAllForAdmin())
          .thenAnswer((_) async => [_fakeEvent()]);
      await container.read(adminEventsProvider.future);
      when(() => repo.deleteEvent(any())).thenAnswer((_) async {});

      await container.read(adminEventsProvider.notifier).remove('e-1');
      expect(container.read(adminEventsProvider).value!, isEmpty);
    });

    test('update replaces the matching event', () async {
      when(() => repo.fetchAllForAdmin())
          .thenAnswer((_) async => [_fakeEvent()]);
      await container.read(adminEventsProvider.future);

      final updated = _fakeEvent(title: 'Sunrise Camp (rescheduled)');
      when(() => repo.updateEvent(any(), any()))
          .thenAnswer((_) async => updated);

      await container
          .read(adminEventsProvider.notifier)
          .edit('e-1', _fakeEvent(title: 'Sunrise Camp (rescheduled)'));

      expect(container.read(adminEventsProvider).value!.first.title,
          'Sunrise Camp (rescheduled)');
    });
  });
}
