import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:garden_planner/core/models/bed.dart';
import 'package:garden_planner/core/models/crop_placement.dart';
import 'package:garden_planner/core/models/crop_spacing.dart';
import 'package:garden_planner/core/plant_icons/generated_plant_icon.dart';
import 'package:garden_planner/features/planner/controller/garden_controller.dart';

enum MobileBedTool { plant, move, erase }

double _strictSpacingMeters(String cropName) {
  final crop = cropName.toLowerCase();
  final base = CropSpacing.spacingMetersForCrop(cropName);

  bool hasAny(List<String> words) => words.any(crop.contains);

  var minimum = 0.08;

  if (hasAny([
    'almond',
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
    'walnut',
    'hazelnut',
    'tree',
  ])) {
    minimum = 6.0;
  } else if (hasAny([
    'acorn squash',
    'butternut',
    'pumpkin',
    'squash',
    'zucchini',
    'courgette',
    'melon',
    'watermelon',
  ])) {
    minimum = 1.20;
  } else if (hasAny(['cucumber'])) {
    minimum = 0.70;
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
    minimum = 0.90;
  } else if (hasAny([
    'tomato',
    'eggplant',
    'aubergine',
    'pepper',
    'capsicum',
  ])) {
    minimum = 0.65;
  } else if (hasAny(['corn', 'maize', 'sunflower'])) {
    minimum = 0.35;
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
    minimum = 0.45;
  } else if (hasAny([
    'lettuce',
    'spinach',
    'chard',
    'silverbeet',
    'bok',
    'pak',
    'celery',
  ])) {
    minimum = 0.25;
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
    minimum = 0.18;
  }

  return math.max(base, minimum).clamp(0.04, 50.0).toDouble();
}

bool _strictFitsBed({required String cropName, required Bed bed}) {
  final spacing = _strictSpacingMeters(cropName);

  return spacing <= bed.width && spacing <= bed.height;
}

class MobileBedDesigner extends StatefulWidget {
  const MobileBedDesigner({
    super.key,
    required this.controller,
    required this.selectedPlantName,
    required this.onPickPlant,
    required this.onProjectChanged,
    required this.onSave,
  });

  final GardenController controller;
  final String? selectedPlantName;
  final VoidCallback onPickPlant;
  final VoidCallback onProjectChanged;
  final VoidCallback onSave;

  @override
  State<MobileBedDesigner> createState() => _MobileBedDesignerState();
}

class _MobileBedDesignerState extends State<MobileBedDesigner> {
  final List<Bed> undoStack = [];
  final Set<String> strokeSlots = <String>{};

  MobileBedTool tool = MobileBedTool.plant;
  bool showShade = true;
  bool showNames = false;
  String? movingPlacementId;

  GardenController get controller => widget.controller;

  String get activePlant => widget.selectedPlantName?.trim() ?? '';

  bool get hasPlant => activePlant.isNotEmpty;

  Bed? get activeBed {
    if (controller.selectedBed != null) return controller.selectedBed;
    if (controller.beds.isEmpty) return null;
    return controller.beds.first;
  }

  String _bedTitle(Bed bed) {
    return bed.name.trim().isEmpty ? 'Bed ${bed.number}' : bed.name.trim();
  }

  void _replaceBed(
    Bed updatedBed, {
    bool trackUndo = true,
    bool notifyProjectChanged = true,
  }) {
    final index = controller.beds.indexWhere((bed) => bed.id == updatedBed.id);
    if (index == -1) return;

    if (trackUndo) {
      undoStack.add(controller.beds[index]);
      if (undoStack.length > 30) {
        undoStack.removeAt(0);
      }
    }

    final beds = [...controller.beds];
    beds[index] = updatedBed;

    controller.project = controller.project.copyWith(beds: beds);
    controller.selectBed(updatedBed.id);
    if (notifyProjectChanged) {
      widget.onProjectChanged();
    }

    setState(() {});
  }

  void _undo() {
    if (undoStack.isEmpty) return;

    final previous = undoStack.removeLast();
    _replaceBed(previous, trackUndo: false);
  }

  void _selectBed(Bed bed) {
    controller.selectBed(bed.id);

    setState(() {
      movingPlacementId = null;
      strokeSlots.clear();
    });
  }

