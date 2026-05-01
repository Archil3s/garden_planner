import 'package:flutter/material.dart';

import '../../../../core/theme/garden_theme.dart';

class PlannerLegend extends StatelessWidget {
  const PlannerLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: GardenTheme.paper,
        border: Border(top: BorderSide(color: GardenTheme.border)),
      ),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            LegendItem(
              color: GardenTheme.good,
              icon: Icons.check_circle,
              label: 'Healthy',
            ),
            SizedBox(width: 8),
            LegendItem(
              color: GardenTheme.warn,
              icon: Icons.warning_amber_rounded,
              label: 'Needs attention',
            ),
            SizedBox(width: 8),
            LegendItem(
              color: GardenTheme.hold,
              icon: Icons.pause_circle_outline,
              label: 'On hold',
            ),
            SizedBox(width: 8),
            LegendItem(
              color: Color(0xFF1F8A54),
              icon: Icons.crop_square,
              label: 'Selected',
            ),
            SizedBox(width: 8),
            LegendItem(
              color: Color(0xFF8C5629),
              icon: Icons.yard_outlined,
              label: 'Raised beds',
            ),
            SizedBox(width: 8),
            LegendItem(
              color: Color(0xFFA86412),
              icon: Icons.grass_outlined,
              label: 'Crop rows',
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  const LegendItem({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
