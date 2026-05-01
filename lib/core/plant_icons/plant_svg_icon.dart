import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'plant_icon_assets.dart';

class PlantSvgIcon extends StatelessWidget {
  const PlantSvgIcon({
    super.key,
    required this.plantName,
    this.size = 32,
    this.fallbackColor,
  });

  final String plantName;
  final double size;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final asset = PlantIconAssets.assetFor(plantName);

    if (asset == null) {
      return Icon(
        Icons.eco_outlined,
        size: size,
        color: fallbackColor ?? const Color(0xFF4A7C3F),
      );
    }

    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class PlantIconBubble extends StatelessWidget {
  const PlantIconBubble({
    super.key,
    required this.plantName,
    this.size = 42,
    this.iconSize = 34,
  });

  final String plantName;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCF7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8CEB8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: PlantSvgIcon(
        plantName: plantName,
        size: iconSize,
        fallbackColor: const Color(0xFF4A7C3F),
      ),
    );
  }
}
