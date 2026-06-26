import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/therapeutic_log.dart';

abstract interface class TherapeuticLogRepository {
  /// Returns all logs for a given student, newest first.
  Future<List<TherapeuticLog>> fetchForStudent(String studentId);
  /// Returns all logs written by a given trainer, newest first.
  Future<List<TherapeuticLog>> fetchByTrainer(String trainerId);
  Future<TherapeuticLog> addLog({
    required String studentId,
    required String trainerId,
    required String note,
  });
  Future<void> deleteLog(String id);
}

class SupabaseTherapeuticLogRepository implements TherapeuticLogRepository {
  SupabaseTherapeuticLogRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<TherapeuticLog>> fetchForStudent(String studentId) async {
    final rows = await _client
        .from('therapeutic_logs')
        .select('*, trainer:trainer_id(name)')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => TherapeuticLog.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TherapeuticLog>> fetchByTrainer(String trainerId) async {
    final rows = await _client
        .from('therapeutic_logs')
        .select('*, student:student_id(name)')
        .eq('trainer_id', trainerId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => TherapeuticLog.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TherapeuticLog> addLog({
    required String studentId,
    required String trainerId,
    required String note,
  }) async {
    final row = await _client
        .from('therapeutic_logs')
        .insert({
          'student_id': studentId,
          'trainer_id': trainerId,
          'note': note,
        })
        .select('*, trainer:trainer_id(name)')
        .single();
    return TherapeuticLog.fromMap(row);
  }

  @override
  Future<void> deleteLog(String id) async {
    await _client.from('therapeutic_logs').delete().eq('id', id);
  }
}
