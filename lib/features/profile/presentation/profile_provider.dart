import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../features/auth/presentation/auth_provider.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
);

final myProfileProvider = AsyncNotifierProvider<MyProfileNotifier, UserProfile>(
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

  Future<void> pauseMembership() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);

      await ref
          .read(supabaseClientProvider)
          .from('users')
          .update({'plan_status': 'PAUSED', 'pause_start_date': todayStr})
          .eq('id', userId);

      return ref.read(profileRepositoryProvider).fetchProfile(userId);
    });
  }

  Future<void> resumeMembership() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final profile = await ref
          .read(profileRepositoryProvider)
          .fetchProfile(userId);
      if (profile.planStatus.toUpperCase() != 'PAUSED' ||
          profile.pauseStartDate == null) {
        return profile;
      }

      final today = DateTime.now();
      final difference = today.difference(profile.pauseStartDate!).inDays;
      final offsetDays = difference > 0 ? difference : 0;

      DateTime newExpiration = today;
      if (profile.expirationDate != null) {
        newExpiration = profile.expirationDate!.add(Duration(days: offsetDays));
      } else {
        newExpiration = today.add(const Duration(days: 30));
      }

      final newExpStr = DateFormat('yyyy-MM-dd').format(newExpiration);

      await ref
          .read(supabaseClientProvider)
          .from('users')
          .update({
            'plan_status': 'ACTIVE',
            'pause_start_date': null,
            'expiration_date': newExpStr,
          })
          .eq('id', userId);

      return ref.read(profileRepositoryProvider).fetchProfile(userId);
    });
  }
}
