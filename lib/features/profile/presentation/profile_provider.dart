import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/auth_provider.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
);

final myProfileProvider =
    AsyncNotifierProvider<MyProfileNotifier, UserProfile>(
  MyProfileNotifier.new,
);

class MyProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) throw StateError('Not authenticated');
    return ref.read(profileRepositoryProvider).fetchProfile(userId);
  }

  Future<void> updateName(String name) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).updateName(userId, name);
      return ref.read(profileRepositoryProvider).fetchProfile(userId);
    });
  }

  Future<void> updateEmergencyContact({
    required String name,
    required String phone,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(profileRepositoryProvider)
          .updateEmergencyContact(userId, name: name, phone: phone);
      return ref.read(profileRepositoryProvider).fetchProfile(userId);
    });
  }
}
