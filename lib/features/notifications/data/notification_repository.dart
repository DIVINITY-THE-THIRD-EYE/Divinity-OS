import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_notification.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> fetchMyNotifications(String userId);
  Future<int> fetchUnreadCount(String userId);
  Future<AppNotification> markRead(String id);
  Future<void> markAllRead(String userId);
  Future<AppNotification> sendNotification({
    required String userId,
    required NotificationKind kind,
    required String title,
    String? body,
    Map<String, dynamic>? metadata,
  });
}

class SupabaseNotificationRepository implements NotificationRepository {
  SupabaseNotificationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AppNotification>> fetchMyNotifications(String userId) async {
    final rows = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return (rows as List<dynamic>)
        .map((r) => AppNotification.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> fetchUnreadCount(String userId) async {
    final result = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .count();
    return result.count;
  }

  @override
  Future<AppNotification> markRead(String id) async {
    final row = await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id)
        .select()
        .single();
    return AppNotification.fromMap(row);
  }

  @override
  Future<void> markAllRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<AppNotification> sendNotification({
    required String userId,
    required NotificationKind kind,
    required String title,
    String? body,
    Map<String, dynamic>? metadata,
  }) async {
    final insert = <String, dynamic>{
      'user_id': userId,
      'kind': kind.dbValue,
      'title': title,
    };
    if (body != null) insert['body'] = body;
    if (metadata != null) insert['metadata'] = metadata;
    final row = await _client
        .from('notifications')
        .insert(insert)
        .select()
        .single();
    return AppNotification.fromMap(row);
  }
}
