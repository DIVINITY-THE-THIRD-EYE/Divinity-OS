import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/app_notification.dart';
import 'notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myNotificationsProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(myNotificationsProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 64,
                    color: AppColors.accentViolet.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text('All caught up', style: tt.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'No notifications yet.',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(myNotificationsProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
              itemBuilder: (ctx, i) {
                final n = notifications[i];
                return _NotificationTile(
                  notification: n,
                  onTap: n.isRead
                      ? null
                      : () => ref
                            .read(myNotificationsProvider.notifier)
                            .markRead(n.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, this.onTap});
  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final kindColor = _kindColor(notification.kind);

    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: notification.isRead
            ? Colors.transparent
            : colors.primaryContainer.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: kindColor.withValues(alpha: 0.15),
                child: Icon(
                  _kindIcon(notification.kind),
                  color: kindColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notification.timeLabel,
                          style: tt.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    if (notification.body != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body!,
                        style: tt.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _kindIcon(NotificationKind k) => switch (k) {
    NotificationKind.leaveApproved => Icons.check_circle_outline,
    NotificationKind.leaveRejected => Icons.cancel_outlined,
    NotificationKind.paymentDue => Icons.payment_outlined,
    NotificationKind.batchUpdate => Icons.groups_outlined,
    NotificationKind.attendance => Icons.how_to_reg_outlined,
    NotificationKind.general => Icons.info_outline,
  };

  Color _kindColor(NotificationKind k) => switch (k) {
    NotificationKind.leaveApproved => Colors.green,
    NotificationKind.leaveRejected => Colors.red,
    NotificationKind.paymentDue => Colors.orange,
    NotificationKind.batchUpdate => Colors.blue,
    NotificationKind.attendance => Colors.teal,
    NotificationKind.general => Colors.grey,
  };
}
