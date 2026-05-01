import 'package:flutter/material.dart';

class MapViewControls extends StatelessWidget {
  const MapViewControls({
    super.key,
    required this.gridVisible,
    required this.labelsVisible,
    required this.cropRowsVisible,
    required this.instructionsVisible,
    required this.onFitMap,
    required this.onResetZoom,
    required this.onGridVisibleChanged,
    required this.onLabelsVisibleChanged,
    required this.onCropRowsVisibleChanged,
    required this.onInstructionsVisibleChanged,
  });

  final bool gridVisible;
  final bool labelsVisible;
  final bool cropRowsVisible;
  final bool instructionsVisible;

  final VoidCallback onFitMap;
  final VoidCallback onResetZoom;

  final ValueChanged<bool> onGridVisibleChanged;
  final ValueChanged<bool> onLabelsVisibleChanged;
  final ValueChanged<bool> onCropRowsVisibleChanged;
  final ValueChanged<bool> onInstructionsVisibleChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(18),
      elevation: 6,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD9CDB8)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SmallActionChip(
                icon: Icons.fit_screen,
                label: 'Fit',
                onTap: onFitMap,
              ),
              const SizedBox(width: 8),
              _SmallActionChip(
                icon: Icons.restart_alt,
                label: 'Reset',
                onTap: onResetZoom,
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                icon: Icons.grid_on,
                label: 'Grid',
                value: gridVisible,
                onChanged: onGridVisibleChanged,
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                icon: Icons.label_outline,
                label: 'Labels',
                value: labelsVisible,
                onChanged: onLabelsVisibleChanged,
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                icon: Icons.grass_outlined,
                label: 'Rows',
                value: cropRowsVisible,
                onChanged: onCropRowsVisibleChanged,
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                icon: Icons.info_outline,
                label: 'Help',
                value: instructionsVisible,
                onChanged: onInstructionsVisibleChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallActionChip extends StatelessWidget {
  const _SmallActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 17),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 17),
      label: Text(label),
      selected: value,
      onSelected: onChanged,
    );
  }
}
