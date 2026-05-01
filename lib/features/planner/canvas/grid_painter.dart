import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  const GridPainter({
    double? widthMeters,
    double? heightMeters,
    double? metersWide,
    double? metersHigh,
    required this.pixelsPerMeter,
  }) : widthMeters = widthMeters ?? metersWide ?? 30,
       heightMeters = heightMeters ?? metersHigh ?? 20;

  final double widthMeters;
  final double heightMeters;
  final double pixelsPerMeter;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final backgroundPaint = Paint()..color = const Color(0xFFF4F8EF);

    canvas.drawRect(rect, backgroundPaint);

    final minorStep = pixelsPerMeter / 4;
    final majorStep = pixelsPerMeter;

    final minorPaint = Paint()
      ..color = const Color(0x228EAA87)
      ..strokeWidth = 0.6;

    final majorPaint = Paint()
      ..color = const Color(0x558EAA87)
      ..strokeWidth = 1.0;

    final borderPaint = Paint()
      ..color = const Color(0x778EAA87)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    if (minorStep > 4) {
      for (double x = 0; x <= size.width; x += minorStep) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
      }

      for (double y = 0; y <= size.height; y += minorStep) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), minorPaint);
      }
    }

    for (double x = 0; x <= size.width; x += majorStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
    }

    for (double y = 0; y <= size.height; y += majorStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
    }

    canvas.drawRect(rect.deflate(1), borderPaint);

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (double xMeters = 0; xMeters <= widthMeters; xMeters += 10) {
      final x = xMeters * pixelsPerMeter;

      labelPainter.text = TextSpan(
        text: '${xMeters.toStringAsFixed(0)}m',
        style: const TextStyle(
          color: Color(0xFF899286),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      );

      labelPainter.layout();
      labelPainter.paint(canvas, Offset(x + 4, 4));
    }

    for (double yMeters = 10; yMeters <= heightMeters; yMeters += 10) {
      final y = yMeters * pixelsPerMeter;

      labelPainter.text = TextSpan(
        text: '${yMeters.toStringAsFixed(0)}m',
        style: const TextStyle(
          color: Color(0xFF899286),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      );

      labelPainter.layout();
      labelPainter.paint(canvas, Offset(4, y + 4));
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.widthMeters != widthMeters ||
        oldDelegate.heightMeters != heightMeters ||
        oldDelegate.pixelsPerMeter != pixelsPerMeter;
  }
}
