import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/garden_theme.dart';
import '../../services/frost_forecast_service.dart';

enum FrostRiskLevel { none, low, moderate, high, danger }

class FrostForecastDay {
  const FrostForecastDay({
    required this.date,
    required this.lowC,
    required this.highC,
    required this.condition,
  });

  final DateTime date;
  final double lowC;
  final double highC;
  final String condition;
}

class FrostRiskWidget extends StatefulWidget {
  const FrostRiskWidget({
    super.key,
    this.compactMode = false,
    this.latitude = FrostForecastService.defaultLatitude,
    this.longitude = FrostForecastService.defaultLongitude,
  });

  final double latitude;
  final double longitude;
  final bool compactMode;

  @override
  State<FrostRiskWidget> createState() => _FrostRiskWidgetState();
}

class _FrostRiskWidgetState extends State<FrostRiskWidget> {
  final FrostForecastService service = const FrostForecastService();

  late Future<List<FrostForecastDay>> forecastFuture;

  @override
  void initState() {
    super.initState();
    forecastFuture = _load();
  }

  @override
  void didUpdateWidget(covariant FrostRiskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      forecastFuture = _load();
    }
  }

  Future<List<FrostForecastDay>> _load() {
    return service.fetchForecast(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
  }

  void _refresh() {
    setState(() {
      forecastFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FrostForecastDay>>(
      future: forecastFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _FrostLoading();
        }

        if (snapshot.hasError) {
          return _FrostError(
            message: snapshot.error.toString(),
            onRetry: _refresh,
          );
        }

        final days = snapshot.data ?? const <FrostForecastDay>[];

        if (days.isEmpty) {
          return _FrostError(
            message: 'No frost forecast data available.',
            onRetry: _refresh,
          );
        }

        return _FrostContent(days: days, onRefresh: _refresh);
      },
    );
  }
}

