import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/certificate_repository.dart';
import '../domain/certificate.dart';

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseCertificateRepository(client);
});

/// The signed-in student's own certificates.
final myCertificatesProvider = FutureProvider<List<Certificate>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const [];
  return ref.watch(certificateRepositoryProvider).fetchForStudent(uid);
});

/// Certificates for a given student (used by trainer/admin views).
final studentCertificatesProvider =
    FutureProvider.family<List<Certificate>, String>((ref, studentId) async {
      return ref
          .watch(certificateRepositoryProvider)
          .fetchForStudent(studentId);
    });

/// All certificates with student names (admin only).
final allCertificatesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return ref.watch(certificateRepositoryProvider).fetchAllWithStudentNames();
});

/// Issue-certificate action (trainer/admin).
class IssueCertificateNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> issue(Certificate certificate) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(certificateRepositoryProvider).issue(certificate);
      ref.invalidate(studentCertificatesProvider(certificate.studentId));
      ref.invalidate(myCertificatesProvider);
    });
  }
}

final issueCertificateNotifierProvider =
    AutoDisposeAsyncNotifierProvider<IssueCertificateNotifier, void>(
      IssueCertificateNotifier.new,
    );
