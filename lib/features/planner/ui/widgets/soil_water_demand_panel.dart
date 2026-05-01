import 'package:flutter/material.dart';

import '../../../../core/models/seed_catalog.dart';

class SoilWaterDemandPanel extends StatefulWidget {
  const SoilWaterDemandPanel({super.key, this.onQuickSowSeedKey});

  final ValueChanged<String>? onQuickSowSeedKey;
  static const String buildMarker = 'bed-fertility-panel-20260426_071553';

  static const double surfaceTemp = 10.9;
  static const double rootZoneTemp = 8.4;
  static const double deepTemp = 8.9;

  static const double eto = 1.8;
  static const double tempMax = 18.0;
  static const double tempMin = 6.1;
  static const int humidity = 83;
  static const int wind = 8;
  static const int solar = 150;

  static String formatC(double value) => '${value.toStringAsFixed(1)}\u00B0C';

  @override
  State<SoilWaterDemandPanel> createState() => _SoilWaterDemandPanelState();
}

class _SoilWaterDemandPanelState extends State<SoilWaterDemandPanel> {
  String? expandedGroup;
  String? detailCropKey;

  @override
  Widget build(BuildContext context) {
    final isLowWaterDemand = SoilWaterDemandPanel.eto < 2.5;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8D0C0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeader(
            isLowWaterDemand: isLowWaterDemand,
            buildMarker: SoilWaterDemandPanel.buildMarker,
          ),
          const Divider(height: 1, color: Color(0xFFD8D0C0)),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;

              if (wide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildSoilSide()),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Color(0xFFD8D0C0),
                      ),
                      const Expanded(child: _WaterSide()),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  _buildSoilSide(),
                  const Divider(height: 1, color: Color(0xFFD8D0C0)),
                  const _WaterSide(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoilSide() {
    final groups = <_QuickSowGroup>[
      _QuickSowGroup.tooCold(
        keyName: 'fruiting',
        label: 'Fruiting crops',
        neededMoreC: 6.6,
        cropKeys: const [
          'tomato',
          'capsicum',
          'chilli',
          'eggplant',
          'cucumber',
          'zucchini',
          'pumpkin',
          'squash',
          'melon',
          'sweetcorn',
          'okra',
          'tomatillo',
        ],
      ),
      _QuickSowGroup.tooCold(
        keyName: 'legumes',
        label: 'Legumes',
        neededMoreC: 3.6,
        cropKeys: const [
          'beans',
          'dwarf_beans',
          'runner_beans',
          'peas',
          'snow_peas',
          'sugar_snap_peas',
          'broad_beans',
        ],
      ),
      _QuickSowGroup.tooCold(
        keyName: 'herbs',
        label: 'Herbs',
        neededMoreC: 3.6,
        cropKeys: const [
          'basil',
          'coriander',
          'parsley',
          'dill',
          'chives',
          'thyme',
          'oregano',
          'sage',
          'rosemary',
          'mint',
          'chervil',
          'fennel',
        ],
      ),
      _QuickSowGroup.ready(
        keyName: 'leafy',
        label: 'Leaf & greens',
        thresholdC: 8,
        cropKeys: const [
          'lettuce',
          'spinach',
          'silverbeet',
          'rocket',
          'pak_choi',
          'bok_choy',
          'mizuna',
          'tatsoi',
          'endive',
          'chicory',
          'radicchio',
          'mustard_greens',
          'collards',
          'watercress',
          'cress',
          'corn_salad',
          'celery',
        ],
      ),
      _QuickSowGroup.ready(
        keyName: 'root',
        label: 'Root veg',
        thresholdC: 8,
        cropKeys: const [
          'carrot',
          'beetroot',
          'radish',
          'turnip',
          'parsnip',
          'swede',
          'rutabaga',
          'salsify',
          'scorzonera',
          'celeriac',
          'potato',
          'kumara',
          'sweet_potato',
          'yacon',
        ],
      ),
      _QuickSowGroup.ready(
        keyName: 'brassica',
        label: 'Brassicas',
        thresholdC: 7,
        cropKeys: const [
          'broccoli',
          'cabbage',
          'kale',
          'cauliflower',
          'kohlrabi',
          'brussels_sprouts',
          'bok_choy',
          'cavolo_nero',
          'chinese_cabbage',
          'gai_lan',
          'mustard_greens',
        ],
      ),
      _QuickSowGroup.ready(
        keyName: 'allium',
        label: 'Alliums',
        thresholdC: 7,
        cropKeys: const [
          'onion',
          'spring_onion',
          'leek',
          'shallot',
          'chives',
          'garlic',
        ],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.eco,
            title: 'Soil temperature',
            color: Color(0xFF227A47),
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TempCard(
                  label: 'Surface',
                  value: SoilWaterDemandPanel.surfaceTemp,
                  depth: '0 cm',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _TempCard(
                  label: 'Root zone',
                  value: SoilWaterDemandPanel.rootZoneTemp,
                  depth: '6 cm',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _TempCard(
                  label: 'Deep',
                  value: SoilWaterDemandPanel.deepTemp,
                  depth: '18 cm',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionTitle(
            icon: Icons.spa,
            title: 'Germination windows now',
            color: Color(0xFF227A47),
          ),
          const SizedBox(height: 5),
          const Text(
            'Blenheim rule: soil warmth checks germination. Season fit checks the local sowing window and whether harvest lands in a realistic window.',
            style: TextStyle(
              color: Color(0xFF757068),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          for (final group in groups) ...[
            _groupTile(group),
            if (expandedGroup == group.keyName && group.ready)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        for (final cropKey in group.cropKeys)
                          _CropChoiceChip(
                            crop: SeedCatalog.byKey(cropKey),
                            onAdd: widget.onQuickSowSeedKey == null
                                ? null
                                : () => widget.onQuickSowSeedKey!(cropKey),
                            onExplain: () {
                              setState(() {
                                detailCropKey = detailCropKey == cropKey
                                    ? null
                                    : cropKey;
                              });
                            },
                            detailOpen: detailCropKey == cropKey,
                          ),
                      ],
                    ),
                    if (detailCropKey != null &&
                        group.cropKeys.contains(detailCropKey))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _RecommendationDetailCard(
                          crop: SeedCatalog.byKey(detailCropKey!),
                          onClose: () {
                            setState(() {
                              detailCropKey = null;
                            });
                          },
                          onAddVariety: widget.onQuickSowSeedKey == null
                              ? null
                              : (variety) => widget.onQuickSowSeedKey!(
                                  '${detailCropKey!}::$variety',
                                ),
                          onAdd: widget.onQuickSowSeedKey == null
                              ? null
                              : () => widget.onQuickSowSeedKey!(detailCropKey!),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _groupTile(_QuickSowGroup group) {
    final isExpanded = expandedGroup == group.keyName;

    final background = group.ready
        ? const Color(0xFFE6F5EC)
        : const Color(0xFFFDECEF);
    final border = group.ready
        ? const Color(0xFFB8DDC8)
        : const Color(0xFFF4B8C8);
    final foreground = group.ready
        ? const Color(0xFF227A47)
        : const Color(0xFFA6261A);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            group.ready ? Icons.check_circle : Icons.close,
            color: foreground,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 5,
            child: Text(
              group.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              group.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (group.ready && widget.onQuickSowSeedKey != null) ...[
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  expandedGroup = isExpanded ? null : group.keyName;
                  detailCropKey = null;
                });
              },
              icon: Icon(isExpanded ? Icons.expand_less : Icons.add, size: 15),
              label: Text(isExpanded ? 'Hide' : 'Choose'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B1A17),
                foregroundColor: const Color(0xFFF5F0E8),
                minimumSize: const Size(92, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickSowGroup {
  const _QuickSowGroup({
    required this.keyName,
    required this.label,
    required this.detail,
    required this.ready,
    required this.cropKeys,
  });

  factory _QuickSowGroup.ready({
    required String keyName,
    required String label,
    required int thresholdC,
    required List<String> cropKeys,
  }) {
    return _QuickSowGroup(
      keyName: keyName,
      label: label,
      detail: 'Ready - soil 8.4\u00B0C >= $thresholdC\u00B0C',
      ready: true,
      cropKeys: cropKeys,
    );
  }

  factory _QuickSowGroup.tooCold({
    required String keyName,
    required String label,
    required double neededMoreC,
    required List<String> cropKeys,
  }) {
    return _QuickSowGroup(
      keyName: keyName,
      label: label,
      detail: 'Too cold - need ${neededMoreC.toStringAsFixed(1)}\u00B0C more',
      ready: false,
      cropKeys: cropKeys,
    );
  }

  final String keyName;
  final String label;
  final String detail;
  final bool ready;
  final List<String> cropKeys;
}

enum _SeasonFit { good, tight, wait, tooLate }

class _BlenheimSeasonRule {
  const _BlenheimSeasonRule({
    required this.label,
    required this.sowStartMonth,
    required this.sowStartDay,
    required this.sowEndMonth,
    required this.sowEndDay,
    required this.harvestStartMonth,
    required this.harvestStartDay,
    required this.harvestEndMonth,
    required this.harvestEndDay,
    required this.note,
    this.allowOverwinter = false,
  });

  final String label;
  final int sowStartMonth;
  final int sowStartDay;
  final int sowEndMonth;
  final int sowEndDay;
  final int harvestStartMonth;
  final int harvestStartDay;
  final int harvestEndMonth;
  final int harvestEndDay;
  final String note;
  final bool allowOverwinter;

  DateTime sowStartFor(DateTime today) {
    return _dateNearToday(
      today,
      sowStartMonth,
      sowStartDay,
      sowEndMonth,
      sowEndDay,
    ).start;
  }

  DateTime sowEndFor(DateTime today) {
    return _dateNearToday(
      today,
      sowStartMonth,
      sowStartDay,
      sowEndMonth,
      sowEndDay,
    ).end;
  }

  DateTime harvestStartAfter(DateTime sowDate) {
    var start = DateTime(sowDate.year, harvestStartMonth, harvestStartDay);
    var end = DateTime(sowDate.year, harvestEndMonth, harvestEndDay);

    if (end.isBefore(start)) {
      end = DateTime(end.year + 1, end.month, end.day);
    }

    while (end.isBefore(sowDate)) {
      start = DateTime(start.year + 1, start.month, start.day);
      end = DateTime(end.year + 1, end.month, end.day);
    }

    return start;
  }

  DateTime harvestEndAfter(DateTime sowDate) {
    var start = DateTime(sowDate.year, harvestStartMonth, harvestStartDay);
    var end = DateTime(sowDate.year, harvestEndMonth, harvestEndDay);

    if (end.isBefore(start)) {
      end = DateTime(end.year + 1, end.month, end.day);
    }

    while (end.isBefore(sowDate)) {
      start = DateTime(start.year + 1, start.month, start.day);
      end = DateTime(end.year + 1, end.month, end.day);
    }

    return end;
  }

  static _Window _dateNearToday(
    DateTime today,
    int startMonth,
    int startDay,
    int endMonth,
    int endDay,
  ) {
    var start = DateTime(today.year, startMonth, startDay);
    var end = DateTime(today.year, endMonth, endDay);

    if (end.isBefore(start)) {
      end = DateTime(end.year + 1, end.month, end.day);
    }

    if (today.isAfter(end)) {
      start = DateTime(start.year + 1, start.month, start.day);
      end = DateTime(end.year + 1, end.month, end.day);
    }

    return _Window(start: start, end: end);
  }
}

class _Window {
  const _Window({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class _CropChoiceChip extends StatelessWidget {
  const _CropChoiceChip({
    required this.crop,
    required this.onAdd,
    required this.onExplain,
    required this.detailOpen,
  });

  final SeedCatalogItem crop;
  final VoidCallback? onAdd;
  final VoidCallback onExplain;
  final bool detailOpen;

  @override
  Widget build(BuildContext context) {
    final fit = RecommendationModel.seasonFit(crop);
    final fitColor = RecommendationModel.seasonFitColor(fit);
    final fitLabel = RecommendationModel.seasonFitLabel(fit);
    final method = RecommendationModel.plantingActionFor(crop);
    final rule = RecommendationModel.ruleFor(crop);
    final daysNeeded = RecommendationModel.daysNeeded(crop);
    final harvestText = RecommendationModel.harvestText(crop);
    final enabled =
        onAdd != null && fit != _SeasonFit.wait && fit != _SeasonFit.tooLate;

    return Material(
      color: RecommendationModel.seasonFitBackground(fit),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onExplain,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: enabled ? 1 : 0.72,
          child: Container(
            constraints: const BoxConstraints(minWidth: 210, maxWidth: 278),
            padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: detailOpen ? fitColor : fitColor.withValues(alpha: 0.38),
                width: detailOpen ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CropIconBadge(crop: crop, color: fitColor),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.cropName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1B1A17),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$method - $fitLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fitColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${rule.label} - ${daysNeeded}d - $harvestText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF757068),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Why this recommendation?',
                      onPressed: onExplain,
                      icon: Icon(detailOpen ? Icons.info : Icons.info_outline),
                      color: fitColor,
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                    IconButton(
                      tooltip: enabled ? 'Add crop' : 'Not recommended now',
                      onPressed: enabled ? onAdd : null,
                      icon: Icon(enabled ? Icons.add_circle : Icons.block),
                      color: enabled ? fitColor : const Color(0xFF9D968E),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantingInstructions {
  const _PlantingInstructions({
    required this.depth,
    required this.spacing,
    required this.rows,
    required this.note,
  });

  final String depth;
  final String spacing;
  final String rows;
  final String note;
}

class _PlantingInstructionBlock extends StatelessWidget {
  const _PlantingInstructionBlock({required this.instructions});

  final _PlantingInstructions instructions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8D8BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.straighten_outlined,
                color: Color(0xFFA86412),
                size: 16,
              ),
              SizedBox(width: 7),
              Text(
                'Planting instructions',
                style: TextStyle(
                  color: Color(0xFF1B1A17),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InstructionTile(
                label: 'Depth',
                value: instructions.depth,
                icon: Icons.vertical_align_bottom,
              ),
              _InstructionTile(
                label: 'Spacing',
                value: instructions.spacing,
                icon: Icons.open_in_full,
              ),
              _InstructionTile(
                label: 'Rows',
                value: instructions.rows,
                icon: Icons.table_rows_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.notes_outlined,
                color: Color(0xFF757068),
                size: 16,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  instructions.note,
                  style: const TextStyle(
                    color: Color(0xFF1B1A17),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionTile extends StatelessWidget {
  const _InstructionTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D8BE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFA86412), size: 15),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF757068),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1B1A17),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VarietyChoiceBlock extends StatelessWidget {
  const _VarietyChoiceBlock({required this.crop, required this.onAddVariety});

  final SeedCatalogItem crop;
  final ValueChanged<String>? onAddVariety;

  @override
  Widget build(BuildContext context) {
    final varieties = crop.varieties;

    if (varieties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCFC8F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_florist_outlined,
                color: Color(0xFF5F53C7),
                size: 16,
              ),
              SizedBox(width: 7),
              Text(
                'Varieties',
                style: TextStyle(
                  color: Color(0xFF1B1A17),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final variety in varieties)
                ActionChip(
                  onPressed: onAddVariety == null
                      ? null
                      : () => onAddVariety!(variety),
                  avatar: Text(
                    crop.emoji,
                    style: const TextStyle(fontSize: 15),
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFCFC8F3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  label: Text(
                    variety,
                    style: const TextStyle(
                      color: Color(0xFF1B1A17),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap a variety to add it directly to the Seedling Tracker.',
            style: TextStyle(
              color: Color(0xFF757068),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvironmentalRiskBlock extends StatelessWidget {
  const _EnvironmentalRiskBlock({required this.crop});

  final SeedCatalogItem crop;

  @override
  Widget build(BuildContext context) {
    final transplantRisk = _transplantRiskFor(crop);
    final diseaseRisk = _diseaseRiskFor(crop);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      child: Column(
        children: [
          _RiskCard(
            icon: Icons.move_down_outlined,
            title: 'Transplant risk',
            level: transplantRisk.level,
            color: transplantRisk.color,
            why: transplantRisk.why,
            advice: transplantRisk.advice,
            watchTitle: null,
            watchItems: const [],
          ),
          const SizedBox(height: 10),
          _RiskCard(
            icon: Icons.biotech_outlined,
            title: 'Disease risk',
            level: diseaseRisk.level,
            color: diseaseRisk.color,
            why: diseaseRisk.why,
            advice: diseaseRisk.advice,
            watchTitle: 'Watch for',
            watchItems: diseaseRisk.watchItems,
          ),
        ],
      ),
    );
  }

  static _TransplantRiskData _transplantRiskFor(SeedCatalogItem crop) {
    final cropText = '${crop.key} ${crop.cropName} ${crop.category}'
        .toLowerCase();

    final isTender =
        cropText.contains('tomato') ||
        cropText.contains('capsicum') ||
        cropText.contains('chilli') ||
        cropText.contains('eggplant') ||
        cropText.contains('cucumber') ||
        cropText.contains('zucchini') ||
        cropText.contains('pumpkin') ||
        cropText.contains('melon') ||
        cropText.contains('beans');

    if (isTender) {
      return const _TransplantRiskData(
        level: 'High',
        color: Color(0xFFA6261A),
        why: [
          'overnight low is near the frost-sensitive range',
          'tender warm-season seedlings are vulnerable to cold stress',
          'weather is marginal for transplanting',
        ],
        advice: 'Wait for warmer nights before transplanting.',
        watchItems: [],
      );
    }

    return const _TransplantRiskData(
      level: 'Medium',
      color: Color(0xFFA86412),
      why: [
        'overnight low is near frost range',
        'seedling may be ready but weather is marginal',
        'wind exposure can increase transplant stress',
      ],
      advice:
          'Transplant tomorrow morning if conditions are calmer; water in gently.',
      watchItems: [],
    );
  }

  static _DiseaseRiskData _diseaseRiskFor(SeedCatalogItem crop) {
    final cropText = '${crop.key} ${crop.cropName} ${crop.category}'
        .toLowerCase();

    final dampingOffCrops =
        cropText.contains('leaf') ||
        cropText.contains('lettuce') ||
        cropText.contains('spinach') ||
        cropText.contains('brassica') ||
        cropText.contains('broccoli') ||
        cropText.contains('cabbage') ||
        cropText.contains('cauliflower') ||
        cropText.contains('tray');

    if (SoilWaterDemandPanel.humidity >= 80 || dampingOffCrops) {
      return const _DiseaseRiskData(
        level: 'High humidity period',
        color: Color(0xFFA86412),
        why: [
          'humidity is high enough to favour fungal pressure',
          'dense seedlings and still air increase damping-off risk',
        ],
        watchItems: ['mildew', 'damping off', 'fungal leaf spots'],
        advice: 'Avoid overhead watering. Increase spacing. Vent trays.',
      );
    }

    return const _DiseaseRiskData(
      level: 'Low',
      color: Color(0xFF227A47),
      why: ['current humidity is not in the highest risk band'],
      watchItems: ['early leaf spots', 'poor airflow'],
      advice: 'Water at soil level and keep seedlings spaced.',
    );
  }
}

class _TransplantRiskData {
  const _TransplantRiskData({
    required this.level,
    required this.color,
    required this.why,
    required this.advice,
    required this.watchItems,
  });

  final String level;
  final Color color;
  final List<String> why;
  final String advice;
  final List<String> watchItems;
}

class _DiseaseRiskData {
  const _DiseaseRiskData({
    required this.level,
    required this.color,
    required this.why,
    required this.watchItems,
    required this.advice,
  });

  final String level;
  final Color color;
  final List<String> why;
  final List<String> watchItems;
  final String advice;
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({
    required this.icon,
    required this.title,
    required this.level,
    required this.color,
    required this.why,
    required this.advice,
    required this.watchTitle,
    required this.watchItems,
  });

  final IconData icon;
  final String title;
  final String level;
  final Color color;
  final List<String> why;
  final String advice;
  final String? watchTitle;
  final List<String> watchItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1B1A17),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Why',
            style: TextStyle(
              color: Color(0xFF757068),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in why) _RiskBullet(text: item, color: color),
          if (watchTitle != null && watchItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              watchTitle!,
              style: const TextStyle(
                color: Color(0xFF757068),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            for (final item in watchItems)
              _RiskBullet(text: item, color: color),
          ],
          const SizedBox(height: 8),
          Text(
            'Advice',
            style: const TextStyle(
              color: Color(0xFF757068),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            advice,
            style: const TextStyle(
              color: Color(0xFF1B1A17),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBullet extends StatelessWidget {
  const _RiskBullet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '- ',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1B1A17),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationDetailCard extends StatelessWidget {
  const _RecommendationDetailCard({
    required this.crop,
    required this.onClose,
    required this.onAdd,
    required this.onAddVariety,
  });

  final SeedCatalogItem crop;
  final VoidCallback onClose;
  final VoidCallback? onAdd;
  final ValueChanged<String>? onAddVariety;

  @override
  Widget build(BuildContext context) {
    final fit = RecommendationModel.seasonFit(crop);
    final fitColor = RecommendationModel.seasonFitColor(fit);
    final fitLabel = RecommendationModel.seasonFitLabel(fit);
    final method = RecommendationModel.plantingActionFor(crop);
    final rule = RecommendationModel.ruleFor(crop);
    final daysNeeded = RecommendationModel.daysNeeded(crop);
    final harvestText = RecommendationModel.harvestText(crop);
    final enabled =
        onAdd != null && fit != _SeasonFit.wait && fit != _SeasonFit.tooLate;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 760),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fitColor.withValues(alpha: 0.32)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CropIconBadge(crop: crop, color: fitColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${crop.cropName} in Blenheim',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1B1A17),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close explanation',
                onPressed: onClose,
                icon: const Icon(Icons.close),
                color: const Color(0xFF757068),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _EvidencePill(
                label: fitLabel,
                color: fitColor,
                icon: fit == _SeasonFit.good
                    ? Icons.check_circle
                    : fit == _SeasonFit.tight
                    ? Icons.warning_amber_rounded
                    : fit == _SeasonFit.wait
                    ? Icons.schedule
                    : Icons.block,
              ),
              _EvidencePill(
                label: method,
                color: const Color(0xFF1B1A17),
                icon: Icons.grass_outlined,
              ),
              _EvidencePill(
                label: rule.label,
                color: const Color(0xFF5F53C7),
                icon: Icons.calendar_month_outlined,
              ),
              _EvidencePill(
                label: harvestText,
                color: const Color(0xFFA86412),
                icon: Icons.event_available_outlined,
              ),
            ],
          ),
          const SizedBox(height: 13),
          _DetailLine(
            icon: Icons.thermostat_outlined,
            label: 'Soil check',
            value:
                'Root-zone soil is ${SoilWaterDemandPanel.formatC(SoilWaterDemandPanel.rootZoneTemp)}. This panel separates germination warmth from regional timing.',
          ),
          _DetailLine(
            icon: Icons.map_outlined,
            label: 'Regional window',
            value: '${rule.label}. ${rule.note}',
          ),
          _DetailLine(
            icon: Icons.timelapse_outlined,
            label: 'Crop timing',
            value:
                '$daysNeeded days estimated crop time; expected harvest window is $harvestText.',
          ),
          _DetailLine(
            icon: Icons.construction_outlined,
            label: 'Method',
            value: RecommendationModel.methodExplanation(method),
          ),
          _PlantingInstructionBlock(
            instructions: RecommendationModel.plantingInstructionsFor(crop),
          ),
          _EnvironmentalRiskBlock(crop: crop),
          _VarietyChoiceBlock(crop: crop, onAddVariety: onAddVariety),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  RecommendationModel.recommendationSentence(crop),
                  style: TextStyle(
                    color: fitColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: enabled ? onAdd : null,
                icon: const Icon(Icons.add),
                label: Text(method),
                style: FilledButton.styleFrom(
                  backgroundColor: fitColor,
                  foregroundColor: const Color(0xFFF5F0E8),
                  disabledBackgroundColor: const Color(0xFFD8D0C0),
                  disabledForegroundColor: const Color(0xFF757068),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecommendationModel {
  static _PlantingInstructions plantingInstructionsFor(SeedCatalogItem crop) {
    final key = crop.key.trim().toLowerCase();
    final name = crop.cropName.trim().toLowerCase();
    final category = crop.category.trim().toLowerCase();
    final text = '$key $name $category';

    if (text.contains('garlic')) {
      return const _PlantingInstructions(
        depth: '5 cm',
        spacing: '10-15 cm',
        rows: '20-30 cm',
        note:
            'Plant individual cloves point-up into firm, free-draining soil. Mulch lightly after planting and keep the bed weed-free through winter.',
      );
    }

    if (text.contains('potato') && !text.contains('sweet')) {
      return const _PlantingInstructions(
        depth: '10-15 cm',
        spacing: '30-40 cm',
        rows: '60-75 cm',
        note:
            'Plant seed tubers with shoots facing up. Hill soil around stems as plants grow to protect developing tubers.',
      );
    }

    if (text.contains('kumara') ||
        text.contains('sweet_potato') ||
        text.contains('sweet potato')) {
      return const _PlantingInstructions(
        depth: '5-10 cm',
        spacing: '30-40 cm',
        rows: '75-90 cm',
        note:
            'Plant rooted slips only after the warm-season window begins. Bury the lower stem and keep watered until established.',
      );
    }

    if (text.contains('yacon')) {
      return const _PlantingInstructions(
        depth: '5-8 cm',
        spacing: '75-100 cm',
        rows: '100 cm',
        note:
            'Plant crowns or divisions, not seed. Give each plant generous space because mature plants become large.',
      );
    }

    if (text.contains('carrot')) {
      return const _PlantingInstructions(
        depth: '5-10 mm',
        spacing: 'thin to 3-5 cm',
        rows: '20 cm',
        note:
            'Direct sow only. Keep the seedbed evenly moist until germination and avoid transplanting because roots fork easily.',
      );
    }

    if (text.contains('beetroot')) {
      return const _PlantingInstructions(
        depth: '10-15 mm',
        spacing: 'thin to 8-10 cm',
        rows: '25-30 cm',
        note:
            'Sow direct or transplant very young. Each seed cluster can produce several seedlings, so thin early.',
      );
    }

    if (text.contains('radish')) {
      return const _PlantingInstructions(
        depth: '10 mm',
        spacing: '3-5 cm',
        rows: '15-20 cm',
        note:
            'Direct sow in short succession rows. Keep evenly moist for crisp roots.',
      );
    }

    if (text.contains('turnip') ||
        text.contains('swede') ||
        text.contains('rutabaga')) {
      return const _PlantingInstructions(
        depth: '10-15 mm',
        spacing: '10-20 cm',
        rows: '30 cm',
        note:
            'Direct sow or transplant young seedlings. Thin early to prevent crowded roots.',
      );
    }

    if (text.contains('parsnip') ||
        text.contains('salsify') ||
        text.contains('scorzonera')) {
      return const _PlantingInstructions(
        depth: '10-15 mm',
        spacing: '8-12 cm',
        rows: '30 cm',
        note:
            'Direct sow into deep loose soil. Use fresh seed where possible and keep the row damp until emergence.',
      );
    }

    if (text.contains('broccoli')) {
      return const _PlantingInstructions(
        depth: '5 mm',
        spacing: '45-60 cm',
        rows: '60 cm',
        note:
            'Start in trays, then transplant sturdy seedlings before they become root-bound. Firm soil around transplants.',
      );
    }

    if (text.contains('cabbage') || text.contains('cauliflower')) {
      return const _PlantingInstructions(
        depth: '5 mm',
        spacing: '45-60 cm',
        rows: '60 cm',
        note:
            'Start in trays and transplant stocky seedlings. Keep growth steady to avoid stress and poor heads.',
      );
    }

    if (text.contains('kale') ||
        text.contains('collards') ||
        text.contains('cavolo')) {
      return const _PlantingInstructions(
        depth: '5 mm',
        spacing: '35-50 cm',
        rows: '50-60 cm',
        note:
            'Start in trays or sow direct. Transplant before seedlings are crowded.',
      );
    }

    if (text.contains('lettuce')) {
      return const _PlantingInstructions(
        depth: '3-5 mm',
        spacing: '20-30 cm',
        rows: '25-30 cm',
        note:
            'Sow shallowly. Start in trays for easier spacing or direct sow small succession rows.',
      );
    }

    if (text.contains('spinach') || text.contains('silverbeet')) {
      return const _PlantingInstructions(
        depth: '10-15 mm',
        spacing: '20-30 cm',
        rows: '30 cm',
        note:
            'Sow direct or in modules. Keep evenly watered to reduce bolting stress.',
      );
    }

    if (text.contains('rocket') ||
        text.contains('mizuna') ||
        text.contains('tatsoi') ||
        text.contains('mustard') ||
        text.contains('cress')) {
      return const _PlantingInstructions(
        depth: '3-5 mm',
        spacing: '5-15 cm',
        rows: '15-25 cm',
        note:
            'Fast leafy crops suit short succession rows. Harvest baby leaves early for best quality.',
      );
    }

    if (text.contains('onion') || text.contains('shallot')) {
      return const _PlantingInstructions(
        depth: '5-10 mm',
        spacing: '8-12 cm',
        rows: '25-30 cm',
        note:
            'Start in trays or sow direct in fine soil. Transplant when seedlings are sturdy but still pencil-thin.',
      );
    }

    if (text.contains('leek')) {
      return const _PlantingInstructions(
        depth: '5-10 mm',
        spacing: '15-20 cm',
        rows: '30-40 cm',
        note:
            'Start in trays, then transplant into deeper holes when seedlings are pencil-thick for longer white stems.',
      );
    }

    if (text.contains('beans')) {
      return const _PlantingInstructions(
        depth: '25-40 mm',
        spacing: '10-20 cm',
        rows: '45-60 cm',
        note:
            'Direct sow into warm soil. Provide climbing support for runner or climbing beans.',
      );
    }

    if (text.contains('peas')) {
      return const _PlantingInstructions(
        depth: '25-40 mm',
        spacing: '5-10 cm',
        rows: '45-60 cm',
        note:
            'Direct sow or transplant very young. Provide support for taller pea varieties.',
      );
    }

    if (text.contains('tomato') ||
        text.contains('capsicum') ||
        text.contains('chilli') ||
        text.contains('eggplant')) {
      return const _PlantingInstructions(
        depth: '5 mm',
        spacing: '45-60 cm',
        rows: '60-90 cm',
        note:
            'Start in trays with warmth. Transplant only after nights and soil are reliably warm.',
      );
    }

    if (text.contains('cucumber') ||
        text.contains('zucchini') ||
        text.contains('pumpkin') ||
        text.contains('squash') ||
        text.contains('melon')) {
      return const _PlantingInstructions(
        depth: '15-25 mm',
        spacing: '60-100 cm',
        rows: '100-150 cm',
        note:
            'Sow direct into warm soil or start in large cells. Avoid root disturbance when transplanting.',
      );
    }

    if (text.contains('corn') || text.contains('sweetcorn')) {
      return const _PlantingInstructions(
        depth: '20-30 mm',
        spacing: '20-30 cm',
        rows: '60-75 cm',
        note:
            'Direct sow in blocks rather than single rows for better pollination.',
      );
    }

    if (category.contains('herb')) {
      return const _PlantingInstructions(
        depth: 'surface to 5 mm',
        spacing: '15-30 cm',
        rows: '20-30 cm',
        note:
            'Most herbs are small-seeded. Sow shallowly and keep the surface lightly moist until germination.',
      );
    }

    return const _PlantingInstructions(
      depth: '5-10 mm',
      spacing: 'check variety',
      rows: 'check variety',
      note:
          'Use the seed packet as the final authority for variety-specific depth and spacing.',
    );
  }

  static String plantingActionFor(SeedCatalogItem crop) {
    final key = crop.key.trim().toLowerCase();
    final name = crop.cropName.trim().toLowerCase();
    final text = '$key $name';

    if (text.contains('garlic')) return 'Plant cloves';
    if (text.contains('potato') && !text.contains('sweet')) {
      return 'Plant tubers';
    }
    if (text.contains('kumara') ||
        text.contains('sweet_potato') ||
        text.contains('sweet potato')) {
      return 'Plant slips';
    }
    if (text.contains('yacon')) return 'Plant crowns';

    if (text.contains('carrot') ||
        text.contains('beet') ||
        text.contains('radish') ||
        text.contains('turnip') ||
        text.contains('parsnip') ||
        text.contains('swede') ||
        text.contains('rutabaga') ||
        text.contains('salsify') ||
        text.contains('scorzonera') ||
        text.contains('beans') ||
        text.contains('peas') ||
        text.contains('corn')) {
      return 'Direct sow';
    }

    if (text.contains('lettuce') ||
        text.contains('spinach') ||
        text.contains('silverbeet') ||
        text.contains('rocket') ||
        text.contains('mizuna') ||
        text.contains('tatsoi') ||
        text.contains('endive') ||
        text.contains('pak') ||
        text.contains('bok')) {
      return 'Direct or tray';
    }

    return 'Start tray';
  }

  static String methodExplanation(String method) {
    switch (method) {
      case 'Plant cloves':
        return 'Place individual cloves directly into the bed; this is not a seedling-tray crop.';
      case 'Plant tubers':
        return 'Plant seed tubers directly into prepared soil once the regional window is right.';
      case 'Plant slips':
        return 'Use rooted slips rather than seed; wait for the warm-season planting window.';
      case 'Plant crowns':
        return 'Plant crowns or divisions rather than seed; wait for the warm-season planting window.';
      case 'Direct sow':
        return 'Sow directly into the bed because transplanting can disturb roots or because the crop establishes well in place.';
      case 'Direct or tray':
        return 'Either sow direct or start in trays, depending on bed space, pest pressure, and weather protection.';
      default:
        return 'Start in a tray, then transplant once seedlings are sturdy and conditions are suitable.';
    }
  }

  static int daysNeeded(SeedCatalogItem crop) {
    if (crop.key == 'garlic') return 230;
    if (crop.key == 'yacon') return 210;

    final harvestDays = crop.harvestDaysFromTransplant;
    if (harvestDays <= 0) return 70;
    return harvestDays;
  }

  static _BlenheimSeasonRule ruleFor(SeedCatalogItem crop) {
    final key = crop.key.toLowerCase();
    final category = crop.category.toLowerCase();

    if (key == 'garlic') {
      return const _BlenheimSeasonRule(
        label: 'plant Apr-Jun',
        sowStartMonth: 4,
        sowStartDay: 1,
        sowEndMonth: 6,
        sowEndDay: 30,
        harvestStartMonth: 12,
        harvestStartDay: 1,
        harvestEndMonth: 1,
        harvestEndDay: 31,
        allowOverwinter: true,
        note:
            'Garlic is an overwintering allium in Blenheim; autumn to early winter planting is realistic.',
      );
    }

    if (key == 'potato') {
      return const _BlenheimSeasonRule(
        label: 'plant Aug-Dec',
        sowStartMonth: 8,
        sowStartDay: 1,
        sowEndMonth: 12,
        sowEndDay: 15,
        harvestStartMonth: 11,
        harvestStartDay: 1,
        harvestEndMonth: 4,
        harvestEndDay: 30,
        note:
            'Potatoes are usually better held until late winter or spring in this model.',
      );
    }

    if (key == 'kumara' || key == 'sweet_potato' || key == 'yacon') {
      return const _BlenheimSeasonRule(
        label: 'plant Oct-Dec',
        sowStartMonth: 10,
        sowStartDay: 1,
        sowEndMonth: 12,
        sowEndDay: 31,
        harvestStartMonth: 3,
        harvestStartDay: 1,
        harvestEndMonth: 5,
        harvestEndDay: 31,
        note:
            'Warm-season tuber crop; soil warmth alone is not enough in April.',
      );
    }

    if (category.contains('root')) {
      return const _BlenheimSeasonRule(
        label: 'sow Feb-May',
        sowStartMonth: 2,
        sowStartDay: 1,
        sowEndMonth: 5,
        sowEndDay: 31,
        harvestStartMonth: 5,
        harvestStartDay: 1,
        harvestEndMonth: 9,
        harvestEndDay: 30,
        note: 'Cool-season root crop window for autumn into winter harvest.',
      );
    }

    if (category.contains('allium')) {
      return const _BlenheimSeasonRule(
        label: 'sow Mar-Jul',
        sowStartMonth: 3,
        sowStartDay: 1,
        sowEndMonth: 7,
        sowEndDay: 31,
        harvestStartMonth: 8,
        harvestStartDay: 1,
        harvestEndMonth: 1,
        harvestEndDay: 31,
        allowOverwinter: true,
        note: 'Cool-season allium window.',
      );
    }

    if (category.contains('brassica') || category.contains('leaf')) {
      return const _BlenheimSeasonRule(
        label: 'sow Feb-May',
        sowStartMonth: 2,
        sowStartDay: 1,
        sowEndMonth: 5,
        sowEndDay: 31,
        harvestStartMonth: 4,
        harvestStartDay: 1,
        harvestEndMonth: 9,
        harvestEndDay: 30,
        note: 'Autumn brassica and leafy-green window.',
      );
    }

    if (category.contains('legume')) {
      return const _BlenheimSeasonRule(
        label: 'sow Sep-Dec',
        sowStartMonth: 9,
        sowStartDay: 1,
        sowEndMonth: 12,
        sowEndDay: 31,
        harvestStartMonth: 11,
        harvestStartDay: 1,
        harvestEndMonth: 4,
        harvestEndDay: 30,
        note: 'Warm-soil legume window.',
      );
    }

    if (category.contains('fruiting') || category.contains('cucurbit')) {
      return const _BlenheimSeasonRule(
        label: 'sow Sep-Dec',
        sowStartMonth: 9,
        sowStartDay: 1,
        sowEndMonth: 12,
        sowEndDay: 31,
        harvestStartMonth: 12,
        harvestStartDay: 1,
        harvestEndMonth: 4,
        harvestEndDay: 30,
        note: 'Warm-season crop window.',
      );
    }

    return const _BlenheimSeasonRule(
      label: 'sow Mar-May',
      sowStartMonth: 3,
      sowStartDay: 1,
      sowEndMonth: 5,
      sowEndDay: 31,
      harvestStartMonth: 5,
      harvestStartDay: 1,
      harvestEndMonth: 9,
      harvestEndDay: 30,
      note: 'Default cool-season vegetable window.',
    );
  }

  static _SeasonFit seasonFit(SeedCatalogItem crop) {
    final todayRaw = DateTime.now();
    final today = DateTime(todayRaw.year, todayRaw.month, todayRaw.day);
    final rule = ruleFor(crop);
    final sowStart = rule.sowStartFor(today);
    final sowEnd = rule.sowEndFor(today);

    if (today.isBefore(sowStart)) return _SeasonFit.wait;
    if (today.isAfter(sowEnd)) return _SeasonFit.tooLate;

    final days = daysNeeded(crop);
    final harvestStart = rule.harvestStartAfter(today);
    final harvestEnd = rule.harvestEndAfter(today);
    final expectedHarvest = today.add(Duration(days: days));

    if (expectedHarvest.isAfter(harvestEnd)) return _SeasonFit.tooLate;

    if (expectedHarvest.isBefore(harvestStart)) {
      return rule.allowOverwinter ? _SeasonFit.good : _SeasonFit.tight;
    }

    final spareDays = harvestEnd.difference(expectedHarvest).inDays;
    if (spareDays >= 21) return _SeasonFit.good;
    return _SeasonFit.tight;
  }

  static String harvestText(SeedCatalogItem crop) {
    final todayRaw = DateTime.now();
    final today = DateTime(todayRaw.year, todayRaw.month, todayRaw.day);
    final rule = ruleFor(crop);
    final start = rule.harvestStartAfter(today);
    final end = rule.harvestEndAfter(today);

    return 'harvest ${_shortMonth(start)}-${_shortMonth(end)}';
  }

  static String recommendationSentence(SeedCatalogItem crop) {
    final fit = seasonFit(crop);
    final method = plantingActionFor(crop);

    switch (fit) {
      case _SeasonFit.good:
        return 'Recommendation: $method now.';
      case _SeasonFit.tight:
        return 'Recommendation: $method soon; timing is workable but not generous.';
      case _SeasonFit.wait:
        return 'Recommendation: wait for the regional planting window.';
      case _SeasonFit.tooLate:
        return 'Recommendation: do not plant now; the local timing window has passed.';
    }
  }

  static String seasonFitLabel(_SeasonFit fit) {
    switch (fit) {
      case _SeasonFit.good:
        return 'Good time';
      case _SeasonFit.tight:
        return 'Tight';
      case _SeasonFit.wait:
        return 'Wait';
      case _SeasonFit.tooLate:
        return 'Too late';
    }
  }

  static Color seasonFitColor(_SeasonFit fit) {
    switch (fit) {
      case _SeasonFit.good:
        return const Color(0xFF227A47);
      case _SeasonFit.tight:
        return const Color(0xFFA86412);
      case _SeasonFit.wait:
        return const Color(0xFF5F53C7);
      case _SeasonFit.tooLate:
        return const Color(0xFFA6261A);
    }
  }

  static Color seasonFitBackground(_SeasonFit fit) {
    switch (fit) {
      case _SeasonFit.good:
        return const Color(0xFFEAF6EE);
      case _SeasonFit.tight:
        return const Color(0xFFFFF5E3);
      case _SeasonFit.wait:
        return const Color(0xFFF2F0FF);
      case _SeasonFit.tooLate:
        return const Color(0xFFFDECEF);
    }
  }

  static String _shortMonth(DateTime date) {
    const months = <int, String>{
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };

    return months[date.month] ?? '${date.month}';
  }
}

class _EvidencePill extends StatelessWidget {
  const _EvidencePill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF757068), size: 16),
          const SizedBox(width: 8),
          SizedBox(
            width: 108,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF757068),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1B1A17),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropIconBadge extends StatelessWidget {
  const _CropIconBadge({required this.crop, required this.color});

  final SeedCatalogItem crop;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(crop.emoji, style: const TextStyle(fontSize: 19)),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.isLowWaterDemand,
    required this.buildMarker,
  });

  final bool isLowWaterDemand;
  final String buildMarker;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          const Icon(
            Icons.thermostat_outlined,
            color: Color(0xFFA86412),
            size: 18,
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Soil temperature & season fit - Blenheim, NZ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF1B1A17),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (isLowWaterDemand)
            const _Badge(
              icon: Icons.water_drop,
              label: 'Low water demand',
              background: Color(0xFFE6F5EC),
              border: Color(0xFFB8DDC8),
              foreground: Color(0xFF227A47),
            ),
          const SizedBox(width: 8),
          Tooltip(
            message: buildMarker,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5F53C7),
                side: const BorderSide(color: Color(0xFFCFC8F3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterSide extends StatelessWidget {
  const _WaterSide();

  @override
  Widget build(BuildContext context) {
    final demandWidth = (SoilWaterDemandPanel.eto / 6).clamp(0.08, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.water_drop,
            title: 'Daily water demand (ET0)',
            color: Color(0xFF227A47),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(height: 10, color: const Color(0xFFE8E0D4)),
                      FractionallySizedBox(
                        widthFactor: demandWidth,
                        child: Container(
                          height: 10,
                          color: const Color(0xFF227A47),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '1.8 mm/day',
                style: TextStyle(
                  color: Color(0xFF227A47),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 26,
            runSpacing: 14,
            children: const [
              _Fact(label: 'Temp max', value: '18.0\u00B0C'),
              _Fact(label: 'Temp min', value: '6.1\u00B0C'),
              _Fact(label: 'Humidity', value: '83%'),
              _Fact(label: 'Wind avg', value: '8 km/h'),
              _Fact(label: 'Solar rad', value: '150 W/m2'),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5EC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB8DDC8)),
            ),
            child: const Text(
              'Low water demand (1.8 mm/day) - beds watered in the last 2-3 days are fine.',
              style: TextStyle(
                color: Color(0xFF16613A),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BedFertilityPanel extends StatelessWidget {
  const _BedFertilityPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8D8BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.eco_outlined, color: Color(0xFFA86412), size: 16),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Bed fertility & compost',
                  style: TextStyle(
                    color: Color(0xFF1B1A17),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _FertilityStatusBadge(label: 'Bed 1'),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FertilityMetric(
                icon: Icons.grass_outlined,
                label: 'Nitrogen demand',
                value: 'High',
              ),
              _FertilityMetric(
                icon: Icons.compost_outlined,
                label: 'Last compost',
                value: '42 days ago',
              ),
              _FertilityMetric(
                icon: Icons.event_note_outlined,
                label: 'Next feed',
                value: 'Due soon',
              ),
            ],
          ),
          SizedBox(height: 12),
          _FertilityReasonBox(),
        ],
      ),
    );
  }
}

class _FertilityMetric extends StatelessWidget {
  const _FertilityMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D8BE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFA86412), size: 15),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF757068),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1B1A17),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FertilityStatusBadge extends StatelessWidget {
  const _FertilityStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFFFFF5E3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Color(0xFFE8D8BE)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFA86412),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FertilityReasonBox extends StatelessWidget {
  const _FertilityReasonBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Color(0xFFFFF5E3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE8D8BE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: Color(0xFFA86412), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Reason: Brassicas are heavy feeders. Add compost or a balanced organic feed before the next heavy-feeding crop.',
              style: TextStyle(
                color: Color(0xFF1B1A17),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF757068),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0CF9D)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF757068),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            SoilWaterDemandPanel.formatC(value),
            style: const TextStyle(
              color: Color(0xFFA86412),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            depth,
            style: const TextStyle(
              color: Color(0xFF757068),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF757068),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1B1A17),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color border;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
