import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';

class ActionCards extends StatelessWidget {
  const ActionCards({
    super.key,
    required this.beds,
    required this.overlapCount,
  });

  final List<Bed> beds;
  final int overlapCount;

  @override
  Widget build(BuildContext context) {
    final attentionBeds = beds
        .where((bed) => bed.status != BedStatus.ok)
        .toList();

    final totalArea = beds.fold<double>(
      0,
      (sum, bed) => sum + bed.width * bed.height,
    );

    final actions = <_PlannerAction>[
      if (overlapCount > 0)
        _PlannerAction(
          priority: 'P1',
          priorityColor: GardenTheme.bad,
          title: 'Resolve overlapping beds',
          meta: '$overlapCount bed${overlapCount == 1 ? '' : 's'} overlap',
          description:
              'Move or resize overlapping beds before finalizing the garden layout.',
        ),
      if (attentionBeds.isNotEmpty)
        _PlannerAction(
          priority: 'P2',
          priorityColor: GardenTheme.warn,
          title: 'Review ${attentionBeds.first.name}',
          meta:
              '${attentionBeds.length} bed${attentionBeds.length == 1 ? '' : 's'} need attention',
          description:
              'Status is not healthy. Check crops, size, and placement before finalizing the garden layout.',
        ),
      if (beds.isEmpty)
        const _PlannerAction(
          priority: 'P1',
          priorityColor: GardenTheme.bad,
          title: 'Add your first bed',
          meta: 'No beds placed',
          description:
              'Create a bed to begin planning the garden layout on the meter-based canvas.',
        )
      else
        _PlannerAction(
          priority: 'P3',
          priorityColor: GardenTheme.good,
          title: 'Continue layout planning',
          meta:
              '${beds.length} beds · ${totalArea.toStringAsFixed(0)} m² planned',
          description:
              'Adjust bed placement, crop labels, and health status before moving to crop layout or zoom controls.',
        ),
    ];

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = actions[index];

          return _ActionCard(action: action);
        },
      ),
    );
  }
}

class _PlannerAction {
  const _PlannerAction({
    required this.priority,
    required this.priorityColor,
    required this.title,
    required this.meta,
    required this.description,
  });

  final String priority;
  final Color priorityColor;
  final String title;
  final String meta;
  final String description;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final _PlannerAction action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(14),
      decoration: GardenTheme.cardDecoration(
        background: Colors.white,
        borderColor: GardenTheme.border,
        radius: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PriorityChip(label: action.priority, color: action.priorityColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GardenTheme.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GardenTheme.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF39352F),
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

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
