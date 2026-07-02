import 'package:intl/intl.dart';

enum LeaveStatus {
  pending,
  approved,
  rejected;

  static LeaveStatus fromString(String v) => switch (v.toUpperCase()) {
    'APPROVED' => LeaveStatus.approved,
    'REJECTED' => LeaveStatus.rejected,
    _ => LeaveStatus.pending,
  };

  String get dbValue => name.toUpperCase();

  String get label => switch (this) {
    LeaveStatus.pending => 'Pending',
    LeaveStatus.approved => 'Approved',
    LeaveStatus.rejected => 'Rejected',
  };
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.status,
    this.approvedBy,
    this.isAutoApproved = false,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String? studentName;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final LeaveStatus status;
  final String? approvedBy;
  final bool isAutoApproved;
  final DateTime createdAt;

  int get durationDays => endDate.difference(startDate).inDays + 1;

  String get dateRangeLabel {
    final fmt = DateFormat('dd MMM');
    return '${fmt.format(startDate)} – ${fmt.format(endDate)}';
  }

  factory LeaveRequest.fromMap(Map<String, dynamic> m) {
    String? studentName;
    final users = m['users'];
    if (users is Map<String, dynamic>) {
      studentName = users['name'] as String?;
    }
    return LeaveRequest(
      id: m['id'] as String,
      studentId: m['student_id'] as String,
      studentName: studentName,
      startDate: DateTime.parse(m['start_date'] as String),
      endDate: DateTime.parse(m['end_date'] as String),
      reason: m['reason'] as String?,
      status: LeaveStatus.fromString(m['status'] as String? ?? 'PENDING'),
      approvedBy: m['approved_by'] as String?,
      isAutoApproved: m['is_auto_approved'] as bool? ?? false,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }
}
