import 'package:divinity_app/core/theme/app_theme.dart';
import 'package:divinity_app/features/auth/presentation/auth_provider.dart';
import 'package:divinity_app/features/events/data/event_repository.dart';
import 'package:divinity_app/features/events/domain/event.dart';
import 'package:divinity_app/features/events/presentation/admin_events_screen.dart';
import 'package:divinity_app/features/events/presentation/event_provider.dart';
import 'package:divinity_app/features/events/presentation/student_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEventRepository implements EventRepository {
  _FakeEventRepository({this.published = const [], this.all = const []});

  final List<Event> published;
  final List<Event> all;

  @override
  Future<List<Event>> fetchPublishedForStudent(String studentId) async =>
      published;

  @override
  Future<List<Event>> fetchAllForAdmin() async => all;

  @override
  Future<Event> createEvent(Event event, {required String createdBy}) async =>
      event;

  @override
  Future<Event> updateEvent(String id, Event event) async => event;

  @override
  Future<void> deleteEvent(String id) async {}

  @override
  Future<void> register({
    required String eventId,
    required String studentId,
  }) async {}

  @override
  Future<void> unregister({
    required String eventId,
    required String studentId,
  }) async {}
}

Event _event({
  String id = 'e-1',
  String title = 'Sunrise Camp',
  int? capacity,
  int registrationCount = 0,
  bool isRegistered = false,
}) =>
    Event.fromMap({
      'id': id,
      'title': title,
      'location': 'Rishikesh',
      'starts_at': '2026-08-01T06:00:00.000Z',
      'capacity': capacity,
      'status': 'PUBLISHED',
      'created_at': '2026-06-16T10:00:00.000Z',
      'event_registrations': [
        {'count': registrationCount}
      ],
      'is_registered': isRegistered,
    });

Widget _wrap(Widget child, {required EventRepository repo, String uid = 'u'}) {
  return ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue(uid),
      eventRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(theme: AppTheme.dark(), home: child),
  );
}

void main() {
  group('StudentEventsScreen', () {
    testWidgets('shows empty state when no events', (tester) async {
      await tester.pumpWidget(
        _wrap(const StudentEventsScreen(), repo: _FakeEventRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.text('No upcoming events'), findsOneWidget);
    });

    testWidgets('renders event with Register CTA', (tester) async {
      await tester.pumpWidget(
        _wrap(const StudentEventsScreen(),
            repo: _FakeEventRepository(published: [_event()])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sunrise Camp'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Register'), findsOneWidget);
    });

    testWidgets('shows Full and disables CTA when at capacity', (tester) async {
      await tester.pumpWidget(
        _wrap(const StudentEventsScreen(),
            repo: _FakeEventRepository(
                published: [_event(capacity: 1, registrationCount: 1)])),
      );
      await tester.pumpAndSettle();
      final btn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Full'),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('registered event shows Going chip and Cancel', (tester) async {
      await tester.pumpWidget(
        _wrap(const StudentEventsScreen(),
            repo: _FakeEventRepository(published: [_event(isRegistered: true)])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Going'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    });
  });

  group('AdminEventsScreen', () {
    testWidgets('shows empty state and CTA', (tester) async {
      await tester.pumpWidget(
        _wrap(const AdminEventsScreen(), repo: _FakeEventRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.text('No events yet'), findsOneWidget);
      expect(find.widgetWithText(FloatingActionButton, 'New Event'),
          findsOneWidget);
    });

    testWidgets('renders event with registration count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AdminEventsScreen(),
          repo: _FakeEventRepository(
              all: [_event(capacity: 10, registrationCount: 4)]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sunrise Camp'), findsOneWidget);
      expect(find.textContaining('4 / 10 registered'), findsOneWidget);
    });
  });
}
