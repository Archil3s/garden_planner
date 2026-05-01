import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/models/crop_spacing.dart';
import '../../../../core/theme/garden_theme.dart';
import '../../controller/garden_controller.dart';
import 'draggable_crop_block.dart';
import 'map_view_controls.dart';
import 'plant_picker_panel.dart';

class PlannerMapView extends StatefulWidget {
  const PlannerMapView({
    super.key,
    required this.controller,
    required this.beds,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.pixelsPerMeter,
    required this.gridVisible,
    required this.labelsVisible,
    required this.cropRowsVisible,
    required this.instructionsVisible,
    required this.onOpenBedDetails,
    required this.onFitMap,
    required this.onResetZoom,
    required this.onGridVisibleChanged,
    required this.onLabelsVisibleChanged,
    required this.onCropRowsVisibleChanged,
    required this.onInstructionsVisibleChanged,
  });

  final GardenController controller;
  final List<Bed> beds;
  final double canvasWidth;
  final double canvasHeight;
  final double pixelsPerMeter;

  final bool gridVisible;
  final bool labelsVisible;
  final bool cropRowsVisible;
  final bool instructionsVisible;

  final ValueChanged<Bed> onOpenBedDetails;
  final VoidCallback onFitMap;
  final VoidCallback onResetZoom;

  final ValueChanged<bool> onGridVisibleChanged;
  final ValueChanged<bool> onLabelsVisibleChanged;
  final ValueChanged<bool> onCropRowsVisibleChanged;
  final ValueChanged<bool> onInstructionsVisibleChanged;

  @override
  State<PlannerMapView> createState() => _PlannerMapViewState();
}

class _PlannerMapViewState extends State<PlannerMapView> {
  String? selectedBedId;
  String? activePlantName;

  static const String buildMarker = 'one-bed-only-force-20260426_085802';

  Bed? get selectedBed {
    if (widget.beds.isEmpty) return null;

    final id = selectedBedId ?? widget.controller.selectedBedId;

    for (final bed in widget.beds) {
      if (bed.id == id) return bed;
    }

    return widget.beds.first;
  }

  @override
  void initState() {
    super.initState();

    if (widget.beds.isNotEmpty) {
      selectedBedId = widget.controller.selectedBedId ?? widget.beds.first.id;
      widget.controller.selectBed(selectedBedId!);
    }
  }

  @override
  void didUpdateWidget(covariant PlannerMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.beds.isEmpty) {
      selectedBedId = null;
      activePlantName = null;
      return;
    }

    final stillExists = widget.beds.any((bed) => bed.id == selectedBedId);

    if (!stillExists) {
      selectedBedId = widget.controller.selectedBedId ?? widget.beds.first.id;
      widget.controller.selectBed(selectedBedId!);
      activePlantName = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bed = selectedBed;

    return Stack(
      children: [
        const Positioned.fill(child: _MapBackdrop()),
        Positioned(
          left: 14,
          top: 14,
          bottom: 14,
          width: 300,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              return PlantPickerPanel(
                key: const ValueKey('one-bed-force-plant-picker-panel'),
                controller: widget.controller,
                onPlantChosen: _startPlantPlacement,
              );
            },
          ),
        ),
        Positioned.fill(
          left: 326,
          child: bed == null
              ? const _NoBedPanel()
              : _OneBedWorkspace(
                  marker: buildMarker,
                  bed: bed,
                  beds: widget.beds,
                  controller: widget.controller,
                  activePlantName: activePlantName,
                  showLabels: widget.labelsVisible,
                  showCropRows: widget.cropRowsVisible,
                  showInstructions: widget.instructionsVisible,
                  controls: MapViewControls(
                    gridVisible: widget.gridVisible,
                    labelsVisible: widget.labelsVisible,
                    cropRowsVisible: widget.cropRowsVisible,
                    instructionsVisible: widget.instructionsVisible,
                    onFitMap: widget.onFitMap,
                    onResetZoom: widget.onResetZoom,
                    onGridVisibleChanged: widget.onGridVisibleChanged,
                    onLabelsVisibleChanged: widget.onLabelsVisibleChanged,
                    onCropRowsVisibleChanged: widget.onCropRowsVisibleChanged,
                    onInstructionsVisibleChanged:
                        widget.onInstructionsVisibleChanged,
                  ),
                  onSelectBed: _selectBed,
                  onOpenDetails: () => widget.onOpenBedDetails(bed),
                  onClearPlant: () {
                    setState(() {
                      activePlantName = null;
                    });
                  },
                  onPlantPlaced: () {
                    setState(() {
                      activePlantName = null;
                    });
                  },
                ),
        ),
      ],
    );
  }

  void _selectBed(Bed bed) {
    widget.controller.selectBed(bed.id);

    setState(() {
      selectedBedId = bed.id;
      activePlantName = null;
    });
  }

  void _startPlantPlacement(String cropName) {
    final bed = selectedBed;

    if (bed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a bed before placing plants.')),
      );
      return;
    }

    widget.controller.selectBed(bed.id);

    setState(() {
      activePlantName = cropName;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Placing $cropName in ${bed.name}.')),
    );
  }
}

