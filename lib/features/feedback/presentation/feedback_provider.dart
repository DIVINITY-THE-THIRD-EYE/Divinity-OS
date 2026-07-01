import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/feedback_repository.dart';
import '../data/supabase_feedback_repository.dart';
import '../domain/student_feedback.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return SupabaseFeedbackRepository(ref.watch(supabaseClientProvider));
});

// ── Student's own feedback list ──────────────────────────────────────────────

class MyFeedbackNotifier extends AsyncNotifier<List<StudentFeedback>> {
  @override
  Future<List<StudentFeedback>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref.read(feedbackRepositoryProvider).fetchMyFeedback(uid);
  }

  Future<void> submit({
    String? trainerId,
    String? batchId,
    required int rating,
    String? comments,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final created = await ref.read(feedbackRepositoryProvider).submitFeedback(
          studentId: uid,
          trainerId: trainerId,
          batchId: batchId,
          rating: rating,
          comments: comments,
        );
    state = AsyncData([created, ...state.value ?? []]);
  }
}

final myFeedbackProvider =
    AsyncNotifierProvider<MyFeedbackNotifier, List<StudentFeedback>>(
  MyFeedbackNotifier.new,
);

// ── All feedback (Admin view) ────────────────────────────────────────────────

class AllFeedbackNotifier extends AsyncNotifier<List<StudentFeedback>> {
  @override
  Future<List<StudentFeedback>> build() {
    return ref.read(feedbackRepositoryProvider).fetchAllFeedback();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(feedbackRepositoryProvider).fetchAllFeedback(),
    );
  }
}

final allFeedbackProvider =
    AsyncNotifierProvider<AllFeedbackNotifier, List<StudentFeedback>>(
  AllFeedbackNotifier.new,
);

// ── Batch feedback (Trainer view) ────────────────────────────────────────────

class BatchFeedbackNotifier extends FamilyAsyncNotifier<List<StudentFeedback>, String> {
  @override
  Future<List<StudentFeedback>> build(String arg) {
    return ref.read(feedbackRepositoryProvider).fetchBatchFeedback(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(feedbackRepositoryProvider).fetchBatchFeedback(arg),
    );
  }
}

final batchFeedbackProvider =
    AsyncNotifierProviderFamily<BatchFeedbackNotifier, List<StudentFeedback>, String>(
  BatchFeedbackNotifier.new,
);
