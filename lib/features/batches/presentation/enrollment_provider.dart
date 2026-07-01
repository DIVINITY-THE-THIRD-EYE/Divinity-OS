import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/enrollment_repository.dart';
import '../domain/enrollment.dart';

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
