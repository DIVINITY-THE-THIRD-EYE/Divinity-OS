import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/holiday_repository.dart';
import '../domain/holiday.dart';

final holidayRepositoryProvider = Provider<HolidayRepository>(
  (ref) => SupabaseHolidayRepository(ref.watch(supabaseClientProvider)),
);

class HolidayNotifier extends AsyncNotifier<List<Holiday>> {
  @override
  Future<List<Holiday>> build() =>
      ref.read(holidayRepositoryProvider).fetchUpcoming();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(holidayRepositoryProvider).fetchUpcoming(),
    );
  }

  Future<void> add({required DateTime date, required String name}) async {
    final holiday = await ref
        .read(holidayRepositoryProvider)
        .addHoliday(date: date, name: name);
    state = AsyncData(
      [...state.value ?? [], holiday]..sort((a, b) => a.date.compareTo(b.date)),
    );
  }

  Future<void> remove(String id) async {
    await ref.read(holidayRepositoryProvider).deleteHoliday(id);
    state = AsyncData((state.value ?? []).where((h) => h.id != id).toList());
  }
}

final holidaysProvider = AsyncNotifierProvider<HolidayNotifier, List<Holiday>>(
  HolidayNotifier.new,
);
