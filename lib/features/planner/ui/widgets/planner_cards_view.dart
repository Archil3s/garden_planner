import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';

class PlannerCardsView extends StatefulWidget {
  const PlannerCardsView({
    super.key,
    required this.beds,
    required this.onOpenBedDetails,
  });

  final List<Bed> beds;
  final ValueChanged<Bed> onOpenBedDetails;

  @override
  State<PlannerCardsView> createState() => _PlannerCardsViewState();
}

class _PlannerCardsViewState extends State<PlannerCardsView> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.beds.isEmpty) {
      return const Center(
        child: Text(
          'No beds match the current search or filter.',
          style: TextStyle(
            color: GardenTheme.muted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 1180
            ? 3
            : width >= 760
            ? 2
            : 1;

        return Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: widget.beds.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 330,
            ),
            itemBuilder: (context, index) {
              final bed = widget.beds[index];

              return _BedSummaryCard(
                bed: bed,
                onTap: () => widget.onOpenBedDetails(bed),
              );
            },
          ),
        );
      },
    );
  }
}

class _BedSummaryCard extends StatelessWidget {
  const _BedSummaryCard({required this.bed, required this.onTap});

  final Bed bed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(bed.status);
    final statusLabel = _statusLabel(bed.status);
    final area = bed.width * bed.height;
    final plantedCount = bed.cropPlacements.length + bed.cropBlocks.length;
    final cleanCrops = bed.crops
        .map((crop) => crop.toString().trim())
        .where((crop) => crop.isNotEmpty)
        .toList();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withValues(alpha: 0.42)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NumberBadge(number: bed.number, color: statusColor),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bed.name.trim().isEmpty
                                ? 'Untitled Bed'
                                : bed.name.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GardenTheme.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${bed.zone.trim().isEmpty ? 'Main Garden' : bed.zone.trim().toUpperCase()} · ${bed.width.toStringAsFixed(1)}m × ${bed.height.toStringAsFixed(1)}m',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GardenTheme.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(label: statusLabel, color: statusColor),
                  ],
                ),
              ),
              const Divider(height: 1, color: GardenTheme.border),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FactTile(
                            label: 'Health',
                            value: '${(bed.healthPercent * 100).round()}%',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FactTile(
                            label: 'Area',
                            value: '${area.toStringAsFixed(0)} m²',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FactTile(
                            label: 'Planted',
                            value: plantedCount.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _CropsPanel(crops: cleanCrops),
                    const SizedBox(height: 12),
                    _ActivityPanel(bed: bed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        return 'On track';
      case BedStatus.warning:
        return 'Attention';
      case BedStatus.bad:
        return 'Issue';
      case BedStatus.hold:
        return 'Hold';
    }
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.color});

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        number.toString(),
        style: const TextStyle(
          color: GardenTheme.cream,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label.toUpperCase(),
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

class _FactTile extends StatelessWidget {
  const _FactTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(10),
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
            style: const TextStyle(
              color: GardenTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: GardenTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropsPanel extends StatelessWidget {
  const _CropsPanel({required this.crops});

  final List<String> crops;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: GardenTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CROPS IN THIS BED',
            style: TextStyle(
              color: GardenTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          if (crops.isEmpty)
            const Text(
              'No crops assigned.',
              style: TextStyle(
                color: GardenTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final crop in crops.take(5))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF8F0),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: GardenTheme.good.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      crop,
                      style: const TextStyle(
                        color: GardenTheme.good,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.bed});

  final Bed bed;

  @override
  Widget build(BuildContext context) {
    final hasPlantings =
        bed.cropPlacements.isNotEmpty || bed.cropBlocks.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Row(
        children: [
          Icon(
            hasPlantings ? Icons.eco : Icons.event_note_outlined,
            color: hasPlantings ? GardenTheme.good : GardenTheme.muted,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              hasPlantings
                  ? '${bed.cropPlacements.length} icons · ${bed.cropBlocks.length} rows planted'
                  : 'No planting activity logged yet.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: GardenTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: GardenTheme.muted, size: 20),
        ],
      ),
    );
  }
}