class _OneBedWorkspace extends StatelessWidget {
  const _OneBedWorkspace({
    required this.marker,
    required this.bed,
    required this.beds,
    required this.controller,
    required this.activePlantName,
    required this.showLabels,
    required this.showCropRows,
    required this.showInstructions,
    required this.controls,
    required this.onSelectBed,
    required this.onOpenDetails,
    required this.onClearPlant,
    required this.onPlantPlaced,
  });

  final String marker;
  final Bed bed;
  final List<Bed> beds;
  final GardenController controller;
  final String? activePlantName;
  final bool showLabels;
  final bool showCropRows;
  final bool showInstructions;
  final Widget controls;
  final ValueChanged<Bed> onSelectBed;
  final VoidCallback onOpenDetails;
  final VoidCallback onClearPlant;
  final VoidCallback onPlantPlaced;

  @override
  Widget build(BuildContext context) {
    final ppm = _pixelsPerMeterForBed(bed);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 18, 18),
      child: Column(
        children: [
          _Header(
            marker: marker,
            bed: bed,
            activePlantName: activePlantName,
            controls: controls,
            onOpenDetails: onOpenDetails,
            onClearPlant: onClearPlant,
          ),
          const SizedBox(height: 10),
          _BedSwitcher(
            beds: beds,
            selectedBedId: bed.id,
            onSelectBed: onSelectBed,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _BedCanvas(
              key: ValueKey('one-bed-${bed.id}-${activePlantName ?? 'none'}'),
              bed: bed,
              controller: controller,
              pixelsPerMeter: ppm,
              activePlantName: activePlantName,
              showLabels: showLabels,
              showCropRows: showCropRows,
              showInstructions: showInstructions,
              onPlantPlaced: onPlantPlaced,
            ),
          ),
        ],
      ),
    );
  }

  static double _pixelsPerMeterForBed(Bed bed) {
    final longest = math.max(bed.width, bed.height);

    if (longest <= 2.5) return 150;
    if (longest <= 4.0) return 120;
    if (longest <= 6.0) return 92;
    if (longest <= 8.5) return 74;

    return 62;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.marker,
    required this.bed,
    required this.activePlantName,
    required this.controls,
    required this.onOpenDetails,
    required this.onClearPlant,
  });

  final String marker;
  final Bed bed;
  final String? activePlantName;
  final Widget controls;
  final VoidCallback onOpenDetails;
  final VoidCallback onClearPlant;

  @override
  Widget build(BuildContext context) {
    final area = bed.width * bed.height;

    return Tooltip(
      message: marker,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD8D0C0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF227A47),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                bed.number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bed.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1B1A17),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${bed.width.toStringAsFixed(1)}m x ${bed.height.toStringAsFixed(1)}m - ${area.toStringAsFixed(1)} m2 - ${bed.cropBlocks.length} crop blocks',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF75695C),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (activePlantName != null) ...[
              _ActivePlantPill(
                plantName: activePlantName!,
                onClear: onClearPlant,
              ),
              const SizedBox(width: 8),
            ],
            OutlinedButton.icon(
              onPressed: onOpenDetails,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Details'),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Align(alignment: Alignment.centerRight, child: controls),
            ),
          ],
        ),
      ),
    );
  }
}

class _BedSwitcher extends StatelessWidget {
  const _BedSwitcher({
    required this.beds,
    required this.selectedBedId,
    required this.onSelectBed,
  });

  final List<Bed> beds;
  final String selectedBedId;
  final ValueChanged<Bed> onSelectBed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: beds.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bed = beds[index];
          final selected = bed.id == selectedBedId;
          final area = bed.width * bed.height;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onSelectBed(bed),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF1B1A17) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF1B1A17)
                      : const Color(0xFFD8D0C0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF227A47)
                          : const Color(0xFFEAF6EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      bed.number.toString(),
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF227A47),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 190),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bed.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF1B1A17),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${area.toStringAsFixed(1)} m2 - ${bed.cropBlocks.length} blocks',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.70)
                                : const Color(0xFF75695C),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BedCanvas extends StatefulWidget {
  const _BedCanvas({
    super.key,
    required this.bed,
    required this.controller,
    required this.pixelsPerMeter,
    required this.activePlantName,
    required this.showLabels,
    required this.showCropRows,
    required this.showInstructions,
    required this.onPlantPlaced,
  });

  final Bed bed;
  final GardenController controller;
  final double pixelsPerMeter;
  final String? activePlantName;
  final bool showLabels;
  final bool showCropRows;
  final bool showInstructions;
  final VoidCallback onPlantPlaced;

  @override
  State<_BedCanvas> createState() => _BedCanvasState();
}

