import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';
import 'bed_detail_sections.dart';
import 'crop_planning_section.dart';

class BedInspector extends StatelessWidget {
  const BedInspector({
    super.key,
    required this.bed,
    required this.onNameChanged,
    required this.onZoneChanged,
    required this.onWidthChanged,
    required this.onHeightChanged,
    required this.onCropsChanged,
    required this.onRemoveCrop,
    required this.onPlantCrop,
    required this.onPlaceCropRow,
    required this.onStatusChanged,
    required this.onHealthChanged,
    this.width = 340,
    this.borderSide = const BorderSide(color: GardenTheme.border),
  });

  final Bed? bed;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onZoneChanged;
  final ValueChanged<String> onWidthChanged;
  final ValueChanged<String> onHeightChanged;
  final ValueChanged<String> onCropsChanged;
  final ValueChanged<String> onRemoveCrop;
  final ValueChanged<String> onPlantCrop;
  final ValueChanged<String> onPlaceCropRow;
  final ValueChanged<BedStatus> onStatusChanged;
  final ValueChanged<String> onHealthChanged;
  final double? width;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: GardenTheme.panel,
        border: Border(
          left: width == null ? BorderSide.none : borderSide,
          top: width == null ? borderSide : BorderSide.none,
        ),
      ),
      child: bed == null
          ? const EmptyInspector()
          : SelectedBedInspector(
              bed: bed!,
              onNameChanged: onNameChanged,
              onZoneChanged: onZoneChanged,
              onWidthChanged: onWidthChanged,
              onHeightChanged: onHeightChanged,
              onCropsChanged: onCropsChanged,
              onRemoveCrop: onRemoveCrop,
              onPlantCrop: onPlantCrop,
              onPlaceCropRow: onPlaceCropRow,
              onStatusChanged: onStatusChanged,
              onHealthChanged: onHealthChanged,
            ),
    );
  }
}

