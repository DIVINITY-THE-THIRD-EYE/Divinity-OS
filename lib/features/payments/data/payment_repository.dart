import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/payment_record.dart';

abstract interface class PaymentRepository {
  Future<List<PaymentRecord>> fetchStudentPayments(String studentId);
  Future<List<PaymentRecord>> fetchAllPayments();
  Future<PaymentRecord> recordPayment({
    required String studentId,
    required double amount,
    required PaymentMethod method,
    String? referenceNumber,
    String? notes,
    String? recordedBy,
    String? screenshotUrl,
    PaymentStatus status = PaymentStatus.paid,
    bool adminApproved = false,
    bool receiptGivenByTrainer = false,
    DateTime? planExpirationDate,
  });
  Future<PaymentRecord> updateStatus(String id, PaymentStatus status);
  Future<PaymentRecord> approvePayment(String id, DateTime expirationDate);
  Future<PaymentRecord> rejectPayment(String id);
  Future<PaymentRecord> confirmTrainerReceipt(String id);
  Future<String> uploadScreenshot({
    required String userId,
    required String filename,
    required List<int> bytes,
  });
}

class SupabasePaymentRepository implements PaymentRepository {
  SupabasePaymentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PaymentRecord>> fetchStudentPayments(String studentId) async {
    final rows = await _client
        .from('payments')
        .select()
        .eq('student_id', studentId)
        .order('paid_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => PaymentRecord.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PaymentRecord>> fetchAllPayments() async {
    final rows = await _client
        .from('payments')
        .select('*, users(id, name, phone)')
        .order('paid_at', ascending: false)
        .limit(100);
    return (rows as List<dynamic>)
        .map((r) => PaymentRecord.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PaymentRecord> recordPayment({
    required String studentId,
    required double amount,
    required PaymentMethod method,
    String? referenceNumber,
    String? notes,
    String? recordedBy,
    String? screenshotUrl,
    PaymentStatus status = PaymentStatus.paid,
    bool adminApproved = false,
    bool receiptGivenByTrainer = false,
    DateTime? planExpirationDate,
  }) async {
    final insert = <String, dynamic>{
      'student_id': studentId,
      'amount': amount,
      'payment_method': method.dbValue,
      'status': status.dbValue,
      'admin_approved': adminApproved,
      'receipt_given_by_trainer': receiptGivenByTrainer,
    };
    if (referenceNumber != null) insert['reference_number'] = referenceNumber;
    if (notes != null) insert['notes'] = notes;
    if (recordedBy != null) insert['recorded_by'] = recordedBy;
    if (screenshotUrl != null) insert['screenshot_url'] = screenshotUrl;
    if (planExpirationDate != null) {
      insert['plan_expiration_date'] = DateFormat('yyyy-MM-dd').format(planExpirationDate);
    }
    
    final row = await _client
        .from('payments')
        .insert(insert)
        .select()
        .single();
    return PaymentRecord.fromMap(row);
  }

  @override
  Future<PaymentRecord> updateStatus(String id, PaymentStatus status) async {
    final row = await _client
        .from('payments')
        .update({'status': status.dbValue})
        .eq('id', id)
        .select()
        .single();
    return PaymentRecord.fromMap(row);
  }

  @override
  Future<PaymentRecord> approvePayment(String id, DateTime expirationDate) async {
    final row = await _client
        .from('payments')
        .update({
          'admin_approved': true,
          'plan_expiration_date': DateFormat('yyyy-MM-dd').format(expirationDate),
        })
        .eq('id', id)
        .select()
        .single();
    return PaymentRecord.fromMap(row);
  }

  @override
  Future<PaymentRecord> rejectPayment(String id) async {
    final row = await _client
        .from('payments')
        .update({'status': 'FAILED'})
        .eq('id', id)
        .select()
        .single();
    return PaymentRecord.fromMap(row);
  }

  @override
  Future<PaymentRecord> confirmTrainerReceipt(String id) async {
    final row = await _client
        .from('payments')
        .update({'receipt_given_by_trainer': true})
        .eq('id', id)
        .select()
        .single();
    return PaymentRecord.fromMap(row);
  }

  @override
  Future<String> uploadScreenshot({
    required String userId,
    required String filename,
    required List<int> bytes,
  }) async {
    final path = '$userId/$filename';
    await _client.storage.from('payment_screenshots').uploadBinary(
          path,
          bytes as dynamic,
          fileOptions: const FileOptions(upsert: true),
        );
    // Return a 10-year signed URL so the bucket can be set to private in
    // Supabase Storage settings (LB-5). The URL is stored in payments.screenshot_url
    // and is only accessible by the holder, unlike a public URL.
    return _client.storage
        .from('payment_screenshots')
        .createSignedUrl(path, 315360000); // 10 years
  }
}
