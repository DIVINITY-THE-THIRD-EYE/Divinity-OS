import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/supabase_support_repository.dart';
import '../data/support_repository.dart';
import '../domain/support_ticket.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupabaseSupportRepository(ref.watch(supabaseClientProvider));
});

// ── Student's own tickets list ───────────────────────────────────────────────

class MyTicketsNotifier extends AsyncNotifier<List<SupportTicket>> {
  @override
  Future<List<SupportTicket>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref.read(supportRepositoryProvider).fetchMyTickets(uid);
  }

  Future<void> createTicket({
    required String subject,
    required String description,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final created = await ref
        .read(supportRepositoryProvider)
        .createTicket(
          studentId: uid,
          subject: subject,
          description: description,
        );
    state = AsyncData([created, ...state.value ?? []]);
  }
}

final myTicketsProvider =
    AsyncNotifierProvider<MyTicketsNotifier, List<SupportTicket>>(
      MyTicketsNotifier.new,
    );

// ── All tickets (Admin view) ──────────────────────────────────────────────────

class AllTicketsNotifier extends AsyncNotifier<List<SupportTicket>> {
  @override
  Future<List<SupportTicket>> build() {
    return ref.read(supportRepositoryProvider).fetchAllTickets();
  }

  Future<void> resolveTicket(String id) async {
    final updated = await ref
        .read(supportRepositoryProvider)
        .updateTicketStatus(id, SupportTicketStatus.resolved);
    _replace(updated);
  }

  void _replace(SupportTicket updated) {
    state = AsyncData(
      (state.value ?? []).map((t) => t.id == updated.id ? updated : t).toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(supportRepositoryProvider).fetchAllTickets(),
    );
  }
}

final allTicketsProvider =
    AsyncNotifierProvider<AllTicketsNotifier, List<SupportTicket>>(
      AllTicketsNotifier.new,
    );
