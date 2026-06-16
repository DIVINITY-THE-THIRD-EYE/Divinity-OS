import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/attendance_record.dart';

abstract interface class AttendanceRepository {
  Future<AttendanceRecord?> fetchTodayRecord(String studentId);
  Future<List<AttendanceRecord>> fetchHistory(String studentId, {int days = 30});
  Future<AttendanceRecord> checkIn(String studentId, {String? batchId});
  Future<AttendanceRecord> updateStatus(
    String id,
    AttendanceStatus status, {
    MarkedBy markedBy = MarkedBy.admin,
  });
  /// Returns the first active enrollment's batch row for the given student, or null.
  Future<Map<String, dynamic>?> fetchActiveBatch(String studentId);
  Future<List<Map<String, dynamic>>> fetchBatchAttendanceToday(String batchId);
}

class SupabaseAttendanceRepository implements AttendanceRepository {
  SupabaseAttendanceRepository(this._client);

  final SupabaseClient _client;

  static String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Future<AttendanceRecord?> fetchTodayRecord(String studentId) async {
    final row = await _client
        .from('attendance')
        .select()
        .eq('student_id', studentId)
        .eq('date', _today())
        .maybeSingle();
    return row == null ? null : AttendanceRecord.fromMap(row);
  }

  @override
  Future<List<AttendanceRecord>> fetchHistory(
    String studentId, {
    int days = 30,
  }) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceStr = DateFormat('yyyy-MM-dd').format(since);
    final rows = await _client
        .from('attendance')
        .select()
        .eq('student_id', studentId)
        .gte('date', sinceStr)
        .order('date', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => AttendanceRecord.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceRecord> checkIn(String studentId, {String? batchId}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final insert = {
      'student_id': studentId,
      'batch_id': ?batchId,
      'date': _today(),
      'checkin_time': now,
      'status': 'PRESENT',
      'marked_by': 'STUDENT',
    };
    // Use upsert so a second tap just refreshes the checkin_time.
    final row = await _client
        .from('attendance')
        .upsert(insert, onConflict: 'student_id,date')
        .select()
        .single();
    return AttendanceRecord.fromMap(row);
  }

  @override
  Future<AttendanceRecord> updateStatus(
    String id,
    AttendanceStatus status, {
    MarkedBy markedBy = MarkedBy.admin,
  }) async {
    final row = await _client
        .from('attendance')
        .update({'status': status.dbValue, 'marked_by': markedBy.dbValue})
        .eq('id', id)
        .select()
        .single();
    return AttendanceRecord.fromMap(row);
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveBatch(String studentId) async {
    // Returns the batch row for the student's first enrollment that has a location.
    final rows = await _client
        .from('enrollments')
        .select('batch_id, batches(id, name, location_lat, location_lng, schedule_time)')
        .eq('student_id', studentId)
        .limit(1);
    final list = rows as List<dynamic>;
    if (list.isEmpty) return null;
    return (list.first as Map<String, dynamic>)['batches'] as Map<String, dynamic>?;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBatchAttendanceToday(
    String batchId,
  ) async {
    final rows = await _client
        .from('attendance')
        .select('*, users(id, name, phone)')
        .eq('batch_id', batchId)
        .eq('date', _today());
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
