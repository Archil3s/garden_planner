import 'package:flutter/material.dart';

import '../../../../core/theme/garden_theme.dart';

class PlannerPageHeader extends StatelessWidget {
  const PlannerPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Garden Planner',
                style: TextStyle(
                  color: GardenTheme.ink,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'METER-BASED INTERACTIVE PLANNING CANVAS',
                style: TextStyle(
                  color: GardenTheme.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: GardenTheme.ink,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              _StatusDot(color: GardenTheme.good),
              SizedBox(width: 7),
              Text(
                'PLANNER MODE',
                style: TextStyle(
                  color: GardenTheme.cream,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
