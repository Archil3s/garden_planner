import 'package:flutter/foundation.dart';

class PlantingSelectionBridge {
  const PlantingSelectionBridge._();

  static final ValueNotifier<String?> pendingPlant = ValueNotifier<String?>(
    null,
  );

  static void selectPlant(String cropName) {
    final cleanName = cropName.trim();

    if (cleanName.isEmpty) return;

    pendingPlant.value = cleanName;
  }

  static String? consumePlant() {
    final value = pendingPlant.value;
    pendingPlant.value = null;

    if (value == null || value.trim().isEmpty) return null;

    return value.trim();
  }
}
