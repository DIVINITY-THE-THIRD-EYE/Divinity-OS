import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/enrollment_repository.dart';
import '../domain/enrollment.dart';
import '../domain/waitlist_entry.dart';

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>(
  (ref) => SupabaseEnrollmentRepository(ref.watch(supabaseClientProvider)),
);

class EnrollmentNotifier extends FamilyAsyncNotifier<List<Enrollment>, String> {
  @override
  Future<List<Enrollment>> build(String batchId) =>
      ref.read(enrollmentRepositoryProvider).fetchByBatch(batchId);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(enrollmentRepositoryProvider).fetchByBatch(arg),
    );
  }

  Future<void> enroll(String studentId) async {
    final uid = ref.read(currentUserIdProvider)!;
    await ref
        .read(enrollmentRepositoryProvider)
        .enroll(studentId: studentId, batchId: arg, assignedBy: uid);
    await refresh();
  }

  Future<void> unenroll(String enrollmentId) async {
    await ref.read(enrollmentRepositoryProvider).unenroll(enrollmentId);
    state = AsyncData(
      (state.value ?? []).where((e) => e.id != enrollmentId).toList(),
    );
  }
}

final batchEnrollmentsProvider =
    AsyncNotifierProvider.family<EnrollmentNotifier, List<Enrollment>, String>(
      EnrollmentNotifier.new,
    );

// ── Student's own enrollment requests (across all batches) ─────────────────

class MyEnrollmentsNotifier extends AsyncNotifier<List<Enrollment>> {
  @override
  Future<List<Enrollment>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref.read(enrollmentRepositoryProvider).fetchMyEnrollments(uid);
  }

  Future<String> request(String batchId) async {
    final result = await ref
        .read(enrollmentRepositoryProvider)
        .requestEnrollment(batchId);
    state = const AsyncLoading();
    final uid = ref.read(currentUserIdProvider);
    if (uid != null) {
      state = await AsyncValue.guard(
        () => ref.read(enrollmentRepositoryProvider).fetchMyEnrollments(uid),
      );
    }
    return result;
  }
}

final myEnrollmentsProvider =
    AsyncNotifierProvider<MyEnrollmentsNotifier, List<Enrollment>>(
      MyEnrollmentsNotifier.new,
    );

// ── Admin: pending enrollment requests + waitlist ───────────────────────────

class PendingEnrollmentsNotifier extends AsyncNotifier<List<Enrollment>> {
  @override
  Future<List<Enrollment>> build() =>
      ref.read(enrollmentRepositoryProvider).fetchPendingRequests();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(enrollmentRepositoryProvider).fetchPendingRequests(),
    );
  }

  Future<void> respond(String enrollmentId, {required bool approve}) async {
    await ref
        .read(enrollmentRepositoryProvider)
        .respondToRequest(enrollmentId, approve: approve);
    state = AsyncData(
      (state.value ?? []).where((e) => e.id != enrollmentId).toList(),
    );
  }
}

final pendingEnrollmentsProvider =
    AsyncNotifierProvider<PendingEnrollmentsNotifier, List<Enrollment>>(
      PendingEnrollmentsNotifier.new,
    );

class WaitlistNotifier extends AsyncNotifier<List<WaitlistEntry>> {
  @override
  Future<List<WaitlistEntry>> build() =>
      ref.read(enrollmentRepositoryProvider).fetchWaitlist();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(enrollmentRepositoryProvider).fetchWaitlist(),
    );
  }

  Future<void> convert(String waitlistId) async {
    await ref
        .read(enrollmentRepositoryProvider)
        .convertWaitlistEntry(waitlistId);
    state = AsyncData(
      (state.value ?? []).where((w) => w.id != waitlistId).toList(),
    );
  }
}

final waitlistProvider =
    AsyncNotifierProvider<WaitlistNotifier, List<WaitlistEntry>>(
      WaitlistNotifier.new,
    );
