import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/payment_repository.dart';
import '../domain/payment_record.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => SupabasePaymentRepository(ref.watch(supabaseClientProvider)),
);

// ── Student's own payment history ─────────────────────────────────────────────

class MyPaymentsNotifier extends AsyncNotifier<List<PaymentRecord>> {
  @override
  Future<List<PaymentRecord>> build() {
    final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) return Future.value([]);
    return ref.read(paymentRepositoryProvider).fetchStudentPayments(uid);
  }
}

final myPaymentsProvider =
    AsyncNotifierProvider<MyPaymentsNotifier, List<PaymentRecord>>(
  MyPaymentsNotifier.new,
);

// ── All payments (admin view) ─────────────────────────────────────────────────

class AllPaymentsNotifier extends AsyncNotifier<List<PaymentRecord>> {
  @override
  Future<List<PaymentRecord>> build() =>
      ref.read(paymentRepositoryProvider).fetchAllPayments();

  Future<void> record({
    required String studentId,
    required double amount,
    required PaymentMethod method,
    String? referenceNumber,
    String? notes,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    final created = await ref.read(paymentRepositoryProvider).recordPayment(
          studentId: studentId,
          amount: amount,
          method: method,
          referenceNumber: referenceNumber,
          notes: notes,
          recordedBy: uid,
        );
    state = AsyncData([created, ...state.value ?? []]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(paymentRepositoryProvider).fetchAllPayments(),
    );
  }
}

final allPaymentsProvider =
    AsyncNotifierProvider<AllPaymentsNotifier, List<PaymentRecord>>(
  AllPaymentsNotifier.new,
);
