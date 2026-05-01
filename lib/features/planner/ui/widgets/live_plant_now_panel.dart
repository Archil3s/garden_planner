import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LivePlantNowPanel extends StatefulWidget {
  const LivePlantNowPanel({super.key});

  @override
  State<LivePlantNowPanel> createState() => _LivePlantNowPanelState();
}

class _LivePlantNowPanelState extends State<LivePlantNowPanel> {
  static const double latitude = -41.5042;
  static const double longitude = 173.9662;

  static const _fallback = _WeatherSnapshot(
    source: 'Fallback',
    rootSoilTemp: 8.4,
    surfaceSoilTemp: 10.9,
    deepSoilTemp: 8.9,
    airTemp: 12.0,
    humidity: 83,
    windKmh: 8,
    solar: 150,
    updated: 'offline',
  );

  _WeatherSnapshot _weather = _fallback;
  bool _loading = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _notice = null;
    });

    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': [
          'soil_temperature_0cm',
          'soil_temperature_6cm',
          'soil_temperature_18cm',
          'temperature_2m',
          'relative_humidity_2m',
          'wind_speed_10m',
          'shortwave_radiation',
        ].join(','),
        'forecast_days': '1',
        'wind_speed_unit': 'kmh',
        'timezone': 'Pacific/Auckland',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Weather unavailable');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final hourly = json['hourly'] as Map<String, dynamic>?;
      if (hourly == null) {
        throw StateError('Weather unavailable');
      }

      final index = _nearestHourIndex(hourly['time']);
      final snapshot = _WeatherSnapshot(
        source: 'Live',
        rootSoilTemp:
            _numAt(hourly['soil_temperature_6cm'], index) ??
            _fallback.rootSoilTemp,
        surfaceSoilTemp:
            _numAt(hourly['soil_temperature_0cm'], index) ??
            _fallback.surfaceSoilTemp,
        deepSoilTemp:
            _numAt(hourly['soil_temperature_18cm'], index) ??
            _fallback.deepSoilTemp,
        airTemp: _numAt(hourly['temperature_2m'], index) ?? _fallback.airTemp,
        humidity:
            (_numAt(hourly['relative_humidity_2m'], index) ??
                    _fallback.humidity)
                .round(),
        windKmh: (_numAt(hourly['wind_speed_10m'], index) ?? _fallback.windKmh)
            .round(),
        solar: (_numAt(hourly['shortwave_radiation'], index) ?? _fallback.solar)
            .round(),
        updated: _timeLabel(),
      );

      if (mounted) {
        setState(() {
          _weather = snapshot;
          _notice = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _weather = _fallback;
          _notice = 'Live weather unavailable. Using offline fallback values.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _groups
        .where((group) => _weather.rootSoilTemp >= group.minimumSoilTemp)
        .toList();

    final notReady = _groups
        .where((group) => _weather.rootSoilTemp < group.minimumSoilTemp)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF8EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              const Text(
                'Live soil-temp planting guide',
                style: TextStyle(
                  color: Color(0xFF1A5C34),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Chip(label: _weather.source),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _refresh,
                    icon: _loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Metric(
                label: 'Root zone',
                value: '${_weather.rootSoilTemp.toStringAsFixed(1)} C',
                detail: '6 cm soil',
              ),
              _Metric(
                label: 'Surface',
                value: '${_weather.surfaceSoilTemp.toStringAsFixed(1)} C',
                detail: '0 cm soil',
              ),
              _Metric(
                label: 'Air',
                value: '${_weather.airTemp.toStringAsFixed(1)} C',
                detail: 'now',
              ),
              _Metric(
                label: 'Humidity',
                value: '${_weather.humidity}%',
                detail: 'now',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ready.isEmpty
                ? 'Good to plant now: soil is still cool. Start hardy crops in trays.'
                : 'Good to plant now: ${ready.map((g) => g.name).join(', ')}.',
            style: const TextStyle(
              color: Color(0xFF1A5C34),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            notReady.isEmpty
                ? 'Nothing is blocked by soil temperature right now.'
                : 'Too cold for: ${notReady.map((g) => '${g.name} needs ${g.minimumSoilTemp.toStringAsFixed(0)} C').join(', ')}.',
            style: const TextStyle(
              color: Color(0xFF5B5148),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Updated: ${_weather.updated}. Wind ${_weather.windKmh} km/h. Solar ${_weather.solar} W/m2.',
            style: const TextStyle(
              color: Color(0xFF757068),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_notice != null) ...[
            const SizedBox(height: 8),
            Text(
              _notice!,
              style: const TextStyle(
                color: Color(0xFF7A4010),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static int _nearestHourIndex(dynamic values) {
    if (values is! List || values.isEmpty) return 0;

    final now = DateTime.now();
    var bestIndex = 0;
    var bestDiff = const Duration(days: 999);

    for (var i = 0; i < values.length; i++) {
      final raw = values[i];
      if (raw is! String) continue;

      final parsed = DateTime.tryParse(raw);
      if (parsed == null) continue;

      final diff = parsed.difference(now).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  static double? _numAt(dynamic values, int index) {
    if (values is! List || values.isEmpty) return null;

    final safeIndex = index.clamp(0, values.length - 1);
    final value = values[safeIndex];

    if (value is num) return value.toDouble();
    return null;
  }

  static String _timeLabel() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _WeatherSnapshot {
  const _WeatherSnapshot({
    required this.source,
    required this.rootSoilTemp,
    required this.surfaceSoilTemp,
    required this.deepSoilTemp,
    required this.airTemp,
    required this.humidity,
    required this.windKmh,
    required this.solar,
    required this.updated,
  });

  final String source;
  final double rootSoilTemp;
  final double surfaceSoilTemp;
  final double deepSoilTemp;
  final double airTemp;
  final int humidity;
  final int windKmh;
  final int solar;
  final String updated;
}

class _PlantGroup {
  const _PlantGroup(this.name, this.minimumSoilTemp);

  final String name;
  final double minimumSoilTemp;
}

const List<_PlantGroup> _groups = [
  _PlantGroup('brassicas', 7),
  _PlantGroup('alliums', 7),
  _PlantGroup('leaf greens', 8),
  _PlantGroup('root veg', 8),
  _PlantGroup('legumes', 12),
  _PlantGroup('herbs', 12),
  _PlantGroup('fruiting crops', 15),
];

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFBFDCC8)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF757068),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF227A47),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: const TextStyle(color: Color(0xFF757068), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDCC8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF227A47),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
