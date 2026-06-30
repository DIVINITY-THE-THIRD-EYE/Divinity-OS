import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/certificate.dart';

abstract interface class CertificateRepository {
  /// Certificates owned by [studentId] (RLS: a student only ever sees own).
  Future<List<Certificate>> fetchForStudent(String studentId);

  /// Issue a certificate (trainer/admin). Returns the created row (with code).
  Future<Certificate> issue(Certificate certificate);
}

class SupabaseCertificateRepository implements CertificateRepository {
  SupabaseCertificateRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Certificate>> fetchForStudent(String studentId) async {
    final rows = await _client
        .from('certificates')
        .select()
        .eq('student_id', studentId)
        .order('issued_on', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => Certificate.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Certificate> issue(Certificate certificate) async {
    final row = await _client
        .from('certificates')
        .insert(certificate.toMap())
        .select()
        .single();
    return Certificate.fromMap(row);
  }
}
