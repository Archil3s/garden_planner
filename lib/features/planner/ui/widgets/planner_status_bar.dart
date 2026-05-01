import 'package:flutter/material.dart';

import '../../../../core/models/bed.dart';
import '../../../../core/theme/garden_theme.dart';

class PlannerStatusBar extends StatelessWidget {
  const PlannerStatusBar({
    super.key,
    required this.visibleBedCount,
    required this.totalBedCount,
    required this.zoomPercent,
    required this.selectedBed,
    required this.searchQuery,
    required this.filterLabel,
    required this.onClearSearch,
  });

  final int visibleBedCount;
  final int totalBedCount;
  final int zoomPercent;
  final Bed? selectedBed;
  final String searchQuery;
  final String filterLabel;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final hasSearch = searchQuery.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: GardenTheme.paper,
        border: Border(top: BorderSide(color: GardenTheme.border)),
      ),
      child: Row(
        children: [
          _StatusItem(
            icon: Icons.layers_outlined,
            label: '$visibleBedCount / $totalBedCount beds',
          ),
          const SizedBox(width: 12),
          _StatusItem(icon: Icons.visibility_outlined, label: '$zoomPercent%'),
          const SizedBox(width: 12),
          _StatusItem(icon: Icons.filter_list, label: filterLabel),
          const SizedBox(width: 12),
          Expanded(
            child: _StatusItem(
              icon: selectedBed == null
                  ? Icons.ads_click
                  : Icons.crop_square_outlined,
              label: selectedBed == null
                  ? 'No bed selected'
                  : 'Selected: ${selectedBed!.name.trim().isEmpty ? 'Bed ${selectedBed!.number}' : selectedBed!.name.trim()}',
              overflow: true,
            ),
          ),
          if (hasSearch) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onClearSearch,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: GardenTheme.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.close, color: GardenTheme.muted, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Clear search',
                        style: TextStyle(
                          color: GardenTheme.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.label,
    this.overflow = false,
  });

  final IconData icon;
  final String label;
  final bool overflow;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: overflow ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, color: GardenTheme.muted, size: 14),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GardenTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );

    return overflow ? row : IntrinsicWidth(child: row);
  }
}
