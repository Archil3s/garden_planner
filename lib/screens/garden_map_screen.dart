import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../models/garden_project.dart';
import '../models/bed.dart';

class GardenMapScreen extends StatefulWidget {
  final GardenProject project;

  const GardenMapScreen({super.key, required this.project});

  @override
  State<GardenMapScreen> createState() => _GardenMapScreenState();
}

class _GardenMapScreenState extends State<GardenMapScreen> {
  List<Bed> beds = [];
  final Set<String> selected = {};

  double scale = 1.0;
  Offset offset = Offset.zero;

  Bed? dragging;
  Bed? resizing;
  String? resizeHandle;

  @override
  void initState() {
    super.initState();

    // GUARANTEED VISIBILITY (prevents empty canvas)
    beds = widget.project.beds.isNotEmpty
        ? List<Bed>.from(widget.project.beds)
        : [
            Bed(
              id: "debug",
              name: "Debug Bed",
              x: 100,
              y: 100,
              width: 200,
              height: 120,
              cropCount: 0,
            ),
          ];
  }

  // ---------------- SAFE WORLD TRANSFORM ----------------
  Offset _world(Offset p) => (p - offset) / scale;

  double _snap(double v) => (v / 20).round() * 20;

  // ---------------- HIT TEST ----------------
  Bed? _hit(Offset p) {
    for (final b in beds) {
      final r = Rect.fromLTWH(b.x, b.y, b.width, b.height);
      if (r.contains(p)) return b;
    }
    return null;
  }

  String? _handleAt(Bed b, Offset p) {
    const s = 12.0;

    final map = {
      "tl": Rect.fromLTWH(b.x - s, b.y - s, s * 2, s * 2),
      "tr": Rect.fromLTWH(b.x + b.width - s, b.y - s, s * 2, s * 2),
      "bl": Rect.fromLTWH(b.x - s, b.y + b.height - s, s * 2, s * 2),
      "br": Rect.fromLTWH(b.x + b.width - s, b.y + b.height - s, s * 2, s * 2),
    };

    for (final e in map.entries) {
      if (e.value.contains(p)) return e.key;
    }
    return null;
  }

  // ---------------- SAFE ZOOM ----------------
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final dy = event.scrollDelta.dy;

      setState(() {
        scale -= dy * 0.001;
        scale = scale.clamp(0.5, 3.0);
      });
    }
  }

  // ---------------- TAP ----------------
  void _onTapDown(TapDownDetails d) {
    final p = _world(d.localPosition);
    final hit = _hit(p);

    setState(() {
      if (hit == null) {
        beds.add(
          Bed(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: "Bed",
            x: _snap(p.dx),
            y: _snap(p.dy),
            width: 140,
            height: 80,
            cropCount: 0,
          ),
        );
      } else {
        selected.contains(hit.id)
            ? selected.remove(hit.id)
            : selected.add(hit.id);
      }
    });
  }

  // ---------------- SAFE DRAG START ----------------
  void _onPanStart(DragStartDetails d) {
    final p = _world(d.localPosition);

    dragging = null;
    resizing = null;
    resizeHandle = null;

    final hit = _hit(p);
    if (hit == null) return;

    final h = _handleAt(hit, p);

    if (h != null) {
      resizing = hit;
      resizeHandle = h;
      return;
    }

    dragging = hit;
  }

  // ---------------- SAFE DRAG UPDATE ----------------
  void _onPanUpdate(DragUpdateDetails d) {
    final Offset raw = d.delta;

    final double dx = (raw.dx.isFinite) ? raw.dx : 0.0;
    final double dy = (raw.dy.isFinite) ? raw.dy : 0.0;

    final Offset delta = Offset(dx, dy) / scale;

    setState(() {
      // CAMERA PAN
      if (dragging == null && resizing == null && selected.isEmpty) {
        offset += Offset(dx, dy);
        return;
      }

      // RESIZE
      if (resizing != null && resizeHandle != null) {
        final b = resizing!;

        switch (resizeHandle) {
          case "br":
            b.width = _snap(b.width + delta.dx);
            b.height = _snap(b.height + delta.dy);
            break;

          case "bl":
            b.x = _snap(b.x + delta.dx);
            b.width = _snap(b.width - delta.dx);
            b.height = _snap(b.height + delta.dy);
            break;

          case "tr":
            b.y = _snap(b.y + delta.dy);
            b.width = _snap(b.width + delta.dx);
            b.height = _snap(b.height - delta.dy);
            break;

          case "tl":
            b.x = _snap(b.x + delta.dx);
            b.y = _snap(b.y + delta.dy);
            b.width = _snap(b.width - delta.dx);
            b.height = _snap(b.height - delta.dy);
            break;
        }

        if (b.width < 40) b.width = 40;
        if (b.height < 40) b.height = 40;
        return;
      }

      // MOVE
      if (selected.isNotEmpty) {
        for (final b in beds) {
          if (selected.contains(b.id)) {
            b.x = _snap(b.x + delta.dx);
            b.y = _snap(b.y + delta.dy);
          }
        }
      } else if (dragging != null) {
        dragging!.x = _snap(dragging!.x + delta.dx);
        dragging!.y = _snap(dragging!.y + delta.dy);
      }
    });
  }

  void _onPanEnd(_) {
    dragging = null;
    resizing = null;
    resizeHandle = null;
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final frame = List<Bed>.from(beds);

    return Scaffold(
      appBar: AppBar(title: Text(widget.project.name)),

      body: SizedBox.expand(
        child: Listener(
          onPointerSignal: _onPointerSignal,

          child: GestureDetector(
            onTapDown: _onTapDown,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,

            child: CustomPaint(
              painter: _Painter(
                beds: frame,
                selected: Set<String>.from(selected),
                scale: scale,
                offset: offset,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final List<Bed> beds;
  final Set<String> selected;
  final double scale;
  final Offset offset;

  _Painter({
    required this.beds,
    required this.selected,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.translate(offset.dx, offset.dy);
    c.scale(scale);

    final bg = Paint()..color = const Color(0xFFE8F5E2);
    c.drawRect(Rect.fromLTWH(-5000, -5000, 10000, 10000), bg);

    final grid = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double x = -5000; x < 5000; x += 20) {
      c.drawLine(Offset(x, -5000), Offset(x, 5000), grid);
    }

    for (double y = -5000; y < 5000; y += 20) {
      c.drawLine(Offset(-5000, y), Offset(5000, y), grid);
    }

    final fill = Paint()..color = const Color(0xFF4CAF50);

    final border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    final selectedBorder = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (final b in beds) {
      final r = Rect.fromLTWH(b.x, b.y, b.width, b.height);

      c.drawRect(r, fill);
      c.drawRect(r, border);

      if (selected.contains(b.id)) {
        c.drawRect(r.inflate(2), selectedBorder);
      }
    }

    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
