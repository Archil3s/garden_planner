import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/crop_spacing.dart';

class CropPatternPainter extends CustomPainter {
  const CropPatternPainter({
    required this.crops,
    required this.widthMeters,
    required this.heightMeters,
    this.maxDots = 90,
  });

  final List<String> crops;
  final double widthMeters;
  final double heightMeters;
  final int maxDots;

  @override
  void paint(Canvas canvas, Size size) {
    final cleanCrops = crops
        .map((crop) => crop.trim())
        .where((crop) => crop.isNotEmpty)
        .toList();

    if (cleanCrops.isEmpty) return;
    if (widthMeters <= 0 || heightMeters <= 0) return;
    if (size.width <= 0 || size.height <= 0) return;

    final cropBandHeightPixels = size.height / cleanCrops.length;
    final cropBandHeightMeters = heightMeters / cleanCrops.length;

    for (var cropIndex = 0; cropIndex < cleanCrops.length; cropIndex++) {
      final crop = cleanCrops[cropIndex];
      final spacingMeters = CropSpacing.spacingMetersForCrop(crop);

      _paintCropBand(
        canvas: canvas,
        crop: crop,
        cropIndex: cropIndex,
        bandTopPixels: cropBandHeightPixels * cropIndex,
        bandHeightPixels: cropBandHeightPixels,
        bandHeightMeters: cropBandHeightMeters,
        spacingMeters: spacingMeters,
        size: size,
        maxDotsForCrop: math.max(12, maxDots ~/ cleanCrops.length),
      );
    }
  }

  void _paintCropBand({
    required Canvas canvas,
    required String crop,
    required int cropIndex,
    required double bandTopPixels,
    required double bandHeightPixels,
    required double bandHeightMeters,
    required double spacingMeters,
    required Size size,
    required int maxDotsForCrop,
  }) {
    if (spacingMeters <= 0) return;

    final pixelsPerMeterX = size.width / widthMeters;
    final pixelsPerMeterY = bandHeightPixels / bandHeightMeters;

    final spacingPixelsX = spacingMeters * pixelsPerMeterX;
    final spacingPixelsY = spacingMeters * pixelsPerMeterY;

    if (spacingPixelsX <= 0 || spacingPixelsY <= 0) return;

    final columns = math.max(1, (widthMeters / spacingMeters).floor());
    final rows = math.max(1, (bandHeightMeters / spacingMeters).floor());
    final totalDots = columns * rows;

    final skip = math.max(1, math.sqrt(totalDots / maxDotsForCrop).ceil());

    final color = _cropColor(crop, cropIndex);

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.26)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final dotRadius = _dotRadius(spacingPixelsX, spacingPixelsY);

    for (var row = 0; row < rows; row += skip) {
      for (var column = 0; column < columns; column += skip) {
        final x = (column + 0.5) * spacingPixelsX;
        final y = bandTopPixels + (row + 0.5) * spacingPixelsY;

        if (x < 0 || x > size.width) continue;
        if (y < bandTopPixels || y > bandTopPixels + bandHeightPixels) {
          continue;
        }

        canvas.drawCircle(Offset(x, y), dotRadius, fillPaint);
        canvas.drawCircle(Offset(x, y), dotRadius, strokePaint);
      }
    }
  }

  double _dotRadius(double spacingPixelsX, double spacingPixelsY) {
    final spacing = math.min(spacingPixelsX, spacingPixelsY);

    if (spacing < 7) return 1.8;
    if (spacing < 12) return 2.2;
    if (spacing < 18) return 2.7;

    return 3.2;
  }

  Color _cropColor(String cropName, int index) {
    final crop = cropName.toLowerCase();

    if (crop.contains('strawberry')) return const Color(0xFF2E8B57);
    if (crop.contains('raspberry')) return const Color(0xFFB56A13);
    if (crop.contains('blueberry')) return const Color(0xFF5D5AD6);

    if (crop.contains('broccoli')) return const Color(0xFF207C4A);
    if (crop.contains('lettuce')) return const Color(0xFF4E9B50);
    if (crop.contains('spinach')) return const Color(0xFF2F7D32);
    if (crop.contains('kale')) return const Color(0xFF326B37);

    if (crop.contains('tomato')) return const Color(0xFFC94F3D);
    if (crop.contains('pepper')) return const Color(0xFFD17A22);
    if (crop.contains('cucumber')) return const Color(0xFF4B9B72);

    if (crop.contains('carrot')) return const Color(0xFFE08A24);
    if (crop.contains('radish')) return const Color(0xFFD95C75);
    if (crop.contains('beet')) return const Color(0xFF8E3A59);
    if (crop.contains('onion')) return const Color(0xFF9A8F6A);
    if (crop.contains('garlic')) return const Color(0xFF8E876E);

    if (crop.contains('basil')) return const Color(0xFF338A4B);
    if (crop.contains('parsley')) return const Color(0xFF4B8F39);
    if (crop.contains('cilantro')) return const Color(0xFF4C9B55);
    if (crop.contains('thyme')) return const Color(0xFF6E8F55);
    if (crop.contains('mint')) return const Color(0xFF3E9B7A);

    const colors = [
      Color(0xFF2E8B57),
      Color(0xFFB56A13),
      Color(0xFF5D5AD6),
      Color(0xFF207C4A),
    ];

    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CropPatternPainter oldDelegate) {
    return oldDelegate.crops.join('|') != crops.join('|') ||
        oldDelegate.widthMeters != widthMeters ||
        oldDelegate.heightMeters != heightMeters ||
        oldDelegate.maxDots != maxDots;
  }
}
