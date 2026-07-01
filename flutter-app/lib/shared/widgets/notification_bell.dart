import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/presentation/notification_provider.dart';
import '../../features/notifications/presentation/notifications_screen.dart';

/// AppBar action icon that shows the unread notification count as a badge.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);

    return IconButton(
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 9 ? '9+' : '$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
      tooltip: 'Notifications',
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
    );
  }
}
