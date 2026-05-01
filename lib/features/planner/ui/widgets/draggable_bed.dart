import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/models/crop_spacing.dart';
import '../../../../core/theme/garden_theme.dart';
import '../../controller/garden_controller.dart';
import 'draggable_crop_block.dart';

class DraggableBed extends StatefulWidget {
  const DraggableBed({
    super.key,
    required this.bed,
    required this.selected,
    required this.pixelsPerMeter,
    required this.controller,
    this.showLabels = true,
    this.showCrops = true,
    this.onOpenDetails,
    this.onFocusBed,
    this.activePlantName,
    this.onPlantPlaced,
  });

  final Bed bed;
  final bool selected;
  final double pixelsPerMeter;
  final GardenController controller;
  final bool showLabels;
  final bool showCrops;
  final VoidCallback? onOpenDetails;
  final VoidCallback? onFocusBed;
  final String? activePlantName;
  final VoidCallback? onPlantPlaced;

  @override
  State<DraggableBed> createState() => _DraggableBedState();
}

class _DraggableBedState extends State<DraggableBed> {
  Offset dragOffsetPixels = Offset.zero;
  Offset resizeOffsetPixels = Offset.zero;

  Offset? plantDragStartLocal;
  Offset? plantDragCurrentLocal;

  bool moving = false;
  bool resizing = false;

  bool get planting => widget.activePlantName != null;

  @override
  void didUpdateWidget(covariant DraggableBed oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!moving) {
      dragOffsetPixels = Offset.zero;
    }

    if (!resizing) {
      resizeOffsetPixels = Offset.zero;
    }

    if (!planting) {
      plantDragStartLocal = null;
      plantDragCurrentLocal = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.bed.x * widget.pixelsPerMeter + dragOffsetPixels.dx;
    final top = widget.bed.y * widget.pixelsPerMeter + dragOffsetPixels.dy;

    final widthPx = _visualWidthPixels();
    final heightPx = _visualHeightPixels();

    final overlapping = widget.controller.bedOverlaps(widget.bed.id);

    return Positioned(
      left: left,
      top: top,
      width: widthPx,
      height: heightPx,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: planting ? _plantAtTap : null,
              onTap: planting ? null : _selectOnly,
              onDoubleTap: planting ? null : _openDetails,
              onLongPress: planting ? null : _openDetails,
              onPanStart: planting ? _startPlantDrag : null,
              onPanUpdate: planting ? _updatePlantDrag : null,
              onPanEnd: planting ? _endPlantDrag : null,
              onPanCancel: planting ? _cancelPlantDrag : null,
              child: _SimpleRaisedBedSurface(
                bed: widget.bed,
                selected: widget.selected,
                overlapping: overlapping,
                widthMeters: _visualWidthMeters(),
                heightMeters: _visualHeightMeters(),
                showLabels: widget.showLabels,
                planting: planting,
              ),
            ),
          ),

