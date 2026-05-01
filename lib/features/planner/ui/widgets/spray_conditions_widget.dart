import 'package:flutter/material.dart';

import '../../../../core/theme/garden_theme.dart';
import '../../services/spray_conditions_service.dart';

class SprayConditionsWidget extends StatefulWidget {
  const SprayConditionsWidget({
    super.key,
    this.compactMode = false,
    this.latitude = SprayConditionsService.defaultLatitude,
    this.longitude = SprayConditionsService.defaultLongitude,
  });

  final double latitude;
  final double longitude;
  final bool compactMode;

  @override
  State<SprayConditionsWidget> createState() => _SprayConditionsWidgetState();
}

class _SprayConditionsWidgetState extends State<SprayConditionsWidget> {
  final SprayConditionsService service = const SprayConditionsService();

  late Future<SprayConditions> conditionsFuture;

  @override
  void initState() {
    super.initState();
    conditionsFuture = _load();
  }

  @override
  void didUpdateWidget(covariant SprayConditionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      conditionsFuture = _load();
    }
  }

  Future<SprayConditions> _load() {
    return service.fetchCurrent(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
  }

  void _refresh() {
    setState(() {
      conditionsFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SprayConditions>(
      future: conditionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SprayLoading();
        }

        if (snapshot.hasError) {
          return _SprayError(
            message: snapshot.error.toString(),
            onRetry: _refresh,
          );
        }

        final conditions = snapshot.data;

        if (conditions == null) {
          return _SprayError(
            message: 'No spray condition data available.',
            onRetry: _refresh,
          );
        }

        return _SprayContent(conditions: conditions, onRefresh: _refresh);
      },
    );
  }
}

class _SprayLoading extends StatelessWidget {
  const _SprayLoading();

