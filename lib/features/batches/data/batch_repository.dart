import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/batch.dart';

abstract interface class BatchRepository {
  Future<List<Batch>> fetchBatches();
  Future<Batch> createBatch(Batch batch);
  Future<Batch> updateBatch(String id, Map<String, dynamic> updates);
  Future<void> deleteBatch(String id);
}

class SupabaseBatchRepository implements BatchRepository {
  SupabaseBatchRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Batch>> fetchBatches() async {
    final rows = await _client
        .from('batches')
        .select()
        .order('created_at');
    return (rows as List<dynamic>)
        .map((r) => Batch.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Batch> createBatch(Batch batch) async {
    final row = await _client
        .from('batches')
        .insert(batch.toInsertMap())
        .select()
        .single();
    return Batch.fromMap(row);
  }

  @override
  Future<Batch> updateBatch(String id, Map<String, dynamic> updates) async {
    final row = await _client
        .from('batches')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return Batch.fromMap(row);
  }

  @override
  Future<void> deleteBatch(String id) async {
    await _client.from('batches').delete().eq('id', id);
  }
}
