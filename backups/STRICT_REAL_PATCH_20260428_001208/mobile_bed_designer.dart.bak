import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:garden_planner/core/models/bed.dart';
import 'package:garden_planner/core/models/crop_placement.dart';
import 'package:garden_planner/core/models/crop_spacing.dart';
import 'package:garden_planner/core/plant_icons/generated_plant_icon.dart';
import 'package:garden_planner/features/planner/controller/garden_controller.dart';

enum MobileBedTool { plant, move, erase, size, info }

double _mobileRecommendedSpacingMetersForCrop(String cropName) {
  final crop = cropName.toLowerCase();
  final baseSpacing = CropSpacing.spacingMetersForCrop(cropName);

  bool hasAny(List<String> words) => words.any(crop.contains);

  var minimumSpacing = 0.08;

  if (hasAny([
    'acorn squash',
    'butternut',
    'pumpkin',
    'squash',
    'zucchini',
    'courgette',
    'melon',
    'watermelon',
  ])) {
    minimumSpacing = 1.20;
  } else if (hasAny(['cucumber'])) {
    minimumSpacing = 0.70;
  } else if (hasAny([
    'apple',
    'pear',
    'peach',
    'plum',
    'cherry',
    'citrus',
    'lemon',
    'orange',
    'lime',
    'avocado',
    'olive',
    'fig',
    'mango',
    'almond',
    'walnut',
    'hazelnut',
    'tree',
  ])) {
    minimumSpacing = 2.50;
  } else if (hasAny([
    'raspberry',
    'blueberry',
    'blackberry',
    'currant',
    'gooseberry',
    'elderberry',
    'boysenberry',
    'bush',
    'shrub',
  ])) {
    minimumSpacing = 0.90;
  } else if (hasAny([
    'tomato',
    'eggplant',
    'aubergine',
    'pepper',
    'capsicum',
  ])) {
    minimumSpacing = 0.65;
  } else if (hasAny(['corn', 'maize', 'sunflower'])) {
    minimumSpacing = 0.35;
  } else if (hasAny([
    'broccoli',
    'broccolini',
    'cauliflower',
    'cabbage',
    'brussels',
    'brussel',
    'kale',
    'collard',
  ])) {
    minimumSpacing = 0.45;
  } else if (hasAny([
    'lettuce',
    'spinach',
    'chard',
    'silverbeet',
    'bok',
    'pak',
    'celery',
  ])) {
    minimumSpacing = 0.25;
  } else if (hasAny([
    'carrot',
    'radish',
    'beet',
    'beetroot',
    'onion',
    'garlic',
    'shallot',
    'leek',
  ])) {
    minimumSpacing = 0.08;
  } else if (hasAny([
    'basil',
    'parsley',
    'cilantro',
    'coriander',
    'dill',
    'mint',
    'thyme',
    'oregano',
    'sage',
    'chives',
  ])) {
    minimumSpacing = 0.18;
  }

  return math.max(baseSpacing, minimumSpacing).clamp(0.04, 6.0).toDouble();
}

class MobileBedDesigner extends StatefulWidget {
  const MobileBedDesigner({
    super.key,
    required this.controller,
    required this.selectedPlantName,
    required this.onPickPlant,
    required this.onSave,
  });

  final GardenController controller;
  final String? selectedPlantName;
  final VoidCallback onPickPlant;
  final VoidCallback onSave;

  @override
  State<MobileBedDesigner> createState() => _MobileBedDesignerState();
}

class _MobileBedDesignerState extends State<MobileBedDesigner> {
  MobileBedTool tool = MobileBedTool.plant;

  final List<Bed> undoStack = [];
  final Set<String> autoCleanedBedIds = <String>{};
  final Set<String> strokeSlotKeys = <String>{};

  String? movingPlacementId;
  Offset? lastPaintPoint;
  DateTime? lastPaintAt;
  _PlantPreview? preview;

  bool showShade = true;
  bool showNames = false;

  GardenController get controller => widget.controller;

  Bed? get activeBed {
    if (controller.selectedBed != null) return controller.selectedBed;
    if (controller.beds.isEmpty) return null;
    return controller.beds.first;
  }

  String get activePlant => widget.selectedPlantName?.trim() ?? '';

  bool get hasPlant => activePlant.isNotEmpty;

  String _bedTitle(Bed bed) {
    return bed.name.trim().isEmpty ? 'Bed ${bed.number}' : bed.name.trim();
  }

  void _selectBed(Bed bed) {
    controller.selectBed(bed.id);

    setState(() {
      movingPlacementId = null;
      lastPaintPoint = null;
      lastPaintAt = null;
      preview = null;
      strokeSlotKeys.clear();
    });
  }

  void _pushUndo(Bed bed) {
    undoStack.add(bed);

    if (undoStack.length > 35) {
      undoStack.removeAt(0);
    }
  }