class EmptyInspector extends StatelessWidget {
  const EmptyInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No bed selected',
            style: TextStyle(
              color: GardenTheme.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select a bed on the canvas to view details.',
            style: TextStyle(
              color: GardenTheme.muted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedBedInspector extends StatefulWidget {
  const SelectedBedInspector({
    super.key,
    required this.bed,
    required this.onNameChanged,
    required this.onZoneChanged,
    required this.onWidthChanged,
    required this.onHeightChanged,
    required this.onCropsChanged,
    required this.onRemoveCrop,
    required this.onPlantCrop,
    required this.onPlaceCropRow,
    required this.onStatusChanged,
    required this.onHealthChanged,
  });

  final Bed bed;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onZoneChanged;
  final ValueChanged<String> onWidthChanged;
  final ValueChanged<String> onHeightChanged;
  final ValueChanged<String> onCropsChanged;
  final ValueChanged<String> onRemoveCrop;
  final ValueChanged<String> onPlantCrop;
  final ValueChanged<String> onPlaceCropRow;
  final ValueChanged<BedStatus> onStatusChanged;
  final ValueChanged<String> onHealthChanged;

  @override
  State<SelectedBedInspector> createState() => _SelectedBedInspectorState();
}

class _SelectedBedInspectorState extends State<SelectedBedInspector> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InspectorHeader(bed: widget.bed),
        _InspectorTabs(
          selectedIndex: selectedTabIndex,
          onChanged: (index) {
            setState(() {
              selectedTabIndex = index;
            });
          },
        ),
        Expanded(
          child: IndexedStack(
            index: selectedTabIndex,
            children: [
              _InspectorTabScroll(
                child: _EditTab(
                  bed: widget.bed,
                  onNameChanged: widget.onNameChanged,
                  onZoneChanged: widget.onZoneChanged,
                  onWidthChanged: widget.onWidthChanged,
                  onHeightChanged: widget.onHeightChanged,
                  onStatusChanged: widget.onStatusChanged,
                  onHealthChanged: widget.onHealthChanged,
                ),
              ),
              _InspectorTabScroll(
                child: _CropsTab(
                  bed: widget.bed,
                  onCropsChanged: widget.onCropsChanged,
                  onRemoveCrop: widget.onRemoveCrop,
                  onPlantCrop: widget.onPlantCrop,
                  onPlaceCropRow: widget.onPlaceCropRow,
                ),
              ),
              _InspectorTabScroll(child: BedDetailSections(bed: widget.bed)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InspectorHeader extends StatelessWidget {
  const _InspectorHeader({required this.bed});

  final Bed bed;

  @override
  Widget build(BuildContext context) {
    final area = bed.width * bed.height;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: const BoxDecoration(
        color: GardenTheme.panel,
        border: Border(bottom: BorderSide(color: GardenTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Bed',
            style: TextStyle(
              color: GardenTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bed.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GardenTheme.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _HeaderChip(label: bed.zone),
              _HeaderChip(label: '${area.toStringAsFixed(0)} m²'),
              _HeaderChip(label: '${bed.crops.length} crops'),
              _HeaderChip(label: '${bed.cropPlacements.length} icons'),
              _HeaderChip(label: '${bed.cropBlocks.length} rows'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: GardenTheme.paper,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: GardenTheme.muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _InspectorTabs extends StatelessWidget {
  const _InspectorTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: GardenTheme.panel,
        border: Border(bottom: BorderSide(color: GardenTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InspectorTabButton(
              label: 'Edit',
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _InspectorTabButton(
              label: 'Crops',
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _InspectorTabButton(
              label: 'Notes',
              selected: selectedIndex == 2,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectorTabButton extends StatelessWidget {
  const _InspectorTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? GardenTheme.ink : Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? GardenTheme.ink : GardenTheme.border,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: selected ? GardenTheme.cream : GardenTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _InspectorTabScroll extends StatelessWidget {
  const _InspectorTabScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _EditTab extends StatelessWidget {
  const _EditTab({
    required this.bed,
    required this.onNameChanged,
    required this.onZoneChanged,
    required this.onWidthChanged,
    required this.onHeightChanged,
    required this.onStatusChanged,
    required this.onHealthChanged,
  });

  final Bed bed;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onZoneChanged;
  final ValueChanged<String> onWidthChanged;
  final ValueChanged<String> onHeightChanged;
  final ValueChanged<BedStatus> onStatusChanged;
  final ValueChanged<String> onHealthChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorTextField(
          key: ValueKey('${bed.id}-name'),
          label: 'Name',
          value: bed.name,
          onChanged: onNameChanged,
        ),
        const SizedBox(height: 10),
        InspectorTextField(
          key: ValueKey('${bed.id}-zone'),
          label: 'Zone',
          value: bed.zone,
          onChanged: onZoneChanged,
        ),
        const SizedBox(height: 14),
        StatusPicker(value: bed.status, onChanged: onStatusChanged),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InspectorTextField(
                key: ValueKey('${bed.id}-width'),
                label: 'Width',
                value: bed.width.toStringAsFixed(1),
                suffix: 'm',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: onWidthChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InspectorTextField(
                key: ValueKey('${bed.id}-height'),
                label: 'Height',
                value: bed.height.toStringAsFixed(1),
                suffix: 'm',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: onHeightChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InspectorTextField(
          key: ValueKey('${bed.id}-health'),
          label: 'Health',
          value: (bed.healthPercent * 100).round().toString(),
          suffix: '%',
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          onChanged: onHealthChanged,
        ),
        const SizedBox(height: 10),
        InspectorReadOnlyFact(
          label: 'Position',
          value: '${bed.x.toStringAsFixed(1)}m, ${bed.y.toStringAsFixed(1)}m',
        ),
      ],
    );
  }
}

class _CropsTab extends StatelessWidget {
  const _CropsTab({
    required this.bed,
    required this.onCropsChanged,
    required this.onRemoveCrop,
    required this.onPlantCrop,
    required this.onPlaceCropRow,
  });

  final Bed bed;
  final ValueChanged<String> onCropsChanged;
  final ValueChanged<String> onRemoveCrop;
  final ValueChanged<String> onPlantCrop;
  final ValueChanged<String> onPlaceCropRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorTextField(
          key: ValueKey('${bed.id}-crops'),
          label: 'Crops',
          value: bed.crops.join(', '),
          hint: 'Example: Tomatoes, Basil',
          maxLines: 2,
          onChanged: onCropsChanged,
        ),
        const SizedBox(height: 14),
        CropPreview(crops: bed.crops),
        const SizedBox(height: 18),
        CropPlanningSection(
          crops: bed.crops,
          cropPlacements: bed.cropPlacements,
          onRemoveCrop: onRemoveCrop,
          onPlantCrop: onPlantCrop,
          onPlaceCropRow: onPlaceCropRow,
        ),
        const SizedBox(height: 18),
        _PlantedCropSummary(bed: bed),
      ],
    );
  }
}

class _PlantedCropSummary extends StatelessWidget {
  const _PlantedCropSummary({required this.bed});

  final Bed bed;

  @override
  Widget build(BuildContext context) {
    if (bed.cropPlacements.isEmpty && bed.cropBlocks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: GardenTheme.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GardenTheme.border),
        ),
        child: const Text(
          'No crop icons or rows placed yet. Use PLACE ICON or PLACE ROW above to add draggable crop elements inside this bed.',
          style: TextStyle(
            color: GardenTheme.muted,
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final groupedIcons = <String, int>{};
    final groupedRows = <String, int>{};

    for (final placement in bed.cropPlacements) {
      final crop = placement.cropName.trim();
      if (crop.isEmpty) continue;
      groupedIcons[crop] = (groupedIcons[crop] ?? 0) + 1;
    }

    for (final block in bed.cropBlocks) {
      final crop = block.cropName.trim();
      if (crop.isEmpty) continue;
      groupedRows[crop] = (groupedRows[crop] ?? 0) + 1;
    }

    final crops = <String>{...groupedIcons.keys, ...groupedRows.keys}.toList()
      ..sort();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GardenTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PLACED CROPS',
            style: TextStyle(
              color: GardenTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          for (final crop in crops) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    crop,
                    style: const TextStyle(
                      color: GardenTheme.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${groupedIcons[crop] ?? 0} icons · ${groupedRows[crop] ?? 0} rows',
                  style: const TextStyle(
                    color: GardenTheme.good,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class InspectorTextField extends StatefulWidget {
  const InspectorTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String value;
  final String? hint;
  final String? suffix;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  State<InspectorTextField> createState() => _InspectorTextFieldState();
}

class _InspectorTextFieldState extends State<InspectorTextField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant InspectorTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value && controller.text != widget.value) {
      controller.text = widget.value;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      style: const TextStyle(
        color: GardenTheme.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: widget.label.toUpperCase(),
        hintText: widget.hint,
        suffixText: widget.suffix,
        labelStyle: const TextStyle(
          color: GardenTheme.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
        hintStyle: const TextStyle(color: GardenTheme.muted, fontSize: 13),
        suffixStyle: const TextStyle(
          color: GardenTheme.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: GardenTheme.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GardenTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GardenTheme.ink, width: 1.4),
        ),
      ),
    );
  }
}

class StatusPicker extends StatelessWidget {
  const StatusPicker({super.key, required this.value, required this.onChanged});

  final BedStatus value;
  final ValueChanged<BedStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        StatusOption(
          label: 'Healthy',
          status: BedStatus.ok,
          selected: value == BedStatus.ok,
          color: GardenTheme.good,
          background: const Color(0xFFEEF8F0),
          onChanged: onChanged,
        ),
        StatusOption(
          label: 'Attention',
          status: BedStatus.warning,
          selected: value == BedStatus.warning,
          color: GardenTheme.warn,
          background: const Color(0xFFFFF4E7),
          onChanged: onChanged,
        ),
        StatusOption(
          label: 'Issue',
          status: BedStatus.bad,
          selected: value == BedStatus.bad,
          color: GardenTheme.bad,
          background: const Color(0xFFFFF0EE),
          onChanged: onChanged,
        ),
        StatusOption(
          label: 'Hold',
          status: BedStatus.hold,
          selected: value == BedStatus.hold,
          color: GardenTheme.hold,
          background: const Color(0xFFF0EDFF),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class StatusOption extends StatelessWidget {
  const StatusOption({
    super.key,
    required this.label,
    required this.status,
    required this.selected,
    required this.color,
    required this.background,
    required this.onChanged,
  });

  final String label;
  final BedStatus status;
  final bool selected;
  final Color color;
  final Color background;
  final ValueChanged<BedStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? background : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => onChanged(status),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.5)
                  : GardenTheme.border,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: selected ? color : GardenTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class InspectorReadOnlyFact extends StatelessWidget {
  const InspectorReadOnlyFact({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GardenTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: GardenTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: GardenTheme.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class CropPreview extends StatelessWidget {
  const CropPreview({super.key, required this.crops});

  final List<String> crops;

  @override
  Widget build(BuildContext context) {
    if (crops.isEmpty) {
      return const Text(
        'No crops assigned.',
        style: TextStyle(color: GardenTheme.muted, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [for (final crop in crops) InspectorChip(label: crop)],
    );
  }
}

class InspectorChip extends StatelessWidget {
  const InspectorChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF8F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GardenTheme.good.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: GardenTheme.good,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
