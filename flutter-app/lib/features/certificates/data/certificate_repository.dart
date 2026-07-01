import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/certificate.dart';

abstract interface class CertificateRepository {
  /// Certificates owned by [studentId] (RLS: a student only ever sees own).
  Future<List<Certificate>> fetchForStudent(String studentId);

  /// All certificates across all students (admin only).
  Future<List<Map<String, dynamic>>> fetchAllWithStudentNames();

  /// Issue a certificate (trainer/admin). Returns the created row (with code).
  Future<Certificate> issue(Certificate certificate);

  /// Revoke a certificate by marking deleted (admin only).
  Future<void> revoke(String certificateId);
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
  Future<List<Map<String, dynamic>>> fetchAllWithStudentNames() async {
    final rows = await _client
        .from('certificates')
        .select('*, users!student_id(name, phone)')
        .order('issued_on', ascending: false);
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
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

  @override
  Future<void> revoke(String certificateId) async {
    await _client.from('certificates').delete().eq('id', certificateId);
  }
}
