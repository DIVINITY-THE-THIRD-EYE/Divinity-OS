import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/transformation_score.dart';

abstract interface class TransformationRepository {
  Future<List<TransformationScore>> fetchScoresForStudent(String studentId);
  Future<void> setWeeklyScore(TransformationScore score);
}

class SupabaseTransformationRepository implements TransformationRepository {
  SupabaseTransformationRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<TransformationScore>> fetchScoresForStudent(
    String studentId,
  ) async {
    final rows = await _client
        .from('transformation_scores')
        .select()
        .eq('student_id', studentId)
        .order('week_start_date', ascending: true);
    return (rows as List<dynamic>)
        .map((r) => TransformationScore.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setWeeklyScore(TransformationScore score) async {
    final map = score.toMap();
    await _client
        .from('transformation_scores')
        .upsert(map, onConflict: 'student_id,week_start_date');
  }
}
