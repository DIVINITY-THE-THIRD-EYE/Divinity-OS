import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/leave_request.dart';

abstract interface class LeaveRepository {
  Future<List<LeaveRequest>> fetchMyRequests(String studentId);
  Future<List<LeaveRequest>> fetchPendingRequests();
  Future<LeaveRequest> submitRequest({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  });
  Future<LeaveRequest> updateStatus(
    String id,
    LeaveStatus status,
    String approvedBy,
  );
}

class SupabaseLeaveRepository implements LeaveRepository {
  SupabaseLeaveRepository(this._client);

  final SupabaseClient _client;

  static String _dateStr(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  Future<List<LeaveRequest>> fetchMyRequests(String studentId) async {
    final rows = await _client
        .from('leave_requests')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => LeaveRequest.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LeaveRequest>> fetchPendingRequests() async {
    final rows = await _client
        .from('leave_requests')
        .select('*, users(id, name)')
        .eq('status', 'PENDING')
        .order('created_at');
    return (rows as List<dynamic>)
        .map((r) => LeaveRequest.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LeaveRequest> submitRequest({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    final row = await _client
        .from('leave_requests')
        .insert({
          'student_id': studentId,
          'start_date': _dateStr(startDate),
          'end_date': _dateStr(endDate),
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        })
        .select()
        .single();
    return LeaveRequest.fromMap(row);
  }

  @override
  Future<LeaveRequest> updateStatus(
    String id,
    LeaveStatus status,
    String approvedBy,
  ) async {
    final row = await _client
        .from('leave_requests')
        .update({'status': status.dbValue, 'approved_by': approvedBy})
        .eq('id', id)
        .select()
        .single();
    return LeaveRequest.fromMap(row);
  }
}