          if (widget.showCrops)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: planting,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 34, 8, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                ),
              ),
            ),

          if (planting &&
              plantDragStartLocal != null &&
              plantDragCurrentLocal != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PlantDragPreviewPainter(
                    start: plantDragStartLocal!,
                    current: plantDragCurrentLocal!,
                  ),
                ),
              ),
            ),

          if (widget.selected && !planting)
            Positioned(
              right: 8,
              top: 8,
              child: _MovePill(
                active: moving,
                onPanStart: _onMovePanStart,
                onPanUpdate: _onMovePanUpdate,
                onPanEnd: _onMovePanEnd,
                onPanCancel: _onMovePanCancel,
              ),
            ),

          if (widget.selected && !planting)
            Positioned(
              right: -8,
              bottom: -8,
              child: _ResizeKnob(
                active: resizing,
                warning: overlapping,
                onPanStart: _onResizePanStart,
                onPanUpdate: _onResizePanUpdate,
                onPanEnd: _onResizePanEnd,
                onPanCancel: _onResizePanCancel,
              ),
            ),
        ],
      ),
    );
  }

  void _selectOnly() {
    widget.controller.selectBed(widget.bed.id);
    widget.onFocusBed?.call();
  }

  void _openDetails() {
    widget.controller.selectBed(widget.bed.id);
    widget.onOpenDetails?.call();
  }

  void _plantAtTap(TapDownDetails details) {
    final cropName = widget.activePlantName;
    if (cropName == null) return;

    _addCropFromLocalPoints(
      cropName: cropName,
      startLocal: details.localPosition,
      endLocal: details.localPosition,
    );

    widget.onPlantPlaced?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$cropName planted in ${widget.bed.name}.')),
    );
  }

  void _startPlantDrag(DragStartDetails details) {
    setState(() {
      plantDragStartLocal = details.localPosition;
      plantDragCurrentLocal = details.localPosition;
    });
  }

  void _updatePlantDrag(DragUpdateDetails details) {
    setState(() {
      plantDragCurrentLocal = details.localPosition;
    });
  }

  void _endPlantDrag(DragEndDetails details) {
    final cropName = widget.activePlantName;
    final start = plantDragStartLocal;
    final end = plantDragCurrentLocal;

    if (cropName == null || start == null || end == null) {
      _cancelPlantDrag();
      return;
    }

    _addCropFromLocalPoints(
      cropName: cropName,
      startLocal: start,
      endLocal: end,
    );

    setState(() {
      plantDragStartLocal = null;
      plantDragCurrentLocal = null;
    });

    widget.onPlantPlaced?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$cropName planted in ${widget.bed.name}.')),
    );
  }

  void _cancelPlantDrag() {
    setState(() {
      plantDragStartLocal = null;
      plantDragCurrentLocal = null;
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
      return;
    }

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

  Offset _localToGarden(Offset local) {
    return Offset(
      widget.bed.x + local.dx / widget.pixelsPerMeter,
      widget.bed.y + local.dy / widget.pixelsPerMeter,
    );
  }

  void _onMovePanStart(DragStartDetails details) {
    widget.controller.selectBed(widget.bed.id);
    setState(() {
      moving = true;
      dragOffsetPixels = Offset.zero;
    });
  }

  void _onMovePanUpdate(DragUpdateDetails details) {
    if (!moving) return;

    setState(() {
      dragOffsetPixels += details.delta;
    });
  }

  void _onMovePanEnd(DragEndDetails details) {
    if (!moving) return;

    final nextX = widget.bed.x + dragOffsetPixels.dx / widget.pixelsPerMeter;
    final nextY = widget.bed.y + dragOffsetPixels.dy / widget.pixelsPerMeter;

    setState(() {
      moving = false;
      dragOffsetPixels = Offset.zero;
    });

    widget.controller.setBedPosition(
      widget.bed.id,
      x: nextX,
      y: nextY,
      snap: true,
    );
  }

  void _onMovePanCancel() {
    setState(() {
      moving = false;
      dragOffsetPixels = Offset.zero;
    });
  }

  void _onResizePanStart(DragStartDetails details) {
    widget.controller.selectBed(widget.bed.id);
    setState(() {
      resizing = true;
      resizeOffsetPixels = Offset.zero;
    });
  }

  void _onResizePanUpdate(DragUpdateDetails details) {
    if (!resizing) return;

    setState(() {
      resizeOffsetPixels += details.delta;
    });
  }

  void _onResizePanEnd(DragEndDetails details) {
    if (!resizing) return;

    final nextWidth =
        widget.bed.width + resizeOffsetPixels.dx / widget.pixelsPerMeter;
    final nextHeight =
        widget.bed.height + resizeOffsetPixels.dy / widget.pixelsPerMeter;

    setState(() {
      resizing = false;
      resizeOffsetPixels = Offset.zero;
    });

    widget.controller.resizeBed(
      widget.bed.id,
      width: nextWidth,
      height: nextHeight,
      snap: true,
    );
  }

  void _onResizePanCancel() {
    setState(() {
      resizing = false;
      resizeOffsetPixels = Offset.zero;
    });
  }

  double _visualWidthPixels() {
    final minWidthPixels = widget.pixelsPerMeter;
    final rawWidth =
        widget.bed.width * widget.pixelsPerMeter + resizeOffsetPixels.dx;

    return rawWidth < minWidthPixels ? minWidthPixels : rawWidth;
  }

  double _visualHeightPixels() {
    final minHeightPixels = widget.pixelsPerMeter;
    final rawHeight =
        widget.bed.height * widget.pixelsPerMeter + resizeOffsetPixels.dy;

    return rawHeight < minHeightPixels ? minHeightPixels : rawHeight;
  }

  double _visualWidthMeters() => _visualWidthPixels() / widget.pixelsPerMeter;

  double _visualHeightMeters() => _visualHeightPixels() / widget.pixelsPerMeter;
}

class _SimpleRaisedBedSurface extends StatelessWidget {
  const _SimpleRaisedBedSurface({
    required this.bed,
    required this.selected,
    required this.overlapping,
    required this.widthMeters,
    required this.heightMeters,
    required this.showLabels,
    required this.planting,
  });

  final Bed bed;
  final bool selected;
  final bool overlapping;
  final double widthMeters;
  final double heightMeters;
  final bool showLabels;
  final bool planting;

  @override
  Widget build(BuildContext context) {
    final accent = overlapping
        ? GardenTheme.bad
        : planting || selected
        ? const Color(0xFF1F8A54)
        : const Color(0xFF8B5A2B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB77A43), Color(0xFF8C5629), Color(0xFF6E3F1F)],
        ),
        border: Border.all(
          color: accent,
          width: selected || planting ? 3 : 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: selected || planting ? 0.22 : 0.08),
            blurRadius: selected || planting ? 22 : 10,
            spreadRadius: selected || planting ? 2 : 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4C3325), Color(0xFF60402B), Color(0xFF3B281F)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomPaint(painter: _PlantingSurfacePainter()),
                ),
              ),
              if (showLabels)
                Positioned(
                  left: 9,
                  top: 9,
                  right: selected ? 82 : 9,
                  child: _BedHeader(
                    bed: bed,
                    widthMeters: widthMeters,
                    heightMeters: heightMeters,
                    overlapping: overlapping,
                  ),
                ),
              if (selected && !planting && !overlapping)
                const Positioned(
                  left: 9,
                  bottom: 9,
                  child: _BedStatusBadge(
                    icon: Icons.check_circle,
                    label: 'Selected',
                    color: Color(0xFF1F8A54),
                  ),
                ),
              if (overlapping)
                const Positioned(
                  left: 9,
                  bottom: 9,
                  child: _BedStatusBadge(
                    icon: Icons.warning_amber_rounded,
                    label: 'Overlap',
                    color: GardenTheme.bad,
                  ),
                ),
              if (planting)
                const Positioned(
                  left: 9,
                  bottom: 9,
                  child: _ModeBadge(
                    icon: Icons.local_florist,
                    label: 'Tap or drag to plant',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BedHeader extends StatelessWidget {
  const _BedHeader({
    required this.bed,
    required this.widthMeters,
    required this.heightMeters,
    required this.overlapping,
  });

  final Bed bed;
  final double widthMeters;
  final double heightMeters;
  final bool overlapping;

  @override
  Widget build(BuildContext context) {
    final badgeColor = overlapping ? GardenTheme.bad : const Color(0xFF1F8A54);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            bed.number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.93),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4D8C9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bed.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.8,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF211B16),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widthMeters.toStringAsFixed(1)}m x ${heightMeters.toStringAsFixed(1)}m',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8.8,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6E655C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BedStatusBadge extends StatelessWidget {
  const _BedStatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovePill extends StatelessWidget {
  const _MovePill({
    required this.active,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onPanCancel,
  });

  final bool active;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final VoidCallback onPanCancel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF238B55) : const Color(0xE62A241E),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.open_with_rounded, size: 13, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'Move',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResizeKnob extends StatelessWidget {
  const _ResizeKnob({
    required this.active,
    required this.warning,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onPanCancel,
  });

  final bool active;
  final bool warning;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final VoidCallback onPanCancel;

  @override
  Widget build(BuildContext context) {
    final fill = warning
        ? GardenTheme.bad
        : active
        ? const Color(0xFF238B55)
        : const Color(0xE62A241E);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1.25),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.open_in_full_rounded,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE62A241E),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantDragPreviewPainter extends CustomPainter {
  const _PlantDragPreviewPainter({required this.start, required this.current});

  final Offset start;
  final Offset current;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GardenTheme.good.withValues(alpha: 0.85)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, current, paint);

    final dot = Paint()..color = GardenTheme.good.withValues(alpha: 0.95);

    canvas.drawCircle(start, 5, dot);
    canvas.drawCircle(current, 5, dot);
  }

  @override
  bool shouldRepaint(covariant _PlantDragPreviewPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.current != current;
  }
}

class _PlantingSurfacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rowPaint = Paint()
      ..color = const Color(0x24E8D8BE)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final finePaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 0.65
      ..strokeCap = StrokeCap.round;

    for (double y = 20; y <= size.height; y += 22) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 50) {
        path.quadraticBezierTo(x + 20, y + 4, x + 50, y);
      }
      canvas.drawPath(path, rowPaint);
    }

    for (double y = 10; y <= size.height; y += 11) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 2), finePaint);
    }

    final speck = Paint()..color = const Color(0x18FFFFFF);
    for (double x = 8; x < size.width; x += 21) {
      for (double y = 11; y < size.height; y += 19) {
        final offset = ((x + y) % 13) / 13;
        canvas.drawCircle(Offset(x + offset * 5, y), 0.8, speck);
      }
    }

    final shade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x18FFFFFF), Color(0x00000000), Color(0x22000000)],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, shade);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
