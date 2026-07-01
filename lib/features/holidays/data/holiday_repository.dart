import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/holiday.dart';

abstract interface class HolidayRepository {
  Future<List<Holiday>> fetchUpcoming({int limit = 50});
  Future<Holiday> addHoliday({required DateTime date, required String name});
  Future<void> deleteHoliday(String id);
}

class SupabaseHolidayRepository implements HolidayRepository {
  SupabaseHolidayRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Holiday>> fetchUpcoming({int limit = 50}) async {
    final rows = await _client
        .from('holidays')
        .select()
        .order('date')
        .limit(limit);
    return (rows as List<dynamic>)
        .map((r) => Holiday.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Holiday> addHoliday({
    required DateTime date,
    required String name,
  }) async {
    final row = await _client
        .from('holidays')
        .insert({'date': date.toIso8601String().substring(0, 10), 'name': name})
        .select()
        .single();
    return Holiday.fromMap(row);
  }

  @override
  Future<void> deleteHoliday(String id) async {
    await _client.from('holidays').delete().eq('id', id);
  }
}
