import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/lead.dart';

abstract interface class LeadsRepository {
  Future<List<Lead>> fetchLeads();
  Future<Lead> createLead({
    required String name,
    String? phone,
    String? email,
    String? source,
    String? notes,
    required String createdBy,
  });
  Future<Lead> advancePipeline(String id, LeadStatus newStatus);
  Future<Lead> updateNotes(String id, String notes);
  Future<Lead> convertToMember(String leadId, String userId);
}

class SupabaseLeadsRepository implements LeadsRepository {
  SupabaseLeadsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Lead>> fetchLeads() async {
    final rows = await _client
        .from('leads')
        .select()
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => Lead.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Lead> createLead({
    required String name,
    String? phone,
    String? email,
    String? source,
    String? notes,
    required String createdBy,
  }) async {
    final row = await _client
        .from('leads')
        .insert({
          'name': name,
          'phone': phone,
          'email': email,
          'source': source,
          'notes': notes,
          'created_by': createdBy,
          'pipeline_status': 'NEW',
        })
        .select()
        .single();
    return Lead.fromMap(row);
  }

  @override
  Future<Lead> advancePipeline(String id, LeadStatus newStatus) async {
    final row = await _client
        .from('leads')
        .update({'pipeline_status': newStatus.dbValue})
        .eq('id', id)
        .select()
        .single();
    return Lead.fromMap(row);
  }

  @override
  Future<Lead> updateNotes(String id, String notes) async {
    final row = await _client
        .from('leads')
        .update({'notes': notes})
        .eq('id', id)
        .select()
        .single();
    return Lead.fromMap(row);
  }

  @override
  Future<Lead> convertToMember(String leadId, String userId) async {
    // Link the lead to an existing users row and mark as ADMITTED.
    final row = await _client
        .from('leads')
        .update({
          'pipeline_status': 'ADMITTED',
          'converted_user_id': userId,
        })
        .eq('id', leadId)
        .select()
        .single();
    return Lead.fromMap(row);
  }
}