  void _resetBed() {
    final bed = activeBed;
    if (bed == null) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF4),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reset ${_bedTitle(bed)}?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This removes all plants from this bed but keeps the bed size and name.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();

                    _replaceBed(
                      bed.copyWith(
                        crops: const [],
                        cropPlacements: const [],
                        cropBlocks: const [],
                      ),
                    );

                    strokeSlots.clear();
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset bed'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearBed() {
    final bed = activeBed;
    if (bed == null) return;

    _replaceBed(
      bed.copyWith(
        crops: const [],
        cropPlacements: const [],
        cropBlocks: const [],
      ),
    );

    strokeSlots.clear();
  }

  void _cleanSpacing() {
    final bed = activeBed;
    if (bed == null) return;

    final cleaned = _sanitizeBed(bed);
    _replaceBed(cleaned);
  }

  Bed _sanitizeBed(Bed bed) {
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
      if (!_strictFitsBed(cropName: placement.cropName, bed: bed)) {
        continue;
      }

      if (_blockedByList(
        bed: bed,
        existing: kept,
        cropName: placement.cropName,
        x: placement.x,
        y: placement.y,
      )) {
        continue;
      }

      kept.add(placement);
    }

    final crops = <String>[];
    final seen = <String>{};

    for (final placement in kept) {
      final key = placement.cropName.trim().toLowerCase();
      if (key.isEmpty || seen.contains(key)) continue;

      seen.add(key);
      crops.add(placement.cropName);
    }

    return bed.copyWith(
      crops: crops,
      cropPlacements: kept,
      cropBlocks: const [],
    );
  }

  bool _blockedByList({
    required Bed bed,
    required List<CropPlacement> existing,
    required String cropName,
    required double x,
    required double y,
  }) {
    final spacing = _strictSpacingMeters(cropName);
    final radius = spacing / 2;

    for (final placement in existing) {
      final otherSpacing = _strictSpacingMeters(placement.cropName);
      final otherRadius = otherSpacing / 2;

      final requiredDistance = radius + otherRadius;
      final requiredDistanceSquared = requiredDistance * requiredDistance;
      final dx = placement.x - x;
      final dy = placement.y - y;

      if (dx * dx + dy * dy < requiredDistanceSquared) {
        return true;
      }
    }

    return false;
  }

  bool _blockedByBed({
    required Bed bed,
    required String cropName,
    required double x,
    required double y,
    String? ignorePlacementId,
  }) {
    final spacing = _strictSpacingMeters(cropName);
    final radius = spacing / 2;

    for (final placement in bed.cropPlacements) {
      if (ignorePlacementId != null && placement.id == ignorePlacementId) {
        continue;
      }

      if (!_strictFitsBed(cropName: placement.cropName, bed: bed)) {
        continue;
      }

      final otherSpacing = _strictSpacingMeters(placement.cropName);
      final otherRadius = otherSpacing / 2;

      final requiredDistance = radius + otherRadius;
      final requiredDistanceSquared = requiredDistance * requiredDistance;
      final dx = placement.x - x;
      final dy = placement.y - y;

      if (dx * dx + dy * dy < requiredDistanceSquared) {
        return true;
      }
    }

    for (final block in bed.cropBlocks) {
      if (!_strictFitsBed(cropName: block.cropName, bed: bed)) {
        continue;
      }

      final otherSpacing = _strictSpacingMeters(block.cropName);
      final otherRadius = otherSpacing / 2;

      final requiredDistance = radius + otherRadius;
      final requiredDistanceSquared = requiredDistance * requiredDistance;
      final dx = block.x - x;
      final dy = block.y - y;

      if (dx * dx + dy * dy < requiredDistanceSquared) {
        return true;
      }
    }

    return false;
  }

  void _handlePointerDown(Offset localPosition, Size canvasSize) {
    final bed = activeBed;
    if (bed == null) return;

    strokeSlots.clear();

    if (tool == MobileBedTool.plant) {
      _plantAt(bed: bed, localPosition: localPosition, canvasSize: canvasSize);
      return;
    }

    if (tool == MobileBedTool.erase) {
      _eraseAt(bed: bed, localPosition: localPosition, canvasSize: canvasSize);
      return;
    }

    if (tool == MobileBedTool.move) {
      movingPlacementId = _nearestPlacementId(
        bed: bed,
        localPosition: localPosition,
        canvasSize: canvasSize,
      );
    }
  }

  void _handlePointerMove(Offset localPosition, Size canvasSize) {
    final bed = activeBed;
    if (bed == null) return;

    if (tool == MobileBedTool.plant) {
      _plantAt(bed: bed, localPosition: localPosition, canvasSize: canvasSize);
      return;
    }

    if (tool == MobileBedTool.erase) {
      _eraseAt(bed: bed, localPosition: localPosition, canvasSize: canvasSize);
      return;
    }

    if (tool == MobileBedTool.move && movingPlacementId != null) {
      _moveAt(
        bed: bed,
        placementId: movingPlacementId!,
        localPosition: localPosition,
        canvasSize: canvasSize,
      );
    }
  }

  void _handlePointerEnd() {
    final wasMoving = movingPlacementId != null;

    movingPlacementId = null;
    strokeSlots.clear();

    if (wasMoving) {
      widget.onProjectChanged();
    }
  }

  void _plantAt({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
  }) {
    if (!hasPlant) {
      widget.onPickPlant();
      return;
    }

    final cropName = activePlant;

    if (!_strictFitsBed(cropName: cropName, bed: bed)) {
      return;
    }

    final slot = _nearestOpenSlot(
      bed: bed,
      cropName: cropName,
      localPosition: localPosition,
      canvasSize: canvasSize,
    );

    if (slot == null) return;

    final slotKey = _slotKey(
      bedId: bed.id,
      cropName: cropName,
      x: slot.dx,
      y: slot.dy,
    );

    if (strokeSlots.contains(slotKey)) return;

    final crops =
        bed.crops
            .map((crop) => crop.trim().toLowerCase())
            .contains(cropName.toLowerCase())
        ? bed.crops
        : [...bed.crops, cropName];

    final updated = bed.copyWith(
      crops: crops,
      cropPlacements: [
        ...bed.cropPlacements,
        CropPlacement(
          id: 'strict-${DateTime.now().microsecondsSinceEpoch}',
          cropName: cropName,
          x: slot.dx,
          y: slot.dy,
        ),
      ],
    );

    strokeSlots.add(slotKey);
    _replaceBed(updated);
  }

  void _moveAt({
    required Bed bed,
    required String placementId,
    required Offset localPosition,
    required Size canvasSize,
  }) {
    final index = bed.cropPlacements.indexWhere(
      (item) => item.id == placementId,
    );
    if (index == -1) return;

    final placement = bed.cropPlacements[index];

    if (!_strictFitsBed(cropName: placement.cropName, bed: bed)) {
      return;
    }

    final slot = _nearestOpenSlot(
      bed: bed,
      cropName: placement.cropName,
      localPosition: localPosition,
      canvasSize: canvasSize,
      ignorePlacementId: placementId,
    );

    if (slot == null) return;

    final placements = [...bed.cropPlacements];
    placements[index] = CropPlacement(
      id: placement.id,
      cropName: placement.cropName,
      x: slot.dx,
      y: slot.dy,
    );

    _replaceBed(
      bed.copyWith(cropPlacements: placements),
      trackUndo: false,
      notifyProjectChanged: false,
    );
  }

  void _eraseAt({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
  }) {
    final id = _nearestPlacementId(
      bed: bed,
      localPosition: localPosition,
      canvasSize: canvasSize,
    );

    if (id == null) return;

    _replaceBed(
      bed.copyWith(
        cropPlacements: bed.cropPlacements
            .where((placement) => placement.id != id)
            .toList(),
      ),
    );
  }

  String? _nearestPlacementId({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
  }) {
    var bestDistance = double.infinity;
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

    return bestDistance <= 48 ? bestId : null;
  }

  Offset? _nearestOpenSlot({
    required Bed bed,
    required String cropName,
    required Offset localPosition,
    required Size canvasSize,
    String? ignorePlacementId,
  }) {
    final spacing = _strictSpacingMeters(cropName);

    if (!_strictFitsBed(cropName: cropName, bed: bed)) {
      return null;
    }

    final radius = spacing / 2;
    final target = _localToMeters(
      bed: bed,
      localPosition: localPosition,
      canvasSize: canvasSize,
    );

    final candidates = <Offset>[];

    for (double y = radius; y <= bed.height - radius + 0.0001; y += spacing) {
      for (double x = radius; x <= bed.width - radius + 0.0001; x += spacing) {
        candidates.add(Offset(x, y));
      }
    }

    candidates.sort((a, b) {
      final adx = a.dx - target.dx;
      final ady = a.dy - target.dy;
      final bdx = b.dx - target.dx;
      final bdy = b.dy - target.dy;

      return (adx * adx + ady * ady).compareTo(bdx * bdx + bdy * bdy);
    });

    final tolerance = spacing * 0.55;

    for (final candidate in candidates) {
      final dx = candidate.dx - target.dx;
      final dy = candidate.dy - target.dy;

      if (math.sqrt(dx * dx + dy * dy) > tolerance) {
        continue;
      }

      if (_blockedByBed(
        bed: bed,
        cropName: cropName,
        x: candidate.dx,
        y: candidate.dy,
        ignorePlacementId: ignorePlacementId,
      )) {
        continue;
      }

      return candidate;
    }

    return null;
  }

  String _slotKey({
    required String bedId,
    required String cropName,
    required double x,
    required double y,
  }) {
    final spacing = _strictSpacingMeters(cropName);
    final sx = (x / spacing).round();
    final sy = (y / spacing).round();

    return '$bedId:${cropName.toLowerCase()}:$sx:$sy';
  }

  Offset _localToMeters({
    required Bed bed,
    required Offset localPosition,
    required Size canvasSize,
  }) {
    return Offset(
      (localPosition.dx / canvasSize.width * bed.width).clamp(0.0, bed.width),
      (localPosition.dy / canvasSize.height * bed.height).clamp(
        0.0,
        bed.height,
      ),
    );
  }

  Offset _metersToLocal({
    required Bed bed,
    required double x,
    required double y,
    required Size canvasSize,
  }) {
    return Offset(
      (x / bed.width).clamp(0.0, 1.0) * canvasSize.width,
      (y / bed.height).clamp(0.0, 1.0) * canvasSize.height,
    );
  }

  void _openSizeSheet(Bed bed) {
    double width = bed.width;
    double height = bed.height;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFBF4),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bed size',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${width.toStringAsFixed(1)}m Ã— ${height.toStringAsFixed(1)}m',
                    ),
                    Slider(
                      value: width.clamp(0.5, 12.0),
                      min: 0.5,
                      max: 12,
                      divisions: 115,
                      label: '${width.toStringAsFixed(1)}m',
                      onChanged: (value) => setSheetState(() => width = value),
                    ),
                    Slider(
                      value: height.clamp(0.5, 8.0),
                      min: 0.5,
                      max: 8,
                      divisions: 75,
                      label: '${height.toStringAsFixed(1)}m',
                      onChanged: (value) => setSheetState(() => height = value),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _replaceBed(
                          _sanitizeBed(
                            bed.copyWith(width: width, height: height),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Apply size'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bed = activeBed;

    if (controller.beds.isEmpty || bed == null) {
      return const Center(child: Text('No beds available.'));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final current = activeBed;
      if (current == null) return;

      final cleaned = _sanitizeBed(current);

      if (cleaned.cropPlacements.length != current.cropPlacements.length ||
          cleaned.cropBlocks.length != current.cropBlocks.length) {
        _replaceBed(cleaned, trackUndo: false);
      }
    });

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
          plantName: activePlant,
          onPickPlant: widget.onPickPlant,
          onSize: () => _openSizeSheet(bed),
          onSave: widget.onSave,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: _StrictCanvas(
              bed: bed,
              tool: tool,
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
          plantName: activePlant,
          canUndo: undoStack.isNotEmpty,
          showShade: showShade,
          showNames: showNames,
          onUndo: _undo,
          onCleanSpacing: _cleanSpacing,
          onClearBed: _clearBed,
          onResetBed: _resetBed,
          onPickPlant: widget.onPickPlant,
          onToolChanged: (value) => setState(() => tool = value),
          onShadeChanged: (value) => setState(() => showShade = value),
          onNamesChanged: (value) => setState(() => showNames = value),
        ),
      ],
    );
  }
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
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bed = beds[index];
          final selected = bed.id == selectedBedId;

          return ChoiceChip(
            selected: selected,
            avatar: selected
                ? const Icon(Icons.check_circle, size: 18)
                : const Icon(Icons.view_week_outlined, size: 18),
            label: Text(titleForBed(bed)),
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
    required this.plantName,
    required this.onPickPlant,
    required this.onSize,
    required this.onSave,
  });

  final Bed bed;
  final String bedName;
  final String plantName;
  final VoidCallback onPickPlant;
  final VoidCallback onSize;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  '$bedName\n${bed.width.toStringAsFixed(1)}m Ã— ${bed.height.toStringAsFixed(1)}m'
                  '${plantName.isEmpty ? '' : ' â€¢ $plantName'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton.outlined(
                onPressed: onPickPlant,
                icon: const Icon(Icons.eco_outlined),
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                onPressed: onSize,
                icon: const Icon(Icons.straighten),
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrictCanvas extends StatelessWidget {
  const _StrictCanvas({
    required this.bed,
    required this.tool,
    required this.showShade,
    required this.showNames,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerEnd,
  });

  final Bed bed;
  final MobileBedTool tool;
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
        var width = constraints.maxWidth;
        var height = width / aspect;

        if (height > constraints.maxHeight) {
          height = constraints.maxHeight;
          width = height * aspect;
        }

        final size = Size(width, height);

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) =>
                  onPointerDown(event.localPosition, size),
              onPointerMove: (event) =>
                  onPointerMove(event.localPosition, size),
              onPointerUp: (_) => onPointerEnd(),
              onPointerCancel: (_) => onPointerEnd(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
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
                      child: _PlantLayer(
                        bed: bed,
                        canvasSize: size,
                        showShade: showShade,
                        showNames: showNames,
                      ),
                    ),
                    Positioned(left: 10, top: 10, child: _ModePill(tool: tool)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlantLayer extends StatelessWidget {
  const _PlantLayer({
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
    final markers = <CropPlacement>[
      for (final block in bed.cropBlocks)
        if (_strictFitsBed(cropName: block.cropName, bed: bed))
          CropPlacement(
            id: 'block-${block.id}',
            cropName: block.cropName,
            x: block.x,
            y: block.y,
          ),
      for (final placement in bed.cropPlacements)
        if (_strictFitsBed(cropName: placement.cropName, bed: bed)) placement,
    ];

    if (markers.isEmpty) {
      return const Center(
        child: Text(
          'Pick a plant, then draw here',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      );
    }

    return Stack(
      children: [
        for (final marker in markers)
          _PlantMarker(
            placement: marker,
            bed: bed,
            canvasSize: canvasSize,
            showShade: showShade,
            showNames: showNames,
          ),
      ],
    );
  }
}

class _PlantMarker extends StatelessWidget {
  const _PlantMarker({
    required this.placement,
    required this.bed,
    required this.canvasSize,
    required this.showShade,
    required this.showNames,
  });

  final CropPlacement placement;
  final Bed bed;
  final Size canvasSize;
  final bool showShade;
  final bool showNames;

  @override
  Widget build(BuildContext context) {
    final spacing = _strictSpacingMeters(placement.cropName);
    final ppm = math.min(
      canvasSize.width / bed.width,
      canvasSize.height / bed.height,
    );
    final spacingPixels = spacing * ppm;

    final iconPixels = spacingPixels.clamp(28.0, 150.0).toDouble();

    final point = Offset(
      (placement.x / bed.width).clamp(0.0, 1.0) * canvasSize.width,
      (placement.y / bed.height).clamp(0.0, 1.0) * canvasSize.height,
    );

    final crop = placement.cropName.toLowerCase();
    final castsShade =
        crop.contains('tree') ||
        crop.contains('almond') ||
        crop.contains('apple') ||
        crop.contains('pear') ||
        crop.contains('raspberry') ||
        crop.contains('blueberry') ||
        crop.contains('tomato') ||
        crop.contains('corn');

    final shadeWidth = (spacingPixels * 1.1)
        .clamp(0.0, canvasSize.width)
        .toDouble();
    final shadeHeight = (spacingPixels * 0.45)
        .clamp(0.0, canvasSize.height)
        .toDouble();

    final left = (point.dx - iconPixels / 2)
        .clamp(0.0, math.max(0.0, canvasSize.width - iconPixels))
        .toDouble();

    final top = (point.dy - iconPixels / 2)
        .clamp(0.0, math.max(0.0, canvasSize.height - iconPixels))
        .toDouble();

    return Stack(
      children: [
        if (showShade && castsShade)
          Positioned(
            left: (point.dx - shadeWidth / 2 + spacingPixels * 0.15)
                .clamp(0.0, math.max(0.0, canvasSize.width - shadeWidth))
                .toDouble(),
            top: (point.dy - shadeHeight / 2 + spacingPixels * 0.10)
                .clamp(0.0, math.max(0.0, canvasSize.height - shadeHeight))
                .toDouble(),
            width: shadeWidth,
            height: shadeHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        Positioned(
          left: left,
          top: top,
          width: iconPixels,
          height: iconPixels,
          child: GeneratedPlantIcon(
            cropName: placement.cropName,
            size: iconPixels,
          ),
        ),
        if (showNames)
          Positioned(
            left: (point.dx - 44)
                .clamp(0.0, math.max(0.0, canvasSize.width - 88))
                .toDouble(),
            top: (top + iconPixels - 2)
                .clamp(0.0, math.max(0.0, canvasSize.height - 20))
                .toDouble(),
            width: 88,
            height: 20,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    placement.cropName,
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
          ),
      ],
    );
  }
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
    required this.plantName,
    required this.canUndo,
    required this.showShade,
    required this.showNames,
    required this.onUndo,
    required this.onCleanSpacing,
    required this.onClearBed,
    required this.onResetBed,
    required this.onPickPlant,
    required this.onToolChanged,
    required this.onShadeChanged,
    required this.onNamesChanged,
  });

  final Bed bed;
  final MobileBedTool tool;
  final String plantName;
  final bool canUndo;
  final bool showShade;
  final bool showNames;
  final VoidCallback onUndo;
  final VoidCallback onCleanSpacing;
  final VoidCallback onClearBed;
  final VoidCallback onResetBed;
  final VoidCallback onPickPlant;
  final ValueChanged<MobileBedTool> onToolChanged;
  final ValueChanged<bool> onShadeChanged;
  final ValueChanged<bool> onNamesChanged;

  @override
  Widget build(BuildContext context) {
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
              _BrushCard(
                bed: bed,
                plantName: plantName,
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
                      label: const Text('Fix spacing'),
                      onPressed: onCleanSpacing,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear plants'),
                      onPressed: onClearBed,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Reset bed'),
                      onPressed: onResetBed,
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      selected: tool == MobileBedTool.plant,
                      icon: Icons.brush_outlined,
                      label: 'Plant',
                      onTap: () => onToolChanged(MobileBedTool.plant),
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      selected: tool == MobileBedTool.move,
                      icon: Icons.open_with_outlined,
                      label: 'Move',
                      onTap: () => onToolChanged(MobileBedTool.move),
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      selected: tool == MobileBedTool.erase,
                      icon: Icons.cleaning_services_outlined,
                      label: 'Erase',
                      onTap: () => onToolChanged(MobileBedTool.erase),
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

class _BrushCard extends StatelessWidget {
  const _BrushCard({
    required this.bed,
    required this.plantName,
    required this.tool,
    required this.onPickPlant,
  });

  final Bed bed;
  final String plantName;
  final MobileBedTool tool;
  final VoidCallback onPickPlant;

  @override
  Widget build(BuildContext context) {
    final crop = plantName.trim();

    if (crop.isEmpty) {
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

    final spacing = _strictSpacingMeters(crop);
    final fits = _strictFitsBed(cropName: crop, bed: bed);

    final slotCount = fits
        ? math.max(1, (bed.width / spacing).floor()) *
              math.max(1, (bed.height / spacing).floor())
        : 0;

    final mode = !fits
        ? 'Does not fit this bed'
        : switch (tool) {
            MobileBedTool.plant => 'Tap/drag legal slots only',
            MobileBedTool.move => 'Move existing plants',
            MobileBedTool.erase => 'Erase plants',
          };

    return InkWell(
      onTap: onPickPlant,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fits ? const Color(0xFFEAF6EA) : const Color(0xFFFFE8E2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            GeneratedPlantIcon(cropName: crop, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$crop\nSpacing: ${(spacing * 100).round()}cm â€¢ 0/$slotCount slots â€¢ $mode',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
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
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onSelected: (_) => onTap(),
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
    };

    return Material(
      color: Colors.white.withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
