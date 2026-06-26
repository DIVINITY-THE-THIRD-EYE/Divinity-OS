import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/notification_repository.dart';
import '../domain/app_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) =>
      SupabaseNotificationRepository(ref.watch(supabaseClientProvider)),
);

class MyNotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);

    // Establish a Realtime listener to push new notifications to the client
    final client = ref.watch(supabaseClientProvider);
    final channel = client.channel('public:notifications:user_id=eq.$uid');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: uid,
      ),
      callback: (payload) {
        ref.invalidateSelf();
      },
    );
    channel.subscribe();

    ref.onDispose(() {
      client.removeChannel(channel);
    });

    return ref
        .read(notificationRepositoryProvider)
        .fetchMyNotifications(uid);
  }

  Future<void> markRead(String id) async {
    final updated =
        await ref.read(notificationRepositoryProvider).markRead(id);
    state = AsyncData(
      (state.value ?? [])
          .map((n) => n.id == updated.id ? updated : n)
          .toList(),
    );
  }

  Future<void> markAllRead() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ref.read(notificationRepositoryProvider).markAllRead(uid);
    state = AsyncData(
      (state.value ?? []).map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  Future<void> refresh() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(notificationRepositoryProvider)
          .fetchMyNotifications(uid),
    );
  }
}

final myNotificationsProvider =
    AsyncNotifierProvider<MyNotificationsNotifier, List<AppNotification>>(
  MyNotificationsNotifier.new,
);

/// Derived count of unread notifications — cheap, no extra fetch.
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(myNotificationsProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
