import 'package:flutter/material.dart';

import '../widgets/soil_water_demand_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4EFE7),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header(context)),
          const SliverToBoxAdapter(child: SoilWaterDemandPanel()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F5EF),
        border: Border(bottom: BorderSide(color: Color(0xFFE0D7C8))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Garden Spray Map',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF17130F),
                  fontFamily: 'serif',
                  fontSize: compact ? 28 : 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'BLENHEIM, NZ - DECISION-FIRST SPRAY PLANNING',
                style: TextStyle(
                  color: Color(0xFF867A6A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
