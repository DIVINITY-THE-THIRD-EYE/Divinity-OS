import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/auth_provider.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => SupabaseDashboardRepository(ref.watch(supabaseClientProvider)),
);

final dashboardStatsProvider = FutureProvider<DashboardStats>(
  (ref) => ref.watch(dashboardRepositoryProvider).fetchStats(),
);
