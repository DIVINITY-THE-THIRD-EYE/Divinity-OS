enum SupportTicketStatus {
  open,
  resolved;

  static SupportTicketStatus fromString(String v) => switch (v.toUpperCase()) {
    'RESOLVED' => SupportTicketStatus.resolved,
    _ => SupportTicketStatus.open,
  };

  String get dbValue => name.toUpperCase();

  String get label => switch (this) {
    SupportTicketStatus.open => 'Open',
    SupportTicketStatus.resolved => 'Resolved',
  };
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String? studentName;
  final String subject;
  final String description;
  final SupportTicketStatus status;
  final DateTime createdAt;

  factory SupportTicket.fromMap(Map<String, dynamic> m) {
    String? studentName;
    final studentData = m['student'] ?? m['users'];
    if (studentData is Map<String, dynamic>) {
      studentName = studentData['name'] as String?;
    }
    return SupportTicket(
      id: m['id'] as String,
      studentId: m['student_id'] as String,
      studentName: studentName,
      subject: m['subject'] as String,
      description: m['description'] as String,
      status: SupportTicketStatus.fromString(m['status'] as String? ?? 'OPEN'),
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }
}
