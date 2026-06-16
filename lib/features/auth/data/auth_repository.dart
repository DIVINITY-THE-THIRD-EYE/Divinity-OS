import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRepository {
  User? get currentUser;

  Future<void> signInWithPhone({required String phone, required String password});
  Future<void> signInWithOtp({required String phone});
  Future<void> verifyOtp({required String phone, required String token});
  Future<void> signOut();
  Future<Map<String, dynamic>?> fetchProfile(String userId);
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<void> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(phone: phone, password: password);
  }

  @override
  Future<void> signInWithOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  @override
  Future<void> verifyOtp({
    required String phone,
    required String token,
  }) async {
    await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    return _client.from('users').select().eq('id', userId).maybeSingle();
  }
}