class _BedCanvasState extends State<_BedCanvas> {
  Offset? dragStartLocal;
  Offset? dragCurrentLocal;

  bool get planting => widget.activePlantName != null;

  @override
  void didUpdateWidget(covariant _BedCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!planting || oldWidget.activePlantName != widget.activePlantName) {
      dragStartLocal = null;
      dragCurrentLocal = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.bed.width * widget.pixelsPerMeter;
    final height = widget.bed.height * widget.pixelsPerMeter;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8D0C0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: const _BackdropDotsPainter()),
            ),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Container(
                    width: width,
                    height: height,
                    margin: const EdgeInsets.all(30),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB77A43),
                          Color(0xFF8C5629),
                          Color(0xFF6E3F1F),
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: planting ? _plantAtTap : null,
                      onPanStart: planting ? _startPlantDrag : null,
                      onPanUpdate: planting ? _updatePlantDrag : null,
                      onPanEnd: planting ? _endPlantDrag : null,
                      onPanCancel: planting ? _cancelPlantDrag : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4C3325),
                                Color(0xFF60402B),
                                Color(0xFF3B281F),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _BedGridPainter(
                                    pixelsPerMeter: widget.pixelsPerMeter,
                                  ),
                                ),
                              ),
                              if (widget.showCropRows)
                                Positioned.fill(
                                  child: Stack(
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      for (final block in widget.bed.cropBlocks)
                                        DraggableCropBlock(
                                          key: ValueKey(block.id),
                                          bedId: widget.bed.id,
                                          block: block,
                                          pixelsPerMeter: widget.pixelsPerMeter,
                                          controller: widget.controller,
                                        ),
                                    ],
                                  ),
                                ),
                              if (widget.showLabels)
                                Positioned(
                                  left: 14,
                                  top: 14,
                                  child: _BedCanvasBadge(bed: widget.bed),
                                ),
                              if (widget.showInstructions)
                                Positioned(
                                  right: 14,
                                  top: 14,
                                  child: _CanvasHint(planting: planting),
                                ),
                              if (planting)
                                Positioned(
                                  left: 14,
                                  bottom: 14,
                                  child: _PlantingBadge(
                                    plantName: widget.activePlantName!,
                                  ),
                                ),
                              if (planting &&
                                  dragStartLocal != null &&
                                  dragCurrentLocal != null)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _PlantDragPreviewPainter(
                                        start: dragStartLocal!,
                                        current: dragCurrentLocal!,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _plantAtTap(TapDownDetails details) {
    final cropName = widget.activePlantName;
    if (cropName == null) return;

    _addCropFromLocalPoints(
      cropName: cropName,
      startLocal: details.localPosition,
      endLocal: details.localPosition,
    );
  }

  void _startPlantDrag(DragStartDetails details) {
    setState(() {
      dragStartLocal = details.localPosition;
      dragCurrentLocal = details.localPosition;
    });
  }

  void _updatePlantDrag(DragUpdateDetails details) {
    setState(() {
      dragCurrentLocal = details.localPosition;
    });
  }

  void _endPlantDrag(DragEndDetails details) {
    final cropName = widget.activePlantName;
    final start = dragStartLocal;
    final end = dragCurrentLocal;

    if (cropName == null || start == null || end == null) {
      _cancelPlantDrag();
      return;
    }

    _addCropFromLocalPoints(
      cropName: cropName,
      startLocal: start,
      endLocal: end,
    );
  }

  void _cancelPlantDrag() {
    setState(() {
      dragStartLocal = null;
      dragCurrentLocal = null;
    });
  }

  void _addCropFromLocalPoints({
    required String cropName,
    required Offset startLocal,
    required Offset endLocal,
  }) {
    final spacing = CropSpacing.spacingMetersForCrop(cropName);
    final largeCanopy = CropSpacing.isLargeCanopyCrop(cropName);

    final startGarden = _localToGarden(startLocal);
    var endGarden = _localToGarden(endLocal);

    final dragDistanceMeters = (endGarden - startGarden).distance;

    if (largeCanopy) {
      final half = math.max(0.5, spacing / 2);

      widget.controller.addCropRowToBedRect(
        bedId: widget.bed.id,
        cropName: cropName,
        startX: startGarden.dx - half,
        startY: startGarden.dy - half,
        endX: startGarden.dx + half,
        endY: startGarden.dy + half,
      );
    } else {
      if (dragDistanceMeters < spacing * 1.25) {
        final rowLength = math.max(spacing * 3, 1.2);
        endGarden = Offset(startGarden.dx + rowLength, startGarden.dy);
      }

      widget.controller.addCropRowToBedRect(
        bedId: widget.bed.id,
        cropName: cropName,
        startX: startGarden.dx,
        startY: startGarden.dy,
        endX: endGarden.dx,
        endY: endGarden.dy,
      );
    }

    setState(() {
      dragStartLocal = null;
      dragCurrentLocal = null;
    });

    widget.onPlantPlaced();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$cropName planted in ${widget.bed.name}.')),
    );
  }

  Offset _localToGarden(Offset local) {
    return Offset(
      widget.bed.x + local.dx / widget.pixelsPerMeter,
      widget.bed.y + local.dy / widget.pixelsPerMeter,
    );
  }
}

