import 'package:intl/intl.dart';

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded;

  static PaymentStatus fromString(String v) => switch (v.toUpperCase()) {
    'PAID' => PaymentStatus.paid,
    'FAILED' => PaymentStatus.failed,
    'REFUNDED' => PaymentStatus.refunded,
    _ => PaymentStatus.pending,
  };

  String get dbValue => switch (this) {
    PaymentStatus.pending => 'PENDING',
    PaymentStatus.paid => 'PAID',
    PaymentStatus.failed => 'FAILED',
    PaymentStatus.refunded => 'REFUNDED',
  };

  String get label => switch (this) {
    PaymentStatus.pending => 'Pending',
    PaymentStatus.paid => 'Paid',
    PaymentStatus.failed => 'Failed',
    PaymentStatus.refunded => 'Refunded',
  };
}

enum PaymentMethod {
  cash,
  upi,
  bankTransfer;

  static PaymentMethod fromString(String v) => switch (v.toUpperCase()) {
    'UPI' => PaymentMethod.upi,
    'BANK_TRANSFER' => PaymentMethod.bankTransfer,
    _ => PaymentMethod.cash,
  };

  String get dbValue => switch (this) {
    PaymentMethod.cash => 'CASH',
    PaymentMethod.upi => 'UPI',
    PaymentMethod.bankTransfer => 'BANK_TRANSFER',
  };

  String get label => switch (this) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.upi => 'UPI',
    PaymentMethod.bankTransfer => 'Bank Transfer',
  };
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.studentId,
    this.studentName,
    this.recordedBy,
    required this.amount,
    this.currency = 'INR',
    required this.method,
    required this.status,
    this.referenceNumber,
    this.notes,
    this.screenshotUrl,
    this.planId,
    required this.paidAt,
    required this.createdAt,
    this.adminApproved = false,
    this.receiptGivenByTrainer = false,
    this.planExpirationDate,
  });

  final String id;
  final String studentId;
  final String? studentName;
  final String? recordedBy;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? referenceNumber;
  final String? notes;
  final String? screenshotUrl;
  final String? planId;
  final DateTime paidAt;
  final DateTime createdAt;
  final bool adminApproved;
  final bool receiptGivenByTrainer;
  final DateTime? planExpirationDate;

  factory PaymentRecord.fromMap(Map<String, dynamic> m) {
    final usersMap = m['users'] as Map<String, dynamic>?;
    return PaymentRecord(
      id: m['id'] as String,
      studentId: m['student_id'] as String,
      studentName: usersMap?['name'] as String?,
      recordedBy: m['recorded_by'] as String?,
      amount: (m['amount'] as num).toDouble(),
      currency: m['currency'] as String? ?? 'INR',
      method: PaymentMethod.fromString(
        m['payment_method'] as String? ?? 'CASH',
      ),
      status: PaymentStatus.fromString(m['status'] as String? ?? 'PAID'),
      referenceNumber: m['reference_number'] as String?,
      notes: m['notes'] as String?,
      screenshotUrl: m['screenshot_url'] as String?,
      planId: m['plan_id'] as String?,
      paidAt: DateTime.parse(
        m['paid_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(m['created_at'] as String),
      adminApproved: m['admin_approved'] as bool? ?? false,
      receiptGivenByTrainer: m['receipt_given_by_trainer'] as bool? ?? false,
      planExpirationDate: m['plan_expiration_date'] != null
          ? DateTime.parse(m['plan_expiration_date'] as String)
          : null,
    );
  }

  String get amountLabel => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  ).format(amount);

  String get dateLabel => DateFormat('dd MMM yyyy').format(paidAt);
}
