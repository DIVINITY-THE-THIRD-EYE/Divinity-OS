import '../domain/student_feedback.dart';

abstract interface class FeedbackRepository {
  Future<List<StudentFeedback>> fetchMyFeedback(String studentId);
  Future<List<StudentFeedback>> fetchAllFeedback();
  Future<List<StudentFeedback>> fetchBatchFeedback(String batchId);
  Future<StudentFeedback> submitFeedback({
    required String studentId,
    String? trainerId,
    String? batchId,
    required int rating,
    String? comments,
  });
}
