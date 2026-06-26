import 'package:intl/intl.dart';

enum AttendanceStatus {
  present,
  absent,
  excused,
  onLeave,
  holiday,
  cancelled;

  static AttendanceStatus fromString(String v) => switch (v.toUpperCase()) {
        'PRESENT' => AttendanceStatus.present,
        'EXCUSED' => AttendanceStatus.excused,
        'ON_LEAVE' => AttendanceStatus.onLeave,
        'HOLIDAY' => AttendanceStatus.holiday,
        'CANCELLED' => AttendanceStatus.cancelled,
        _ => AttendanceStatus.absent,
      };

  String get dbValue => switch (this) {
        AttendanceStatus.present => 'PRESENT',
        AttendanceStatus.absent => 'ABSENT',
        AttendanceStatus.excused => 'EXCUSED',
        AttendanceStatus.onLeave => 'ON_LEAVE',
        AttendanceStatus.holiday => 'HOLIDAY',
        AttendanceStatus.cancelled => 'CANCELLED',
      };

  String get label => switch (this) {
        AttendanceStatus.present => 'Present',
        AttendanceStatus.absent => 'Absent',
        AttendanceStatus.excused => 'Excused',
        AttendanceStatus.onLeave => 'On Leave',
        AttendanceStatus.holiday => 'Holiday',
        AttendanceStatus.cancelled => 'Cancelled',
      };
}

enum MarkedBy {
  student,
  trainer,
  admin,
  system;

  static MarkedBy fromString(String? v) => switch (v?.toUpperCase()) {
        'TRAINER' => MarkedBy.trainer,
        'ADMIN' => MarkedBy.admin,
        'SYSTEM' => MarkedBy.system,
        _ => MarkedBy.student,
      };

  String get dbValue => name.toUpperCase();

  String get label => switch (this) {
        MarkedBy.student => 'Student',
        MarkedBy.trainer => 'Trainer',
        MarkedBy.admin => 'Admin',
        MarkedBy.system => 'System',
      };
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.studentId,
    this.batchId,
    required this.date,
    this.checkinTime,
    required this.status,
    required this.markedBy,
  });

  final String id;
  final String studentId;
  final String? batchId;
  final DateTime date;
  final DateTime? checkinTime;
  final AttendanceStatus status;
  final MarkedBy markedBy;

  factory AttendanceRecord.fromMap(Map<String, dynamic> m) => AttendanceRecord(
        id: m['id'] as String,
        studentId: m['student_id'] as String,
        batchId: m['batch_id'] as String?,
        date: DateTime.parse(m['date'] as String),
        checkinTime: m['checkin_time'] != null
            ? DateTime.parse(m['checkin_time'] as String)
            : null,
        status:
            AttendanceStatus.fromString(m['status'] as String? ?? 'ABSENT'),
        markedBy: MarkedBy.fromString(m['marked_by'] as String?),
      );

  String get dateLabel => DateFormat('dd MMM yyyy').format(date);
}
