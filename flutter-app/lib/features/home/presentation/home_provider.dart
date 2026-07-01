import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/auth_provider.dart';
import '../data/home_repository.dart';
import '../domain/home_data.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => SupabaseHomeRepository(ref.watch(supabaseClientProvider)),
);

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw StateError('Not authenticated');
  return ref.read(homeRepositoryProvider).fetchHomeData(userId);
});
