import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../profile/presentation/profile_provider.dart';
import '../../shared/students_screen.dart';
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

  Future<void> submitManualPayment({
    required double amount,
    required PaymentMethod method,
    required String referenceNumber,
    required String filename,
    required List<int> bytes,
    String? notes,
  }) async {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) throw Exception('Not signed in');

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Upload screenshot to Supabase Storage
      final screenshotUrl = await ref.read(paymentRepositoryProvider).uploadScreenshot(
            userId: uid,
            filename: filename,
            bytes: bytes,
          );

      // 2. Record payment with PENDING status
      final record = await ref.read(paymentRepositoryProvider).recordPayment(
            studentId: uid,
            amount: amount,
            method: method,
            referenceNumber: referenceNumber,
            notes: notes,
            screenshotUrl: screenshotUrl,
            status: PaymentStatus.pending,
          );

      // 3. Update student's plan_status to PENDING_ADMIN
      await ref.read(supabaseClientProvider)
          .from('users')
          .update({'plan_status': 'PENDING_ADMIN'})
          .eq('id', uid);

      // 4. Invalidate profile so that it fetches the updated plan_status
      ref.invalidate(myProfileProvider);

      return [record, ...state.value ?? []];
    });
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

  Future<void> verifyPayment({
    required String paymentId,
    required String studentId,
    required PaymentStatus status,
    DateTime? expirationDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final PaymentRecord updated;
      if (status == PaymentStatus.paid) {
        if (expirationDate == null) throw Exception('Expiration date required for approval');
        updated = await ref.read(paymentRepositoryProvider).approvePayment(paymentId, expirationDate);
      } else {
        updated = await ref.read(paymentRepositoryProvider).rejectPayment(paymentId);
      }

      // Invalidate caches to refresh data across pages
      ref.invalidate(studentsProvider);
      ref.invalidate(myProfileProvider);

      return (state.value ?? [])
          .map((p) => p.id == paymentId ? updated : p)
          .toList();
    });
  }

  Future<void> confirmReceipt(String paymentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = await ref.read(paymentRepositoryProvider).confirmTrainerReceipt(paymentId);
      ref.invalidate(studentsProvider);
      ref.invalidate(myProfileProvider);
      return (state.value ?? [])
          .map((p) => p.id == paymentId ? updated : p)
          .toList();
    });
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