  @override
  Widget build(BuildContext context) {
    return _SprayShell(
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(
            'Loading spray conditions...',
            style: TextStyle(
              color: GardenTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SprayError extends StatelessWidget {
  const _SprayError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SprayShell(
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: GardenTheme.warn, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: GardenTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SprayContent extends StatelessWidget {
  const _SprayContent({required this.conditions, required this.onRefresh});

  final SprayConditions conditions;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final suitability = conditions.suitability;
    final color = _suitabilityColor(suitability);
    final background = _suitabilityBackground(suitability);

    return _SprayShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SprayHeader(
            conditions: conditions,
            color: color,
            background: background,
            onRefresh: onRefresh,
          ),
          const SizedBox(height: 12),
          Text(
            conditions.recommendation,
            style: const TextStyle(
              color: GardenTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;

              if (compact) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ConditionTile(
                      label: 'Wind',
                      value:
                          '${conditions.windSpeedKmh.toStringAsFixed(0)} km/h',
                      caption:
                          'Gust ${conditions.windGustKmh.toStringAsFixed(0)}',
                      icon: Icons.air,
                      color: _windColor(conditions),
                    ),
                    _ConditionTile(
                      label: 'Rain',
                      value:
                          '${conditions.precipitationMm.toStringAsFixed(1)} mm',
                      caption: conditions.conditionLabel,
                      icon: Icons.water_drop_outlined,
                      color: _rainColor(conditions),
                    ),
                    _ConditionTile(
                      label: 'Humidity',
                      value: '${conditions.relativeHumidity}%',
                      caption: _humidityCaption(conditions.relativeHumidity),
                      icon: Icons.opacity,
                      color: _humidityColor(conditions.relativeHumidity),
                    ),
                    _ConditionTile(
                      label: 'Temp',
                      value: '${conditions.temperatureC.toStringAsFixed(0)}Â°C',
                      caption: _temperatureCaption(conditions.temperatureC),
                      icon: Icons.thermostat,
                      color: _temperatureColor(conditions.temperatureC),
                    ),
                    _ConditionTile(
                      label: 'UV',
                      value: conditions.uvIndex.toStringAsFixed(1),
                      caption: _uvCaption(conditions.uvIndex),
                      icon: Icons.wb_sunny_outlined,
                      color: _uvColor(conditions.uvIndex),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _ConditionTile(
                      label: 'Wind',
                      value:
                          '${conditions.windSpeedKmh.toStringAsFixed(0)} km/h',
                      caption:
                          'Gust ${conditions.windGustKmh.toStringAsFixed(0)}',
                      icon: Icons.air,
                      color: _windColor(conditions),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ConditionTile(
                      label: 'Rain',
                      value:
                          '${conditions.precipitationMm.toStringAsFixed(1)} mm',
                      caption: conditions.conditionLabel,
                      icon: Icons.water_drop_outlined,
                      color: _rainColor(conditions),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ConditionTile(
                      label: 'Humidity',
                      value: '${conditions.relativeHumidity}%',
                      caption: _humidityCaption(conditions.relativeHumidity),
                      icon: Icons.opacity,
                      color: _humidityColor(conditions.relativeHumidity),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ConditionTile(
                      label: 'Temp',
                      value: '${conditions.temperatureC.toStringAsFixed(0)}Â°C',
                      caption: _temperatureCaption(conditions.temperatureC),
                      icon: Icons.thermostat,
                      color: _temperatureColor(conditions.temperatureC),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ConditionTile(
                      label: 'UV',
                      value: conditions.uvIndex.toStringAsFixed(1),
                      caption: _uvCaption(conditions.uvIndex),
                      icon: Icons.wb_sunny_outlined,
                      color: _uvColor(conditions.uvIndex),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SprayHeader extends StatelessWidget {
  const _SprayHeader({
    required this.conditions,
    required this.color,
    required this.background,
    required this.onRefresh,
  });

  final SprayConditions conditions;
  final Color color;
  final Color background;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.26)),
          ),
          child: Icon(
            _suitabilityIcon(conditions.suitability),
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SPRAY CONDITIONS NOW',
                style: TextStyle(
                  color: GardenTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _suitabilityTitle(conditions.suitability),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GardenTheme.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SuitabilityChip(
                    label: _suitabilityChipLabel(conditions.suitability),
                    color: color,
                    background: background,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          iconSize: 18,
          color: GardenTheme.muted,
          tooltip: 'Refresh spray conditions',
        ),
      ],
    );
  }
}

class _SuitabilityChip extends StatelessWidget {
  const _SuitabilityChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ConditionTile extends StatelessWidget {
  const _ConditionTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      constraints: const BoxConstraints(minWidth: 98),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: GardenTheme.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            top: -2,
            child: Icon(icon, size: 34, color: color.withValues(alpha: 0.10)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: GardenTheme.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: GardenTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SprayShell extends StatelessWidget {
  const _SprayShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GardenTheme.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GardenTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

Color _suitabilityColor(SpraySuitability suitability) {
  switch (suitability) {
    case SpraySuitability.good:
      return GardenTheme.good;
    case SpraySuitability.caution:
      return GardenTheme.warn;
    case SpraySuitability.noSpray:
      return GardenTheme.bad;
  }
}

Color _suitabilityBackground(SpraySuitability suitability) {
  switch (suitability) {
    case SpraySuitability.good:
      return const Color(0xFFEEF8F0);
    case SpraySuitability.caution:
      return const Color(0xFFFFF3E5);
    case SpraySuitability.noSpray:
      return const Color(0xFFFFF0EE);
  }
}

IconData _suitabilityIcon(SpraySuitability suitability) {
  switch (suitability) {
    case SpraySuitability.good:
      return Icons.check_circle_outline;
    case SpraySuitability.caution:
      return Icons.warning_amber_rounded;
    case SpraySuitability.noSpray:
      return Icons.block_outlined;
  }
}

String _suitabilityTitle(SpraySuitability suitability) {
  switch (suitability) {
    case SpraySuitability.good:
      return 'Good spray window';
    case SpraySuitability.caution:
      return 'Spray with caution';
    case SpraySuitability.noSpray:
      return 'Do not spray';
  }
}

String _suitabilityChipLabel(SpraySuitability suitability) {
  switch (suitability) {
    case SpraySuitability.good:
      return 'GOOD';
    case SpraySuitability.caution:
      return 'CAUTION';
    case SpraySuitability.noSpray:
      return 'NO SPRAY';
  }
}

Color _windColor(SprayConditions conditions) {
  if (conditions.windSpeedKmh >= 18 || conditions.windGustKmh >= 28) {
    return GardenTheme.bad;
  }
  if (conditions.windSpeedKmh >= 12 || conditions.windGustKmh >= 20) {
    return GardenTheme.warn;
  }
  return GardenTheme.good;
}

Color _rainColor(SprayConditions conditions) {
  return conditions.precipitationMm > 0.2 ? GardenTheme.bad : GardenTheme.good;
}

Color _humidityColor(int humidity) {
  if (humidity >= 90 || humidity <= 35) return GardenTheme.warn;
  return GardenTheme.good;
}

Color _temperatureColor(double temperatureC) {
  if (temperatureC >= 29) return GardenTheme.bad;
  if (temperatureC >= 25) return GardenTheme.warn;
  return GardenTheme.good;
}

Color _uvColor(double uvIndex) {
  if (uvIndex >= 8) return GardenTheme.bad;
  if (uvIndex >= 6) return GardenTheme.warn;
  return GardenTheme.good;
}

String _humidityCaption(int humidity) {
  if (humidity >= 90) return 'Very humid';
  if (humidity <= 35) return 'Very dry';
  return 'Suitable';
}

String _temperatureCaption(double temperatureC) {
  if (temperatureC >= 29) return 'Too hot';
  if (temperatureC >= 25) return 'Warm';
  return 'Suitable';
}

String _uvCaption(double uvIndex) {
  if (uvIndex >= 8) return 'Very high';
  if (uvIndex >= 6) return 'High';
  return 'Suitable';
}
