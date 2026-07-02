import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/plans_repository.dart';
import '../domain/plan.dart';

final plansRepositoryProvider = Provider<PlansRepository>(
  (ref) => SupabasePlansRepository(ref.watch(supabaseClientProvider)),
);

class PlansNotifier extends AsyncNotifier<List<Plan>> {
  @override
  Future<List<Plan>> build() => ref.read(plansRepositoryProvider).fetchAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(plansRepositoryProvider).fetchAll(),
    );
  }

  Future<void> create({
    required String name,
    required double price,
    required int durationDays,
    double discountPercent = 0,
    String? couponCode,
    List<String> programs = const [],
    int maxLeaveDaysPerMonth = 4,
  }) async {
    final plan = await ref
        .read(plansRepositoryProvider)
        .createPlan(
          name: name,
          price: price,
          durationDays: durationDays,
          discountPercent: discountPercent,
          couponCode: couponCode,
          programs: programs,
          maxLeaveDaysPerMonth: maxLeaveDaysPerMonth,
        );
    state = AsyncData([...state.value ?? [], plan]);
  }

  Future<void> toggleActive(Plan plan) async {
    final updated = await ref
        .read(plansRepositoryProvider)
        .updatePlan(plan.id, isActive: !plan.isActive);
    state = AsyncData([
      for (final p in state.value ?? []) if (p.id == updated.id) updated else p,
    ]);
  }

  Future<void> editPlan(
    String id, {
    String? name,
    double? price,
    int? durationDays,
    double? discountPercent,
    String? couponCode,
    List<String>? programs,
    int? maxLeaveDaysPerMonth,
  }) async {
    final updated = await ref
        .read(plansRepositoryProvider)
        .updatePlan(
          id,
          name: name,
          price: price,
          durationDays: durationDays,
          discountPercent: discountPercent,
          couponCode: couponCode,
          programs: programs,
          maxLeaveDaysPerMonth: maxLeaveDaysPerMonth,
        );
    state = AsyncData([
      for (final p in state.value ?? []) if (p.id == updated.id) updated else p,
    ]);
  }
}

final plansProvider = AsyncNotifierProvider<PlansNotifier, List<Plan>>(
  PlansNotifier.new,
);

final activePlansProvider = FutureProvider<List<Plan>>(
  (ref) => ref.read(plansRepositoryProvider).fetchActive(),
);
