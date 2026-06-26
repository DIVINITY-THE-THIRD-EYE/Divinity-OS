import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/transformation_repository.dart';
import '../domain/transformation_score.dart';

final transformationRepositoryProvider = Provider<TransformationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseTransformationRepository(client);
});

final studentScoresProvider = FutureProvider<List<TransformationScore>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const [];
  return ref.watch(transformationRepositoryProvider).fetchScoresForStudent(uid);
});

final studentScoresHistoryProvider = FutureProvider.family<List<TransformationScore>, String>((ref, studentId) async {
  return ref.watch(transformationRepositoryProvider).fetchScoresForStudent(studentId);
});

class RecordScoreNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveScore(TransformationScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(transformationRepositoryProvider).setWeeklyScore(score);
      ref.invalidate(studentScoresProvider);
      ref.invalidate(studentScoresHistoryProvider(score.studentId));
    });
  }
}

final recordScoreNotifierProvider = AutoDisposeAsyncNotifierProvider<RecordScoreNotifier, void>(
  RecordScoreNotifier.new,
);
