import 'package:intl/intl.dart';

enum NotificationKind {
  general,
  leaveApproved,
  leaveRejected,
  paymentDue,
  batchUpdate,
  attendance;

  static NotificationKind fromString(String v) => switch (v.toUpperCase()) {
    'LEAVE_APPROVED' => NotificationKind.leaveApproved,
    'LEAVE_REJECTED' => NotificationKind.leaveRejected,
    'PAYMENT_DUE' => NotificationKind.paymentDue,
    'BATCH_UPDATE' => NotificationKind.batchUpdate,
    'ATTENDANCE' => NotificationKind.attendance,
    _ => NotificationKind.general,
  };

  String get dbValue => switch (this) {
    NotificationKind.general => 'GENERAL',
    NotificationKind.leaveApproved => 'LEAVE_APPROVED',
    NotificationKind.leaveRejected => 'LEAVE_REJECTED',
    NotificationKind.paymentDue => 'PAYMENT_DUE',
    NotificationKind.batchUpdate => 'BATCH_UPDATE',
    NotificationKind.attendance => 'ATTENDANCE',
  };
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    this.body,
    required this.isRead,
    this.metadata,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final NotificationKind kind;
  final String title;
  final String? body;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
    id: m['id'] as String,
    userId: m['user_id'] as String,
    kind: NotificationKind.fromString(m['kind'] as String? ?? 'GENERAL'),
    title: m['title'] as String,
    body: m['body'] as String?,
    isRead: m['is_read'] as bool? ?? false,
    metadata: m['metadata'] as Map<String, dynamic>?,
    createdAt: DateTime.parse(m['created_at'] as String),
  );

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    userId: userId,
    kind: kind,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    metadata: metadata,
    createdAt: createdAt,
  );

  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(createdAt);
  }
}
