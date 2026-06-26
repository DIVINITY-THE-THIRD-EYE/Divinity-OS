import 'package:divinity_app/features/auth/presentation/auth_provider.dart'
    show currentUserIdProvider, supabaseClientProvider;
import 'package:divinity_app/features/notifications/data/notification_repository.dart';
import 'package:divinity_app/features/notifications/domain/app_notification.dart';
import 'package:divinity_app/features/notifications/presentation/notification_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

// ── Helpers ───────────────────────────────────────────────────────────────────

AppNotification _fakeNotification({
  String id = 'notif-1',
  NotificationKind kind = NotificationKind.general,
  bool isRead = false,
  String title = 'Test notification',
  String? body,
}) =>
    AppNotification(
      id: id,
      userId: 'user-1',
      kind: kind,
      title: title,
      body: body,
      isRead: isRead,
      createdAt: DateTime(2026, 6, 16, 10),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(NotificationKind.general);
    registerFallbackValue(PostgresChangeEvent.all);
    registerFallbackValue(PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'user_id',
      value: 'user-1',
    ));
    registerFallbackValue(MockRealtimeChannel());
  });

  // ── NotificationKind parsing ───────────────────────────────────────────────

  group('NotificationKind.fromString', () {
    test('parses all known values', () {
      expect(NotificationKind.fromString('GENERAL'),
          NotificationKind.general);
      expect(NotificationKind.fromString('LEAVE_APPROVED'),
          NotificationKind.leaveApproved);
      expect(NotificationKind.fromString('LEAVE_REJECTED'),
          NotificationKind.leaveRejected);
      expect(NotificationKind.fromString('PAYMENT_DUE'),
          NotificationKind.paymentDue);
      expect(NotificationKind.fromString('BATCH_UPDATE'),
          NotificationKind.batchUpdate);
      expect(NotificationKind.fromString('ATTENDANCE'),
          NotificationKind.attendance);
    });

    test('defaults to general for unknown', () {
      expect(NotificationKind.fromString('TYPO'), NotificationKind.general);
      expect(NotificationKind.fromString(''), NotificationKind.general);
    });

    test('dbValue round-trips', () {
      for (final k in NotificationKind.values) {
        expect(NotificationKind.fromString(k.dbValue), k);
      }
    });
  });

  // ── AppNotification model ──────────────────────────────────────────────────

  group('AppNotification', () {
    test('fromMap parses correctly', () {
      final n = AppNotification.fromMap({
        'id': 'n-1',
        'user_id': 'user-1',
        'kind': 'LEAVE_APPROVED',
        'title': 'Leave approved',
        'body': 'Your leave from 20–22 Jun has been approved.',
        'is_read': false,
        'created_at': '2026-06-16T09:00:00.000Z',
      });
      expect(n.id, 'n-1');
      expect(n.kind, NotificationKind.leaveApproved);
      expect(n.title, 'Leave approved');
      expect(n.isRead, false);
    });

    test('fromMap handles null body and metadata', () {
      final n = AppNotification.fromMap({
        'id': 'n-1',
        'user_id': 'user-1',
        'kind': 'GENERAL',
        'title': 'Hello',
        'is_read': true,
        'created_at': '2026-06-16T09:00:00.000Z',
      });
      expect(n.body, isNull);
      expect(n.metadata, isNull);
      expect(n.isRead, true);
    });

    test('copyWith updates isRead', () {
      final n = _fakeNotification();
      final updated = n.copyWith(isRead: true);
      expect(updated.isRead, true);
      expect(updated.id, n.id);
      expect(updated.title, n.title);
    });

    test('timeLabel returns "Just now" for very recent', () {
      final n = AppNotification(
        id: 'n-1',
        userId: 'user-1',
        kind: NotificationKind.general,
        title: 'Test',
        isRead: true,
        createdAt: DateTime.now(),
      );
      expect(n.timeLabel, 'Just now');
    });
  });

  // ── MyNotificationsNotifier ────────────────────────────────────────────────

  group('MyNotificationsNotifier', () {
    late MockNotificationRepository mockRepo;
    late MockSupabaseClient mockClient;
    late MockRealtimeChannel mockChannel;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockNotificationRepository();
      mockClient = MockSupabaseClient();
      mockChannel = MockRealtimeChannel();

      when(() => mockClient.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
            event: any(named: 'event'),
            schema: any(named: 'schema'),
            table: any(named: 'table'),
            filter: any(named: 'filter'),
            callback: any(named: 'callback'),
          )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenReturn(mockChannel);
      when(() => mockClient.removeChannel(any())).thenAnswer((_) async => '');

      container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue('user-1'),
          supabaseClientProvider.overrideWithValue(mockClient),
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('markRead updates notification in list', () async {
      when(() => mockRepo.fetchMyNotifications(any()))
          .thenAnswer((_) async => [_fakeNotification()]);
      await container.read(myNotificationsProvider.future);

      final readNotif = _fakeNotification(isRead: true);
      when(() => mockRepo.markRead(any()))
          .thenAnswer((_) async => readNotif);

      await container
          .read(myNotificationsProvider.notifier)
          .markRead('notif-1');

      final state = container.read(myNotificationsProvider).value!;
      expect(state.first.isRead, true);
    });

    test('markAllRead sets all to read', () async {
      when(() => mockRepo.fetchMyNotifications(any())).thenAnswer(
          (_) async => [
                _fakeNotification(id: 'n-1'),
                _fakeNotification(id: 'n-2'),
              ]);
      await container.read(myNotificationsProvider.future);

      when(() => mockRepo.markAllRead(any())).thenAnswer((_) async {});

      await container
          .read(myNotificationsProvider.notifier)
          .markAllRead();

      final state = container.read(myNotificationsProvider).value!;
      expect(state.every((n) => n.isRead), true);
    });

    test('refresh reloads notifications', () async {
      when(() => mockRepo.fetchMyNotifications(any()))
          .thenAnswer((_) async => [_fakeNotification()]);
      await container.read(myNotificationsProvider.future);
      expect(container.read(myNotificationsProvider).value!.length, 1);

      when(() => mockRepo.fetchMyNotifications(any())).thenAnswer(
          (_) async => [
                _fakeNotification(id: 'n-1'),
                _fakeNotification(id: 'n-2'),
              ]);
      await container.read(myNotificationsProvider.notifier).refresh();
      expect(container.read(myNotificationsProvider).value!.length, 2);
    });
  });

  // ── unreadCountProvider ────────────────────────────────────────────────────

  group('unreadCountProvider', () {
    test('counts unread notifications correctly', () async {
      final mockRepo = MockNotificationRepository();
      final mockClient = MockSupabaseClient();
      final mockChannel = MockRealtimeChannel();

      when(() => mockClient.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
            event: any(named: 'event'),
            schema: any(named: 'schema'),
            table: any(named: 'table'),
            filter: any(named: 'filter'),
            callback: any(named: 'callback'),
          )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenReturn(mockChannel);
      when(() => mockClient.removeChannel(any())).thenAnswer((_) async => '');

      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue('user-1'),
          supabaseClientProvider.overrideWithValue(mockClient),
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      when(() => mockRepo.fetchMyNotifications(any())).thenAnswer(
          (_) async => [
                _fakeNotification(id: 'n-1'),
                _fakeNotification(id: 'n-2', isRead: true),
                _fakeNotification(id: 'n-3'),
              ]);
      await container.read(myNotificationsProvider.future);

      expect(container.read(unreadCountProvider), 2);
      container.dispose();
    });

    test('returns 0 when all read', () async {
      final mockRepo = MockNotificationRepository();
      final mockClient = MockSupabaseClient();
      final mockChannel = MockRealtimeChannel();

      when(() => mockClient.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
            event: any(named: 'event'),
            schema: any(named: 'schema'),
            table: any(named: 'table'),
            filter: any(named: 'filter'),
            callback: any(named: 'callback'),
          )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenReturn(mockChannel);
      when(() => mockClient.removeChannel(any())).thenAnswer((_) async => '');

      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue('user-1'),
          supabaseClientProvider.overrideWithValue(mockClient),
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      when(() => mockRepo.fetchMyNotifications(any())).thenAnswer(
          (_) async => [
                _fakeNotification(id: 'n-1', isRead: true),
                _fakeNotification(id: 'n-2', isRead: true),
              ]);
      // all read → unread count = 0
      await container.read(myNotificationsProvider.future);

      expect(container.read(unreadCountProvider), 0);
      container.dispose();
    });
  });
}
