import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/presentation/auth_provider.dart';

final trialAttendanceRepositoryProvider = Provider<TrialAttendanceRepository>(
  (ref) => TrialAttendanceRepository(ref.watch(supabaseClientProvider)),
);

/// Trial-class attendance tracking (owner decision #32): a lead can be
/// marked as having attended a trial class before converting to a paid
/// member. Deliberately separate from the member `attendance` table.
class TrialAttendanceRepository {
  TrialAttendanceRepository(this._client);

  final SupabaseClient _client;

  Future<int> countForLead(String leadId) async {
    final rows = await _client
        .from('trial_attendances')
        .select('id')
        .eq('lead_id', leadId);
    return (rows as List<dynamic>).length;
  }

  Future<void> markAttended(String leadId, {String? notes}) async {
    final uid = _client.auth.currentUser?.id;
    await _client.from('trial_attendances').insert({
      'lead_id': leadId,
      'marked_by': uid,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }
}

final trialAttendanceCountProvider = FutureProvider.family<int, String>(
  (ref, leadId) =>
      ref.read(trialAttendanceRepositoryProvider).countForLead(leadId),
);
