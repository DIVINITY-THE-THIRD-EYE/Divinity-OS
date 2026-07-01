import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/weather_repository.dart';
import '../domain/weather_model.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepository(),
);

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherData>> {
  final WeatherRepository _repository;

  WeatherNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchWeather();
  }

  Future<void> fetchWeather({bool force = false}) async {
    // If we have data and we're not forcing, don't trigger loading state
    if (state.isLoading && !force) return;

    if (force) {
      // If we already have data, preserve it in the state so the UI can display it
      // during the refresh indicator loading phase, rather than flashing a blank screen.
      state = state.hasValue
          ? AsyncValue.data(state.value!).copyWithPrevious(state)
          : const AsyncValue.loading();
    }

    try {
      final data = await _repository.getWeather(force: force);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final weatherNotifierProvider =
    StateNotifierProvider.autoDispose<WeatherNotifier, AsyncValue<WeatherData>>(
      (ref) {
        final repository = ref.watch(weatherRepositoryProvider);
        return WeatherNotifier(repository);
      },
    );
