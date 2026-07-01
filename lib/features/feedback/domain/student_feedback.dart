class StudentFeedback {
  const StudentFeedback({
    required this.id,
    required this.studentId,
    this.studentName,
    this.trainerId,
    this.trainerName,
    this.batchId,
    this.batchName,
    required this.rating,
    this.comments,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String? studentName;
  final String? trainerId;
  final String? trainerName;
  final String? batchId;
  final String? batchName;
  final int rating;
  final String? comments;
  final DateTime createdAt;

  factory StudentFeedback.fromMap(Map<String, dynamic> m) {
    String? studentName;
    String? trainerName;
    String? batchName;

    // Handle student user data join
    final studentData = m['student'];
    if (studentData is Map<String, dynamic>) {
      studentName = studentData['name'] as String?;
    } else {
      final userData = m['users'];
      if (userData is Map<String, dynamic>) {
        studentName = userData['name'] as String?;
      }
    }

    // Handle trainer user data join
    final trainerData = m['trainer'];
    if (trainerData is Map<String, dynamic>) {
      trainerName = trainerData['name'] as String?;
    }

    // Handle batch data join
    final batchData = m['batches'];
    if (batchData is Map<String, dynamic>) {
      batchName = batchData['name'] as String?;
    }

    return StudentFeedback(
      id: m['id'] as String,
      studentId: m['student_id'] as String,
      studentName: studentName,
      trainerId: m['trainer_id'] as String?,
      trainerName: trainerName,
      batchId: m['batch_id'] as String?,
      batchName: batchName,
      rating: m['rating'] as int,
      comments: m['comments'] as String?,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }
}
