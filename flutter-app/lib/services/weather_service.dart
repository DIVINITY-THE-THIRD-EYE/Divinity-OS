import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/home/domain/weather_model.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  @override
  String toString() => 'WeatherException: $message';
}

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    final weatherUrl = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,uv_index'
      '&daily=sunrise,sunset&timezone=$timezone&forecast_days=1',
    );

    final aqiUrl = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality?'
      'latitude=$latitude&longitude=$longitude'
      '&current=us_aqi&timezone=$timezone',
    );

    try {
      // Fetch both in parallel, with 5 seconds timeout on each
      final responses = await Future.wait([
        _client.get(weatherUrl).timeout(const Duration(seconds: 5)),
        _client.get(aqiUrl).timeout(const Duration(seconds: 5)),
      ]);

      final weatherRes = responses[0];
      final aqiRes = responses[1];

      if (weatherRes.statusCode != 200 || aqiRes.statusCode != 200) {
        throw WeatherException(
          'Weather APIs returned status code ${weatherRes.statusCode} / ${aqiRes.statusCode}',
        );
      }

      final weatherData = json.decode(weatherRes.body) as Map<String, dynamic>;
      final aqiData = json.decode(aqiRes.body) as Map<String, dynamic>;

      if (weatherData['current'] == null ||
          weatherData['daily'] == null ||
          aqiData['current'] == null) {
        throw WeatherException(
          'Invalid JSON payload returned from weather service.',
        );
      }

      final current = weatherData['current'];
      final daily = weatherData['daily'];
      final aqiCurrent = aqiData['current'];

      final double temp = (current['temperature_2m'] as num).toDouble();
      final int aqi = (aqiCurrent['us_aqi'] as num).toInt();
      final int code = (current['weather_code'] as num).toInt();

      String formatTime(String? iso) {
        if (iso == null) return '--:--';
        try {
          final dt = DateTime.parse(iso);
          final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
          final minute = dt.minute.toString().padLeft(2, '0');
          final period = dt.hour >= 12 ? 'PM' : 'AM';
          return '$hour:$minute $period';
        } catch (_) {
          return '--:--';
        }
      }

      final sunriseList = daily['sunrise'] as List?;
      final sunsetList = daily['sunset'] as List?;

      final sunriseIso = (sunriseList != null && sunriseList.isNotEmpty)
          ? sunriseList[0]?.toString()
          : null;
      final sunsetIso = (sunsetList != null && sunsetList.isNotEmpty)
          ? sunsetList[0]?.toString()
          : null;

      final now = DateTime.now();
      final lastUpdatedStr =
          '${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

      return WeatherData(
        temp: temp,
        conditionCode: code,
        conditionText: WeatherData.mapWmoCode(code),
        aqi: aqi,
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        uvIndex: (current['uv_index'] as num?)?.toDouble() ?? 0.0,
        sunrise: formatTime(sunriseIso),
        sunset: formatTime(sunsetIso),
        lastUpdated: lastUpdatedStr,
        recommendation: WeatherData.generateRecommendation(temp, aqi),
      );
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Failed to fetch weather: $e');
    }
  }
}
