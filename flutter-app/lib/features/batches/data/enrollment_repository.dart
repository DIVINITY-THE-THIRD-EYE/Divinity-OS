import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/enrollment.dart';
import '../domain/waitlist_entry.dart';

abstract interface class EnrollmentRepository {
  Future<List<Enrollment>> fetchByBatch(String batchId);
  Future<void> enroll({
    required String studentId,
    required String batchId,
    required String assignedBy,
  });
  Future<void> unenroll(String enrollmentId);

  /// Student-facing: request to join a batch. Returns 'PENDING' if the
  /// request is awaiting staff confirmation, or 'WAITLISTED' if the batch
  /// was full. Also returns the existing status ('PENDING'/'CONFIRMED') if
  /// the student had already requested/joined.
  Future<String> requestEnrollment(String batchId);

  Future<List<Enrollment>> fetchMyEnrollments(String studentId);
  Future<List<Enrollment>> fetchPendingRequests();
  Future<Enrollment> respondToRequest(
    String enrollmentId, {
    required bool approve,
  });

  Future<List<WaitlistEntry>> fetchWaitlist();
  Future<void> convertWaitlistEntry(String waitlistId);
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
        .eq('status', 'CONFIRMED')
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

  @override
  Future<String> requestEnrollment(String batchId) async {
    final result = await _client.rpc(
      'request_enrollment',
      params: {'p_batch_id': batchId},
    );
    return result as String;
  }

  @override
  Future<List<Enrollment>> fetchMyEnrollments(String studentId) async {
    final rows = await _client
        .from('enrollments')
        .select()
        .eq('student_id', studentId);
    return (rows as List<dynamic>)
        .map((r) => Enrollment.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Enrollment>> fetchPendingRequests() async {
    final rows = await _client
        .from('enrollments')
        .select('*, users(id, name, phone, email)')
        .eq('status', 'PENDING')
        .order('assigned_at');
    return (rows as List<dynamic>)
        .map((r) => Enrollment.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Enrollment> respondToRequest(
    String enrollmentId, {
    required bool approve,
  }) async {
    final row = await _client
        .from('enrollments')
        .update({'status': approve ? 'CONFIRMED' : 'REJECTED'})
        .eq('id', enrollmentId)
        .select('*, users(id, name, phone, email)')
        .single();
    return Enrollment.fromMap(row);
  }

  @override
  Future<List<WaitlistEntry>> fetchWaitlist() async {
    final rows = await _client
        .from('batch_waitlist')
        .select('*, users(id, name), batches(id, name)')
        .eq('status', 'WAITING')
        .order('requested_at');
    return (rows as List<dynamic>)
        .map((r) => WaitlistEntry.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> convertWaitlistEntry(String waitlistId) async {
    await _client.rpc(
      'convert_waitlist_entry',
      params: {'p_waitlist_id': waitlistId},
    );
  }
}
