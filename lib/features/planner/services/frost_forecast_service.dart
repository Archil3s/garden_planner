import 'dart:convert';

import 'package:http/http.dart' as http;

import '../ui/widgets/frost_risk_widget.dart';

class FrostForecastService {
  const FrostForecastService();

  static const double defaultLatitude = -41.5134;
  static const double defaultLongitude = 173.9612;

  Future<List<FrostForecastDay>> fetchForecast({
    double latitude = defaultLatitude,
    double longitude = defaultLongitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': 'temperature_2m_min,temperature_2m_max,weather_code',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Weather request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid weather response.');
    }

    final daily = decoded['daily'];

    if (daily is! Map<String, dynamic>) {
      throw Exception('Weather response missing daily forecast.');
    }

    final times = _readList(daily['time']);
    final lows = _readList(daily['temperature_2m_min']);
    final highs = _readList(daily['temperature_2m_max']);
    final codes = _readList(daily['weather_code']);

    final count = [
      times.length,
      lows.length,
      highs.length,
      codes.length,
    ].reduce((a, b) => a < b ? a : b);

    final days = <FrostForecastDay>[];

    for (var i = 0; i < count; i++) {
      final date = DateTime.tryParse(times[i].toString());
      final low = _toDouble(lows[i]);
      final high = _toDouble(highs[i]);
      final code = _toInt(codes[i]);

      if (date == null || low == null || high == null) continue;

      days.add(
        FrostForecastDay(
          date: date,
          lowC: low,
          highC: high,
          condition: _conditionFromCode(code),
        ),
      );
    }

    if (days.isEmpty) {
      throw Exception('No usable frost forecast data returned.');
    }

    return days;
  }

  static List<dynamic> _readList(Object? value) {
    if (value is List) return value;
    return const [];
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _conditionFromCode(int code) {
    if (code == 0) return 'Clear';
    if (code == 1 || code == 2 || code == 3) return 'Cloud';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Showers';
    if (code >= 95) return 'Storm';
    return 'Weather';
  }
}
