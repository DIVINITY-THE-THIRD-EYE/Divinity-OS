import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/attendance_record.dart';

/// Thrown when the server rejects a check-in (outside geofence, not enrolled,
/// no active batch). Carries a user-facing message from the RPC.
class CheckInException implements Exception {
  CheckInException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class AttendanceRepository {
  Future<AttendanceRecord?> fetchTodayRecord(String studentId);
  Future<List<AttendanceRecord>> fetchHistory(String studentId, {int days = 30});

  /// Records the current user's check-in via the server-side `check_in` RPC,
  /// which validates the geofence and forces marked_by=STUDENT. The user id is
  /// derived server-side from auth.uid(). Throws [CheckInException] if rejected.
  Future<AttendanceRecord> checkIn({
    required double lat,
    required double lng,
    String? batchId,
  });
  Future<AttendanceRecord> updateStatus(
    String id,
    AttendanceStatus status, {
    MarkedBy markedBy = MarkedBy.admin,
  });
  /// Returns the first active enrollment's batch row for the given student, or null.
  Future<Map<String, dynamic>?> fetchActiveBatch(String studentId);
  Future<List<Map<String, dynamic>>> fetchBatchAttendanceToday(String batchId);
  Future<List<Map<String, dynamic>>> fetchBatchesAttendanceToday(List<String> batchIds);

  /// Upserts an attendance record on behalf of a trainer.
  Future<void> trainerMark({
    required String studentId,
    required String batchId,
    required AttendanceStatus status,
  });
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
  Future<AttendanceRecord> checkIn({
    required double lat,
    required double lng,
    String? batchId,
  }) async {
    try {
      // Server validates geofence + enrollment, forces student_id & marked_by.
      final data = await _client.rpc('check_in', params: {
        'p_lat': lat,
        'p_lng': lng,
        'p_batch_id': batchId,
      });
      // `returns public.attendance` → single object; tolerate a 1-element list.
      final map = data is List
          ? (data.first as Map<String, dynamic>)
          : (data as Map<String, dynamic>);
      return AttendanceRecord.fromMap(map);
    } on PostgrestException catch (e) {
      throw CheckInException(e.message);
    }
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
        .select('batch_id, batches(id, name, location_lat, location_lng, radius_meters, schedule_time, days_of_week, trainer_id, users(name))')
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

  @override
  Future<List<Map<String, dynamic>>> fetchBatchesAttendanceToday(
    List<String> batchIds,
  ) async {
    if (batchIds.isEmpty) return [];
    final rows = await _client
        .from('attendance')
        .select('*, users(id, name, phone)')
        .inFilter('batch_id', batchIds)
        .eq('date', _today());
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> trainerMark({
    required String studentId,
    required String batchId,
    required AttendanceStatus status,
  }) async {
    await _client.from('attendance').upsert(
      {
        'student_id': studentId,
        'batch_id': batchId,
        'date': _today(),
        'status': status.dbValue,
        'marked_by': 'TRAINER',
      },
      onConflict: 'student_id,date',
    );
  }
}
