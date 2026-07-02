class WaitlistEntry {
  const WaitlistEntry({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.batchId,
    required this.batchName,
    required this.requestedAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String batchId;
  final String batchName;
  final DateTime requestedAt;

  factory WaitlistEntry.fromMap(Map<String, dynamic> m) {
    final user = m['users'] as Map<String, dynamic>? ?? {};
    final batch = m['batches'] as Map<String, dynamic>? ?? {};
    return WaitlistEntry(
      id: m['id'] as String,
      studentId: m['student_id'] as String,
      studentName: user['name'] as String? ?? 'Unnamed',
      batchId: m['batch_id'] as String,
      batchName: batch['name'] as String? ?? 'Batch',
      requestedAt: DateTime.parse(m['requested_at'] as String),
    );
  }
}
