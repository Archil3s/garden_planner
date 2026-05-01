import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/crop_block.dart';
import '../../../../core/models/crop_spacing.dart';
import '../../../../core/models/plant_profile_data.dart';
import '../../../../core/models/plant_variety_catalog.dart';
import '../../../../core/theme/garden_theme.dart';
import '../../../../core/plant_icons/generated_plant_icon.dart';
import '../../controller/garden_controller.dart';

class DraggableCropBlock extends StatefulWidget {
  const DraggableCropBlock({
    super.key,
    required this.bedId,
    required this.block,
    required this.pixelsPerMeter,
    required this.controller,
  });

  final String bedId;
  final CropBlock block;
  final double pixelsPerMeter;
  final GardenController controller;

  @override
  State<DraggableCropBlock> createState() => _DraggableCropBlockState();
}

class _DraggableCropBlockState extends State<DraggableCropBlock> {
  Offset dragOffsetPixels = Offset.zero;
  bool dragging = false;
  bool selected = false;
  int? activePointer;

  @override
  void didUpdateWidget(covariant DraggableCropBlock oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!dragging) {
      activePointer = null;
      dragOffsetPixels = Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _compactSinglePlantFastPath =
        widget.block.id.startsWith('single-plant-') ||
        (widget.block.width <= 0.22 && widget.block.height <= 0.22);

    if (_compactSinglePlantFastPath) {
      const markerSize = 26.0;

      final centerX =
          (widget.block.x + widget.block.width / 2) * widget.pixelsPerMeter;
      final centerY =
          (widget.block.y + widget.block.height / 2) * widget.pixelsPerMeter;

      return Positioned(
        left: centerX - markerSize / 2,
        top: centerY - markerSize / 2,
        width: markerSize,
        height: markerSize,
        child: _PrettySinglePlantMarker(cropName: widget.block.cropName),
      );
    }

    final cropName = widget.block.cropName.trim().isEmpty
        ? 'Crop'
        : widget.block.cropName.trim();

    final largeCanopy = CropSpacing.isLargeCanopyCrop(cropName);
    final spacingMeters = CropSpacing.spacingMetersForCrop(cropName);
    final compactSinglePlant =
        widget.block.id.startsWith('single-plant-') ||
        (widget.block.width <= 0.22 && widget.block.height <= 0.22);
    final estimatedCount = largeCanopy
        ? 1
        : math.max(
            1,
            CropSpacing.estimatedPlantCount(
              cropName: cropName,
              widthMeters: widget.block.width,
              heightMeters: widget.block.height,
            ),
          );

    final left = widget.block.x * widget.pixelsPerMeter + dragOffsetPixels.dx;
    final top = widget.block.y * widget.pixelsPerMeter + dragOffsetPixels.dy;

    final width = compactSinglePlant
        ? 28.0
        : math.max(26.0, widget.block.width * widget.pixelsPerMeter);
    final height = compactSinglePlant
        ? 28.0
        : math.max(26.0, widget.block.height * widget.pixelsPerMeter);

    final plantStyle = _PlantEmojiStyle.forCrop(cropName);

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              child: Tooltip(
                message:
                    '$cropName\n$estimatedCount planted\n${CropSpacing.spacingLabelForCrop(cropName)}',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  decoration: BoxDecoration(
                    color: dragging || selected
                        ? GardenTheme.good.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: dragging || selected
                          ? GardenTheme.good.withValues(alpha: 0.70)
                          : Colors.transparent,
                      width: dragging || selected ? 1.6 : 0,
                    ),
                  ),
                  child: ClipRect(
                    child: (largeCanopy || compactSinglePlant)
                        ? _SingleCanopyPlant(
                            cropName: cropName,
                            style: plantStyle,
                          )
                        : _SpacingScaledPlantField(
                            cropName: cropName,
                            style: plantStyle,
                            spacingMeters: spacingMeters,
                            pixelsPerMeter: widget.pixelsPerMeter,
                            blockWidthMeters: widget.block.width,
                            blockHeightMeters: widget.block.height,
                            estimatedCount: estimatedCount,
                          ),
                  ),
                ),
              ),
            ),
          ),
          if (estimatedCount > 1)
            Positioned(
              right: -7,
              bottom: -7,
              child: _MapCountBadge(count: estimatedCount),
            ),
          if (selected)
            Positioned(
              left: -10,
              top: -10,
              child: Builder(
                builder: (context) => _InfoButton(
                  onPressed: () => _openPlantInfo(context, cropName),
                ),
              ),
            ),
          if (selected)
            Positioned(
              right: -10,
              top: -10,
              child: _DeleteButton(
                onPressed: () {
                  widget.controller.removeCropBlock(
                    bedId: widget.bedId,
                    blockId: widget.block.id,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    activePointer = event.pointer;

    setState(() {
      selected = true;
      dragging = false;
      dragOffsetPixels = Offset.zero;
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (activePointer != event.pointer) return;

    setState(() {
      dragging = true;
      selected = true;
      dragOffsetPixels += event.delta;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (activePointer != event.pointer) return;

    if (!dragging) {
      setState(() {
        selected = !selected;
        activePointer = null;
      });
      return;
    }

    _commitMove();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (activePointer != event.pointer) return;

    setState(() {
      activePointer = null;
      dragging = false;
      dragOffsetPixels = Offset.zero;
    });
  }

  void _commitMove() {
    final nextX = widget.block.x + dragOffsetPixels.dx / widget.pixelsPerMeter;
    final nextY = widget.block.y + dragOffsetPixels.dy / widget.pixelsPerMeter;

    setState(() {
      activePointer = null;
      dragging = false;
      dragOffsetPixels = Offset.zero;
    });

    widget.controller.moveCropBlock(
      bedId: widget.bedId,
      blockId: widget.block.id,
      x: nextX,
      y: nextY,
    );
  }

  void _openPlantInfo(BuildContext context, String cropName) {
    final profile = PlantProfileData.forCrop(cropName);
    final varieties = PlantVarietyCatalog.varietiesForCrop(cropName);
    final groups = PlantVarietyCatalog.groupsForCrop(cropName);
    final spacing = CropSpacing.spacingLabelForCrop(cropName);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: AlertDialog(
            backgroundColor: const Color(0xFFFEFCF7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: GardenTheme.border),
            ),
            title: Text(cropName),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GeneratedPlantIcon(cropName: cropName, size: 118),
                    const SizedBox(height: 16),
                    _MapPlantInfoRow('Spacing', spacing),
                    _MapPlantInfoRow(
                      'Recommended layout',
                      profile.recommendedLayout,
                    ),
                    _MapPlantInfoRow('Sowing depth', profile.sowDepth),
                    _MapPlantInfoRow('Sun', profile.sun),
                    _MapPlantInfoRow('Water', profile.water),
                    _MapPlantInfoRow('Soil', profile.soil),
                    _MapPlantInfoRow('Rotation family', profile.rotationFamily),
                    _MapPlantInfoRow('Succession', profile.succession),
                    _MapPlantInfoRow('Frost / temperature', profile.frost),
                    _MapPlantInfoRow(
                      'Container suitability',
                      profile.container,
                    ),
                    _MapPlantInfoRow('Support', profile.support),
                    _MapPlantInfoRow('Planner use', profile.plannerUse),
                    if (profile.warnings.isNotEmpty)
                      _MapPlantInfoRow('Warnings', profile.warnings.join('\n')),
                    if (groups.isNotEmpty)
                      for (final group in groups) _MapPlantTypeGroupCard(group)
                    else
                      const _MapPlantInfoRow(
                        'Subtypes',
                        'No subtype group exists for this plant yet.',
                      ),
                    if (varieties.isNotEmpty)
                      _MapPlantInfoRow(
                        'Subtype count',
                        '${varieties.length} subtype${varieties.length == 1 ? '' : 's'} listed.',
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlantEmojiBubble extends StatelessWidget {
  const _PlantEmojiBubble({
    required this.cropName,
    required this.style,
    required this.bubbleSize,
    required this.showLabel,
  });

  final String cropName;
  final _PlantEmojiStyle style;
  final double bubbleSize;
  final bool showLabel;

  static const List<String> emojiFontFallback = [
    'Segoe UI Emoji',
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Twemoji Mozilla',
  ];

  @override
  Widget build(BuildContext context) {
    final iconSize = (bubbleSize * 0.58).clamp(10.0, 26.0).toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: bubbleSize,
          height: bubbleSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            shape: BoxShape.circle,
            border: Border.all(
              color: style.borderColor,
              width: style.perennial ? 2.1 : 1.35,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: GeneratedPlantIcon(cropName: cropName, size: iconSize),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 3),
          Container(
            constraints: BoxConstraints(
              maxWidth: math.max(42, bubbleSize + 18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: GardenTheme.panel.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: GardenTheme.border.withValues(alpha: 0.85),
              ),
            ),
            child: Text(
              cropName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GardenTheme.ink,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SingleCanopyPlant extends StatelessWidget {
  const _SingleCanopyPlant({required this.cropName, required this.style});

  final String cropName;
  final _PlantEmojiStyle style;

  static const List<String> emojiFontFallback = [
    'Segoe UI Emoji',
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Twemoji Mozilla',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = math.min(constraints.maxWidth, constraints.maxHeight);
        final iconSize = (diameter * 0.30).clamp(26.0, 84.0).toDouble();
        final labelWidth = math.min(140.0, math.max(82.0, diameter * 0.72));

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0).withValues(alpha: 0.62),
                shape: BoxShape.circle,
                border: Border.all(
                  color: style.borderColor.withValues(alpha: 0.24),
                  width: 1.2,
                ),
              ),
            ),
            Text(
              style.emoji,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: iconSize,
                height: 1,
                fontFamilyFallback: emojiFontFallback,
              ),
            ),
            Positioned(
              bottom: math.max(6.0, diameter * 0.10),
              child: Container(
                width: labelWidth,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: GardenTheme.panel.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: GardenTheme.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  cropName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GardenTheme.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SpacingScaledPlantField extends StatelessWidget {
  const _SpacingScaledPlantField({
    required this.cropName,
    required this.style,
    required this.spacingMeters,
    required this.pixelsPerMeter,
    required this.blockWidthMeters,
    required this.blockHeightMeters,
    required this.estimatedCount,
  });

  final String cropName;
  final _PlantEmojiStyle style;
  final double spacingMeters;
  final double pixelsPerMeter;
  final double blockWidthMeters;
  final double blockHeightMeters;
  final int estimatedCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacingPixels = math.max(12.0, spacingMeters * pixelsPerMeter);

        final isSingleRow =
            math.min(blockWidthMeters, blockHeightMeters) < spacingMeters * 1.6;

        final isHorizontal = blockWidthMeters >= blockHeightMeters;

        final bubbleSize = _bubbleSizeForSpacing(spacingPixels);
        final labelHeight = bubbleSize >= 34 ? 16.0 : 0.0;
        final itemWidth = bubbleSize + 6;
        final itemHeight = bubbleSize + labelHeight + 3;

        if (isSingleRow) {
          return _singleRowLayout(
            constraints: constraints,
            horizontal: isHorizontal,
            spacingPixels: spacingPixels,
            itemWidth: itemWidth,
            itemHeight: itemHeight,
            bubbleSize: bubbleSize,
            labelHeight: labelHeight,
          );
        }

        return _gridLayout(
          constraints: constraints,
          spacingPixels: spacingPixels,
          itemWidth: itemWidth,
          itemHeight: itemHeight,
          bubbleSize: bubbleSize,
          labelHeight: labelHeight,
        );
      },
    );
  }

  Widget _singleRowLayout({
    required BoxConstraints constraints,
    required bool horizontal,
    required double spacingPixels,
    required double itemWidth,
    required double itemHeight,
    required double bubbleSize,
    required double labelHeight,
  }) {
    final availableLength = horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    final availableCross = horizontal
        ? constraints.maxHeight
        : constraints.maxWidth;

    final maxByLength = math.max(
      1,
      (availableLength / math.max(spacingPixels, itemWidth)).floor(),
    );

    final count = math.max(1, math.min(estimatedCount, maxByLength));

    final totalLength = count == 1
        ? itemWidth
        : ((count - 1) * spacingPixels) + itemWidth;

    final start = ((availableLength - totalLength) / 2)
        .clamp(0.0, math.max(0.0, availableLength - itemWidth))
        .toDouble();

    final cross = ((availableCross - itemHeight) / 2)
        .clamp(0.0, math.max(0.0, availableCross - itemHeight))
        .toDouble();

    return Stack(
      children: [
        for (var index = 0; index < count; index++)
          Positioned(
            left: horizontal ? start + index * spacingPixels : cross,
            top: horizontal ? cross : start + index * spacingPixels,
            width: itemWidth,
            height: itemHeight,
            child: _PlantEmojiBubble(
              cropName: cropName,
              style: style,
              bubbleSize: bubbleSize,
              showLabel: labelHeight > 0,
            ),
          ),
      ],
    );
  }

  Widget _gridLayout({
    required BoxConstraints constraints,
    required double spacingPixels,
    required double itemWidth,
    required double itemHeight,
    required double bubbleSize,
    required double labelHeight,
  }) {
    final columns = math.max(
      1,
      (constraints.maxWidth / math.max(spacingPixels, itemWidth)).floor(),
    );

    final rows = math.max(
      1,
      (constraints.maxHeight / math.max(spacingPixels, itemHeight)).floor(),
    );

    final visibleCount = math.max(1, math.min(estimatedCount, columns * rows));

    final gridWidth = columns == 1
        ? itemWidth
        : (columns - 1) * spacingPixels + itemWidth;

    final gridHeight = rows == 1
        ? itemHeight
        : (rows - 1) * spacingPixels + itemHeight;

    final originX = ((constraints.maxWidth - gridWidth) / 2)
        .clamp(0.0, math.max(0.0, constraints.maxWidth - itemWidth))
        .toDouble();

    final originY = ((constraints.maxHeight - gridHeight) / 2)
        .clamp(0.0, math.max(0.0, constraints.maxHeight - itemHeight))
        .toDouble();

    return Stack(
      children: [
        for (var index = 0; index < visibleCount; index++)
          Positioned(
            left: originX + (index % columns) * spacingPixels,
            top: originY + (index ~/ columns) * spacingPixels,
            width: itemWidth,
            height: itemHeight,
            child: _PlantEmojiBubble(
              cropName: cropName,
              style: style,
              bubbleSize: bubbleSize,
              showLabel: labelHeight > 0,
            ),
          ),
      ],
    );
  }

  double _bubbleSizeForSpacing(double spacingPixels) {
    if (spacingPixels < 14) return 14;
    if (spacingPixels < 20) return 18;
    if (spacingPixels < 28) return 24;
    if (spacingPixels < 38) return 31;
    if (spacingPixels < 52) return 38;
    return 46;
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'Plant info',
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EE),
              shape: BoxShape.circle,
              border: Border.all(
                color: GardenTheme.good.withValues(alpha: 0.55),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.info_outline,
              color: GardenTheme.good,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPlantInfoRow extends StatelessWidget {
  const _MapPlantInfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
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
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: GardenTheme.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlantTypeGroupCard extends StatelessWidget {
  const _MapPlantTypeGroupCard(this.group);

  final PlantTypeGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.title.toUpperCase(),
            style: const TextStyle(
              color: GardenTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            group.summary,
            style: const TextStyle(
              color: GardenTheme.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          for (final variety in group.varieties) _MapPlantVarietyTile(variety),
        ],
      ),
    );
  }
}

class _MapPlantVarietyTile extends StatelessWidget {
  const _MapPlantVarietyTile(this.variety);

  final PlantVariety variety;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCF7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            variety.name,
            style: const TextStyle(
              color: GardenTheme.ink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (variety.alsoKnownAs.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              'Also known as: ${variety.alsoKnownAs.join(', ')}',
              style: const TextStyle(
                color: GardenTheme.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MapPlantInfoPill('${variety.spacingCm}cm spacing'),
              _MapPlantInfoPill(variety.daysToMaturity),
              _MapPlantInfoPill(variety.difficulty),
            ],
          ),
          const SizedBox(height: 8),
          Text('Use: ${variety.bestUse}', style: _mapPlantDetailBody),
          const SizedBox(height: 4),
          Text('Sow/plant: ${variety.sowingNote}', style: _mapPlantDetailBody),
          const SizedBox(height: 4),
          Text('Harvest: ${variety.harvestNote}', style: _mapPlantDetailBody),
        ],
      ),
    );
  }
}

class _MapPlantInfoPill extends StatelessWidget {
  const _MapPlantInfoPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GardenTheme.good.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GardenTheme.good.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: GardenTheme.good,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

const _mapPlantDetailBody = TextStyle(
  color: GardenTheme.ink,
  fontSize: 12,
  fontWeight: FontWeight.w700,
  height: 1.3,
);

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'Remove plant or row',
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4F2),
              shape: BoxShape.circle,
              border: Border.all(
                color: GardenTheme.bad.withValues(alpha: 0.38),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.close, color: GardenTheme.bad, size: 16),
          ),
        ),
      ),
    );
  }
}

class _MapCountBadge extends StatelessWidget {
  const _MapCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: GardenTheme.panel.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GardenTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'x$count',
        style: const TextStyle(
          color: GardenTheme.muted,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PlantEmojiStyle {
  const _PlantEmojiStyle({
    required this.emoji,
    required this.borderColor,
    required this.perennial,
  });

  final String emoji;
  final Color borderColor;
  final bool perennial;

  static _PlantEmojiStyle forCrop(String cropName) {
    final crop = cropName.trim().toLowerCase();

    if (_containsAny(crop, [
      'almond',
      'apple',
      'apricot',
      'pear',
      'plum',
      'peach',
      'citrus',
    ])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¦Ã¢â‚¬â„¢Ãƒâ€šÃ‚Â³',
        borderColor: GardenTheme.good,
        perennial: true,
      );
    }

    if (_containsAny(crop, ['strawberry'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚ÂÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ',
        borderColor: GardenTheme.good,
        perennial: true,
      );
    }

    if (_containsAny(crop, ['raspberry', 'blackberry'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚ÂÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡',
        borderColor: GardenTheme.good,
        perennial: true,
      );
    }

    if (_containsAny(crop, ['blueberry'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â«Ãƒâ€šÃ‚Â',
        borderColor: GardenTheme.good,
        perennial: true,
      );
    }

    if (_containsAny(crop, ['broccoli'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â¥Ãƒâ€šÃ‚Â¦',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    if (_containsAny(crop, [
      'basil',
      'agastache',
      'herb',
      'mint',
      'parsley',
      'thyme',
    ])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¦Ã¢â‚¬â„¢Ãƒâ€šÃ‚Â¿',
        borderColor: GardenTheme.good,
        perennial: true,
      );
    }

    if (_containsAny(crop, ['ageratum'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â£',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    if (_containsAny(crop, ['allium'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¦Ã¢â‚¬â„¢Ãƒâ€šÃ‚Âº',
        borderColor: GardenTheme.good,
        perennial: true,
      );
    }

    if (_containsAny(crop, ['alyssum'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¦Ã¢â‚¬â„¢Ãƒâ€šÃ‚Â¼',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    if (_containsAny(crop, ['tomato'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚ÂÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    if (_containsAny(crop, ['carrot'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â¥ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    if (_containsAny(crop, ['lettuce', 'spinach', 'kale', 'cabbage'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â¥Ãƒâ€šÃ‚Â¬',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    if (_containsAny(crop, ['onion'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â§ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    if (_containsAny(crop, ['garlic'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â§ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    if (_containsAny(crop, ['potato'])) {
      return const _PlantEmojiStyle(
        emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â¥ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â',
        borderColor: GardenTheme.border,
        perennial: false,
      );
    }

    return const _PlantEmojiStyle(
      emoji: 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¦Ã¢â‚¬â„¢Ãƒâ€šÃ‚Â±',
      borderColor: GardenTheme.border,
      perennial: false,
    );
  }

  static bool _containsAny(String value, List<String> needles) {
    for (final needle in needles) {
      if (value.contains(needle)) return true;
    }

    return false;
  }
}

class _PrettySinglePlantMarker extends StatelessWidget {
  const _PrettySinglePlantMarker({required this.cropName});

  final String cropName;

  @override
  Widget build(BuildContext context) {
    final emoji = _plantBadgeEmoji(cropName);
    final palette = _plantBadgePalette(cropName);

    return Tooltip(
      message: cropName,
      waitDuration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8D8BE), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.light, palette.dark],
            ),
          ),
          alignment: Alignment.center,
          child: GeneratedPlantIcon(cropName: cropName, size: 17),
        ),
      ),
    );
  }
}

class _PlantBadgePalette {
  const _PlantBadgePalette({required this.light, required this.dark});

  final Color light;
  final Color dark;
}

_PlantBadgePalette _plantBadgePalette(String cropName) {
  final name = cropName.toLowerCase();

  if (name.contains('chilli') ||
      name.contains('chili') ||
      name.contains('pepper') ||
      name.contains('tomato') ||
      name.contains('eggplant')) {
    return const _PlantBadgePalette(
      light: Color(0xFFFFF2EA),
      dark: Color(0xFFFFD3C2),
    );
  }

  if (name.contains('strawberry') ||
      name.contains('raspberry') ||
      name.contains('blueberry') ||
      name.contains('berry')) {
    return const _PlantBadgePalette(
      light: Color(0xFFFFF3F6),
      dark: Color(0xFFFFD4DE),
    );
  }

  if (name.contains('carrot') ||
      name.contains('beet') ||
      name.contains('radish') ||
      name.contains('turnip') ||
      name.contains('parsnip') ||
      name.contains('swede') ||
      name.contains('rutabaga')) {
    return const _PlantBadgePalette(
      light: Color(0xFFFFF7DF),
      dark: Color(0xFFFFD889),
    );
  }

  if (name.contains('garlic') ||
      name.contains('onion') ||
      name.contains('leek') ||
      name.contains('shallot') ||
      name.contains('allium')) {
    return const _PlantBadgePalette(
      light: Color(0xFFF7F0FF),
      dark: Color(0xFFE4D6FF),
    );
  }

  if (name.contains('corn') || name.contains('maize')) {
    return const _PlantBadgePalette(
      light: Color(0xFFFFF9DA),
      dark: Color(0xFFFFEA91),
    );
  }

  return const _PlantBadgePalette(
    light: Color(0xFFEAF8EE),
    dark: Color(0xFFCDEFD9),
  );
}

String _plantBadgeEmoji(String cropName) {
  final name = cropName.toLowerCase();

  if (name.contains('chilli') || name.contains('chili')) return '🌶️';
  if (name.contains('pepper')) return '🫑';
  if (name.contains('tomato')) return '🍅';
  if (name.contains('eggplant')) return '🍆';

  if (name.contains('strawberry')) return '🍓';
  if (name.contains('raspberry') ||
      name.contains('blueberry') ||
      name.contains('berry')) {
    return '🫐';
  }

  if (name.contains('carrot')) return '🥕';
  if (name.contains('potato') ||
      name.contains('kumara') ||
      name.contains('sweet potato') ||
      name.contains('yacon')) {
    return '🥔';
  }

  if (name.contains('garlic')) return '🧄';
  if (name.contains('onion') ||
      name.contains('leek') ||
      name.contains('shallot')) {
    return '🧅';
  }

  if (name.contains('broccoli') ||
      name.contains('brassica') ||
      name.contains('brussels')) {
    return '🥦';
  }

  if (name.contains('lettuce') ||
      name.contains('spinach') ||
      name.contains('chicory') ||
      name.contains('cabbage') ||
      name.contains('kale') ||
      name.contains('silverbeet') ||
      name.contains('chard')) {
    return '🥬';
  }

  if (name.contains('corn') || name.contains('maize')) return '🌽';
  if (name.contains('cucumber') ||
      name.contains('courgette') ||
      name.contains('zucchini')) {
    return '🥒';
  }

  if (name.contains('pumpkin') || name.contains('squash')) return '🎃';
  if (name.contains('melon') || name.contains('watermelon')) return '🍉';

  if (name.contains('basil') ||
      name.contains('mint') ||
      name.contains('parsley') ||
      name.contains('coriander') ||
      name.contains('cilantro') ||
      name.contains('thyme') ||
      name.contains('sage') ||
      name.contains('oregano') ||
      name.contains('rosemary') ||
      name.contains('agastache')) {
    return '🌿';
  }

  if (name.contains('pea') ||
      name.contains('bean') ||
      name.contains('legume')) {
    return '🌱';
  }

  if (name.contains('flower') ||
      name.contains('marigold') ||
      name.contains('calendula')) {
    return '🌼';
  }

  return '🌱';
}
