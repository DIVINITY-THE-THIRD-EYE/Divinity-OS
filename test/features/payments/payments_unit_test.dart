import 'package:divinity_app/features/auth/presentation/auth_provider.dart'
    show currentUserIdProvider;
import 'package:divinity_app/features/payments/data/payment_repository.dart';
import 'package:divinity_app/features/payments/domain/payment_record.dart';
import 'package:divinity_app/features/payments/presentation/payment_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockPaymentRepository extends Mock implements PaymentRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

PaymentRecord _fakeRecord({
  String id = 'pay-1',
  PaymentStatus status = PaymentStatus.paid,
  double amount = 5000,
  PaymentMethod method = PaymentMethod.cash,
  String? studentName,
}) =>
    PaymentRecord(
      id: id,
      studentId: 'user-1',
      studentName: studentName,
      amount: amount,
      method: method,
      status: status,
      paidAt: DateTime(2026, 6, 16),
      createdAt: DateTime(2026, 6, 16),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(PaymentStatus.paid);
    registerFallbackValue(PaymentMethod.cash);
  });

  // ── PaymentStatus parsing ──────────────────────────────────────────────────

  group('PaymentStatus.fromString', () {
    test('parses known values', () {
      expect(PaymentStatus.fromString('PAID'), PaymentStatus.paid);
      expect(PaymentStatus.fromString('PENDING'), PaymentStatus.pending);
      expect(PaymentStatus.fromString('FAILED'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('REFUNDED'), PaymentStatus.refunded);
    });

    test('defaults to pending for unknown', () {
      expect(PaymentStatus.fromString('TYPO'), PaymentStatus.pending);
      expect(PaymentStatus.fromString(''), PaymentStatus.pending);
    });

    test('dbValue round-trips', () {
      for (final s in PaymentStatus.values) {
        expect(PaymentStatus.fromString(s.dbValue), s);
      }
    });
  });

  // ── PaymentMethod parsing ──────────────────────────────────────────────────

  group('PaymentMethod.fromString', () {
    test('parses known values', () {
      expect(PaymentMethod.fromString('CASH'), PaymentMethod.cash);
      expect(PaymentMethod.fromString('UPI'), PaymentMethod.upi);
      expect(PaymentMethod.fromString('BANK_TRANSFER'),
          PaymentMethod.bankTransfer);
      expect(PaymentMethod.fromString('RAZORPAY'), PaymentMethod.razorpay);
    });

    test('defaults to cash for unknown', () {
      expect(PaymentMethod.fromString('TYPO'), PaymentMethod.cash);
    });

    test('dbValue round-trips', () {
      for (final m in PaymentMethod.values) {
        expect(PaymentMethod.fromString(m.dbValue), m);
      }
    });

    test('label is human-readable', () {
      expect(PaymentMethod.bankTransfer.label, 'Bank Transfer');
      expect(PaymentMethod.upi.label, 'UPI');
    });
  });

  // ── PaymentRecord model ────────────────────────────────────────────────────

  group('PaymentRecord', () {
    test('fromMap parses correctly', () {
      final record = PaymentRecord.fromMap({
        'id': 'pay-99',
        'student_id': 'user-1',
        'amount': 6000,
        'currency': 'INR',
        'payment_method': 'UPI',
        'status': 'PAID',
        'paid_at': '2026-06-16T10:00:00.000Z',
        'created_at': '2026-06-16T10:00:00.000Z',
      });
      expect(record.id, 'pay-99');
      expect(record.amount, 6000.0);
      expect(record.method, PaymentMethod.upi);
      expect(record.status, PaymentStatus.paid);
    });

    test('fromMap extracts student name from joined users row', () {
      final record = PaymentRecord.fromMap({
        'id': 'pay-1',
        'student_id': 'user-1',
        'users': {'id': 'user-1', 'name': 'Riya Sharma'},
        'amount': 3000,
        'payment_method': 'CASH',
        'status': 'PAID',
        'paid_at': '2026-06-16T10:00:00.000Z',
        'created_at': '2026-06-16T10:00:00.000Z',
      });
      expect(record.studentName, 'Riya Sharma');
    });

    test('fromMap handles null optional fields', () {
      final record = PaymentRecord.fromMap({
        'id': 'pay-1',
        'student_id': 'user-1',
        'amount': 500,
        'payment_method': 'CASH',
        'status': 'PAID',
        'paid_at': '2026-06-16T10:00:00.000Z',
        'created_at': '2026-06-16T10:00:00.000Z',
      });
      expect(record.referenceNumber, isNull);
      expect(record.notes, isNull);
      expect(record.razorpayOrderId, isNull);
      expect(record.studentName, isNull);
    });

    test('amountLabel formats as Indian currency', () {
      final record = _fakeRecord();
      expect(record.amountLabel, contains('₹'));
      expect(record.amountLabel, contains('5,000'));
    });

    test('dateLabel formats date', () {
      final record = _fakeRecord();
      expect(record.dateLabel, '16 Jun 2026');
    });
  });

  // ── AllPaymentsNotifier ────────────────────────────────────────────────────

  group('AllPaymentsNotifier', () {
    late MockPaymentRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockPaymentRepository();
      container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue('admin-1'),
          paymentRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads all payments on build', () async {
      when(() => mockRepo.fetchAllPayments())
          .thenAnswer((_) async => [_fakeRecord()]);

      final result =
          await container.read(allPaymentsProvider.future);
      expect(result.length, 1);
      expect(result.first.id, 'pay-1');
    });

    test('record prepends new payment to list', () async {
      when(() => mockRepo.fetchAllPayments())
          .thenAnswer((_) async => [_fakeRecord()]);
      await container.read(allPaymentsProvider.future);

      final newRecord = _fakeRecord(id: 'pay-2', amount: 8000);
      when(() => mockRepo.recordPayment(
            studentId: any(named: 'studentId'),
            amount: any(named: 'amount'),
            method: any(named: 'method'),
            referenceNumber: any(named: 'referenceNumber'),
            notes: any(named: 'notes'),
            recordedBy: any(named: 'recordedBy'),
          )).thenAnswer((_) async => newRecord);

      await container.read(allPaymentsProvider.notifier).record(
            studentId: 'user-2',
            amount: 8000,
            method: PaymentMethod.upi,
          );

      final state = container.read(allPaymentsProvider).value!;
      expect(state.first.id, 'pay-2');
      expect(state.length, 2);
    });

    test('refresh reloads the list', () async {
      when(() => mockRepo.fetchAllPayments())
          .thenAnswer((_) async => [_fakeRecord()]);
      await container.read(allPaymentsProvider.future);

      when(() => mockRepo.fetchAllPayments()).thenAnswer((_) async => [
            _fakeRecord(),
            _fakeRecord(id: 'pay-2'),
          ]);
      await container.read(allPaymentsProvider.notifier).refresh();

      expect(container.read(allPaymentsProvider).value!.length, 2);
    });
  });

  // ── MyPaymentsNotifier ─────────────────────────────────────────────────────

  group('PaymentRepository.fetchStudentPayments', () {
    late MockPaymentRepository mockRepo;

    setUp(() => mockRepo = MockPaymentRepository());

    test('returns list for student', () async {
      when(() => mockRepo.fetchStudentPayments(any()))
          .thenAnswer((_) async => [_fakeRecord(), _fakeRecord(id: 'pay-2')]);

      final result = await mockRepo.fetchStudentPayments('user-1');
      expect(result.length, 2);
    });
  });
}
