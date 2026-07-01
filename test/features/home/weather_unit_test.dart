import 'dart:convert';

import 'package:divinity_app/features/home/data/weather_repository.dart';
import 'package:divinity_app/features/home/domain/weather_model.dart';
import 'package:divinity_app/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockWeatherService extends Mock implements WeatherService {}

void main() {
  group('WeatherData Model', () {
    const data1 = WeatherData(
      temp: 24.5,
      conditionCode: 0,
      conditionText: 'Clear Sky',
      aqi: 35,
      humidity: 60,
      windSpeed: 12.0,
      uvIndex: 4.0,
      sunrise: '06:00 AM',
      sunset: '06:45 PM',
      lastUpdated: '10:00 AM',
      recommendation: 'Excellent day for outdoor yoga.',
    );

    const data2 = WeatherData(
      temp: 24.5,
      conditionCode: 0,
      conditionText: 'Clear Sky',
      aqi: 35,
      humidity: 60,
      windSpeed: 12.0,
      uvIndex: 4.0,
      sunrise: '06:00 AM',
      sunset: '06:45 PM',
      lastUpdated: '10:00 AM',
      recommendation: 'Excellent day for outdoor yoga.',
    );

    test('value equality and hashcodes work', () {
      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
    });

    test('copyWith works correctly', () {
      final modified = data1.copyWith(temp: 28.0, aqi: 110);
      expect(modified.temp, 28.0);
      expect(modified.aqi, 110);
      expect(modified.conditionCode, 0); // Unchanged
    });

    test('serialization (toMap / fromMap) works', () {
      final map = data1.toMap();
      final reconstructed = WeatherData.fromMap(map);
      expect(reconstructed, equals(data1));
    });

    test('WMO condition and icon mapping works', () {
      expect(WeatherData.mapWmoCode(0), 'Clear Sky');
      expect(WeatherData.mapWmoIcon(0), '☀️');
      expect(WeatherData.mapWmoCode(61), 'Rainy');
      expect(WeatherData.mapWmoIcon(61), '🌧️');
    });

    test('Wellness recommendation logic aligns with rules', () {
      // AQI > 100
      expect(WeatherData.generateRecommendation(25, 105), 'Better to practice indoors today.');
      // Temp > 38
      expect(WeatherData.generateRecommendation(39, 45), 'Consider restorative sessions due to heat.');
      // Temp > 35
      expect(WeatherData.generateRecommendation(36, 45), 'Stay hydrated during afternoon classes.');
      // Excellent outdoor yoga conditions
      expect(WeatherData.generateRecommendation(24, 30), 'Excellent day for outdoor yoga.');
      // Cold
      expect(WeatherData.generateRecommendation(12, 10), 'Warm up dynamically indoors today.');
      // Default
      expect(WeatherData.generateRecommendation(16, 65), 'Good conditions for pranayama.');
    });
  });

  group('WeatherService', () {
    late MockHttpClient mockClient;
    late WeatherService service;

    setUp(() {
      mockClient = MockHttpClient();
      service = WeatherService(client: mockClient);
      registerFallbackValue(Uri.parse('https://api.open-meteo.com'));
    });

    const mockWeatherBody = '''
    {
      "current": {
        "temperature_2m": 26.5,
        "relative_humidity_2m": 55,
        "weather_code": 1,
        "wind_speed_10m": 8.5,
        "uv_index": 2.0
      },
      "daily": {
        "sunrise": ["2026-06-30T06:00:00Z"],
        "sunset": ["2026-06-30T18:45:00Z"]
      }
    }
    ''';

    const mockAqiBody = '''
    {
      "current": {
        "us_aqi": 42
      }
    }
    ''';

    test('succeeds on valid API response', () async {
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=26.8&longitude=80.9'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,uv_index'
        '&daily=sunrise,sunset&timezone=Asia/Kolkata&forecast_days=1',
      );

      final aqiUrl = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?'
        'latitude=26.8&longitude=80.9'
        '&current=us_aqi&timezone=Asia/Kolkata',
      );

      when(() => mockClient.get(weatherUrl))
          .thenAnswer((_) async => http.Response(mockWeatherBody, 200));
      when(() => mockClient.get(aqiUrl))
          .thenAnswer((_) async => http.Response(mockAqiBody, 200));

      final data = await service.fetchWeather(
        latitude: 26.8,
        longitude: 80.9,
        timezone: 'Asia/Kolkata',
      );

      expect(data.temp, 26.5);
      expect(data.aqi, 42);
      expect(data.humidity, 55);
      expect(data.conditionText, 'Partly Cloudy');
    });

    test('throws WeatherException on API error', () async {
      when(() => mockClient.get(any())).thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () => service.fetchWeather(latitude: 26.8, longitude: 80.9, timezone: 'Asia/Kolkata'),
        throwsA(isA<WeatherException>()),
      );
    });

    test('throws WeatherException on invalid JSON format', () async {
      when(() => mockClient.get(any())).thenAnswer((_) async => http.Response('{"invalid": "structure"}', 200));

      expect(
        () => service.fetchWeather(latitude: 26.8, longitude: 80.9, timezone: 'Asia/Kolkata'),
        throwsA(isA<WeatherException>()),
      );
    });

    test('throws WeatherException on network timeout', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => Future.delayed(const Duration(seconds: 6), () => http.Response('{}', 200)),
      );

      expect(
        () => service.fetchWeather(latitude: 26.8, longitude: 80.9, timezone: 'Asia/Kolkata'),
        throwsA(isA<WeatherException>()),
      );
    });
  });

  group('WeatherRepository', () {
    late MockWeatherService mockService;
    late WeatherRepository repository;

    const testWeather = WeatherData(
      temp: 22.0,
      conditionCode: 0,
      conditionText: 'Clear Sky',
      aqi: 25,
      humidity: 50,
      windSpeed: 10.0,
      uvIndex: 3.0,
      sunrise: '06:00 AM',
      sunset: '06:30 PM',
      lastUpdated: '10:00 AM',
      recommendation: 'Excellent day for outdoor yoga.',
    );

    setUp(() {
      mockService = MockWeatherService();
      repository = WeatherRepository(weatherService: mockService);
    });

    test('returns fresh data and writes to cache on cache miss', () async {
      SharedPreferences.setMockInitialValues({}); // Empty cache
      when(() => mockService.fetchWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            timezone: any(named: 'timezone'),
          )).thenAnswer((_) async => testWeather);

      final data = await repository.getWeather();
      expect(data, equals(testWeather));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cached_weather_data'), isNotNull);
      expect(prefs.getInt('cached_weather_timestamp'), isNotNull);
    });

    test('returns cached data on cache hit without calling API', () async {
      final cachedJson = json.encode(testWeather.toMap());
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'cached_weather_data': cachedJson,
        'cached_weather_timestamp': currentTimestamp, // 0 age, valid
      });

      final data = await repository.getWeather();
      expect(data, equals(testWeather));
      verifyNever(() => mockService.fetchWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            timezone: any(named: 'timezone'),
          ));
    });

    test('performs API fetch and returns cached fallback on API failure', () async {
      final cachedJson = json.encode(testWeather.toMap());
      final expiredTimestamp = DateTime.now().millisecondsSinceEpoch - (20 * 60 * 1000); // 20 mins ago (expired)
      SharedPreferences.setMockInitialValues({
        'cached_weather_data': cachedJson,
        'cached_weather_timestamp': expiredTimestamp,
      });

      when(() => mockService.fetchWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            timezone: any(named: 'timezone'),
          )).thenThrow(WeatherException('API down'));

      final data = await repository.getWeather(); // Force fetch due to expiration, but fall back
      expect(data, equals(testWeather));
    });

    test('propagates exception if API fails and no cache exists', () async {
      SharedPreferences.setMockInitialValues({}); // Empty cache
      when(() => mockService.fetchWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            timezone: any(named: 'timezone'),
          )).thenThrow(WeatherException('API down'));

      expect(() => repository.getWeather(), throwsA(isA<WeatherException>()));
    });
  });
}
