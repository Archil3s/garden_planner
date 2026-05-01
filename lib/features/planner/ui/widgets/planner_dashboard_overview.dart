import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';
import 'frost_risk_widget.dart';
import 'spray_conditions_widget.dart';

class PlannerDashboardOverview extends StatefulWidget {
  const PlannerDashboardOverview({
    super.key,
    required this.beds,
    required this.overlapCount,
    required this.showWeather,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  final List<Bed> beds;
  final int overlapCount;
  final bool showWeather;
  final String locationName;
  final double latitude;
  final double longitude;

  @override
  State<PlannerDashboardOverview> createState() =>
      _PlannerDashboardOverviewState();
}

class _PlannerDashboardOverviewState extends State<PlannerDashboardOverview> {
  bool expanded = true;
  bool weatherExpanded = true;

  final ScrollController dashboardScrollController = ScrollController();

  @override
  void dispose() {
    dashboardScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalBeds = widget.beds.length;
    final plantedBeds = widget.beds.where(_hasPlanting).length;
    final attentionBeds = widget.beds.where(_needsAttention).length;
    final onHoldBeds = widget.beds
        .where((bed) => bed.status == BedStatus.hold)
        .length;
    final issueBeds = widget.beds
        .where(
          (bed) =>
              bed.status == BedStatus.bad || bed.status == BedStatus.warning,
        )
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final compact = constraints.maxWidth < 860;
        final maxExpandedHeight = math.max(
          220.0,
          math.min(screenHeight * 0.72, compact ? 560.0 : 720.0),
        );

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: expanded ? maxExpandedHeight : 62,
          ),
          decoration: const BoxDecoration(
            color: GardenTheme.cream,
            border: Border(bottom: BorderSide(color: GardenTheme.border)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 8 : 14,
                  compact ? 8 : 12,
                  compact ? 8 : 14,
                  8,
                ),
                child: _DashboardHeader(
                  compact: compact,
                  totalBeds: totalBeds,
                  locationName: widget.locationName,
                  expanded: expanded,
                  weatherExpanded: weatherExpanded,
                  showWeatherButton: widget.showWeather,
                  onToggleExpanded: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  onToggleWeather: widget.showWeather
                      ? () {
                          setState(() {
                            weatherExpanded = !weatherExpanded;
                          });
                        }
                      : null,
                ),
              ),
              if (expanded)
                Expanded(
                  child: Scrollbar(
                    controller: dashboardScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: dashboardScrollController,
                      padding: EdgeInsets.fromLTRB(
                        compact ? 8 : 14,
                        0,
                        compact ? 8 : 14,
                        compact ? 8 : 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MetricsWrap(
                            cards: [
                              _MetricData(
                                label: 'Total Beds',
                                value: totalBeds.toString(),
                                caption: 'Active beds',
                                color: GardenTheme.ink,
                                icon: Icons.grid_view_rounded,
                              ),
                              _MetricData(
                                label: 'Planted',
                                value: plantedBeds.toString(),
                                caption: 'Crops or rows',
                                color: GardenTheme.good,
                                icon: Icons.eco,
                              ),
                              _MetricData(
                                label: 'Attention',
                                value: attentionBeds.toString(),
                                caption: 'Needs work',
                                color: GardenTheme.warn,
                                icon: Icons.warning_amber_rounded,
                              ),
                              _MetricData(
                                label: 'Hold',
                                value: onHoldBeds.toString(),
                                caption: 'Paused beds',
                                color: GardenTheme.hold,
                                icon: Icons.pause_circle_outline,
                              ),
                              _MetricData(
                                label: 'Overlap',
                                value: widget.overlapCount.toString(),
                                caption: widget.overlapCount == 0
                                    ? 'No conflicts'
                                    : 'Layout issue',
                                color: widget.overlapCount == 0
                                    ? GardenTheme.good
                                    : GardenTheme.bad,
                                icon: Icons.report_problem_outlined,
                              ),
                              _MetricData(
                                label: 'Issues',
                                value: issueBeds.toString(),
                                caption: 'Active problems',
                                color: issueBeds == 0
                                    ? GardenTheme.good
                                    : GardenTheme.bad,
                                icon: Icons.bug_report_outlined,
                              ),
                            ],
                          ),
                          if (widget.showWeather && weatherExpanded) ...[
                            const SizedBox(height: 10),
                            _WeatherRiskGrid(
                              latitude: widget.latitude,
                              longitude: widget.longitude,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static bool _hasPlanting(Bed bed) {
    return bed.crops.isNotEmpty ||
        bed.cropPlacements.isNotEmpty ||
        bed.cropBlocks.isNotEmpty;
  }

  static bool _needsAttention(Bed bed) {
    return bed.status == BedStatus.warning ||
        bed.status == BedStatus.bad ||
        bed.status == BedStatus.hold;
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.compact,
    required this.totalBeds,
    required this.locationName,
    required this.expanded,
    required this.weatherExpanded,
    required this.showWeatherButton,
    required this.onToggleExpanded,
    required this.onToggleWeather,
  });

  final bool compact;
  final int totalBeds;
  final String locationName;
  final bool expanded;
  final bool weatherExpanded;
  final bool showWeatherButton;
  final VoidCallback onToggleExpanded;
  final VoidCallback? onToggleWeather;

  @override
  Widget build(BuildContext context) {
    final cleanLocation = locationName.trim().isEmpty
        ? 'Weather location'
        : locationName.trim();

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: GardenTheme.ink,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.dashboard_customize_outlined,
            color: GardenTheme.cream,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Garden Dashboard',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: GardenTheme.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              if (!compact)
                Text(
                  'Weather location: $cleanLocation.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GardenTheme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        if (!compact)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF8F0),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: GardenTheme.good.withValues(alpha: 0.24),
              ),
            ),
            child: Text(
              '$totalBeds BEDS',
              style: const TextStyle(
                color: GardenTheme.ink,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
        const SizedBox(width: 8),
        if (showWeatherButton && onToggleWeather != null)
          _HeaderButton(
            icon: weatherExpanded ? Icons.cloud_queue : Icons.cloud_off,
            label: compact
                ? ''
                : weatherExpanded
                ? 'Weather'
                : 'Weather Off',
            onTap: onToggleWeather!,
          ),
        const SizedBox(width: 8),
        _HeaderButton(
          icon: expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          label: compact
              ? ''
              : expanded
              ? 'Collapse'
              : 'Expand',
          onTap: onToggleExpanded,
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 34,
          padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 9 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: GardenTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: GardenTheme.ink, size: 16),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: GardenTheme.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricsWrap extends StatelessWidget {
  const _MetricsWrap({required this.cards});

  final List<_MetricData> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1260
            ? 6
            : width >= 980
            ? 3
            : width >= 640
            ? 2
            : 1;

        final cardWidth = (width - ((columns - 1) * 10)) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final card in cards)
              SizedBox(
                width: cardWidth,
                height: 92,
                child: _MetricCard(data: card),
              ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GardenTheme.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GardenTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 5, color: data.color),
            ),
            Positioned(
              right: -16,
              top: -14,
              child: Icon(
                data.icon,
                size: 66,
                color: data.color.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _MetricText(data: data)),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.11),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: data.color.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Icon(data.icon, color: data.color, size: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricText extends StatelessWidget {
  const _MetricText({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: GardenTheme.muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        Text(
          data.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: data.color,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            height: 0.92,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          data.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: GardenTheme.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WeatherRiskGrid extends StatelessWidget {
  const _WeatherRiskGrid({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 1120;

        if (stacked) {
          return Column(
            children: [
              FrostRiskWidget(
                compactMode: true,
                latitude: latitude,
                longitude: longitude,
              ),
              const SizedBox(height: 10),
              SprayConditionsWidget(
                compactMode: true,
                latitude: latitude,
                longitude: longitude,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FrostRiskWidget(
                compactMode: true,
                latitude: latitude,
                longitude: longitude,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SprayConditionsWidget(
                compactMode: true,
                latitude: latitude,
                longitude: longitude,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;
}
