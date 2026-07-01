import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin static wrapper so any screen can fire events without provider wiring.
class AnalyticsService {
  static final _fa = FirebaseAnalytics.instance;

  static Future<void> logLogin() => _fa.logLogin(loginMethod: 'phone_otp');

  static Future<void> logCheckIn({required String batchId}) =>
      _fa.logEvent(name: 'check_in', parameters: {'batch_id': batchId});

  static Future<void> logLeaveRequestSubmit() =>
      _fa.logEvent(name: 'leave_request_submit');

  static Future<void> logPaymentSubmit({required String planType}) =>
      _fa.logEvent(name: 'payment_submit', parameters: {'plan_type': planType});

  static Future<void> logTrainerMarkAttendance({
    required String batchId,
    required String status,
  }) => _fa.logEvent(
    name: 'trainer_mark_attendance',
    parameters: {'batch_id': batchId, 'status': status},
  );

  static Future<void> logBatchCreate({required String batchName}) =>
      _fa.logEvent(name: 'batch_create', parameters: {'batch_name': batchName});

  static Future<void> logStudentEnroll({required String batchId}) =>
      _fa.logEvent(name: 'student_enroll', parameters: {'batch_id': batchId});

  static Future<void> logPaymentRecord({
    required double amount,
    required String method,
  }) => _fa.logEvent(
    name: 'payment_recorded',
    parameters: {'amount': amount, 'method': method},
  );

  static Future<void> logOnboardingComplete({required String goal}) =>
      _fa.logEvent(name: 'onboarding_complete', parameters: {'goal': goal});

  static Future<void> logMockLocationBlocked() =>
      _fa.logEvent(name: 'mock_location_blocked');
}
