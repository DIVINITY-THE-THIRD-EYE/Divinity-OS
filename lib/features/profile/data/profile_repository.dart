import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> fetchProfile(String userId);
  Future<void> updateName(String userId, String name);
  Future<void> updateEmergencyContact(
    String userId, {
    required String name,
    required String phone,
  });
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<UserProfile> fetchProfile(String userId) async {
    final row = await _client.from('users').select().eq('id', userId).single();
    return UserProfile.fromMap(row);
  }

  @override
  Future<void> updateName(String userId, String name) async {
    await _client.from('users').update({'name': name.trim()}).eq('id', userId);
  }

  @override
  Future<void> updateEmergencyContact(
    String userId, {
    required String name,
    required String phone,
  }) async {
    await _client
        .from('users')
        .update({
          'emergency_contact_name': name.trim(),
          'emergency_contact_phone': phone.trim(),
        })
        .eq('id', userId);
  }
}