class _FrostLoading extends StatelessWidget {
  const _FrostLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: GardenTheme.panel,
        border: Border(bottom: BorderSide(color: GardenTheme.border)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(
            'Loading frost forecast...',
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

class _FrostError extends StatelessWidget {
  const _FrostError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: GardenTheme.panel,
        border: Border(bottom: BorderSide(color: GardenTheme.border)),
      ),
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
          const SizedBox(width: 10),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _FrostContent extends StatelessWidget {
  const _FrostContent({required this.days, required this.onRefresh});

  final List<FrostForecastDay> days;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final today = days.isEmpty ? null : days.first;
    final tomorrow = days.length > 1 ? days[1] : null;
    final level = _overallRisk(days);
    final score = _riskScore(days);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: GardenTheme.panel,
        border: Border(bottom: BorderSide(color: GardenTheme.border)),
      ),
      child: Column(
        children: [
          if (level != FrostRiskLevel.none)
            _FrostAlertBanner(level: level, today: today, tomorrow: tomorrow),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 840;

                final header = _FrostHeader(
                  level: level,
                  today: today,
                  tomorrow: tomorrow,
                  onRefresh: onRefresh,
                );

                final scoreBar = _FrostScoreBar(score: score);
                final grid = _FrostSevenDayGrid(days: days);

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header,
                      const SizedBox(height: 12),
                      scoreBar,
                      const SizedBox(height: 12),
                      grid,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          header,
                          const SizedBox(height: 12),
                          scoreBar,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: grid),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static FrostRiskLevel _overallRisk(List<FrostForecastDay> days) {
    if (days.isEmpty) return FrostRiskLevel.none;

    final lowest = days.take(3).map((day) => day.lowC).reduce(math.min);

    if (lowest <= -2) return FrostRiskLevel.danger;
    if (lowest <= 0) return FrostRiskLevel.high;
    if (lowest <= 2) return FrostRiskLevel.moderate;
    if (lowest <= 4) return FrostRiskLevel.low;
    return FrostRiskLevel.none;
  }

  static double _riskScore(List<FrostForecastDay> days) {
    if (days.isEmpty) return 0;

    final lowest = days.take(3).map((day) => day.lowC).reduce(math.min);

    if (lowest <= -3) return 1;
    if (lowest >= 8) return 0;

    return ((8 - lowest) / 11).clamp(0, 1).toDouble();
  }
}

class _FrostAlertBanner extends StatelessWidget {
  const _FrostAlertBanner({
    required this.level,
    required this.today,
    required this.tomorrow,
  });

  final FrostRiskLevel level;
  final FrostForecastDay? today;
  final FrostForecastDay? tomorrow;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(level);
    final background = _riskBackground(level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(color: color.withValues(alpha: 0.22)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.ac_unit, color: color, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _alertCopy(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _alertCopy() {
    final tonight = today == null
        ? null
        : '${today!.lowC.toStringAsFixed(0)}\u00B0C tonight';
    final tomorrowText = tomorrow == null
        ? null
        : '${tomorrow!.lowC.toStringAsFixed(0)}\u00B0C tomorrow night';

    switch (level) {
      case FrostRiskLevel.danger:
        return 'Danger frost risk. Cover tender crops and avoid transplanting. ${_join(tonight, tomorrowText)}.';
      case FrostRiskLevel.high:
        return 'High frost risk. Protect seedlings and tender crops. ${_join(tonight, tomorrowText)}.';
      case FrostRiskLevel.moderate:
        return 'Possible frost risk. Check exposed seedlings and young plantings. ${_join(tonight, tomorrowText)}.';
      case FrostRiskLevel.low:
        return 'Low frost risk. Monitor tender crops in exposed beds. ${_join(tonight, tomorrowText)}.';
      case FrostRiskLevel.none:
        return 'No frost risk detected.';
    }
  }

  String _join(String? a, String? b) {
    final parts = [a, b].whereType<String>().where((v) => v.isNotEmpty);
    return parts.join('. ');
  }
}

class _FrostHeader extends StatelessWidget {
  const _FrostHeader({
    required this.level,
    required this.today,
    required this.tomorrow,
    required this.onRefresh,
  });

  final FrostRiskLevel level;
  final FrostForecastDay? today;
  final FrostForecastDay? tomorrow;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(level);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _riskBackground(level),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Icon(Icons.ac_unit, size: 19, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FROST RISK',
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
                      _riskTitle(level),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GardenTheme.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RiskChip(level: level),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    iconSize: 18,
                    color: GardenTheme.muted,
                    tooltip: 'Refresh forecast',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _detailCopy(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: GardenTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _detailCopy() {
    final tonight = today == null
        ? 'No tonight data'
        : 'Tonight ${today!.lowC.toStringAsFixed(0)}\u00B0C';
    final tomorrowText = tomorrow == null
        ? 'No tomorrow data'
        : 'Tomorrow night ${tomorrow!.lowC.toStringAsFixed(0)}\u00B0C';

    return '$tonight. $tomorrowText. Open-Meteo forecast';
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.level});

  final FrostRiskLevel level;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _riskBackground(level),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        _riskLabel(level),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FrostSevenDayGrid extends StatelessWidget {
  const _FrostSevenDayGrid({required this.days});

  final List<FrostForecastDay> days;

  @override
  Widget build(BuildContext context) {
    final visibleDays = days.take(7).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        if (compact) {
          return Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final day in visibleDays)
                SizedBox(width: 88, child: _FrostDayCard(day: day)),
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < visibleDays.length; i++) ...[
              Expanded(child: _FrostDayCard(day: visibleDays[i])),
              if (i != visibleDays.length - 1) const SizedBox(width: 7),
            ],
          ],
        );
      },
    );
  }
}

class _FrostDayCard extends StatelessWidget {
  const _FrostDayCard({required this.day});

  final FrostForecastDay day;

  @override
  Widget build(BuildContext context) {
    final level = _levelForLow(day.lowC);
    final color = _riskColor(level);

    return Container(
      height: 96,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: _riskBackground(level),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        children: [
          Text(
            _dayLabel(day.date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GardenTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${day.lowC.toStringAsFixed(0)}\u00B0',
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 4),
          Text(
            day.condition,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GardenTheme.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FrostScoreBar extends StatelessWidget {
  const _FrostScoreBar({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final markerLeft = (score.clamp(0, 1) * 100).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3-DAY FROST PRESSURE',
          style: TextStyle(
            color: GardenTheme.muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 18,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 6,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFBFDCC8),
                        Color(0xFFF0CF9D),
                        Color(0xFFB4C8F5),
                        Color(0xFFF4B8C8),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 1,
                child: FractionallySizedBox(
                  widthFactor: markerLeft / 100,
                  alignment: Alignment.centerLeft,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: GardenTheme.ink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LOW', style: _scaleLabelStyle),
            Text('MOD', style: _scaleLabelStyle),
            Text('HIGH', style: _scaleLabelStyle),
            Text('DANGER', style: _scaleLabelStyle),
          ],
        ),
      ],
    );
  }
}

const TextStyle _scaleLabelStyle = TextStyle(
  color: GardenTheme.muted,
  fontSize: 9,
  fontWeight: FontWeight.w800,
  letterSpacing: 0.8,
);

FrostRiskLevel _levelForLow(double lowC) {
  if (lowC <= -2) return FrostRiskLevel.danger;
  if (lowC <= 0) return FrostRiskLevel.high;
  if (lowC <= 2) return FrostRiskLevel.moderate;
  if (lowC <= 4) return FrostRiskLevel.low;
  return FrostRiskLevel.none;
}

Color _riskColor(FrostRiskLevel level) {
  switch (level) {
    case FrostRiskLevel.none:
      return GardenTheme.muted;
    case FrostRiskLevel.low:
      return GardenTheme.good;
    case FrostRiskLevel.moderate:
      return GardenTheme.warn;
    case FrostRiskLevel.high:
      return GardenTheme.hold;
    case FrostRiskLevel.danger:
      return GardenTheme.bad;
  }
}

Color _riskBackground(FrostRiskLevel level) {
  switch (level) {
    case FrostRiskLevel.none:
      return GardenTheme.paper;
    case FrostRiskLevel.low:
      return const Color(0xFFEEF8F0);
    case FrostRiskLevel.moderate:
      return const Color(0xFFFFF3E5);
    case FrostRiskLevel.high:
      return const Color(0xFFEFF3FF);
    case FrostRiskLevel.danger:
      return const Color(0xFFFFF0F3);
  }
}

String _riskTitle(FrostRiskLevel level) {
  switch (level) {
    case FrostRiskLevel.none:
      return 'No frost expected';
    case FrostRiskLevel.low:
      return 'Low frost risk';
    case FrostRiskLevel.moderate:
      return 'Moderate frost risk';
    case FrostRiskLevel.high:
      return 'High frost risk';
    case FrostRiskLevel.danger:
      return 'Danger frost risk';
  }
}

String _riskLabel(FrostRiskLevel level) {
  switch (level) {
    case FrostRiskLevel.none:
      return 'NONE';
    case FrostRiskLevel.low:
      return 'LOW';
    case FrostRiskLevel.moderate:
      return 'MOD';
    case FrostRiskLevel.high:
      return 'HIGH';
    case FrostRiskLevel.danger:
      return 'DANGER';
  }
}

String _dayLabel(DateTime date) {
  const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  return labels[date.weekday - 1];
}
