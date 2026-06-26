import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/leave_repository.dart';
import '../domain/leave_request.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>(
  (ref) => SupabaseLeaveRepository(ref.watch(supabaseClientProvider)),
);

// ── Student's own leave requests ──────────────────────────────────────────────

class MyLeaveNotifier extends AsyncNotifier<List<LeaveRequest>> {
  @override
  Future<List<LeaveRequest>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref.read(leaveRepositoryProvider).fetchMyRequests(uid);
  }

  Future<void> submit({
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final created = await ref.read(leaveRepositoryProvider).submitRequest(
          studentId: uid,
          startDate: startDate,
          endDate: endDate,
          reason: reason,
        );
    state = AsyncData([created, ...state.value ?? []]);
  }
}

final myLeaveProvider =
    AsyncNotifierProvider<MyLeaveNotifier, List<LeaveRequest>>(
  MyLeaveNotifier.new,
);

// ── Pending requests (trainer/admin view) ─────────────────────────────────────

class PendingLeaveNotifier extends AsyncNotifier<List<LeaveRequest>> {
  @override
  Future<List<LeaveRequest>> build() =>
      ref.read(leaveRepositoryProvider).fetchPendingRequests();

  Future<void> approve(String id, {required String approvedBy}) async {
    final updated = await ref
        .read(leaveRepositoryProvider)
        .updateStatus(id, LeaveStatus.approved, approvedBy);
    _replace(updated);
  }

  Future<void> reject(String id, {required String approvedBy}) async {
    final updated = await ref
        .read(leaveRepositoryProvider)
        .updateStatus(id, LeaveStatus.rejected, approvedBy);
    _replace(updated);
  }

  void _replace(LeaveRequest updated) {
    state = AsyncData(
      (state.value ?? []).map((r) => r.id == updated.id ? updated : r).toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(leaveRepositoryProvider).fetchPendingRequests(),
    );
  }
}

final pendingLeaveProvider =
    AsyncNotifierProvider<PendingLeaveNotifier, List<LeaveRequest>>(
  PendingLeaveNotifier.new,
);
