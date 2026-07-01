import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/support_ticket.dart';
import 'support_repository.dart';

class SupabaseSupportRepository implements SupportRepository {
  SupabaseSupportRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<SupportTicket>> fetchMyTickets(String studentId) async {
    final rows = await _client
        .from('support_tickets')
        .select('*, student:users!support_tickets_student_id_fkey(name)')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => SupportTicket.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SupportTicket>> fetchAllTickets() async {
    final rows = await _client
        .from('support_tickets')
        .select('*, student:users!support_tickets_student_id_fkey(name)')
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => SupportTicket.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SupportTicket> createTicket({
    required String studentId,
    required String subject,
    required String description,
  }) async {
    final row = await _client
        .from('support_tickets')
        .insert({
          'student_id': studentId,
          'subject': subject,
          'description': description,
        })
        .select('*, student:users!support_tickets_student_id_fkey(name)')
        .single();
    return SupportTicket.fromMap(row);
  }

  @override
  Future<SupportTicket> updateTicketStatus(
    String ticketId,
    SupportTicketStatus status,
  ) async {
    final row = await _client
        .from('support_tickets')
        .update({'status': status.dbValue})
        .eq('id', ticketId)
        .select('*, student:users!support_tickets_student_id_fkey(name)')
        .single();
    return SupportTicket.fromMap(row);
  }
}
