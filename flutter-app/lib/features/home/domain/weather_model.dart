import 'package:flutter/foundation.dart';

@immutable
class WeatherData {
  final double temp;
  final int conditionCode;
  final String conditionText;
  final int aqi;
  final int humidity;
  final double windSpeed;
  final double uvIndex;
  final String sunrise;
  final String sunset;
  final String lastUpdated;
  final String recommendation;

  const WeatherData({
    required this.temp,
    required this.conditionCode,
    required this.conditionText,
    required this.aqi,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.lastUpdated,
    required this.recommendation,
  });

  WeatherData copyWith({
    double? temp,
    int? conditionCode,
    String? conditionText,
    int? aqi,
    int? humidity,
    double? windSpeed,
    double? uvIndex,
    String? sunrise,
    String? sunset,
    String? lastUpdated,
    String? recommendation,
  }) {
    return WeatherData(
      temp: temp ?? this.temp,
      conditionCode: conditionCode ?? this.conditionCode,
      conditionText: conditionText ?? this.conditionText,
      aqi: aqi ?? this.aqi,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      uvIndex: uvIndex ?? this.uvIndex,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temp': temp,
      'conditionCode': conditionCode,
      'conditionText': conditionText,
      'aqi': aqi,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'uvIndex': uvIndex,
      'sunrise': sunrise,
      'sunset': sunset,
      'lastUpdated': lastUpdated,
      'recommendation': recommendation,
    };
  }

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      temp: (map['temp'] as num).toDouble(),
      conditionCode: map['conditionCode'] as int,
      conditionText: map['conditionText'] as String,
      aqi: map['aqi'] as int,
      humidity: map['humidity'] as int,
      windSpeed: (map['windSpeed'] as num).toDouble(),
      uvIndex: (map['uvIndex'] as num).toDouble(),
      sunrise: map['sunrise'] as String,
      sunset: map['sunset'] as String,
      lastUpdated: map['lastUpdated'] as String,
      recommendation: map['recommendation'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherData &&
        other.temp == temp &&
        other.conditionCode == conditionCode &&
        other.conditionText == conditionText &&
        other.aqi == aqi &&
        other.humidity == humidity &&
        other.windSpeed == windSpeed &&
        other.uvIndex == uvIndex &&
        other.sunrise == sunrise &&
        other.sunset == sunset &&
        other.lastUpdated == lastUpdated &&
        other.recommendation == recommendation;
  }

  @override
  int get hashCode {
    return Object.hash(
      temp,
      conditionCode,
      conditionText,
      aqi,
      humidity,
      windSpeed,
      uvIndex,
      sunrise,
      sunset,
      lastUpdated,
      recommendation,
    );
  }

  static String generateRecommendation(double temp, int aqi) {
    if (aqi > 100) {
      return "Better to practice indoors today.";
    }
    if (temp > 38) {
      return "Consider restorative sessions due to heat.";
    }
    if (temp > 35) {
      return "Stay hydrated during afternoon classes.";
    }
    if (aqi <= 50 && temp >= 18 && temp <= 30) {
      return "Excellent day for outdoor yoga.";
    }
    if (temp < 15) {
      return "Warm up dynamically indoors today.";
    }
    return "Good conditions for pranayama.";
  }

  static String mapWmoCode(int code) {
    switch (code) {
      case 0:
        return "Clear Sky";
      case 1:
      case 2:
      case 3:
        return "Partly Cloudy";
      case 45:
      case 48:
        return "Foggy";
      case 51:
      case 53:
      case 55:
        return "Drizzle";
      case 61:
      case 63:
      case 65:
        return "Rainy";
      case 71:
      case 73:
      case 75:
        return "Snowy";
      case 80:
      case 81:
      case 82:
        return "Showers";
      case 95:
      case 96:
      case 99:
        return "Thunderstorm";
      default:
        return "Cloudy";
    }
  }

  static String mapWmoIcon(int code) {
    switch (code) {
      case 0:
        return "☀️";
      case 1:
      case 2:
      case 3:
        return "🌤️";
      case 45:
      case 48:
        return "🌫️";
      case 51:
      case 53:
      case 55:
        return "🌦️";
      case 61:
      case 63:
      case 65:
        return "🌧️";
      case 71:
      case 73:
      case 75:
        return "❄️";
      case 80:
      case 81:
      case 82:
        return "🌦️";
      case 95:
      case 96:
      case 99:
        return "⛈️";
      default:
        return "☁️";
    }
  }
}
