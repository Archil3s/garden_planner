import 'dart:convert';

import 'package:http/http.dart' as http;

enum SpraySuitability { good, caution, noSpray }

class SprayConditions {
  const SprayConditions({
    required this.temperatureC,
    required this.relativeHumidity,
    required this.windSpeedKmh,
    required this.windGustKmh,
    required this.precipitationMm,
    required this.uvIndex,
    required this.weatherCode,
    required this.updatedAt,
  });

  final double temperatureC;
  final int relativeHumidity;
  final double windSpeedKmh;
  final double windGustKmh;
  final double precipitationMm;
  final double uvIndex;
  final int weatherCode;
  final DateTime updatedAt;

  SpraySuitability get suitability {
    if (precipitationMm > 0.2) return SpraySuitability.noSpray;
    if (windSpeedKmh >= 18 || windGustKmh >= 28) {
      return SpraySuitability.noSpray;
    }
    if (uvIndex >= 8) return SpraySuitability.noSpray;
    if (temperatureC >= 29) return SpraySuitability.noSpray;

    if (windSpeedKmh >= 12 || windGustKmh >= 20) {
      return SpraySuitability.caution;
    }
    if (relativeHumidity >= 90) return SpraySuitability.caution;
    if (relativeHumidity <= 35) return SpraySuitability.caution;
    if (uvIndex >= 6) return SpraySuitability.caution;
    if (temperatureC >= 25) return SpraySuitability.caution;

    return SpraySuitability.good;
  }

  String get conditionLabel {
    if (precipitationMm > 0.2) return 'Rain';
    if (weatherCode == 0) return 'Clear';
    if (weatherCode == 1 || weatherCode == 2 || weatherCode == 3) {
      return 'Cloud';
    }
    if (weatherCode == 45 || weatherCode == 48) return 'Fog';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Rain';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Snow';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Showers';
    if (weatherCode >= 95) return 'Storm';
    return 'Weather';
  }

  String get recommendation {
    switch (suitability) {
      case SpraySuitability.good:
        return 'Good spray window. Conditions are calm and dry.';
      case SpraySuitability.caution:
        return 'Spray with caution. Check wind, humidity, heat, and label limits.';
      case SpraySuitability.noSpray:
        return 'Do not spray now. Conditions are outside safe spray limits.';
    }
  }
}

class SprayConditionsService {
  const SprayConditionsService();

  static const double defaultLatitude = -41.5134;
  static const double defaultLongitude = 173.9612;

  Future<SprayConditions> fetchCurrent({
    double latitude = defaultLatitude,
    double longitude = defaultLongitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m,wind_gusts_10m,uv_index',
      'wind_speed_unit': 'kmh',
      'timezone': 'auto',
      'forecast_days': '1',
    });

    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Spray weather request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid spray weather response.');
    }

    final current = decoded['current'];

    if (current is! Map<String, dynamic>) {
      throw Exception('Spray weather response missing current conditions.');
    }

    final timeText = current['time']?.toString();
    final updatedAt = DateTime.tryParse(timeText ?? '') ?? DateTime.now();

    return SprayConditions(
      temperatureC: _toDouble(current['temperature_2m']),
      relativeHumidity: _toInt(current['relative_humidity_2m']),
      windSpeedKmh: _toDouble(current['wind_speed_10m']),
      windGustKmh: _toDouble(current['wind_gusts_10m']),
      precipitationMm: _toDouble(current['precipitation']),
      uvIndex: _toDouble(current['uv_index']),
      weatherCode: _toInt(current['weather_code']),
      updatedAt: updatedAt,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
