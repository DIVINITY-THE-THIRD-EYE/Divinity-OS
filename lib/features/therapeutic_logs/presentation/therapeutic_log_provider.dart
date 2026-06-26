import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/therapeutic_log_repository.dart';
import '../domain/therapeutic_log.dart';

final therapeuticLogRepositoryProvider = Provider<TherapeuticLogRepository>(
  (ref) => SupabaseTherapeuticLogRepository(ref.watch(supabaseClientProvider)),
);

// ── Trainer's log list (all logs this trainer wrote) ─────────────────────────

class TrainerLogsNotifier extends AsyncNotifier<List<TherapeuticLog>> {
  @override
  Future<List<TherapeuticLog>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref
        .read(therapeuticLogRepositoryProvider)
        .fetchByTrainer(uid);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => future);
  }

  Future<void> add({
    required String studentId,
    required String note,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final log = await ref.read(therapeuticLogRepositoryProvider).addLog(
          studentId: studentId,
          trainerId: uid,
          note: note,
        );
    state = AsyncData([log, ...state.value ?? []]);
  }

  Future<void> remove(String id) async {
    await ref.read(therapeuticLogRepositoryProvider).deleteLog(id);
    state = AsyncData(
      (state.value ?? []).where((l) => l.id != id).toList(),
    );
  }
}

final trainerLogsProvider =
    AsyncNotifierProvider<TrainerLogsNotifier, List<TherapeuticLog>>(
  TrainerLogsNotifier.new,
);

// ── Student-specific logs (family provider) ───────────────────────────────────

class StudentLogsNotifier
    extends FamilyAsyncNotifier<List<TherapeuticLog>, String> {
  @override
  Future<List<TherapeuticLog>> build(String studentId) =>
      ref
          .read(therapeuticLogRepositoryProvider)
          .fetchForStudent(studentId);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(therapeuticLogRepositoryProvider)
          .fetchForStudent(arg),
    );
  }

  Future<void> add({
    required String note,
    required String trainerId,
  }) async {
    final log = await ref.read(therapeuticLogRepositoryProvider).addLog(
          studentId: arg,
          trainerId: trainerId,
          note: note,
        );
    state = AsyncData([log, ...state.value ?? []]);
  }
}

final studentLogsProvider = AsyncNotifierProvider.family<StudentLogsNotifier,
    List<TherapeuticLog>, String>(StudentLogsNotifier.new);
