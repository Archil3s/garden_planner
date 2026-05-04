import 'package:flutter/material.dart';

import 'package:garden_planner/core/models/bed.dart';

Future<void> showBedDesignStudioSheet({
  required BuildContext context,
  required Bed bed,
  required String bedName,
  required String activePlant,
  required int totalPlaced,
  required int capacity,
  required int used,
  required int openSlots,
  required int conflictCount,
  required double spacingMeters,
  required VoidCallback onPickPlant,
  required VoidCallback onAutoFill,
  required VoidCallback onBorderFill,
  required VoidCallback onCenterRowFill,
  required VoidCallback onClearActive,
  required VoidCallback onCleanSpacing,
  required VoidCallback onEditSize,
  required VoidCallback onClearBed,
  required VoidCallback onResetBed,
  required VoidCallback onSave,
}) async {
  void closeThen(BuildContext context, VoidCallback callback) {
    Navigator.of(context).pop();
    callback();
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: const Color(0xFFFFFBF4),
    builder: (context) {
      final hasPlant = activePlant.trim().isNotEmpty;
      final spacingLabel = hasPlant
          ? '${(spacingMeters * 100).round()}cm'
          : 'Pick plant';

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.auto_awesome)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Design Studio',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                bedName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                hasPlant
                    ? 'Active plant: $activePlant'
                    : 'Pick a plant to unlock layout tools.',
              ),
              const SizedBox(height: 16),
              _StudioStatGrid(
                stats: [
                  _StudioStat(
                    label: 'Bed size',
                    value:
                        '${bed.width.toStringAsFixed(1)}m x ${bed.height.toStringAsFixed(1)}m',
                  ),
                  _StudioStat(
                    label: 'Total placed',
                    value: totalPlaced.toString(),
                  ),
                  _StudioStat(label: 'Spacing', value: spacingLabel),
                  _StudioStat(
                    label: 'Capacity',
                    value: hasPlant ? capacity.toString() : 'Pick plant',
                  ),
                  _StudioStat(
                    label: 'Used',
                    value: hasPlant ? used.toString() : 'Pick plant',
                  ),
                  _StudioStat(
                    label: 'Open slots',
                    value: hasPlant ? openSlots.toString() : 'Pick plant',
                  ),
                  _StudioStat(
                    label: 'Conflicts',
                    value: conflictCount.toString(),
                  ),
                  _StudioStat(
                    label: 'Health',
                    value: conflictCount == 0 ? 'Clean' : 'Review',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StudioSection(
                title: 'Layout generators',
                children: [
                  _StudioAction(
                    icon: Icons.grid_on,
                    title: 'Auto-fill grid',
                    subtitle:
                        'Fill all available strict-spacing slots with the active plant.',
                    onPressed: hasPlant
                        ? () => closeThen(context, onAutoFill)
                        : () => closeThen(context, onPickPlant),
                  ),
                  _StudioAction(
                    icon: Icons.border_outer,
                    title: 'Border planting',
                    subtitle:
                        'Place the active plant around the bed edge for borders or companion planting.',
                    onPressed: hasPlant
                        ? () => closeThen(context, onBorderFill)
                        : () => closeThen(context, onPickPlant),
                  ),
                  _StudioAction(
                    icon: Icons.horizontal_rule,
                    title: 'Center row',
                    subtitle:
                        'Create a clean row through the middle of the bed.',
                    onPressed: hasPlant
                        ? () => closeThen(context, onCenterRowFill)
                        : () => closeThen(context, onPickPlant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StudioSection(
                title: 'Cleanup tools',
                children: [
                  _StudioAction(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clear active plant',
                    subtitle: 'Remove only the selected plant from this bed.',
                    onPressed: hasPlant
                        ? () => closeThen(context, onClearActive)
                        : () => closeThen(context, onPickPlant),
                  ),
                  _StudioAction(
                    icon: Icons.rule,
                    title: 'Clean spacing conflicts',
                    subtitle:
                        'Remove placements that break strict spacing rules.',
                    onPressed: () => closeThen(context, onCleanSpacing),
                  ),
                  _StudioAction(
                    icon: Icons.straighten,
                    title: 'Edit bed size',
                    subtitle: 'Resize this bed and sanitize placements.',
                    onPressed: () => closeThen(context, onEditSize),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StudioSection(
                title: 'Project actions',
                children: [
                  _StudioAction(
                    icon: Icons.save_outlined,
                    title: 'Save garden',
                    subtitle: 'Save the current garden project.',
                    onPressed: () => closeThen(context, onSave),
                  ),
                  _StudioAction(
                    icon: Icons.layers_clear_outlined,
                    title: 'Clear bed',
                    subtitle: 'Remove every crop from this bed.',
                    onPressed: () => closeThen(context, onClearBed),
                  ),
                  _StudioAction(
                    icon: Icons.restart_alt,
                    title: 'Reset bed',
                    subtitle: 'Open the reset confirmation for this bed.',
                    onPressed: () => closeThen(context, onResetBed),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Workflow: pick a plant, open Design Studio, generate a layout, then clean spacing if needed.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _StudioStat {
  const _StudioStat({required this.label, required this.value});

  final String label;
  final String value;
}

class _StudioStatGrid extends StatelessWidget {
  const _StudioStatGrid({required this.stats});

  final List<_StudioStat> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: stats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 76,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudioSection extends StatelessWidget {
  const _StudioSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _StudioAction extends StatelessWidget {
  const _StudioAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
