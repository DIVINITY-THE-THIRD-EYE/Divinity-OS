import '../domain/support_ticket.dart';

abstract interface class SupportRepository {
  Future<List<SupportTicket>> fetchMyTickets(String studentId);
  Future<List<SupportTicket>> fetchAllTickets();
  Future<SupportTicket> createTicket({
    required String studentId,
    required String subject,
    required String description,
  });
  Future<SupportTicket> updateTicketStatus(
    String ticketId,
    SupportTicketStatus status,
  );
}