  void _undo() {
    if (undoStack.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to undo.'),
          duration: Duration(milliseconds: 900),
        ),
      );
      return;
    }

    final previousBed = undoStack.removeLast();
    _replaceBed(previousBed, trackUndo: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Undo complete.'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _replaceBed(Bed updatedBed, {bool trackUndo = true}) {
    final index = controller.beds.indexWhere((bed) => bed.id == updatedBed.id);
    if (index == -1) return;

    final currentBed = controller.beds[index];

    if (trackUndo) {
      _pushUndo(currentBed);
    }

    final updatedBeds = [...controller.beds];
    updatedBeds[index] = updatedBed;

    controller.project = controller.project.copyWith(beds: updatedBeds);

    controller.selectBed(updatedBed.id);

    setState(() {});
  }

  void _setTool(MobileBedTool nextTool) {
    if (nextTool == MobileBedTool.size) {
      final bed = activeBed;
      if (bed != null) _openSizeSheet(bed);
      return;
    }

    if (nextTool == MobileBedTool.info) {
      final bed = activeBed;
      if (bed != null) _openBedInfoSheet(bed);
      return;
    }

    setState(() {
      tool = nextTool;
      movingPlacementId = null;
      lastPaintPoint = null;
      lastPaintAt = null;
      preview = null;
      strokeSlotKeys.clear();
    });
  }

  void _openSizeSheet(Bed bed) {
    double width = bed.width.clamp(0.5, 20.0).toDouble();
    double height = bed.height.clamp(0.5, 20.0).toDouble();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF4),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void applyPreset(double w, double h) {
              setSheetState(() {
                width = w;
                height = h;
              });
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.78,
              minChildSize: 0.42,
              maxChildSize: 0.96,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  children: [
                    Text(
                      'Bed size',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(_bedTitle(bed)),
                    const SizedBox(height: 16),
                    _SizePreview(width: width, height: height),
                    const SizedBox(height: 16),
                    const Text(
                      'Presets',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('1.2 × 1.2m'),
                          onPressed: () => applyPreset(1.2, 1.2),
                        ),
                        ActionChip(
                          label: const Text('2 × 1m'),
                          onPressed: () => applyPreset(2.0, 1.0),
                        ),
                        ActionChip(
                          label: const Text('3 × 1m'),
                          onPressed: () => applyPreset(3.0, 1.0),
                        ),
                        ActionChip(
                          label: const Text('4 × 1.2m'),
                          onPressed: () => applyPreset(4.0, 1.2),
                        ),
                        ActionChip(
                          label: const Text('6 × 1.5m'),
                          onPressed: () => applyPreset(6.0, 1.5),
                        ),
                        ActionChip(
                          label: const Text('4 × 4m'),
                          onPressed: () => applyPreset(4.0, 4.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Width: ${width.toStringAsFixed(1)}m',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Slider(
                      value: width,
                      min: 0.5,
                      max: 12,
                      divisions: 115,
                      label: '${width.toStringAsFixed(1)}m',
                      onChanged: (value) {
                        setSheetState(() {
                          width = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Height: ${height.toStringAsFixed(1)}m',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Slider(
                      value: height,
                      min: 0.5,
                      max: 8,
                      divisions: 75,
                      label: '${height.toStringAsFixed(1)}m',
                      onChanged: (value) {
                        setSheetState(() {
                          height = value;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();

                        _replaceBed(bed.copyWith(width: width, height: height));
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Apply size'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _openBedInfoSheet(Bed bed) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF4),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.35,
          maxChildSize: 0.96,
          builder: (context, scrollController) {
            final markerCount =
                bed.cropPlacements.length + bed.cropBlocks.length;

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                Text(
                  _bedTitle(bed),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoTile(
                  icon: Icons.straighten,
                  title: 'Size',
                  value:
                      '${bed.width.toStringAsFixed(1)}m × ${bed.height.toStringAsFixed(1)}m',
                ),
                _InfoTile(
                  icon: Icons.eco_outlined,
                  title: 'Crops',
                  value: bed.crops.isEmpty
                      ? 'No crops yet'
                      : bed.crops.join(', '),
                ),
                _InfoTile(
                  icon: Icons.local_florist_outlined,
                  title: 'Plant icons',
                  value: '$markerCount',
                ),
                _InfoTile(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Health',
                  value: '${(bed.healthPercent * 100).round()}%',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openSizeSheet(bed);
                  },
                  icon: const Icon(Icons.straighten),
                  label: const Text('Change bed size'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handlePointerDown(Offset localPosition, Size canvasSize) {
    FocusManager.instance.primaryFocus?.unfocus();

    final bed = activeBed;
    if (bed == null) return;

    strokeSlotKeys.clear();

    switch (tool) {
      case MobileBedTool.plant:
        _paintPlant(
          bed: bed,
          localPosition: localPosition,
          canvasSize: canvasSize,
          force: true,
        );
        break;
      case MobileBedTool.erase:
        _eraseNearest(
          bed: bed,
          localPosition: localPosition,
          canvasSize: canvasSize,
        );
        break;
      case MobileBedTool.move:
        movingPlacementId = _nearestPlacementId(
          bed: bed,
          localPosition: localPosition,
          canvasSize: canvasSize,
        );

        if (movingPlacementId != null) {
          _pushUndo(bed);

          _movePlacement(
            bed: bed,
            placementId: movingPlacementId!,
            localPosition: localPosition,
            canvasSize: canvasSize,
            trackUndo: false,
          );
        }
        break;
      case MobileBedTool.size:
      case MobileBedTool.info:
        break;
    }
  }

  void _handlePointerMove(Offset localPosition, Size canvasSize) {
    final bed = activeBed;
    if (bed == null) return;

    switch (tool) {
      case MobileBedTool.plant:
        _paintPlant(
          bed: bed,
          localPosition: localPosition,
          canvasSize: canvasSize,
          force: false,
        );
        break;
      case MobileBedTool.erase:
        _eraseNearest(
          bed: bed,
          localPosition: localPosition,
          canvasSize: canvasSize,
        );
        break;
      case MobileBedTool.move:
        final id = movingPlacementId;

        if (id != null) {
          _movePlacement(
            bed: bed,
            placementId: id,
            localPosition: localPosition,
            canvasSize: canvasSize,
            trackUndo: false,
          );
        }
        break;
      case MobileBedTool.size:
      case MobileBedTool.info:
        break;
    }
  }

  void _handlePointerEnd() {
    setState(() {
      movingPlacementId = null;
      lastPaintPoint = null;
      lastPaintAt = null;
      preview = null;
      strokeSlotKeys.clear();
    });
  }

  void _paintPlant({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
    required bool force,
  }) {
    if (!hasPlant) {
      widget.onPickPlant();
      return;
    }

    final currentBed = activeBed ?? bed;
    final cropName = activePlant;
    final spacing = _spacingFor(cropName, currentBed);
    final spacingPixels = spacing * _pixelsPerMeter(currentBed, canvasSize);

    final slot = _nearestOpenPlantingSlot(
      bed: currentBed,
      cropName: cropName,
      localPosition: localPosition,
      canvasSize: canvasSize,
      spacingMeters: spacing,
    );

    if (slot == null) {
      setState(() {
        preview = null;
      });
      return;
    }

    final slotKey = _slotKey(
      bedId: currentBed.id,
      cropName: cropName,
      x: slot.dx,
      y: slot.dy,
      spacingMeters: spacing,
    );

    if (strokeSlotKeys.contains(slotKey)) {
      return;
    }

    final snappedPoint = _metersToLocal(
      bed: currentBed,
      x: slot.dx,
      y: slot.dy,
      canvasSize: canvasSize,
    );

    final now = DateTime.now();

    if (!force) {
      final lastAt = lastPaintAt;
      final lastPoint = lastPaintPoint;
      final minPixelMove = math.max(22.0, spacingPixels * 0.95);

      if (lastAt != null &&
          now.difference(lastAt).inMilliseconds < 130 &&
          lastPoint != null &&
          (snappedPoint - lastPoint).distance < minPixelMove) {
        return;
      }
    }

    setState(() {
      preview = _PlantPreview(
        cropName: cropName,
        x: slot.dx,
        y: slot.dy,
        spacingMeters: spacing,
        valid: true,
      );
    });

    final existingCropsLower = currentBed.crops.map((crop) {
      return crop.trim().toLowerCase();
    }).toSet();

    final updatedCrops = existingCropsLower.contains(cropName.toLowerCase())
        ? currentBed.crops
        : [...currentBed.crops, cropName];

    final updatedPlacements = [
      ...currentBed.cropPlacements,
      CropPlacement(
        id: 'mobile-${DateTime.now().microsecondsSinceEpoch}',
        cropName: cropName,
        x: slot.dx,
        y: slot.dy,
      ),
    ];

    strokeSlotKeys.add(slotKey);

    _replaceBed(
      currentBed.copyWith(
        crops: updatedCrops,
        cropPlacements: updatedPlacements,
      ),
    );

    lastPaintAt = now;
    lastPaintPoint = snappedPoint;
  }

  void _eraseNearest({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
  }) {
    final nearest = _nearestAnyMarker(
      bed: bed,
      localPosition: localPosition,
      canvasSize: canvasSize,
      thresholdPixels: 38,
    );

    if (nearest == null) return;

    final updatedPlacements = [...bed.cropPlacements];
    final updatedBlocks = [...bed.cropBlocks];

    if (nearest.isPlacement) {
      updatedPlacements.removeWhere((placement) => placement.id == nearest.id);
    } else {
      updatedBlocks.removeWhere((block) => block.id == nearest.id);
    }

    _replaceBed(
      bed.copyWith(
        cropPlacements: updatedPlacements,
        cropBlocks: updatedBlocks,
      ),
    );
  }

  void _movePlacement({
    required Bed bed,
    required String placementId,
    required Offset localPosition,
    required Size canvasSize,
    required bool trackUndo,
  }) {
    final currentBed = activeBed ?? bed;
    final index = currentBed.cropPlacements.indexWhere(
      (item) => item.id == placementId,
    );

    if (index == -1) return;

    final placement = currentBed.cropPlacements[index];
    final spacing = _spacingFor(placement.cropName, currentBed);

    final slot = _nearestOpenPlantingSlot(
      bed: currentBed,
      cropName: placement.cropName,
      localPosition: localPosition,
      canvasSize: canvasSize,
      spacingMeters: spacing,
      ignorePlacementId: placementId,
    );

    if (slot == null) return;

    final updatedPlacements = [...currentBed.cropPlacements];
    updatedPlacements[index] = CropPlacement(
      id: placement.id,
      cropName: placement.cropName,
      x: slot.dx,
      y: slot.dy,
    );

    _replaceBed(
      currentBed.copyWith(cropPlacements: updatedPlacements),
      trackUndo: trackUndo,
    );
  }

  String? _nearestPlacementId({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
  }) {
    double bestDistance = double.infinity;
    String? bestId;

    for (final placement in bed.cropPlacements) {
      final point = _metersToLocal(
        bed: bed,
        x: placement.x,
        y: placement.y,
        canvasSize: canvasSize,
      );

      final distance = (point - localPosition).distance;

      if (distance < bestDistance) {
        bestDistance = distance;
        bestId = placement.id;
      }
    }

    return bestDistance <= 46 ? bestId : null;
  }

  _MarkerHit? _nearestAnyMarker({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
    required double thresholdPixels,
  }) {
    double bestDistance = double.infinity;
    _MarkerHit? best;

    for (final placement in bed.cropPlacements) {
      final point = _metersToLocal(
        bed: bed,
        x: placement.x,
        y: placement.y,
        canvasSize: canvasSize,
      );

      final distance = (point - localPosition).distance;

      if (distance < bestDistance) {
        bestDistance = distance;
        best = _MarkerHit(id: placement.id, isPlacement: true);
      }
    }

    for (final block in bed.cropBlocks) {
      final point = _metersToLocal(
        bed: bed,
        x: block.x,
        y: block.y,
        canvasSize: canvasSize,
      );

      final distance = (point - localPosition).distance;

      if (distance < bestDistance) {
        bestDistance = distance;
        best = _MarkerHit(id: block.id, isPlacement: false);
      }
    }

    if (bestDistance <= thresholdPixels) return best;

    return null;
  }

  Offset? _nearestOpenPlantingSlot({
    required Bed bed,
    required String cropName,
    required Offset localPosition,
    required Size canvasSize,
    required double spacingMeters,
    String? ignorePlacementId,
  }) {
    final bedWidth = math.max(0.1, bed.width);
    final bedHeight = math.max(0.1, bed.height);
    final radius = spacingMeters / 2;

    if (bedWidth < spacingMeters || bedHeight < spacingMeters) {
      return null;
    }

    final targetMeters = _localToMeters(
      bed: bed,
      localPosition: localPosition,
      canvasSize: canvasSize,
      spacing: spacingMeters,
      snap: false,
    );

    final candidates = <Offset>[];

    for (
      double y = radius;
      y <= bedHeight - radius + 0.0001;
      y += spacingMeters
    ) {
      for (
        double x = radius;
        x <= bedWidth - radius + 0.0001;
        x += spacingMeters
      ) {
        candidates.add(Offset(x, y));
      }
    }

    candidates.sort((a, b) {
      final adx = a.dx - targetMeters.dx;
      final ady = a.dy - targetMeters.dy;
      final bdx = b.dx - targetMeters.dx;
      final bdy = b.dy - targetMeters.dy;

      final ad = adx * adx + ady * ady;
      final bd = bdx * bdx + bdy * bdy;

      return ad.compareTo(bd);
    });

    final pickToleranceMeters = spacingMeters * 0.50;

    for (final candidate in candidates) {
      final dx = candidate.dx - targetMeters.dx;
      final dy = candidate.dy - targetMeters.dy;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance > pickToleranceMeters) {
        continue;
      }

      final blocked = _isBlockedByAnyPlant(
        bed: bed,
        cropName: cropName,
        x: candidate.dx,
        y: candidate.dy,
        spacingMeters: spacingMeters,
        ignorePlacementId: ignorePlacementId,
      );

      if (!blocked) {
        return candidate;
      }
    }

    return null;
  }

  bool _isBlockedByAnyPlant({
    required Bed bed,
    required String cropName,
    required double x,
    required double y,
    required double spacingMeters,
    String? ignorePlacementId,
    String? ignoreBlockId,
  }) {
    final newRadius = spacingMeters / 2;

    for (final placement in bed.cropPlacements) {
      if (ignorePlacementId != null && placement.id == ignorePlacementId) {
        continue;
      }

      final existingSpacing = _spacingFor(placement.cropName, bed);
      final existingRadius = existingSpacing / 2;

      final requiredDistance = (newRadius + existingRadius) * 0.98;

      final dx = placement.x - x;
      final dy = placement.y - y;
      final actualDistance = math.sqrt(dx * dx + dy * dy);

      if (actualDistance < requiredDistance) {
        return true;
      }
    }

    for (final block in bed.cropBlocks) {
      if (ignoreBlockId != null && block.id == ignoreBlockId) {
        continue;
      }

      final existingSpacing = _spacingFor(block.cropName, bed);
      final existingRadius = existingSpacing / 2;

      final requiredDistance = (newRadius + existingRadius) * 0.98;

      final dx = block.x - x;
      final dy = block.y - y;
      final actualDistance = math.sqrt(dx * dx + dy * dy);

      if (actualDistance < requiredDistance) {
        return true;
      }
    }

    return false;
  }

  String _slotKey({
    required String bedId,
    required String cropName,
    required double x,
    required double y,
    required double spacingMeters,
  }) {
    final sx = (x / spacingMeters).round();
    final sy = (y / spacingMeters).round();

    return '$bedId:${cropName.toLowerCase()}:$sx:$sy';
  }

  double _spacingFor(String cropName, Bed bed) {
    final bedLimit = math.max(0.08, math.min(bed.width, bed.height));

    return _mobileRecommendedSpacingMetersForCrop(
      cropName,
    ).clamp(0.08, bedLimit).toDouble();
  }

  double _pixelsPerMeter(Bed bed, Size canvasSize) {
    return math.min(
      canvasSize.width / math.max(0.1, bed.width),
      canvasSize.height / math.max(0.1, bed.height),
    );
  }

  Offset _localToMeters({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
    required double spacing,
    required bool snap,
  }) {
    final bedWidth = math.max(0.1, bed.width);
    final bedHeight = math.max(0.1, bed.height);
    final radius = spacing / 2;

    var x = (localPosition.dx / canvasSize.width * bedWidth)
        .clamp(radius, math.max(radius, bedWidth - radius))
        .toDouble();

    var y = (localPosition.dy / canvasSize.height * bedHeight)
        .clamp(radius, math.max(radius, bedHeight - radius))
        .toDouble();

    if (snap) {
      x = (((x - radius) / spacing).round() * spacing + radius)
          .clamp(radius, math.max(radius, bedWidth - radius))
          .toDouble();

      y = (((y - radius) / spacing).round() * spacing + radius)
          .clamp(radius, math.max(radius, bedHeight - radius))
          .toDouble();
    }

    return Offset(x, y);
  }

  Offset _metersToLocal({
    required Bed bed,
    required double x,
    required double y,
    required Size canvasSize,
  }) {
    final bedWidth = math.max(0.1, bed.width);
    final bedHeight = math.max(0.1, bed.height);

    return Offset(
      (x / bedWidth).clamp(0.0, 1.0) * canvasSize.width,
      (y / bedHeight).clamp(0.0, 1.0) * canvasSize.height,
    );
  }

  Bed _sanitizeBedSpacing(Bed bed) {
    final source = <CropPlacement>[
      ...bed.cropPlacements,
      for (final block in bed.cropBlocks)
        CropPlacement(
          id: 'converted-${block.id}',
          cropName: block.cropName,
          x: block.x,
          y: block.y,
        ),
    ];

    final kept = <CropPlacement>[];

    for (final placement in source) {
      final spacing = _spacingFor(placement.cropName, bed);

      final blocked = _isBlockedByList(
        existing: kept,
        bed: bed,
        cropName: placement.cropName,
        x: placement.x,
        y: placement.y,
        spacingMeters: spacing,
      );

      if (!blocked) {
        kept.add(placement);
      }
    }

    final seenCrops = <String>{};
    final cleanedCrops = <String>[];

    for (final placement in kept) {
      final key = placement.cropName.trim().toLowerCase();

      if (key.isEmpty || seenCrops.contains(key)) continue;

      seenCrops.add(key);
      cleanedCrops.add(placement.cropName);
    }

    return bed.copyWith(
      crops: cleanedCrops,
      cropPlacements: kept,
      cropBlocks: const [],
    );
  }

  bool _isBlockedByList({
    required List<CropPlacement> existing,
    required Bed bed,
    required String cropName,
    required double x,
    required double y,
    required double spacingMeters,
  }) {
    final newRadius = spacingMeters / 2;

    for (final placement in existing) {
      final existingSpacing = _spacingFor(placement.cropName, bed);
      final existingRadius = existingSpacing / 2;
      final requiredDistance = (newRadius + existingRadius) * 0.98;

      final dx = placement.x - x;
      final dy = placement.y - y;
      final actualDistance = math.sqrt(dx * dx + dy * dy);

      if (actualDistance < requiredDistance) return true;
    }

    return false;
  }

  void _cleanActiveBedSpacing() {
    final bed = activeBed;
    if (bed == null) return;

    final cleaned = _sanitizeBedSpacing(bed);

    _replaceBed(cleaned);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cleaned spacing: ${cleaned.cropPlacements.length} plants kept.',
        ),
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  void _clearActiveBed() {
    final bed = activeBed;
    if (bed == null) return;

    _replaceBed(
      bed.copyWith(
        crops: const [],
        cropPlacements: const [],
        cropBlocks: const [],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cleared this bed.'),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bed = activeBed;

    if (controller.beds.isEmpty || bed == null) {
      return const Center(child: Text('No beds available.'));
    }

    if (!autoCleanedBedIds.contains(bed.id)) {
      autoCleanedBedIds.add(bed.id);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final currentBed = activeBed;
        if (currentBed == null || currentBed.id != bed.id) return;

        final cleaned = _sanitizeBedSpacing(currentBed);

        if (cleaned.cropPlacements.length != currentBed.cropPlacements.length ||
            cleaned.cropBlocks.length != currentBed.cropBlocks.length) {
          _replaceBed(cleaned, trackUndo: false);
        }
      });
    }

    return Column(
      children: [
        _BedSelector(
          beds: controller.beds,
          selectedBedId: bed.id,
          titleForBed: _bedTitle,
          onSelectBed: _selectBed,
        ),
        _DesignerHeader(
          bed: bed,
          bedName: _bedTitle(bed),
          activePlantName: widget.selectedPlantName,
          tool: tool,
          onPickPlant: widget.onPickPlant,
          onSize: () => _openSizeSheet(bed),
          onSave: widget.onSave,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: _DesignerCanvas(
              bed: bed,
              activePlantName: widget.selectedPlantName,
              tool: tool,
              preview: preview,
              showShade: showShade,
              showNames: showNames,
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerEnd: _handlePointerEnd,
            ),
          ),
        ),
        _ToolBar(
          bed: bed,
          tool: tool,
          hasPlant: hasPlant,
          activePlantName: widget.selectedPlantName,
          showShade: showShade,
          showNames: showNames,
          canUndo: undoStack.isNotEmpty,
          onSelectTool: _setTool,
          onPickPlant: widget.onPickPlant,
          onUndo: _undo,
          onCleanSpacing: _cleanActiveBedSpacing,
          onClearBed: _clearActiveBed,
          onShadeChanged: (value) {
            setState(() {
              showShade = value;
            });
          },
          onNamesChanged: (value) {
            setState(() {
              showNames = value;
            });
          },
        ),
      ],
    );
  }
}

class _MarkerHit {
  const _MarkerHit({required this.id, required this.isPlacement});

  final String id;
  final bool isPlacement;
}

class _PlantPreview {
  const _PlantPreview({
    required this.cropName,
    required this.x,
    required this.y,
    required this.spacingMeters,
    required this.valid,
  });

  final String cropName;
  final double x;
  final double y;
  final double spacingMeters;
  final bool valid;
}

class _BedSelector extends StatelessWidget {
  const _BedSelector({
    required this.beds,
    required this.selectedBedId,
    required this.titleForBed,
    required this.onSelectBed,
  });

  final List<Bed> beds;
  final String selectedBedId;
  final String Function(Bed bed) titleForBed;
  final ValueChanged<Bed> onSelectBed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        itemCount: beds.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bed = beds[index];
          final selected = bed.id == selectedBedId;

          return ChoiceChip(
            selected: selected,
            label: Text(titleForBed(bed)),
            avatar: selected
                ? const Icon(Icons.check_circle, size: 18)
                : const Icon(Icons.view_week_outlined, size: 18),
            onSelected: (_) => onSelectBed(bed),
          );
        },
      ),
    );
  }
}

class _DesignerHeader extends StatelessWidget {
  const _DesignerHeader({
    required this.bed,
    required this.bedName,
    required this.activePlantName,
    required this.tool,
    required this.onPickPlant,
    required this.onSize,
    required this.onSave,
  });

  final Bed bed;
  final String bedName;
  final String? activePlantName;
  final MobileBedTool tool;
  final VoidCallback onPickPlant;
  final VoidCallback onSize;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final plant = activePlantName?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.yard_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bedName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${bed.width.toStringAsFixed(1)}m × ${bed.height.toStringAsFixed(1)}m'
                      ' • ${plant == null || plant.isEmpty ? 'No plant selected' : plant}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton.outlined(
                onPressed: onPickPlant,
                icon: const Icon(Icons.eco_outlined),
                tooltip: 'Pick plant',
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                onPressed: onSize,
                icon: const Icon(Icons.straighten),
                tooltip: 'Bed size',
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesignerCanvas extends StatelessWidget {
  const _DesignerCanvas({
    required this.bed,
    required this.activePlantName,
    required this.tool,
    required this.preview,
    required this.showShade,
    required this.showNames,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerEnd,
  });

  final Bed bed;
  final String? activePlantName;
  final MobileBedTool tool;
  final _PlantPreview? preview;
  final bool showShade;
  final bool showNames;
  final void Function(Offset localPosition, Size canvasSize) onPointerDown;
  final void Function(Offset localPosition, Size canvasSize) onPointerMove;
  final VoidCallback onPointerEnd;

  @override
  Widget build(BuildContext context) {
    final aspect = bed.width <= 0 || bed.height <= 0
        ? 1.2
        : (bed.width / bed.height).clamp(0.45, 2.4);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        var canvasWidth = maxWidth;
        var canvasHeight = canvasWidth / aspect;

        if (canvasHeight > maxHeight) {
          canvasHeight = maxHeight;
          canvasWidth = canvasHeight * aspect;
        }

        final canvasSize = Size(canvasWidth, canvasHeight);

        return Center(
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
                onPointerDown(event.localPosition, canvasSize);
              },
              onPointerMove: (event) {
                onPointerMove(event.localPosition, canvasSize);
              },
              onPointerUp: (_) => onPointerEnd(),
              onPointerCancel: (_) => onPointerEnd(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: RepaintBoundary(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _BedPainter(
                            bedWidth: bed.width,
                            bedHeight: bed.height,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: _MarkerLayer(
                          bed: bed,
                          canvasSize: canvasSize,
                          showShade: showShade,
                          showNames: showNames,
                        ),
                      ),
                      if (preview != null)
                        Positioned.fill(
                          child: _PreviewLayer(
                            bed: bed,
                            canvasSize: canvasSize,
                            preview: preview!,
                            showShade: showShade,
                            showNames: showNames,
                          ),
                        ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: _ModePill(tool: tool),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MarkerLayer extends StatelessWidget {
  const _MarkerLayer({
    required this.bed,
    required this.canvasSize,
    required this.showShade,
    required this.showNames,
  });

  final Bed bed;
  final Size canvasSize;
  final bool showShade;
  final bool showNames;

  @override
  Widget build(BuildContext context) {
    final markers = <_MarkerViewModel>[];

    for (final block in bed.cropBlocks) {
      markers.add(
        _MarkerViewModel(cropName: block.cropName, x: block.x, y: block.y),
      );
    }

    for (final placement in bed.cropPlacements) {
      markers.add(
        _MarkerViewModel(
          cropName: placement.cropName,
          x: placement.x,
          y: placement.y,
        ),
      );
    }

    if (markers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Pick a plant, then draw here',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        for (final marker in markers)
          _PlantVisual(
            cropName: marker.cropName,
            xMeters: marker.x,
            yMeters: marker.y,
            bed: bed,
            canvasSize: canvasSize,
            opacity: 1,
            invalid: false,
            showShade: showShade,
            showNames: showNames,
          ),
      ],
    );
  }
}

class _MarkerViewModel {
  const _MarkerViewModel({
    required this.cropName,
    required this.x,
    required this.y,
  });

  final String cropName;
  final double x;
  final double y;
}

class _PreviewLayer extends StatelessWidget {
  const _PreviewLayer({
    required this.bed,
    required this.canvasSize,
    required this.preview,
    required this.showShade,
    required this.showNames,
  });

  final Bed bed;
  final Size canvasSize;
  final _PlantPreview preview;
  final bool showShade;
  final bool showNames;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        _PlantVisual(
          cropName: preview.cropName,
          xMeters: preview.x,
          yMeters: preview.y,
          bed: bed,
          canvasSize: canvasSize,
          opacity: preview.valid ? 0.58 : 0.38,
          invalid: !preview.valid,
          showShade: showShade,
          showNames: showNames,
        ),
      ],
    );
  }
}

class _PlantVisual extends StatelessWidget {
  const _PlantVisual({
    required this.cropName,
    required this.xMeters,
    required this.yMeters,
    required this.bed,
    required this.canvasSize,
    required this.opacity,
    required this.invalid,
    required this.showShade,
    required this.showNames,
  });

  final String cropName;
  final double xMeters;
  final double yMeters;
  final Bed bed;
  final Size canvasSize;
  final double opacity;
  final bool invalid;
  final bool showShade;
  final bool showNames;

  @override
  Widget build(BuildContext context) {
    final profile = _PlantVisualProfile.forCrop(
      cropName: cropName,
      bed: bed,
      canvasSize: canvasSize,
    );

    final point = _pointFor(
      bed: bed,
      x: xMeters,
      y: yMeters,
      canvasSize: canvasSize,
    );

    final iconLeft = point.dx - profile.iconPixels / 2;
    final iconTop = point.dy - profile.iconPixels / 2;
    final iconRight = iconLeft + profile.iconPixels;
    final iconBottom = iconTop + profile.iconPixels;

    var cellLeft = iconLeft;
    var cellTop = iconTop;
    var cellRight = iconRight;
    var cellBottom = iconBottom;

    double? shadeLeft;
    double? shadeTop;
    double? shadeWidth;
    double? shadeHeight;

    if (showShade && profile.castsShade) {
      final shadeCenterX =
          point.dx + profile.shadeOffsetXMeters * profile.pixelsPerMeter;
      final shadeCenterY =
          point.dy + profile.shadeOffsetYMeters * profile.pixelsPerMeter;

      shadeWidth = profile.shadeWidthPixels;
      shadeHeight = profile.shadeHeightPixels;

      shadeLeft = shadeCenterX - shadeWidth / 2;
      shadeTop = shadeCenterY - shadeHeight / 2;

      cellLeft = math.min(cellLeft, shadeLeft);
      cellTop = math.min(cellTop, shadeTop);
      cellRight = math.max(cellRight, shadeLeft + shadeWidth);
      cellBottom = math.max(cellBottom, shadeTop + shadeHeight);
    }

    final labelWidth = math.max(profile.iconPixels + 24, 72.0);
    const labelHeight = 20.0;

    if (showNames) {
      final labelLeft = point.dx - labelWidth / 2;
      final labelTop = iconBottom - 2;
      cellLeft = math.min(cellLeft, labelLeft);
      cellTop = math.min(cellTop, labelTop);
      cellRight = math.max(cellRight, labelLeft + labelWidth);
      cellBottom = math.max(cellBottom, labelTop + labelHeight);
    }

    cellLeft = cellLeft.clamp(0.0, canvasSize.width).toDouble();
    cellTop = cellTop.clamp(0.0, canvasSize.height).toDouble();
    cellRight = cellRight.clamp(cellLeft, canvasSize.width).toDouble();
    cellBottom = cellBottom.clamp(cellTop, canvasSize.height).toDouble();

    final cellWidth = math.max(1.0, cellRight - cellLeft);
    final cellHeight = math.max(1.0, cellBottom - cellTop);

    return Positioned(
      left: cellLeft,
      top: cellTop,
      width: cellWidth,
      height: cellHeight,
      child: RepaintBoundary(
        child: IgnorePointer(
          child: Opacity(
            opacity: opacity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (showShade &&
                    profile.castsShade &&
                    shadeLeft != null &&
                    shadeTop != null &&
                    shadeWidth != null &&
                    shadeHeight != null)
                  Positioned(
                    left: shadeLeft - cellLeft,
                    top: shadeTop - cellTop,
                    width: shadeWidth,
                    height: shadeHeight,
                    child: _ShadeBlob(
                      opacity: invalid
                          ? profile.shadeOpacity * 0.45
                          : profile.shadeOpacity,
                    ),
                  ),
                Positioned(
                  left: iconLeft - cellLeft,
                  top: iconTop - cellTop,
                  width: profile.iconPixels,
                  height: profile.iconPixels,
                  child: invalid
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.red,
                            BlendMode.srcATop,
                          ),
                          child: GeneratedPlantIcon(
                            cropName: cropName,
                            size: profile.iconPixels,
                          ),
                        )
                      : GeneratedPlantIcon(
                          cropName: cropName,
                          size: profile.iconPixels,
                        ),
                ),
                if (showNames)
                  Positioned(
                    left: point.dx - labelWidth / 2 - cellLeft,
                    top: iconBottom - 2 - cellTop,
                    width: labelWidth,
                    height: labelHeight,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          cropName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantVisualProfile {
  const _PlantVisualProfile({
    required this.spacingMeters,
    required this.spacingPixels,
    required this.pixelsPerMeter,
    required this.iconPixels,
    required this.castsShade,
    required this.shadeWidthPixels,
    required this.shadeHeightPixels,
    required this.shadeOffsetXMeters,
    required this.shadeOffsetYMeters,
    required this.shadeOpacity,
  });

  final double spacingMeters;
  final double spacingPixels;
  final double pixelsPerMeter;
  final double iconPixels;

  final bool castsShade;
  final double shadeWidthPixels;
  final double shadeHeightPixels;
  final double shadeOffsetXMeters;
  final double shadeOffsetYMeters;
  final double shadeOpacity;

  static _PlantVisualProfile forCrop({
    required String cropName,
    required Bed bed,
    required Size canvasSize,
  }) {
    final bedWidth = math.max(0.1, bed.width);
    final bedHeight = math.max(0.1, bed.height);

    final pixelsPerMeter = math.min(
      canvasSize.width / bedWidth,
      canvasSize.height / bedHeight,
    );

    final spacingMeters = _mobileRecommendedSpacingMetersForCrop(
      cropName,
    ).clamp(0.04, math.max(0.04, math.min(bedWidth, bedHeight))).toDouble();

    final spacingPixels = spacingMeters * pixelsPerMeter;

    final crop = cropName.toLowerCase();

    bool hasAny(List<String> words) => words.any(crop.contains);

    final isTree = hasAny([
      'apple',
      'pear',
      'peach',
      'plum',
      'cherry',
      'citrus',
      'lemon',
      'orange',
      'lime',
      'avocado',
      'olive',
      'fig',
      'mango',
      'almond',
      'walnut',
      'hazelnut',
      'tree',
    ]);

    final isBush = hasAny([
      'raspberry',
      'blueberry',
      'blackberry',
      'currant',
      'gooseberry',
      'elderberry',
      'boysenberry',
      'bush',
      'shrub',
    ]);

    final isTall = hasAny([
      'corn',
      'maize',
      'sunflower',
      'tomato',
      'pole bean',
      'runner bean',
      'grape',
      'trellis',
    ]);

    final isVine = hasAny([
      'pumpkin',
      'squash',
      'zucchini',
      'courgette',
      'melon',
      'watermelon',
      'cucumber',
    ]);

    final isLargeVeg = hasAny([
      'broccoli',
      'cauliflower',
      'cabbage',
      'kale',
      'brussels',
      'brussel',
      'collard',
      'pepper',
      'capsicum',
      'eggplant',
      'aubergine',
    ]);

    final isLeafy = hasAny([
      'lettuce',
      'spinach',
      'silverbeet',
      'chard',
      'bok',
      'pak',
      'celery',
      'rocket',
      'arugula',
    ]);

    final isRootOrHerb = hasAny([
      'carrot',
      'radish',
      'beet',
      'beetroot',
      'onion',
      'garlic',
      'leek',
      'turnip',
      'parsnip',
      'potato',
      'shallot',
      'basil',
      'parsley',
      'cilantro',
      'coriander',
      'dill',
      'mint',
      'thyme',
      'rosemary',
      'oregano',
      'sage',
      'chives',
      'fennel',
      'tarragon',
      'lavender',
    ]);

    double rawIconPixels;

    if (isTree) {
      rawIconPixels = (spacingPixels * 0.58).clamp(58.0, 150.0).toDouble();
    } else if (isBush) {
      rawIconPixels = (spacingPixels * 0.70).clamp(42.0, 116.0).toDouble();
    } else if (isTall) {
      rawIconPixels = (spacingPixels * 0.76).clamp(42.0, 104.0).toDouble();
    } else if (isVine) {
      rawIconPixels = (spacingPixels * 0.72).clamp(48.0, 118.0).toDouble();
    } else if (isLargeVeg) {
      rawIconPixels = (spacingPixels * 0.86).clamp(34.0, 86.0).toDouble();
    } else if (isLeafy) {
      rawIconPixels = (spacingPixels * 0.96).clamp(26.0, 66.0).toDouble();
    } else if (isRootOrHerb) {
      rawIconPixels = (spacingPixels * 1.15).clamp(18.0, 44.0).toDouble();
    } else {
      rawIconPixels = (spacingPixels * 0.90).clamp(28.0, 74.0).toDouble();
    }

    final maxMobileIcon = math.min(canvasSize.shortestSide * 0.68, 155.0);
    final iconPixels = rawIconPixels.clamp(14.0, maxMobileIcon).toDouble();

    var castsShade = false;
    var shadeWidthPixels = 0.0;
    var shadeHeightPixels = 0.0;
    var shadeOffsetXMeters = 0.0;
    var shadeOffsetYMeters = 0.0;
    var shadeOpacity = 0.0;

    if (isTree) {
      castsShade = true;
      final shadeMeters = math.max(spacingMeters * 1.45, 2.2);
      final shadePixels = shadeMeters * pixelsPerMeter;
      shadeWidthPixels = shadePixels * 1.35;
      shadeHeightPixels = shadePixels * 0.72;
      shadeOffsetXMeters = shadeMeters * 0.22;
      shadeOffsetYMeters = shadeMeters * 0.16;
      shadeOpacity = 0.20;
    } else if (isBush) {
      castsShade = true;
      final shadeMeters = math.max(spacingMeters * 1.15, 0.85);
      final shadePixels = shadeMeters * pixelsPerMeter;
      shadeWidthPixels = shadePixels * 1.18;
      shadeHeightPixels = shadePixels * 0.68;
      shadeOffsetXMeters = shadeMeters * 0.18;
      shadeOffsetYMeters = shadeMeters * 0.14;
      shadeOpacity = 0.14;
    } else if (isTall) {
      castsShade = true;
      final shadeMeters = math.max(spacingMeters * 0.90, 0.55);
      final shadePixels = shadeMeters * pixelsPerMeter;
      shadeWidthPixels = shadePixels * 1.05;
      shadeHeightPixels = shadePixels * 0.58;
      shadeOffsetXMeters = shadeMeters * 0.16;
      shadeOffsetYMeters = shadeMeters * 0.12;
      shadeOpacity = 0.10;
    }

    shadeWidthPixels = shadeWidthPixels
        .clamp(0.0, math.min(canvasSize.width * 1.15, 230.0))
        .toDouble();

    shadeHeightPixels = shadeHeightPixels
        .clamp(0.0, math.min(canvasSize.height * 0.95, 180.0))
        .toDouble();

    return _PlantVisualProfile(
      spacingMeters: spacingMeters,
      spacingPixels: spacingPixels,
      pixelsPerMeter: pixelsPerMeter,
      iconPixels: iconPixels,
      castsShade: castsShade,
      shadeWidthPixels: shadeWidthPixels,
      shadeHeightPixels: shadeHeightPixels,
      shadeOffsetXMeters: shadeOffsetXMeters,
      shadeOffsetYMeters: shadeOffsetYMeters,
      shadeOpacity: shadeOpacity,
    );
  }
}

class _ShadeBlob extends StatelessWidget {
  const _ShadeBlob({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

Offset _pointFor({
  required Bed bed,
  required double x,
  required double y,
  required Size canvasSize,
}) {
  final bedWidth = math.max(0.1, bed.width);
  final bedHeight = math.max(0.1, bed.height);

  return Offset(
    (x / bedWidth).clamp(0.0, 1.0) * canvasSize.width,
    (y / bedHeight).clamp(0.0, 1.0) * canvasSize.height,
  );
}

class _BedPainter extends CustomPainter {
  const _BedPainter({required this.bedWidth, required this.bedHeight});

  final double bedWidth;
  final double bedHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final soil = Paint()..color = const Color(0xFFE9D2A8);
    final border = Paint()
      ..color = const Color(0xFF7A5A36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(22));

    canvas.drawRRect(rrect, soil);
    canvas.drawRRect(rrect.deflate(2), border);

    final pixelsPerMeter = math.min(
      size.width / math.max(0.1, bedWidth),
      size.height / math.max(0.1, bedHeight),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFF7A5A36).withValues(alpha: 0.08)
      ..strokeWidth = 1;

    final step = math.max(18.0, pixelsPerMeter * 0.5);

    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BedPainter oldDelegate) {
    return oldDelegate.bedWidth != bedWidth ||
        oldDelegate.bedHeight != bedHeight;
  }
}

class _ToolBar extends StatelessWidget {
  const _ToolBar({
    required this.bed,
    required this.tool,
    required this.hasPlant,
    required this.activePlantName,
    required this.showShade,
    required this.showNames,
    required this.canUndo,
    required this.onSelectTool,
    required this.onPickPlant,
    required this.onUndo,
    required this.onCleanSpacing,
    required this.onClearBed,
    required this.onShadeChanged,
    required this.onNamesChanged,
  });

  final Bed bed;
  final MobileBedTool tool;
  final bool hasPlant;
  final String? activePlantName;
  final bool showShade;
  final bool showNames;
  final bool canUndo;
  final ValueChanged<MobileBedTool> onSelectTool;
  final VoidCallback onPickPlant;
  final VoidCallback onUndo;
  final VoidCallback onCleanSpacing;
  final VoidCallback onClearBed;
  final ValueChanged<bool> onShadeChanged;
  final ValueChanged<bool> onNamesChanged;

  @override
  Widget build(BuildContext context) {
    final plant = activePlantName?.trim();

    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CurrentBrushCard(
                bed: bed,
                plantName: plant,
                tool: tool,
                onPickPlant: onPickPlant,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canUndo ? onUndo : null,
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    selected: showShade,
                    avatar: const Icon(Icons.wb_shade_outlined, size: 18),
                    label: const Text('Shade'),
                    onSelected: onShadeChanged,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    selected: showNames,
                    avatar: const Icon(Icons.label_outline, size: 18),
                    label: const Text('Names'),
                    onSelected: onNamesChanged,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                      label: const Text('Clean spacing'),
                      onPressed: onCleanSpacing,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear bed'),
                      onPressed: onClearBed,
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      selected: tool == MobileBedTool.plant,
                      enabled: hasPlant,
                      icon: Icons.brush_outlined,
                      label: 'Plant brush',
                      onTap: () => onSelectTool(MobileBedTool.plant),
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      selected: tool == MobileBedTool.move,
                      enabled: true,
                      icon: Icons.open_with_outlined,
                      label: 'Move plants',
                      onTap: () => onSelectTool(MobileBedTool.move),
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      selected: tool == MobileBedTool.erase,
                      enabled: true,
                      icon: Icons.cleaning_services_outlined,
                      label: 'Erase plants',
                      onTap: () => onSelectTool(MobileBedTool.erase),
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      selected: false,
                      enabled: true,
                      icon: Icons.straighten,
                      label: 'Bed size',
                      onTap: () => onSelectTool(MobileBedTool.size),
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      selected: false,
                      enabled: true,
                      icon: Icons.info_outline,
                      label: 'Bed details',
                      onTap: () => onSelectTool(MobileBedTool.info),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentBrushCard extends StatelessWidget {
  const _CurrentBrushCard({
    required this.bed,
    required this.plantName,
    required this.tool,
    required this.onPickPlant,
  });

  final Bed bed;
  final String? plantName;
  final MobileBedTool tool;
  final VoidCallback onPickPlant;

  @override
  Widget build(BuildContext context) {
    final crop = plantName?.trim();

    if (crop == null || crop.isEmpty) {
      return InkWell(
        onTap: onPickPlant,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6DF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(Icons.eco_outlined),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pick a plant to start designing',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
    }

    final spacingMeters = _mobileRecommendedSpacingMetersForCrop(crop);
    final modeText = switch (tool) {
      MobileBedTool.plant => 'Tap or drag • snaps to open spacing slots',
      MobileBedTool.move => 'Drag an existing plant',
      MobileBedTool.erase => 'Tap a plant to erase',
      MobileBedTool.size => 'Change bed size',
      MobileBedTool.info => 'View bed details',
    };

    return InkWell(
      onTap: onPickPlant,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF6EA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            GeneratedPlantIcon(cropName: crop, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Guideline spacing: ${(spacingMeters * 100).round()}cm • $modeText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.swap_horiz),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.selected,
    required this.enabled,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final bool enabled;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onSelected: enabled ? (_) => onTap() : null,
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.tool});

  final MobileBedTool tool;

  @override
  Widget build(BuildContext context) {
    final label = switch (tool) {
      MobileBedTool.plant => 'Plant mode',
      MobileBedTool.move => 'Move mode',
      MobileBedTool.erase => 'Erase mode',
      MobileBedTool.size => 'Size',
      MobileBedTool.info => 'Info',
    };

    final icon = switch (tool) {
      MobileBedTool.plant => Icons.brush_outlined,
      MobileBedTool.move => Icons.open_with_outlined,
      MobileBedTool.erase => Icons.cleaning_services_outlined,
      MobileBedTool.size => Icons.straighten,
      MobileBedTool.info => Icons.info_outline,
    };

    return Material(
      color: Colors.white.withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizePreview extends StatelessWidget {
  const _SizePreview({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final aspect = (width / height).clamp(0.55, 2.2);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              '${width.toStringAsFixed(1)}m × ${height.toStringAsFixed(1)}m',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 220,
                height: 220 / aspect,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9D2A8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF7A5A36), width: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(value),
      ),
    );
  }
}
