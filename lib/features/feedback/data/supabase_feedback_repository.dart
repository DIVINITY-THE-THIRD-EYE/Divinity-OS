import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/student_feedback.dart';
import 'feedback_repository.dart';

class SupabaseFeedbackRepository implements FeedbackRepository {
  SupabaseFeedbackRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<StudentFeedback>> fetchMyFeedback(String studentId) async {
    final rows = await _client
        .from('student_feedback')
        .select(
          '*, student:users!student_feedback_student_id_fkey(name), trainer:users!student_feedback_trainer_id_fkey(name), batches(name)',
        )
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => StudentFeedback.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StudentFeedback>> fetchAllFeedback() async {
    final rows = await _client
        .from('student_feedback')
        .select(
          '*, student:users!student_feedback_student_id_fkey(name), trainer:users!student_feedback_trainer_id_fkey(name), batches(name)',
        )
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => StudentFeedback.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StudentFeedback>> fetchBatchFeedback(String batchId) async {
    final rows = await _client
        .from('student_feedback')
        .select(
          '*, student:users!student_feedback_student_id_fkey(name), trainer:users!student_feedback_trainer_id_fkey(name), batches(name)',
        )
        .eq('batch_id', batchId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => StudentFeedback.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StudentFeedback> submitFeedback({
    required String studentId,
    String? trainerId,
    String? batchId,
    required int rating,
    String? comments,
  }) async {
    final row = await _client
        .from('student_feedback')
        .insert({
          'student_id': studentId,
          'trainer_id': trainerId,
          'batch_id': batchId,
          'rating': rating,
          if (comments != null && comments.isNotEmpty) 'comments': comments,
        })
        .select(
          '*, student:users!student_feedback_student_id_fkey(name), trainer:users!student_feedback_trainer_id_fkey(name), batches(name)',
        )
        .single();
    return StudentFeedback.fromMap(row);
  }
}
