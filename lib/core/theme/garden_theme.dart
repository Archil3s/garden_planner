import 'package:flutter/material.dart';

class GardenTheme {
  static const cream = Color(0xFFF5F0E8);
  static const paper = Color(0xFFFAF8F4);
  static const panel = Color(0xFFFFFDF9);
  static const ink = Color(0xFF1B1A17);
  static const muted = Color(0xFF757068);
  static const border = Color(0xFFD8D0C0);

  static const good = Color(0xFF227A47);
  static const warn = Color(0xFFA86412);
  static const bad = Color(0xFF9B2C20);
  static const hold = Color(0xFF5F53C7);

  static BoxDecoration panelDecoration({double radius = 16}) {
    return BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 28,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration({
    Color background = Colors.white,
    Color borderColor = border,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 18,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
