import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';

class BedDetailSections extends StatelessWidget {
  const BedDetailSections({super.key, required this.bed});

  final Bed bed;

  @override
  Widget build(BuildContext context) {
    final area = bed.width * bed.height;
    final cropCount = bed.crops.length;
    final healthPercent = (bed.healthPercent * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'Bed Summary'),
        const SizedBox(height: 8),
        _SummaryGrid(
          children: [
            _SummaryTile(label: 'Area', value: '${area.toStringAsFixed(0)} m²'),
            _SummaryTile(label: 'Crops', value: cropCount.toString()),
            _SummaryTile(
              label: 'Health',
              value: '$healthPercent%',
              valueColor: _healthColor(bed.healthPercent),
            ),
            _SummaryTile(
              label: 'Status',
              value: _statusLabel(bed.status),
              valueColor: _statusColor(bed.status),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionLabel(label: 'Planning Notes'),
        const SizedBox(height: 8),
        _NoteCard(title: 'Rotation', body: _rotationNote(bed), icon: '↻'),
        const SizedBox(height: 8),
        _NoteCard(title: 'Spacing', body: _spacingNote(bed), icon: '↔'),
        const SizedBox(height: 16),
        const _SectionLabel(label: 'Timeline'),
        const SizedBox(height: 8),
        _TimelineItem(
          icon: '1',
          title: 'Bed placed',
          meta:
              '${bed.width.toStringAsFixed(1)}m × ${bed.height.toStringAsFixed(1)}m at ${bed.x.toStringAsFixed(1)}m, ${bed.y.toStringAsFixed(1)}m',
        ),
        const SizedBox(height: 8),
        _TimelineItem(
          icon: '2',
          title: bed.status == BedStatus.ok
              ? 'Layout healthy'
              : 'Review needed',
          meta: bed.status == BedStatus.ok
              ? 'No active status warnings.'
              : 'Check this bed before finalizing the garden plan.',
          warning: bed.status != BedStatus.ok,
        ),
        const SizedBox(height: 8),
        const _TimelineItem(
          icon: '3',
          title: 'Next step',
          meta:
              'Resize handles, crop planning, or save/load can be added next.',
        ),
      ],
    );
  }

  Color _healthColor(double value) {
    if (value >= 0.75) return GardenTheme.good;
    if (value >= 0.45) return GardenTheme.warn;
    return GardenTheme.bad;
  }

  Color _statusColor(BedStatus status) {
    switch (status) {
      case BedStatus.ok:
        return GardenTheme.good;
      case BedStatus.warning:
        return GardenTheme.warn;
      case BedStatus.bad:
        return GardenTheme.bad;
      case BedStatus.hold:
        return GardenTheme.hold;
    }
  }

  String _statusLabel(BedStatus status) {
    switch (status) {
      case BedStatus.ok:
        return 'OK';
      case BedStatus.warning:
        return 'Review';
      case BedStatus.bad:
        return 'Issue';
      case BedStatus.hold:
        return 'Hold';
    }
  }

  String _rotationNote(Bed bed) {
    if (bed.crops.isEmpty) {
      return 'No crops assigned yet. Add crops before planning rotation.';
    }

    return 'Rotate future annual crops away from ${bed.crops.first.toLowerCase()} where possible.';
  }

  String _spacingNote(Bed bed) {
    final area = bed.width * bed.height;

    if (area < 8) {
      return 'Compact bed. Prefer small crops, herbs, or tight spacing.';
    }

    if (area < 20) {
      return 'Medium bed. Suitable for grouped crops or mixed companion planting.';
    }

    return 'Large bed. Consider internal paths, crop zones, or multiple crop blocks.';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: GardenTheme.muted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.85,
      children: children,
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    this.valueColor = GardenTheme.ink,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: GardenTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GardenTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CircleIcon(label: icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GardenTheme.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: GardenTheme.muted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.meta,
    this.warning = false,
  });

  final String icon;
  final String title;
  final String meta;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? GardenTheme.warn : GardenTheme.good;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFF4E7) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: warning
              ? GardenTheme.warn.withValues(alpha: 0.35)
              : GardenTheme.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CircleIcon(label: icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GardenTheme.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  style: const TextStyle(
                    color: GardenTheme.muted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.label, this.color = GardenTheme.ink});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
