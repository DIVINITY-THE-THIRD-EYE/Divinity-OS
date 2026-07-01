import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/weather_config.dart';
import '../../../services/weather_service.dart';
import '../domain/weather_model.dart';

class WeatherRepository {
  final WeatherService _weatherService;
  static const String _cacheKey = 'cached_weather_data';
  static const String _cacheTimeKey = 'cached_weather_timestamp';
  static const int _cacheTtlMs = 15 * 60 * 1000; // 15 minutes

  WeatherRepository({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService();

  Future<WeatherData> getWeather({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!force) {
      try {
        final cachedJson = prefs.getString(_cacheKey);
        final cachedTime = prefs.getInt(_cacheTimeKey);

        if (cachedJson != null && cachedTime != null) {
          final age = DateTime.now().millisecondsSinceEpoch - cachedTime;
          if (age < _cacheTtlMs) {
            final Map<String, dynamic> map = json.decode(cachedJson);
            return WeatherData.fromMap(map);
          }
        }
      } catch (e) {
        // Cache read failed, ignore and fetch fresh
        debugPrint('[WeatherRepository] Failed to read cache: $e');
      }
    }

    try {
      final weather = await _weatherService.fetchWeather(
        latitude: WeatherConfig.latitude,
        longitude: WeatherConfig.longitude,
        timezone: WeatherConfig.timezone,
      );

      // Save to cache
      await prefs.setString(_cacheKey, json.encode(weather.toMap()));
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      return weather;
    } catch (e) {
      // Fetch failed, try reading expired cache as fallback
      try {
        final cachedJson = prefs.getString(_cacheKey);
        if (cachedJson != null) {
          final Map<String, dynamic> map = json.decode(cachedJson);
          return WeatherData.fromMap(map);
        }
      } catch (_) {}
      rethrow;
    }
  }
}
