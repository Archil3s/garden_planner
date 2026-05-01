import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'generated_plant_svgs.dart';

class GeneratedPlantIcon extends StatelessWidget {
  const GeneratedPlantIcon({
    super.key,
    required this.cropName,
    this.size = 24,
  });

  final String cropName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final key = _iconKeyForCrop(cropName);
    final svg = generatedPlantSvgs[key];

    if (svg == null) {
      return Icon(
        Icons.local_florist,
        size: size,
      );
    }

    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  String _iconKeyForCrop(String value) {
    final name = value.trim().toLowerCase();

    final exact = name
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (generatedPlantSvgs.containsKey(exact)) return exact;

    for (final key in generatedPlantSvgs.keys) {
      final normalizedKey = key.replaceAll('_', ' ');

      if (name == normalizedKey ||
          name.contains(normalizedKey) ||
          normalizedKey.contains(name)) {
        return key;
      }
    }

    return exact;
  }
}