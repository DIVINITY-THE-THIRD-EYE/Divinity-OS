import 'package:supabase_flutter/supabase_flutter.dart';

/// Domain-level auth lifecycle events, decoupled from Supabase's AuthChangeEvent
/// (whose AuthState type name collides with the app's app_auth.AuthState).
enum AuthLifecycleEvent {
  signedIn,
  signedOut,
  tokenRefreshed,
  userUpdated,
  passwordRecovery,
}

abstract interface class AuthRepository {
  User? get currentUser;

  /// Stream of auth lifecycle events sourced from Supabase's onAuthStateChange.
  /// Lets the app react to session changes it did not initiate locally
  /// (token-refresh failure, sign-out on another device, user updates).
  Stream<AuthLifecycleEvent> authEvents();

  Future<void> signInWithPhone({required String phone, required String password});
  Future<void> signInWithOtp({required String phone});
  Future<void> verifyOtp({required String phone, required String token});
  Future<void> signOut();
  Future<Map<String, dynamic>?> fetchProfile(String userId);
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);
  RealtimeChannel subscribeToUserProfile(String userId, void Function(Map<String, dynamic> record) callback);
  Future<void> unsubscribeFromChannel(RealtimeChannel channel);
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthLifecycleEvent> authEvents() {
    // onAuthStateChange is a broadcast Stream<AuthState>; map to the domain enum.
    return _client.auth.onAuthStateChange.map((data) {
      return switch (data.event) {
        AuthChangeEvent.signedIn => AuthLifecycleEvent.signedIn,
        AuthChangeEvent.initialSession => AuthLifecycleEvent.signedIn,
        AuthChangeEvent.signedOut => AuthLifecycleEvent.signedOut,
        AuthChangeEvent.tokenRefreshed => AuthLifecycleEvent.tokenRefreshed,
        AuthChangeEvent.userUpdated => AuthLifecycleEvent.userUpdated,
        AuthChangeEvent.passwordRecovery => AuthLifecycleEvent.passwordRecovery,
        // mfaChallengeVerified and any future events → benign refresh.
        _ => AuthLifecycleEvent.tokenRefreshed,
      };
    });
  }

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

  // Columns a user may write to their OWN row. Privileged columns (role,
  // expiration_date, streaks, and plan_status transitions other than
  // PENDING_ADMIN) are rejected here AND server-side by the 009 trigger.
  // Defense-in-depth, not the sole control.
  static const _selfEditableColumns = <String>{
    'name', 'age', 'gender',
    'emergency_contact_name', 'emergency_contact_phone',
    'primary_goal', 'injuries', 'medical_conditions', 'lifestyle_activity',
    'avatar_url', 'fcm_token', 'onboarding_complete', 'plan_status',
  };

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    final filtered = <String, dynamic>{
      for (final e in data.entries)
        if (_selfEditableColumns.contains(e.key)) e.key: e.value,
    };
    // Only the onboarding self-transition to PENDING_ADMIN is allowed.
    if (filtered['plan_status'] != null &&
        filtered['plan_status'] != 'PENDING_ADMIN') {
      filtered.remove('plan_status');
    }
    if (filtered.isEmpty) return;
    await _client.from('users').update(filtered).eq('id', userId);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.divinity://login-callback',
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  @override
  RealtimeChannel subscribeToUserProfile(String userId, void Function(Map<String, dynamic> record) callback) {
    final channel = _client.channel('public:users:id=eq.$userId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'users',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: userId,
      ),
      callback: (payload) {
        callback(payload.newRecord);
      },
    );
    channel.subscribe();
    return channel;
  }

  @override
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
