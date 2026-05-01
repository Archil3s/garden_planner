import 'package:flutter/material.dart';

import '../../../../core/models/crop_placement.dart';
import '../../../../core/models/crop_spacing.dart';
import '../../../../core/theme/garden_theme.dart';

class CropPlanningSection extends StatelessWidget {
  const CropPlanningSection({
    super.key,
    required this.crops,
    required this.cropPlacements,
    required this.onRemoveCrop,
    required this.onPlantCrop,
    required this.onPlaceCropRow,
  });

  final List<String> crops;
  final List<CropPlacement> cropPlacements;
  final ValueChanged<String> onRemoveCrop;
  final ValueChanged<String> onPlantCrop;
  final ValueChanged<String> onPlaceCropRow;

  @override
  Widget build(BuildContext context) {
    final cleanCrops = crops
        .map((crop) => crop.trim())
        .where((crop) => crop.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'Crop Planning'),
        const SizedBox(height: 8),
        if (cleanCrops.isEmpty)
          const _EmptyCropPlanningCard()
        else
          Column(
            children: [
              for (var i = 0; i < cleanCrops.length; i++) ...[
                _CropPlanningCard(
                  crop: cleanCrops[i],
                  index: i,
                  plantedCount: _plantedCountFor(cleanCrops[i]),
                  onRemoveCrop: onRemoveCrop,
                  onPlantCrop: onPlantCrop,
                  onPlaceCropRow: onPlaceCropRow,
                ),
                if (i != cleanCrops.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        const SizedBox(height: 10),
        const _CropPlanningHint(),
      ],
    );
  }

  int _plantedCountFor(String cropName) {
    final target = cropName.trim().toLowerCase();

    return cropPlacements.where((placement) {
      return placement.cropName.trim().toLowerCase() == target;
    }).length;
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

class _EmptyCropPlanningCard extends StatelessWidget {
  const _EmptyCropPlanningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: GardenTheme.paper,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: GardenTheme.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CropIcon(label: '+', color: GardenTheme.muted),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No crops assigned yet. Add crops in the Crops field above using comma-separated names.',
              style: TextStyle(
                color: GardenTheme.muted,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropPlanningCard extends StatelessWidget {
  const _CropPlanningCard({
    required this.crop,
    required this.index,
    required this.plantedCount,
    required this.onRemoveCrop,
    required this.onPlantCrop,
    required this.onPlaceCropRow,
  });

  final String crop;
  final int index;
  final int plantedCount;
  final ValueChanged<String> onRemoveCrop;
  final ValueChanged<String> onPlantCrop;
  final ValueChanged<String> onPlaceCropRow;

  @override
  Widget build(BuildContext context) {
    final color = _cropColor(index);
    final category = _cropCategory(crop);
    final spacingLabel = CropSpacing.spacingLabelForCrop(crop);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GardenTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CropIcon(
                label: crop.characters.first.toUpperCase(),
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GardenTheme.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category,
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
              const SizedBox(width: 8),
              _PlantedCountBadge(count: plantedCount, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  label: spacingLabel,
                  color: GardenTheme.muted,
                  background: GardenTheme.paper,
                ),
              ),
              const SizedBox(width: 8),
              _RemoveCropButton(crop: crop, onRemoveCrop: onRemoveCrop),
            ],
          ),
          const SizedBox(height: 10),
          _PlaceIconButton(crop: crop, color: color, onPlantCrop: onPlantCrop),
          const SizedBox(height: 8),
          _PlaceRowButton(
            crop: crop,
            color: color,
            onPlaceCropRow: onPlaceCropRow,
          ),
        ],
      ),
    );
  }

  Color _cropColor(int index) {
    final colors = [
      GardenTheme.good,
      GardenTheme.warn,
      GardenTheme.hold,
      GardenTheme.ink,
    ];

    return colors[index % colors.length];
  }

  String _cropCategory(String crop) {
    final lower = crop.toLowerCase();

    if (lower.contains('strawberry') ||
        lower.contains('raspberry') ||
        lower.contains('blueberry')) {
      return 'Berry crop';
    }

    if (lower.contains('broccoli') ||
        lower.contains('lettuce') ||
        lower.contains('spinach') ||
        lower.contains('kale')) {
      return 'Leafy / brassica crop';
    }

    if (lower.contains('tomato') ||
        lower.contains('pepper') ||
        lower.contains('cucumber')) {
      return 'Fruit-bearing annual';
    }

    if (lower.contains('basil') ||
        lower.contains('mint') ||
        lower.contains('parsley') ||
        lower.contains('thyme')) {
      return 'Herb / companion crop';
    }

    return 'General crop';
  }
}

class _PlaceIconButton extends StatelessWidget {
  const _PlaceIconButton({
    required this.crop,
    required this.color,
    required this.onPlantCrop,
  });

  final String crop;
  final Color color;
  final ValueChanged<String> onPlantCrop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          onPlantCrop(crop);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.34)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_location_alt_outlined, size: 16, color: color),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  'PLACE ${crop.toUpperCase()} ICON',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceRowButton extends StatelessWidget {
  const _PlaceRowButton({
    required this.crop,
    required this.color,
    required this.onPlaceCropRow,
  });

  final String crop;
  final Color color;
  final ValueChanged<String> onPlaceCropRow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GardenTheme.paper,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          onPlaceCropRow(crop);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.view_week_outlined, size: 16, color: color),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  'PLACE ${crop.toUpperCase()} ROW',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveCropButton extends StatelessWidget {
  const _RemoveCropButton({required this.crop, required this.onRemoveCrop});

  final String crop;
  final ValueChanged<String> onRemoveCrop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0EE),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () {
          onRemoveCrop(crop);
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: GardenTheme.bad.withValues(alpha: 0.28)),
          ),
          child: const Text(
            'REMOVE',
            style: TextStyle(
              color: GardenTheme.bad,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantedCountBadge extends StatelessWidget {
  const _PlantedCountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 planted' : '$count planted';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: count == 0 ? GardenTheme.paper : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: count == 0
              ? GardenTheme.border
              : color.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: count == 0 ? GardenTheme.muted : color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.55,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
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
      height: 31,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.55,
        ),
      ),
    );
  }
}

class _CropIcon extends StatelessWidget {
  const _CropIcon({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CropPlanningHint extends StatelessWidget {
  const _CropPlanningHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GardenTheme.border),
      ),
      child: const Text(
        'Place Icon adds a draggable crop marker. Place Row adds a draggable, resizable crop strip. Both snap to the crop spacing grid.',
        style: TextStyle(
          color: GardenTheme.muted,
          fontSize: 11,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
