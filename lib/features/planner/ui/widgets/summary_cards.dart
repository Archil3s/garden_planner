import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({
    super.key,
    required this.beds,
    required this.overlapCount,
  });

  final List<Bed> beds;
  final int overlapCount;

  @override
  Widget build(BuildContext context) {
    final totalBeds = beds.length;

    final plantedCrops = beds
        .expand((bed) => bed.crops)
        .where((crop) => crop.trim().isNotEmpty)
        .toSet()
        .length;

    final needsAttention = beds
        .where((bed) => bed.status != BedStatus.ok)
        .length;

    final totalArea = beds.fold<double>(
      0,
      (sum, bed) => sum + bed.width * bed.height,
    );

    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SummaryCard(
            label: 'Total Beds',
            value: totalBeds.toString(),
            sublabel: 'Active layout cards',
            accentColor: GardenTheme.ink,
          ),
          const SizedBox(width: 12),
          SummaryCard(
            label: 'Planted Crops',
            value: plantedCrops.toString(),
            sublabel: 'Unique crop labels',
            accentColor: GardenTheme.good,
          ),
          const SizedBox(width: 12),
          SummaryCard(
            label: 'Needs Attention',
            value: needsAttention.toString(),
            sublabel: 'Warning, issue, or hold',
            accentColor: needsAttention == 0
                ? GardenTheme.good
                : GardenTheme.warn,
          ),
          const SizedBox(width: 12),
          SummaryCard(
            label: 'Layout Issues',
            value: overlapCount.toString(),
            sublabel: overlapCount == 0
                ? 'No overlapping beds'
                : 'Overlapping bed warnings',
            accentColor: overlapCount == 0 ? GardenTheme.good : GardenTheme.bad,
          ),
          const SizedBox(width: 12),
          SummaryCard(
            label: 'Garden Area',
            value: '${totalArea.toStringAsFixed(0)} m²',
            sublabel: 'Total planned bed area',
            accentColor: GardenTheme.hold,
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.sublabel,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String sublabel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: GardenTheme.cardDecoration(
        background: GardenTheme.panel,
        borderColor: GardenTheme.border,
        radius: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: double.infinity,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
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
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  sublabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GardenTheme.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
