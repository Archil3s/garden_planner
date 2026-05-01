import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';

class DecisionBanner extends StatelessWidget {
  const DecisionBanner({
    super.key,
    required this.beds,
    required this.overlapCount,
  });

  final List<Bed> beds;
  final int overlapCount;

  @override
  Widget build(BuildContext context) {
    final totalBeds = beds.length;

    final totalArea = beds.fold<double>(
      0,
      (sum, bed) => sum + bed.width * bed.height,
    );

    final attentionBeds = beds
        .where((bed) => bed.status != BedStatus.ok)
        .toList();

    final hasOverlaps = overlapCount > 0;
    final hasAttention = attentionBeds.isNotEmpty;

    final title = hasOverlaps
        ? 'Layout Review Needed'
        : hasAttention
        ? 'Review Needed'
        : 'Ready to Plan';

    final chipLabel = hasOverlaps
        ? '$overlapCount Layout Issues'
        : hasAttention
        ? '${attentionBeds.length} Needs Attention'
        : 'Layout Healthy';

    final body = hasOverlaps
        ? '$overlapCount bed${overlapCount == 1 ? '' : 's'} overlap. Move or resize overlapping beds before finalizing.'
        : hasAttention
        ? 'Review ${attentionBeds.first.name} before finalizing the garden layout.'
        : 'All active beds are currently marked healthy. Continue arranging or add more beds.';

    final accentColor = hasOverlaps
        ? GardenTheme.bad
        : hasAttention
        ? GardenTheme.warn
        : GardenTheme.good;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: GardenTheme.panelDecoration(radius: 16),
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GardenTheme.paper,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GardenTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DecisionChip(label: chipLabel, color: accentColor),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: const TextStyle(
                            color: GardenTheme.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: GardenTheme.muted,
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GardenTheme.border),
              ),
              child: Wrap(
                spacing: 18,
                runSpacing: 14,
                children: [
                  _DecisionFact(label: 'Beds', value: totalBeds.toString()),
                  _DecisionFact(
                    label: 'Area',
                    value: '${totalArea.toStringAsFixed(0)} m²',
                  ),
                  _DecisionFact(
                    label: 'Attention',
                    value: attentionBeds.length.toString(),
                    valueColor: hasAttention
                        ? GardenTheme.warn
                        : GardenTheme.good,
                  ),
                  _DecisionFact(
                    label: 'Overlap',
                    value: overlapCount.toString(),
                    valueColor: hasOverlaps
                        ? GardenTheme.bad
                        : GardenTheme.good,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionChip extends StatelessWidget {
  const _DecisionChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _DecisionFact extends StatelessWidget {
  const _DecisionFact({
    required this.label,
    required this.value,
    this.valueColor = GardenTheme.ink,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
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
              color: valueColor,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
