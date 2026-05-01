import 'package:flutter/material.dart';

class SoilWaterDemandPanel extends StatelessWidget {
  const SoilWaterDemandPanel({super.key});

  static const double surfaceTemp = 10.9;
  static const double rootZoneTemp = 8.4;
  static const double deepTemp = 8.9;
  static const double eto = 1.8;
  static const double tempMax = 18.0;
  static const double tempMin = 6.1;
  static const int humidity = 83;
  static const int wind = 8;
  static const int solar = 150;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8D0C0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(theme: theme),
          const Divider(height: 1, color: Color(0xFFD8D0C0)),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 820;

              if (wide) {
                return const IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _SoilSection()),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Color(0xFFD8D0C0),
                      ),
                      Expanded(child: _WaterSection()),
                    ],
                  ),
                );
              }

              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SoilSection(),
                  Divider(height: 1, color: Color(0xFFD8D0C0)),
                  _WaterSection(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            '🌡️ Soil temperature & water demand — Budge St',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Badge(text: '💧 Low water demand'),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Using offline fallback weather and soil values.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoilSection extends StatelessWidget {
  const _SoilSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('🌱 Soil temperature'),
          SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TempCard(
                label: 'Surface',
                value: SoilWaterDemandPanel.surfaceTemp,
                depth: '0 cm',
              ),
              _TempCard(
                label: 'Root zone',
                value: SoilWaterDemandPanel.rootZoneTemp,
                depth: '6 cm',
              ),
              _TempCard(
                label: 'Deep',
                value: SoilWaterDemandPanel.deepTemp,
                depth: '18 cm',
              ),
            ],
          ),
          SizedBox(height: 18),
          _SectionTitle('Germination windows now'),
          SizedBox(height: 10),
          _GermFlag(
            icon: '🍅',
            name: 'Fruiting crops',
            status: '❌ Too cold — need 6.6°C more',
            ready: false,
          ),
          _GermFlag(
            icon: '🫘',
            name: 'Legumes',
            status: '❌ Too cold — need 3.6°C more',
            ready: false,
          ),
          _GermFlag(
            icon: '🌿',
            name: 'Herbs',
            status: '❌ Too cold — need 3.6°C more',
            ready: false,
          ),
          _GermFlag(
            icon: '🥬',
            name: 'Leaf & greens',
            status: '✅ Ready — soil 8.4°C ≥ 8°C',
            ready: true,
          ),
          _GermFlag(
            icon: '🥕',
            name: 'Root veg',
            status: '✅ Ready — soil 8.4°C ≥ 8°C',
            ready: true,
          ),
          _GermFlag(
            icon: '🥦',
            name: 'Brassicas',
            status: '✅ Ready — soil 8.4°C ≥ 7°C',
            ready: true,
          ),
          _GermFlag(
            icon: '🧅',
            name: 'Alliums',
            status: '✅ Ready — soil 8.4°C ≥ 7°C',
            ready: true,
          ),
        ],
      ),
    );
  }
}

class _WaterSection extends StatelessWidget {
  const _WaterSection();

  @override
  Widget build(BuildContext context) {
    final fill = (SoilWaterDemandPanel.eto / 6.0).clamp(0.05, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('💧 Daily water demand (ET₀)'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: fill,
                    backgroundColor: const Color(0xFFECE5D9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF227A47),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${SoilWaterDemandPanel.eto.toStringAsFixed(1)} mm/day',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF227A47),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _Fact(label: 'Temp max', value: '18.0°C'),
              _Fact(label: 'Temp min', value: '6.1°C'),
              _Fact(label: 'Humidity', value: '83%'),
              _Fact(label: 'Wind avg', value: '8 km/h'),
              _Fact(label: 'Solar rad', value: '150 W/m²'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF8EF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDCC8)),
            ),
            child: const Text(
              '✅ Low water demand (1.8 mm/day) — beds watered in the last 2–3 days are fine.',
              style: TextStyle(
                color: Color(0xFF1A5C34),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: const Color(0xFF757068),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.7,
      ),
    );
  }
}

class _TempCard extends StatelessWidget {
  const _TempCard({
    required this.label,
    required this.value,
    required this.depth,
  });

  final String label;
  final double value;
  final String depth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0CF9D)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF757068),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${value.toStringAsFixed(1)}°C',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFA86412),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(depth, style: const TextStyle(color: Color(0xFF757068))),
        ],
      ),
    );
  }
}

class _GermFlag extends StatelessWidget {
  const _GermFlag({
    required this.icon,
    required this.name,
    required this.status,
    required this.ready,
  });

  final String icon;
  final String name;
  final String status;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = ready ? const Color(0xFF227A47) : const Color(0xFF9B2C20);
    final bg = ready ? const Color(0xFFEBF8EF) : const Color(0xFFFFF0F3);
    final border = ready ? const Color(0xFFBFDCC8) : const Color(0xFFF4B8C8);

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                name,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              status,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF757068),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF8EF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDCC8)),
      ),
      child: const Text(
        '💧 Low water demand',
        style: TextStyle(color: Color(0xFF227A47), fontWeight: FontWeight.w900),
      ),
    );
  }
}
