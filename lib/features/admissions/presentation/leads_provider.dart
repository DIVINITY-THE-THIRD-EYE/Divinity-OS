import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/leads_repository.dart';
import '../domain/lead.dart';

final leadsRepositoryProvider = Provider<LeadsRepository>(
  (ref) => SupabaseLeadsRepository(ref.watch(supabaseClientProvider)),
);

class LeadsNotifier extends AsyncNotifier<List<Lead>> {
  @override
  Future<List<Lead>> build() => _load();

  Future<List<Lead>> _load() =>
      ref.read(leadsRepositoryProvider).fetchLeads();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> addLead({
    required String name,
    String? phone,
    String? email,
    String? source,
    String? notes,
    required String createdBy,
  }) async {
    final lead = await ref.read(leadsRepositoryProvider).createLead(
          name: name,
          phone: phone,
          email: email,
          source: source,
          notes: notes,
          createdBy: createdBy,
        );
    state = AsyncData([lead, ...state.value ?? []]);
  }

  Future<void> advancePipeline(String id, LeadStatus newStatus) async {
    final updated =
        await ref.read(leadsRepositoryProvider).advancePipeline(id, newStatus);
    _replaceLead(updated);
  }

  Future<void> updateNotes(String id, String notes) async {
    final updated =
        await ref.read(leadsRepositoryProvider).updateNotes(id, notes);
    _replaceLead(updated);
  }

  Future<void> markLost(String id) async {
    final updated = await ref
        .read(leadsRepositoryProvider)
        .advancePipeline(id, LeadStatus.lost);
    _replaceLead(updated);
  }

  Future<void> convertToMember(String leadId, String userId) async {
    final updated = await ref
        .read(leadsRepositoryProvider)
        .convertToMember(leadId, userId);
    _replaceLead(updated);
  }

  void _replaceLead(Lead updated) {
    state = AsyncData(
      (state.value ?? [])
          .map((l) => l.id == updated.id ? updated : l)
          .toList(),
    );
  }
}

final leadsProvider =
    AsyncNotifierProvider<LeadsNotifier, List<Lead>>(LeadsNotifier.new);
