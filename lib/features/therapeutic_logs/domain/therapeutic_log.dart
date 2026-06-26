import 'package:intl/intl.dart';

class TherapeuticLog {
  const TherapeuticLog({
    required this.id,
    required this.studentId,
    this.trainerId,
    this.trainerName,
    this.studentName,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String? trainerId;
  final String? trainerName;
  final String? studentName;
  final String note;
  final DateTime createdAt;

  factory TherapeuticLog.fromMap(Map<String, dynamic> m) {
    final trainerRow = m['trainer'] as Map<String, dynamic>?;
    final studentRow = m['student'] as Map<String, dynamic>?;
    return TherapeuticLog(
      id: m['id'] as String,
      studentId: m['student_id'] as String,
      trainerId: m['trainer_id'] as String?,
      trainerName: trainerRow?['name'] as String?,
      studentName: studentRow?['name'] as String?,
      note: m['note'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }

  String get dateLabel =>
      DateFormat('d MMM yyyy, HH:mm').format(createdAt.toLocal());
}
