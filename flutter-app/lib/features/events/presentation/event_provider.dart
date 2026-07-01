import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/event_repository.dart';
import '../domain/event.dart';

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => SupabaseEventRepository(ref.watch(supabaseClientProvider)),
);

// ── Student: published events + my registration state ────────────────────────

class StudentEventsNotifier extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Future.value([]);
    return ref.read(eventRepositoryProvider).fetchPublishedForStudent(uid);
  }

  Future<void> refresh() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(eventRepositoryProvider).fetchPublishedForStudent(uid),
    );
  }

  Future<void> toggleRegistration(Event event) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final repo = ref.read(eventRepositoryProvider);
    if (event.isRegistered) {
      await repo.unregister(eventId: event.id, studentId: uid);
    } else {
      await repo.register(eventId: event.id, studentId: uid);
    }
    await refresh();
  }
}

final studentEventsProvider =
    AsyncNotifierProvider<StudentEventsNotifier, List<Event>>(
      StudentEventsNotifier.new,
    );

// ── Admin: all events (any status) ───────────────────────────────────────────

class AdminEventsNotifier extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() =>
      ref.read(eventRepositoryProvider).fetchAllForAdmin();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(eventRepositoryProvider).fetchAllForAdmin(),
    );
  }

  Future<void> create(Event draft) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final created = await ref
        .read(eventRepositoryProvider)
        .createEvent(draft, createdBy: uid);
    state = AsyncData([created, ...state.value ?? []]);
  }

  Future<void> edit(String id, Event draft) async {
    final updated = await ref
        .read(eventRepositoryProvider)
        .updateEvent(id, draft);
    state = AsyncData([
      for (final e in state.value ?? []) e.id == id ? updated : e,
    ]);
  }

  Future<void> remove(String id) async {
    await ref.read(eventRepositoryProvider).deleteEvent(id);
    state = AsyncData((state.value ?? []).where((e) => e.id != id).toList());
  }
}

final adminEventsProvider =
    AsyncNotifierProvider<AdminEventsNotifier, List<Event>>(
      AdminEventsNotifier.new,
    );
