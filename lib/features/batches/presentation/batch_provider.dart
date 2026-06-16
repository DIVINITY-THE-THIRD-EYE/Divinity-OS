import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/batch_repository.dart';
import '../domain/batch.dart';

final batchRepositoryProvider = Provider<BatchRepository>(
  (ref) => SupabaseBatchRepository(ref.watch(supabaseClientProvider)),
);

class BatchNotifier extends AsyncNotifier<List<Batch>> {
  @override
  Future<List<Batch>> build() => _load();

  Future<List<Batch>> _load() =>
      ref.read(batchRepositoryProvider).fetchBatches();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> createBatch(Batch batch) async {
    final repo = ref.read(batchRepositoryProvider);
    final created = await repo.createBatch(batch);
    state = AsyncData([...state.value ?? [], created]);
  }

  Future<void> updateBatch(String id, Map<String, dynamic> updates) async {
    final repo = ref.read(batchRepositoryProvider);
    final updated = await repo.updateBatch(id, updates);
    state = AsyncData(
      (state.value ?? []).map((b) => b.id == id ? updated : b).toList(),
    );
  }
}

final batchesProvider =
    AsyncNotifierProvider<BatchNotifier, List<Batch>>(BatchNotifier.new);
