class Enrollment {
  const Enrollment({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentPhone,
    this.studentEmail,
    required this.batchId,
    required this.assignedAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String? studentPhone;
  final String? studentEmail;
  final String batchId;
  final DateTime assignedAt;

  factory Enrollment.fromMap(Map<String, dynamic> m) {
    final user = m['users'] as Map<String, dynamic>? ?? {};
    return Enrollment(
      id: m['id'] as String,
      studentId: m['student_id'] as String,
      studentName: user['name'] as String? ?? 'Unnamed',
      studentPhone: user['phone'] as String?,
      studentEmail: user['email'] as String?,
      batchId: m['batch_id'] as String,
      assignedAt: DateTime.parse(m['assigned_at'] as String),
    );
  }
}
