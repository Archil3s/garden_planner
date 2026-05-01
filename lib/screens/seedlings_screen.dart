import 'package:flutter/material.dart';

class SeedlingsScreen extends StatefulWidget {
  const SeedlingsScreen({super.key});

  @override
  State<SeedlingsScreen> createState() => _SeedlingsScreenState();
}

class _SeedlingsScreenState extends State<SeedlingsScreen> {
  final List<_Seedling> seedlings = [
    _Seedling(
      crop: 'Broccoli',
      type: 'Brassica',
      bed: 'Standard Bed 3',
      stage: _SeedlingStage.growing,
      sownDate: DateTime.now().subtract(const Duration(days: 21)),
      lastWatered: DateTime.now().subtract(const Duration(days: 3)),
      lastFed: DateTime.now().subtract(const Duration(days: 8)),
    ),
    _Seedling(
      crop: 'Broccoli',
      type: 'Brassica',
      bed: 'Standard Bed 3',
      stage: _SeedlingStage.growing,
      sownDate: DateTime.now().subtract(const Duration(days: 20)),
      lastWatered: DateTime.now().subtract(const Duration(days: 1)),
      lastFed: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  bool strawMulchActive = false;
  bool showTransplanted = false;

  String stageFilter = 'All stages';
  String typeFilter = 'All types';

  final double surfaceTemp = 10.9;
  final double rootZoneTemp = 8.4;
  final double deepTemp = 8.9;

  final double eto = 1.8;
  final double tempMax = 18.0;
  final double tempMin = 6.1;
  final int humidity = 83;
  final int wind = 8;
  final int solar = 150;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSeedlings();
    final overdue = seedlings.where((s) => s.isOverdue).length;

    return Container(
      color: const Color(0xFFF4EFE7),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFFD400),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'VISIBLE SEEDLINGS DEBUG BANNER - ACTIVE FILE IS lib/screens/seedlings_screen.dart',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _soilWaterPanel()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: _sectionHeader(
                title: 'Seedling Tracker • rev-20260425-061108',
                subtitle:
                    'Sow a seed, pick the type Ã¢â‚¬â€ germination and transplant windows calculated automatically.',
                trailing: FilledButton.icon(
                  onPressed: _showSowSeedSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Sow seed'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF17130F),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _overduePanel(overdue)),
          SliverToBoxAdapter(child: _summaryCards()),
          SliverToBoxAdapter(child: _filters()),
          if (filtered.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(
                  child: Text(
                    'No seedlings here yet Ã¢â‚¬â€ hit + Sow seed to get started.',
                    style: TextStyle(
                      color: Color(0xFF867A6A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(16, index == 0 ? 10 : 0, 16, 8),
                  child: _seedlingCard(filtered[index]),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Widget _soilWaterPanel() {
    final effectiveEto = strawMulchActive ? eto * 0.5 : eto;
    final lowDemand = effectiveEto < 2.5;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAF6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD8CDBE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.thermostat,
                    color: Color(0xFF8A5A1F),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'SOIL TEMPERATURE & WATER DEMAND Ã¢â‚¬â€ BUDGE ST',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF5B5148),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ),
                  _lowWaterBadge(lowDemand),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Seedling soil and water panel refreshed.',
                          ),
                        ),
                      );
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE6DCCE)),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 780;

                if (compact) {
                  return Column(
                    children: [
                      _soilPanel(),
                      const Divider(height: 1, color: Color(0xFFE6DCCE)),
                      _waterPanel(effectiveEto),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _soilPanel()),
                    Container(
                      width: 1,
                      height: 360,
                      color: const Color(0xFFE6DCCE),
                    ),
                    Expanded(child: _waterPanel(effectiveEto)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _lowWaterBadge(bool lowDemand) {
    final color = lowDemand ? const Color(0xFF147A44) : const Color(0xFFA86412);
    final bg = lowDemand ? const Color(0xFFE4F6EA) : const Color(0xFFFFF3E5);
    final label = lowDemand
        ? 'Ã°Å¸â€™Â§ LOW WATER DEMAND'
        : 'Ã°Å¸â€™Â§ CHECK WATER';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _soilPanel() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniHeading(icon: Icons.grass, label: 'SOIL TEMPERATURE'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SoilTempTile(
                  label: 'SURFACE',
                  value: surfaceTemp,
                  depth: '0 cm',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SoilTempTile(
                  label: 'ROOT ZONE',
                  value: rootZoneTemp,
                  depth: '6 cm',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SoilTempTile(
                  label: 'DEEP',
                  value: deepTemp,
                  depth: '18 cm',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'GERMINATION WINDOWS NOW',
            style: TextStyle(
              color: Color(0xFF867A6A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          _germinationRow('Ã°Å¸Ââ€¦', 'Fruiting crops', 15.0),
          _germinationRow('Ã°Å¸Â«Ëœ', 'Legumes', 12.0),
          _germinationRow('Ã°Å¸Å’Â¿', 'Herbs', 12.0),
          _germinationRow('Ã°Å¸Â¥Â¬', 'Leaf & greens', 8.0),
          _germinationRow('Ã°Å¸Â¥â€¢', 'Root veg', 8.0),
          _germinationRow('Ã°Å¸Â¥Â¦', 'Brassicas', 7.0),
          _germinationRow('Ã°Å¸Â§â€¦', 'Alliums', 7.0),
        ],
      ),
    );
  }

  Widget _germinationRow(String emoji, String title, double requiredTemp) {
    final ready = rootZoneTemp >= requiredTemp;
    final difference = (requiredTemp - rootZoneTemp).clamp(0, 99).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: ready ? const Color(0xFFE6F5EA) : const Color(0xFFFFEFF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ready ? const Color(0xFFB8DEC3) : const Color(0xFFFFB5C9),
        ),
      ),
      child: Row(
        children: [
          Text(emoji),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: ready
                    ? const Color(0xFF166C3B)
                    : const Color(0xFFB72E59),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            ready
                ? 'Ã¢Å“â€¦ Ready Ã¢â‚¬â€ soil ${rootZoneTemp.toStringAsFixed(1)}Ã‚Â°C Ã¢â€°Â¥ ${requiredTemp.toStringAsFixed(0)}Ã‚Â°C'
                : 'Ã¢ÂÅ’ Too cold Ã¢â‚¬â€ need ${difference.toStringAsFixed(1)}Ã‚Â°C more',
            style: TextStyle(
              color: ready ? const Color(0xFF238B55) : const Color(0xFFD65D82),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _waterPanel(double effectiveEto) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniHeading(
            icon: Icons.water_drop,
            label: 'DAILY WATER DEMAND (ETo)',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _waterDemandBar(effectiveEto)),
              const SizedBox(width: 14),
              Text(
                '${effectiveEto.toStringAsFixed(1)} mm/day',
                style: const TextStyle(
                  color: Color(0xFF147A44),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TinyMetric(
                  label: 'TEMP MAX',
                  value: '${tempMax.toStringAsFixed(1)}Ã‚Â°C',
                ),
              ),
              Expanded(
                child: _TinyMetric(
                  label: 'TEMP MIN',
                  value: '${tempMin.toStringAsFixed(1)}Ã‚Â°C',
                ),
              ),
              Expanded(
                child: _TinyMetric(label: 'HUMIDITY', value: '$humidity%'),
              ),
              Expanded(
                child: _TinyMetric(label: 'WIND AVG', value: '$wind km/h'),
              ),
              Expanded(
                child: _TinyMetric(label: 'SOLAR RAD', value: '$solar W/mÃ‚Â²'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => setState(() => strawMulchActive = !strawMulchActive),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD8CDBE)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: strawMulchActive,
                    onChanged: (value) {
                      setState(() => strawMulchActive = value ?? false);
                    },
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Ã°Å¸Å’Â¾ Straw mulch layer active (~5 cm)',
                            style: TextStyle(
                              color: Color(0xFF2A241E),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text:
                                '\nReduces effective ETo by ~50% Ã¢â‚¬â€ beds need water less often.',
                            style: TextStyle(
                              color: Color(0xFF867A6A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5EA),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFB8DEC3)),
            ),
            child: Text(
              'Ã¢Å“â€¦ Low water demand (${effectiveEto.toStringAsFixed(1)} mm/day) Ã¢â‚¬â€ beds watered in the last 2Ã¢â‚¬â€œ3 days are fine.',
              style: const TextStyle(
                color: Color(0xFF166C3B),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _waterDemandBar(double value) {
    final normalized = (value / 6.0).clamp(0.0, 1.0);

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E2D9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: normalized,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF238B55),
                  Color(0xFFE0B43C),
                  Color(0xFFE04444),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF15130F),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF867A6A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _overduePanel(int overdue) {
    final overdueItems = seedlings.where((s) => s.isOverdue).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAF6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD8CDBE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2EE),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFFFC9BD)),
                    ),
                    child: Text(
                      'Ã¢Å¡Â  $overdue overdue',
                      style: const TextStyle(
                        color: Color(0xFFC0392B),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _showRemindersSheet,
                    icon: const Icon(Icons.notifications),
                    label: const Text('Reminders Ã¢â€ â€™'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF15130F),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (overdueItems.isEmpty)
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'No overdue seedling tasks.',
                  style: TextStyle(
                    color: Color(0xFF867A6A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              ...overdueItems.map(_careRow),
          ],
        ),
      ),
    );
  }

  Widget _careRow(_Seedling seedling) {
    final needsWater = seedling.needsWater;
    final needsFeed = seedling.needsFeed;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE6DCCE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_emojiForCrop(seedling.crop)} ${seedling.crop} Ã‚Â· ${seedling.bed}',
              style: const TextStyle(
                color: Color(0xFF2A241E),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (needsWater)
            OutlinedButton.icon(
              onPressed: () => _waterNow(seedling),
              icon: const Icon(Icons.water_drop, size: 15),
              label: const Text('Water now'),
            ),
          if (needsWater && needsFeed) const SizedBox(width: 8),
          if (needsFeed)
            OutlinedButton.icon(
              onPressed: () => _feedNow(seedling),
              icon: const Icon(Icons.spa, size: 15),
              label: const Text('Feed now'),
            ),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    final active = seedlings.where((s) => !s.transplanted).length;
    final germinating = seedlings
        .where((s) => s.stage == _SeedlingStage.germinating)
        .length;
    final growing = seedlings
        .where((s) => s.stage == _SeedlingStage.growing)
        .length;
    final ready = seedlings
        .where((s) => s.stage == _SeedlingStage.ready)
        .length;

    final cards = [
      _SummaryCard(
        label: 'ACTIVE SEEDLINGS',
        value: active,
        sub: 'currently being grown',
      ),
      _SummaryCard(
        label: 'GERMINATING',
        value: germinating,
        sub: 'waiting to sprout',
      ),
      _SummaryCard(
        label: 'GROWING ON',
        value: growing,
        sub: 'developing in trays',
      ),
      _SummaryCard(label: 'READY TO TRANSPLANT', value: ready, sub: 'none yet'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.9,
              children: cards,
            );
          }

          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i != cards.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _filters() {
    final types = ['All types', ...seedlings.map((s) => s.type).toSet()];
    final stages = ['All stages', ..._SeedlingStage.values.map(_stageLabel)];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 190,
            child: DropdownButtonFormField<String>(
              initialValue: stageFilter,
              decoration: _inputDecoration(),
              items: stages
                  .map(
                    (stage) =>
                        DropdownMenuItem(value: stage, child: Text(stage)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => stageFilter = value ?? 'All stages'),
            ),
          ),
          SizedBox(
            width: 170,
            child: DropdownButtonFormField<String>(
              initialValue: typeFilter,
              decoration: _inputDecoration(),
              items: types
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => typeFilter = value ?? 'All types'),
            ),
          ),
          FilterChip(
            selected: showTransplanted,
            onSelected: (value) => setState(() => showTransplanted = value),
            label: const Text('Show transplanted'),
          ),
        ],
      ),
    );
  }

  Widget _seedlingCard(_Seedling seedling) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8CDBE)),
      ),
      child: Row(
        children: [
          Text(
            _emojiForCrop(seedling.crop),
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${seedling.crop} Ã‚Â· ${seedling.bed}\n${_stageLabel(seedling.stage)} Ã‚Â· sown ${_shortDate(seedling.sownDate)}',
              style: const TextStyle(
                color: Color(0xFF2A241E),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'water') _waterNow(seedling);
              if (action == 'feed') _feedNow(seedling);
              if (action == 'transplant') _markTransplanted(seedling);
              if (action == 'delete') _deleteSeedling(seedling);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'water', child: Text('Water now')),
              PopupMenuItem(value: 'feed', child: Text('Feed now')),
              PopupMenuItem(
                value: 'transplant',
                child: Text('Mark transplanted'),
              ),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFCFAF6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD8CDBE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD8CDBE)),
      ),
    );
  }

  void _showSowSeedSheet() {
    final cropController = TextEditingController();
    final bedController = TextEditingController(text: 'Standard Bed 1');
    String type = 'Vegetable';
    _SeedlingStage stage = _SeedlingStage.germinating;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sow seed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cropController,
                    decoration: const InputDecoration(
                      labelText: 'Crop name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bedController,
                    decoration: const InputDecoration(
                      labelText: 'Bed / tray',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Vegetable',
                        child: Text('Vegetable'),
                      ),
                      DropdownMenuItem(value: 'Herb', child: Text('Herb')),
                      DropdownMenuItem(value: 'Flower', child: Text('Flower')),
                      DropdownMenuItem(value: 'Fruit', child: Text('Fruit')),
                      DropdownMenuItem(
                        value: 'Brassica',
                        child: Text('Brassica'),
                      ),
                    ],
                    onChanged: (value) {
                      setSheetState(() => type = value ?? 'Vegetable');
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<_SeedlingStage>(
                    initialValue: stage,
                    decoration: const InputDecoration(
                      labelText: 'Stage',
                      border: OutlineInputBorder(),
                    ),
                    items: _SeedlingStage.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(_stageLabel(item)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setSheetState(
                        () => stage = value ?? _SeedlingStage.germinating,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        final crop = cropController.text.trim();
                        if (crop.isEmpty) return;

                        setState(() {
                          seedlings.add(
                            _Seedling(
                              crop: crop,
                              type: type,
                              bed: bedController.text.trim().isEmpty
                                  ? 'Unassigned'
                                  : bedController.text.trim(),
                              stage: stage,
                              sownDate: DateTime.now(),
                              lastWatered: DateTime.now(),
                              lastFed: DateTime.now(),
                            ),
                          );
                        });

                        Navigator.of(sheetContext).maybePop();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add seedling'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRemindersSheet() {
    final reminders = seedlings.where((s) => s.isOverdue).toList();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text(
              'Reminders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (reminders.isEmpty)
              const Text('No reminders due.')
            else
              ...reminders.map(
                (seedling) => ListTile(
                  leading: Text(_emojiForCrop(seedling.crop)),
                  title: Text(seedling.crop),
                  subtitle: Text(
                    seedling.needsWater ? 'Water due' : 'Feed due',
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      seedling.needsWater
                          ? _waterNow(seedling)
                          : _feedNow(seedling);
                      Navigator.of(context).maybePop();
                    },
                    child: Text(seedling.needsWater ? 'Water' : 'Feed'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<_Seedling> _filteredSeedlings() {
    return seedlings.where((seedling) {
      final stageMatch =
          stageFilter == 'All stages' ||
          _stageLabel(seedling.stage) == stageFilter;
      final typeMatch =
          typeFilter == 'All types' || seedling.type == typeFilter;
      final transplantMatch = showTransplanted || !seedling.transplanted;
      return stageMatch && typeMatch && transplantMatch;
    }).toList();
  }

  void _waterNow(_Seedling seedling) {
    setState(() {
      seedling.lastWatered = DateTime.now();
    });
  }

  void _feedNow(_Seedling seedling) {
    setState(() {
      seedling.lastFed = DateTime.now();
    });
  }

  void _markTransplanted(_Seedling seedling) {
    setState(() {
      seedling.transplanted = true;
      seedling.stage = _SeedlingStage.transplanted;
    });
  }

  void _deleteSeedling(_Seedling seedling) {
    setState(() {
      seedlings.remove(seedling);
    });
  }

  static String _stageLabel(_SeedlingStage stage) {
    switch (stage) {
      case _SeedlingStage.germinating:
        return 'Germinating';
      case _SeedlingStage.growing:
        return 'Growing on';
      case _SeedlingStage.ready:
        return 'Ready to transplant';
      case _SeedlingStage.transplanted:
        return 'Transplanted';
    }
  }

  static String _shortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _emojiForCrop(String cropName) {
    final crop = cropName.toLowerCase();

    if (crop.contains('strawberry')) return 'Ã°Å¸Ââ€œ';
    if (crop.contains('raspberry') || crop.contains('blackberry')) {
      return 'Ã°Å¸Ââ€¡';
    }
    if (crop.contains('blueberry')) return 'Ã°Å¸Â«Â';
    if (crop.contains('broccoli')) return 'Ã°Å¸Â¥Â¦';
    if (crop.contains('basil') || crop.contains('herb')) return 'Ã°Å¸Å’Â¿';
    if (crop.contains('tomato')) return 'Ã°Å¸Ââ€¦';
    if (crop.contains('carrot')) return 'Ã°Å¸Â¥â€¢';
    if (crop.contains('lettuce') || crop.contains('kale')) return 'Ã°Å¸Â¥Â¬';
    if (crop.contains('onion')) return 'Ã°Å¸Â§â€¦';
    if (crop.contains('garlic')) return 'Ã°Å¸Â§â€ž';
    if (crop.contains('potato')) return 'Ã°Å¸Â¥â€';
    return 'Ã°Å¸Å’Â±';
  }
}

class _Seedling {
  _Seedling({
    required this.crop,
    required this.type,
    required this.bed,
    required this.stage,
    required this.sownDate,
    required this.lastWatered,
    required this.lastFed,
  });

  final String crop;
  final String type;
  final String bed;
  _SeedlingStage stage;
  DateTime sownDate;
  DateTime lastWatered;
  DateTime lastFed;
  bool transplanted;

  bool get needsWater => DateTime.now().difference(lastWatered).inDays >= 2;
  bool get needsFeed => DateTime.now().difference(lastFed).inDays >= 7;
  bool get isOverdue => needsWater || needsFeed;
}

enum _SeedlingStage { germinating, growing, ready, transplanted }

class _MiniHeading extends StatelessWidget {
  const _MiniHeading({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF238B55), size: 15),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6E655C),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _SoilTempTile extends StatelessWidget {
  const _SoilTempTile({
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
      height: 72,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7BC75)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF867A6A),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(1)}Ã‚Â°C',
            style: const TextStyle(
              color: Color(0xFFB65F00),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            depth,
            style: const TextStyle(
              color: Color(0xFF867A6A),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF867A6A),
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF15130F),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.sub,
  });

  final String label;
  final int value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final highlight = value > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8CDBE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF867A6A),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              color: highlight
                  ? const Color(0xFF238B55)
                  : const Color(0xFF15130F),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF867A6A),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
