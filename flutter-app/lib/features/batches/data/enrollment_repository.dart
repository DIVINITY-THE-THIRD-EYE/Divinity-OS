import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/enrollment.dart';

abstract interface class EnrollmentRepository {
  Future<List<Enrollment>> fetchByBatch(String batchId);
  Future<void> enroll({
    required String studentId,
    required String batchId,
    required String assignedBy,
  });
  Future<void> unenroll(String enrollmentId);
}

class SupabaseEnrollmentRepository implements EnrollmentRepository {
  SupabaseEnrollmentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Enrollment>> fetchByBatch(String batchId) async {
    final rows = await _client
        .from('enrollments')
        .select('*, users(id, name, phone, email)')
        .eq('batch_id', batchId)
        .order('assigned_at');
    return (rows as List<dynamic>)
        .map((r) => Enrollment.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> enroll({
    required String studentId,
    required String batchId,
    required String assignedBy,
  }) async {
    await _client.from('enrollments').insert({
      'student_id': studentId,
      'batch_id': batchId,
      'assigned_by': assignedBy,
    });
  }

  @override
  Future<void> unenroll(String enrollmentId) async {
    await _client.from('enrollments').delete().eq('id', enrollmentId);
  }
}
