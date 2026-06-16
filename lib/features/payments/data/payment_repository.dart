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
  });
  Future<PaymentRecord> updateStatus(String id, PaymentStatus status);
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
  }) async {
    final insert = <String, dynamic>{
      'student_id': studentId,
      'amount': amount,
      'payment_method': method.dbValue,
      'status': 'PAID',
    };
    if (referenceNumber != null) insert['reference_number'] = referenceNumber;
    if (notes != null) insert['notes'] = notes;
    if (recordedBy != null) insert['recorded_by'] = recordedBy;
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
}