class _ActivePlantPill extends StatelessWidget {
  const _ActivePlantPill({required this.plantName, required this.onClear});

  final String plantName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFB8DDC8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Placing $plantName',
            style: const TextStyle(
              color: Color(0xFF227A47),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 16),
            color: const Color(0xFF227A47),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _BedCanvasBadge extends StatelessWidget {
  const _BedCanvasBadge({required this.bed});

  final Bed bed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8D0C0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '${bed.name} - ${bed.width.toStringAsFixed(1)}m x ${bed.height.toStringAsFixed(1)}m',
        style: const TextStyle(
          color: Color(0xFF1B1A17),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CanvasHint extends StatelessWidget {
  const _CanvasHint({required this.planting});

  final bool planting;

  @override
  Widget build(BuildContext context) {
    final text = planting
        ? 'Tap for one plant. Drag for a row.'
        : 'Choose a plant.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8D0C0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF75695C),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PlantingBadge extends StatelessWidget {
  const _PlantingBadge({required this.plantName});

  final String plantName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE6227A47),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        'Placing $plantName',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NoBedPanel extends StatelessWidget {
  const _NoBedPanel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Add a bed first. The Map tab works on one editable bed at a time.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF1B1A17),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.35,
        ),
      ),
    );
  }
}

class _MapBackdrop extends StatelessWidget {
  const _MapBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFAF6EE), Color(0xFFF0E7D8), Color(0xFFE7D8C2)],
        ),
      ),
      child: CustomPaint(painter: const _BackdropDotsPainter()),
    );
  }
}

class _BackdropDotsPainter extends CustomPainter {
  const _BackdropDotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x0CA86412);

    for (double x = 24; x < size.width; x += 44) {
      for (double y = 22; y < size.height; y += 42) {
        final wobble = ((x + y) % 23) / 23;
        canvas.drawCircle(Offset(x + wobble * 5, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BedGridPainter extends CustomPainter {
  const _BedGridPainter({required this.pixelsPerMeter});

  final double pixelsPerMeter;

  @override
  void paint(Canvas canvas, Size size) {
    final meterPaint = Paint()
      ..color = const Color(0x26E8D8BE)
      ..strokeWidth = 1.1;

    final halfMeterPaint = Paint()
      ..color = const Color(0x14E8D8BE)
      ..strokeWidth = 0.7;

    final rowPaint = Paint()
      ..color = const Color(0x20FFFFFF)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final halfStep = pixelsPerMeter / 2;

    var index = 0;
    for (double x = 0; x <= size.width; x += halfStep) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        index.isEven ? meterPaint : halfMeterPaint,
      );
      index++;
    }

    index = 0;
    for (double y = 0; y <= size.height; y += halfStep) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        index.isEven ? meterPaint : halfMeterPaint,
      );
      index++;
    }

    for (double y = 24; y <= size.height; y += 26) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 56) {
        path.quadraticBezierTo(x + 22, y + 4, x + 56, y);
      }
      canvas.drawPath(path, rowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BedGridPainter oldDelegate) {
    return oldDelegate.pixelsPerMeter != pixelsPerMeter;
  }
}

class _PlantDragPreviewPainter extends CustomPainter {
  const _PlantDragPreviewPainter({required this.start, required this.current});

  final Offset start;
  final Offset current;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GardenTheme.good.withValues(alpha: 0.92)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, current, paint);

    final dot = Paint()..color = GardenTheme.good;
    canvas.drawCircle(start, 6, dot);
    canvas.drawCircle(current, 6, dot);
  }

  @override
  bool shouldRepaint(covariant _PlantDragPreviewPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.current != current;
  }
}
