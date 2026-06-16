import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_provider.dart';
import 'fcm_service.dart';

final fcmServiceProvider = Provider<FcmService>(
  (ref) => FcmService(ref.watch(supabaseClientProvider)),
);

/// Emits a `target` string whenever the user taps a push notification.
/// Notifications should include `data: {'target': '<tab-name>'}`.
/// Emits once for the launch message (app was terminated) and then for
/// each subsequent background→foreground tap.
final fcmNotificationTapProvider = StreamProvider<String>((ref) {
  final controller = StreamController<String>.broadcast();

  FirebaseMessaging.instance.getInitialMessage().then((msg) {
    final target = msg?.data['target'] as String?;
    if (target != null && target.isNotEmpty) controller.add(target);
  });

  final sub = FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    final target = msg.data['target'] as String?;
    if (target != null && target.isNotEmpty) controller.add(target);
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
