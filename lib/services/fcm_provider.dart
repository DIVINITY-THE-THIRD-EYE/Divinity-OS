import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_provider.dart';
import 'fcm_service.dart';

final fcmServiceProvider = Provider<FcmService>(
  (ref) => FcmService(ref.watch(supabaseClientProvider)),
);
