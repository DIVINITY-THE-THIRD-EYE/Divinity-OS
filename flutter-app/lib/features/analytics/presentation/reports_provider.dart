import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart' show supabaseClientProvider;
import '../data/reports_repository.dart';
import '../domain/reports_data.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>(
  (ref) => SupabaseReportsRepository(ref.watch(supabaseClientProvider)),
);

class ReportsFilterNotifier extends StateNotifier<ReportFilters> {
  ReportsFilterNotifier() : super(const ReportFilters());

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: () => date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: () => date);
  }

  void setTrainerId(String? trainerId) {
    state = state.copyWith(trainerId: () => trainerId);
  }

  void setBatchId(String? batchId) {
    state = state.copyWith(batchId: () => batchId);
  }

  void setMembershipPlan(String? plan) {
    state = state.copyWith(membershipPlan: () => plan);
  }

  void setStudentStatus(String? status) {
    state = state.copyWith(studentStatus: () => status);
  }

  void setEventId(String? eventId) {
    state = state.copyWith(eventId: () => eventId);
  }

  void clear() {
    state = const ReportFilters();
  }
}

final reportsFilterProvider =
    StateNotifierProvider<ReportsFilterNotifier, ReportFilters>(
      (ref) => ReportsFilterNotifier(),
    );

final reportsDataProvider = FutureProvider<ReportsData>((ref) {
  final filters = ref.watch(reportsFilterProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchReports(filters);
});
