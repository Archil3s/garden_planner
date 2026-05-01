class CropSpacing {
  const CropSpacing._();

  static double spacingMetersForCrop(String cropName) {
    final crop = cropName.trim().toLowerCase();

    // Fruit trees / large permanent plants.
    if (crop.contains('apricot') && crop.contains('dwarf')) return 3.5;
    if (crop.contains('apple') && crop.contains('dwarf')) return 3.0;
    if (crop.contains('almond') && crop.contains('dwarf')) return 4.0;

    if (crop.contains('apricot')) return 6.0;
    if (crop.contains('apple')) return 6.0;
    if (crop.contains('almond')) return 6.0;
    if (crop.contains('pear')) return 6.0;
    if (crop.contains('plum')) return 5.0;
    if (crop.contains('peach')) return 5.0;
    if (crop.contains('citrus')) return 4.0;

    // Cane fruit / berries / permanent crops.
    if (crop.contains('raspberry')) return 0.70;
    if (crop.contains('blackberry')) return 1.20;
    if (crop.contains('blueberry')) return 1.20;
    if (crop.contains('strawberry')) return 0.35;
    if (crop.contains('asparagus')) return 0.45;
    if (crop.contains('artichoke')) return 1.00;

    // Larger vegetables.
    if (crop.contains('pumpkin')) return 1.50;
    if (crop.contains('watermelon')) return 1.20;
    if (crop.contains('zucchini')) return 0.90;
    if (crop.contains('cucumber')) return 0.45;
    if (crop.contains('tomato')) return 0.60;
    if (crop.contains('eggplant')) return 0.60;
    if (crop.contains('capsicum')) return 0.45;
    if (crop.contains('pepper')) return 0.45;
    if (crop.contains('chilli')) return 0.40;
    if (crop.contains('sweet corn')) return 0.30;
    if (crop.contains('corn')) return 0.30;

    // Brassicas.
    if (crop.contains('broccoli')) return 0.60;
    if (crop.contains('cauliflower')) return 0.60;
    if (crop.contains('cabbage')) return 0.50;
    if (crop.contains('kale')) return 0.45;
    if (crop.contains('brussels')) return 0.70;

    // Roots / alliums.
    if (crop.contains('potato')) return 0.35;
    if (crop.contains('carrot')) return 0.08;
    if (crop.contains('radish')) return 0.05;
    if (crop.contains('beetroot')) return 0.10;
    if (crop.contains('beet')) return 0.10;
    if (crop.contains('onion')) return 0.10;
    if (crop.contains('garlic')) return 0.12;
    if (crop.contains('leek')) return 0.15;

    // Leafy crops.
    if (crop.contains('lettuce')) return 0.25;
    if (crop.contains('spinach')) return 0.15;
    if (crop.contains('silverbeet')) return 0.30;
    if (crop.contains('chard')) return 0.30;

    // Legumes.
    if (crop.contains('bean')) return 0.20;
    if (crop.contains('pea')) return 0.08;

    // Herbs.
    if (crop.contains('basil')) return 0.25;
    if (crop.contains('parsley')) return 0.20;
    if (crop.contains('cilantro')) return 0.15;
    if (crop.contains('coriander')) return 0.15;
    if (crop.contains('thyme')) return 0.25;
    if (crop.contains('mint')) return 0.30;
    if (crop.contains('rosemary')) return 0.60;
    if (crop.contains('sage')) return 0.45;

    // Ornamentals / flowers currently in picker.
    if (crop.contains('agastache')) return 0.45;
    if (crop.contains('ageratum')) return 0.25;
    if (crop.contains('allium')) return 0.20;
    if (crop.contains('alyssum')) return 0.20;
    if (crop.contains('amaranth')) return 0.35;

    return 0.30;
  }

  static bool isLargeCanopyCrop(String cropName) {
    final crop = cropName.trim().toLowerCase();

    return crop.contains('tree') ||
        crop.contains('almond') ||
        crop.contains('apple') ||
        crop.contains('apricot') ||
        crop.contains('pear') ||
        crop.contains('plum') ||
        crop.contains('peach') ||
        crop.contains('citrus') ||
        crop.contains('blueberry') ||
        crop.contains('artichoke');
  }

  static String spacingLabelForCrop(String cropName) {
    final spacing = spacingMetersForCrop(cropName);

    if (spacing >= 1) {
      return '${spacing.toStringAsFixed(spacing >= 3 ? 0 : 1)}m spacing';
    }

    final centimeters = (spacing * 100).round();
    return '${centimeters}cm spacing';
  }

  static int estimatedPlantCount({
    required String cropName,
    required double widthMeters,
    required double heightMeters,
  }) {
    final spacing = spacingMetersForCrop(cropName);

    if (widthMeters <= 0 || heightMeters <= 0 || spacing <= 0) {
      return 0;
    }

    final longerSide = widthMeters >= heightMeters ? widthMeters : heightMeters;
    final shorterSide = widthMeters >= heightMeters
        ? heightMeters
        : widthMeters;

    // Large plants are placed by canopy spacing, not by dense row multiplication.
    if (isLargeCanopyCrop(cropName)) {
      return (longerSide / spacing).floor().clamp(1, 999);
    }

    // A narrow dragged crop block should behave like a single row.
    if (shorterSide < spacing * 1.6) {
      return (longerSide / spacing).floor().clamp(1, 999);
    }

    final columns = (widthMeters / spacing).floor();
    final rows = (heightMeters / spacing).floor();

    return (columns * rows).clamp(1, 999);
  }

  double realisticSpacingMetersForCrop(String cropName) {
    final name = cropName.trim().toLowerCase();

    // Fruiting crops
    if (name.contains('chilli') || name.contains('chili')) return 0.45;
    if (name.contains('pepper') || name.contains('capsicum')) return 0.45;
    if (name.contains('tomato')) return 0.60;
    if (name.contains('eggplant') || name.contains('aubergine')) return 0.60;
    if (name.contains('cucumber')) return 0.45;
    if (name.contains('courgette') || name.contains('zucchini')) return 0.75;
    if (name.contains('pumpkin') || name.contains('squash')) return 1.20;
    if (name.contains('melon') || name.contains('watermelon')) return 1.00;

    // Berries and perennial fruit
    if (name.contains('strawberry')) return 0.30;
    if (name.contains('raspberry')) return 0.45;
    if (name.contains('blueberry')) return 1.00;
    if (name.contains('berry')) return 0.45;

    // Leaf crops
    if (name.contains('lettuce')) return 0.25;
    if (name.contains('spinach')) return 0.15;
    if (name.contains('silverbeet') || name.contains('chard')) return 0.30;
    if (name.contains('kale')) return 0.45;
    if (name.contains('chicory')) return 0.30;
    if (name.contains('rocket') || name.contains('arugula')) return 0.10;
    if (name.contains('mustard')) return 0.20;

    // Brassicas
    if (name.contains('broccoli')) return 0.45;
    if (name.contains('cauliflower')) return 0.55;
    if (name.contains('cabbage')) return 0.45;
    if (name.contains('brussels')) return 0.60;
    if (name.contains('brassica')) return 0.45;

    // Roots and tubers
    if (name.contains('carrot')) return 0.05;
    if (name.contains('radish')) return 0.05;
    if (name.contains('beetroot') || name.contains('beet')) return 0.10;
    if (name.contains('turnip')) return 0.10;
    if (name.contains('parsnip')) return 0.10;
    if (name.contains('swede') || name.contains('rutabaga')) return 0.25;
    if (name.contains('potato')) return 0.30;
    if (name.contains('kumara') || name.contains('sweet potato')) return 0.40;
    if (name.contains('yacon')) return 0.75;

    // Alliums
    if (name.contains('garlic')) return 0.15;
    if (name.contains('onion')) return 0.10;
    if (name.contains('shallot')) return 0.15;
    if (name.contains('leek')) return 0.15;
    if (name.contains('spring onion') || name.contains('scallion')) return 0.05;
    if (name.contains('allium')) return 0.15;

    // Legumes
    if (name.contains('pea')) return 0.08;
    if (name.contains('bean')) return 0.15;
    if (name.contains('broad bean')) return 0.20;
    if (name.contains('legume')) return 0.15;

    // Herbs
    if (name.contains('basil')) return 0.25;
    if (name.contains('parsley')) return 0.20;
    if (name.contains('coriander') || name.contains('cilantro')) return 0.15;
    if (name.contains('mint')) return 0.30;
    if (name.contains('thyme')) return 0.25;
    if (name.contains('oregano')) return 0.25;
    if (name.contains('sage')) return 0.45;
    if (name.contains('rosemary')) return 0.60;
    if (name.contains('agastache')) return 0.30;

    // Fallback to existing spacing table.
    return CropSpacing.spacingMetersForCrop(cropName);
  }

  String realisticSpacingLabelForCrop(String cropName) {
    final spacing = realisticSpacingMetersForCrop(cropName);

    if (spacing < 1.0) {
      return '${(spacing * 100).round()}cm spacing';
    }

    return '${spacing.toStringAsFixed(1)}m spacing';
  }
}
