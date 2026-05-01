import 'package:flutter/material.dart';

import '../../../../core/models/crop_placement.dart';
import '../../../../core/theme/garden_theme.dart';
import '../../controller/garden_controller.dart';

class DraggableCropIcon extends StatefulWidget {
  const DraggableCropIcon({
    super.key,
    required this.bedId,
    required this.placement,
    required this.pixelsPerMeter,
    required this.controller,
  });

  final String bedId;
  final CropPlacement placement;
  final double pixelsPerMeter;
  final GardenController controller;

  @override
  State<DraggableCropIcon> createState() => _DraggableCropIconState();
}

class _DraggableCropIconState extends State<DraggableCropIcon> {
  Offset dragOffsetPixels = Offset.zero;
  bool dragging = false;
  int? activePointer;

  static const double iconSize = 28;

  @override
  void didUpdateWidget(covariant DraggableCropIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!dragging) {
      dragOffsetPixels = Offset.zero;
      activePointer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final left =
        widget.placement.x * widget.pixelsPerMeter -
        iconSize / 2 +
        dragOffsetPixels.dx;

    final top =
        widget.placement.y * widget.pixelsPerMeter -
        iconSize / 2 +
        dragOffsetPixels.dy;

    return Positioned(
      left: left,
      top: top,
      width: iconSize,
      height: iconSize,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: AnimatedScale(
          scale: dragging ? 1.16 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              shape: BoxShape.circle,
              border: Border.all(
                color: dragging
                    ? GardenTheme.good
                    : GardenTheme.ink.withValues(alpha: 0.28),
                width: dragging ? 2 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _iconForCrop(widget.placement.cropName),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    activePointer = event.pointer;
    dragging = true;
    dragOffsetPixels = Offset.zero;
    setState(() {});
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (activePointer != event.pointer) return;

    setState(() {
      dragOffsetPixels += event.delta;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (activePointer != event.pointer) return;

    final nextX =
        widget.placement.x + dragOffsetPixels.dx / widget.pixelsPerMeter;
    final nextY =
        widget.placement.y + dragOffsetPixels.dy / widget.pixelsPerMeter;

    setState(() {
      dragging = false;
      activePointer = null;
      dragOffsetPixels = Offset.zero;
    });

    widget.controller.moveCropPlacement(
      bedId: widget.bedId,
      placementId: widget.placement.id,
      x: nextX,
      y: nextY,
    );
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (activePointer != event.pointer) return;

    setState(() {
      dragging = false;
      activePointer = null;
      dragOffsetPixels = Offset.zero;
    });
  }

  String _iconForCrop(String cropName) {
    final crop = cropName.toLowerCase();

    if (crop.contains('strawberry')) return 'Ã°Å¸Ââ€œ';
    if (crop.contains('raspberry')) return 'Ã°Å¸Â«Â';
    if (crop.contains('blueberry')) return 'Ã°Å¸Â«Â';

    if (crop.contains('broccoli')) return 'Ã°Å¸Â¥Â¦';
    if (crop.contains('lettuce')) return 'Ã°Å¸Â¥Â¬';
    if (crop.contains('spinach')) return 'Ã°Å¸Â¥Â¬';
    if (crop.contains('kale')) return 'Ã°Å¸Â¥Â¬';

    if (crop.contains('tomato')) return 'Ã°Å¸Ââ€¦';
    if (crop.contains('pepper')) return 'Ã°Å¸Å’Â¶Ã¯Â¸Â';
    if (crop.contains('cucumber')) return 'Ã°Å¸Â¥â€™';

    if (crop.contains('carrot')) return 'Ã°Å¸Â¥â€¢';
    if (crop.contains('onion')) return 'Ã°Å¸Â§â€¦';
    if (crop.contains('garlic')) return 'Ã°Å¸Â§â€ž';

    if (crop.contains('basil')) return 'Ã°Å¸Å’Â¿';
    if (crop.contains('mint')) return 'Ã°Å¸Å’Â¿';
    if (crop.contains('parsley')) return 'Ã°Å¸Å’Â¿';
    if (crop.contains('thyme')) return 'Ã°Å¸Å’Â¿';

    return 'Ã°Å¸Å’Â±';
  }
}
