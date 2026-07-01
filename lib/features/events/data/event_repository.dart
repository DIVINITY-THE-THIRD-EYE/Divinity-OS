import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/event.dart';

abstract interface class EventRepository {
  /// Published events (soonest first) with the student's registration state.
  Future<List<Event>> fetchPublishedForStudent(String studentId);

  /// All events (any status) for admin management, with live registration counts.
  Future<List<Event>> fetchAllForAdmin();

  Future<Event> createEvent(Event event, {required String createdBy});

  Future<Event> updateEvent(String id, Event event);

  Future<void> deleteEvent(String id);

  Future<void> register({required String eventId, required String studentId});

  Future<void> unregister({required String eventId, required String studentId});
}

class SupabaseEventRepository implements EventRepository {
  SupabaseEventRepository(this._client);

  final SupabaseClient _client;

  static const _selectWithCount = '*, event_registrations(count)';

  @override
  Future<List<Event>> fetchPublishedForStudent(String studentId) async {
    final rows = await _client
        .from('events')
        .select(_selectWithCount)
        .eq('status', 'PUBLISHED')
        .order('starts_at', ascending: true);

    final myRegs = await _client
        .from('event_registrations')
        .select('event_id')
        .eq('student_id', studentId);
    final registeredIds = (myRegs as List<dynamic>)
        .map((r) => (r as Map<String, dynamic>)['event_id'] as String)
        .toSet();

    return (rows as List<dynamic>).map((r) {
      final m = Map<String, dynamic>.from(r as Map<String, dynamic>);
      m['is_registered'] = registeredIds.contains(m['id']);
      return Event.fromMap(m);
    }).toList();
  }

  @override
  Future<List<Event>> fetchAllForAdmin() async {
    final rows = await _client
        .from('events')
        .select(_selectWithCount)
        .order('starts_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => Event.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Event> createEvent(Event event, {required String createdBy}) async {
    final payload = event.toInsertMap()..['created_by'] = createdBy;
    final row = await _client
        .from('events')
        .insert(payload)
        .select(_selectWithCount)
        .single();
    return Event.fromMap(row);
  }

  @override
  Future<Event> updateEvent(String id, Event event) async {
    final row = await _client
        .from('events')
        .update(event.toInsertMap())
        .eq('id', id)
        .select(_selectWithCount)
        .single();
    return Event.fromMap(row);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }

  @override
  Future<void> register({
    required String eventId,
    required String studentId,
  }) async {
    await _client.from('event_registrations').upsert(
      {'event_id': eventId, 'student_id': studentId},
      onConflict: 'event_id,student_id',
      ignoreDuplicates: true,
    );
  }

  @override
  Future<void> unregister({
    required String eventId,
    required String studentId,
  }) async {
    await _client
        .from('event_registrations')
        .delete()
        .eq('event_id', eventId)
        .eq('student_id', studentId);
  }
}
