import 'package:flutter/material.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class PlantItem {
  const PlantItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.harvestSafe,
    required this.spacingCm,
    required this.daysToHarvest,
    required this.season,
    required this.waterNeed,
    required this.difficulty,
    required this.tags,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final bool harvestSafe;
  final int spacingCm;
  final int daysToHarvest;
  final String season;
  final String waterNeed;
  final String difficulty;
  final List<String> tags;
}

class GardenTask {
  const GardenTask({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.priority,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String priority;
}

class GardenWarning {
  const GardenWarning({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _GardenScreenState extends State<GardenScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All species';
  String _query = '';
  bool _showOnlyEasy = false;
  bool _showOnlyLowWater = false;

  static const List<String> _filters = [
    'All species',
    'Recommended now',
    'Sowable',
    'Harvest-safe',
    'Quick harvest',
    'Low water',
    'Allium',
    'Berry',
    'Brassica',
    'Root',
    'Herb',
  ];

  static const List<PlantItem> _plants = [
    PlantItem(
      name: 'Broccoli',
      subtitle: 'Cool-season brassica for dense beds',
      icon: Icons.grass,
      harvestSafe: true,
      spacingCm: 45,
      daysToHarvest: 80,
      season: 'Autumn and winter',
      waterNeed: 'Medium',
      difficulty: 'Medium',
      tags: ['Brassica', 'Recommended now', 'Harvest-safe'],
    ),
    PlantItem(
      name: 'Broccolini',
      subtitle: 'Fast brassica shoots with repeat picking',
      icon: Icons.spa,
      harvestSafe: true,
      spacingCm: 35,
      daysToHarvest: 60,
      season: 'Autumn and winter',
      waterNeed: 'Medium',
      difficulty: 'Easy',
      tags: ['Brassica', 'Sowable', 'Harvest-safe', 'Quick harvest'],
    ),
    PlantItem(
      name: 'Carrot',
      subtitle: 'Root crop for direct sowing',
      icon: Icons.eco,
      harvestSafe: true,
      spacingCm: 8,
      daysToHarvest: 70,
      season: 'Most seasons',
      waterNeed: 'Low',
      difficulty: 'Easy',
      tags: ['Root', 'Recommended now', 'Sowable', 'Harvest-safe', 'Low water'],
    ),
    PlantItem(
      name: 'Tomato',
      subtitle: 'Warm-season crop needing support',
      icon: Icons.local_florist,
      harvestSafe: false,
      spacingCm: 65,
      daysToHarvest: 85,
      season: 'Spring and summer',
      waterNeed: 'High',
      difficulty: 'Medium',
      tags: ['Sowable'],
    ),
    PlantItem(
      name: 'Onion',
      subtitle: 'Compact allium for bed edges',
      icon: Icons.adjust,
      harvestSafe: true,
      spacingCm: 12,
      daysToHarvest: 120,
      season: 'Autumn to spring',
      waterNeed: 'Low',
      difficulty: 'Easy',
      tags: ['Allium', 'Harvest-safe', 'Low water'],
    ),
    PlantItem(
      name: 'Strawberry',
      subtitle: 'Berry crop for borders and pots',
      icon: Icons.yard,
      harvestSafe: true,
      spacingCm: 30,
      daysToHarvest: 90,
      season: 'Spring to autumn',
      waterNeed: 'Medium',
      difficulty: 'Easy',
      tags: ['Berry', 'Harvest-safe'],
    ),
    PlantItem(
      name: 'Lettuce',
      subtitle: 'Quick leafy crop for succession sowing',
      icon: Icons.energy_savings_leaf,
      harvestSafe: true,
      spacingCm: 25,
      daysToHarvest: 45,
      season: 'Cool weather',
      waterNeed: 'Medium',
      difficulty: 'Easy',
      tags: ['Recommended now', 'Sowable', 'Harvest-safe', 'Quick harvest'],
    ),
    PlantItem(
      name: 'Basil',
      subtitle: 'Herb companion for tomatoes',
      icon: Icons.park,
      harvestSafe: true,
      spacingCm: 18,
      daysToHarvest: 35,
      season: 'Warm weather',
      waterNeed: 'Medium',
      difficulty: 'Easy',
      tags: ['Herb', 'Sowable', 'Harvest-safe', 'Quick harvest'],
    ),
    PlantItem(
      name: 'Kale',
      subtitle: 'Hardy leafy brassica for repeat harvest',
      icon: Icons.forest,
      harvestSafe: true,
      spacingCm: 45,
      daysToHarvest: 65,
      season: 'Cool weather',
      waterNeed: 'Medium',
      difficulty: 'Easy',
      tags: ['Brassica', 'Recommended now', 'Harvest-safe'],
    ),
    PlantItem(
      name: 'Chives',
      subtitle: 'Compact allium herb for borders',
      icon: Icons.blur_on,
      harvestSafe: true,
      spacingCm: 15,
      daysToHarvest: 40,
      season: 'Most seasons',
      waterNeed: 'Low',
      difficulty: 'Easy',
      tags: ['Allium', 'Herb', 'Sowable', 'Low water', 'Quick harvest'],
    ),
  ];

  static const List<GardenTask> _tasks = [
    GardenTask(
      title: 'Check new seedlings',
      subtitle: 'Look for leggy growth and dry cells.',
      icon: Icons.spa_outlined,
      priority: 'Today',
    ),
    GardenTask(
      title: 'Water shallow-root crops',
      subtitle: 'Prioritise lettuce, basil, and young brassicas.',
      icon: Icons.water_drop_outlined,
      priority: 'Today',
    ),
    GardenTask(
      title: 'Review spacing',
      subtitle: 'Large crops may need thinning before they shade smaller rows.',
      icon: Icons.straighten,
      priority: 'This week',
    ),
  ];

  static const List<GardenWarning> _warnings = [
    GardenWarning(
      title: 'High-water crops need attention',
      subtitle: 'Tomatoes and leafy greens dry out faster in warm weather.',
      icon: Icons.water_damage_outlined,
    ),
    GardenWarning(
      title: 'Check harvest windows',
      subtitle: 'Fast crops should be reviewed weekly for picking.',
      icon: Icons.event_available_outlined,
    ),
  ];

  List<PlantItem> get _visiblePlants {
    final normalizedQuery = _query.trim().toLowerCase();

    return _plants.where((plant) {
      final matchesFilter =
          _selectedFilter == 'All species' ||
          plant.tags.contains(_selectedFilter) ||
          (_selectedFilter == 'Low water' && plant.waterNeed == 'Low') ||
          (_selectedFilter == 'Quick harvest' && plant.daysToHarvest <= 60);

      if (!matchesFilter) return false;
      if (_showOnlyEasy && plant.difficulty != 'Easy') return false;
      if (_showOnlyLowWater && plant.waterNeed != 'Low') return false;

      if (normalizedQuery.isEmpty) return true;

      return plant.name.toLowerCase().contains(normalizedQuery) ||
          plant.subtitle.toLowerCase().contains(normalizedQuery) ||
          plant.season.toLowerCase().contains(normalizedQuery) ||
          plant.waterNeed.toLowerCase().contains(normalizedQuery) ||
          plant.difficulty.toLowerCase().contains(normalizedQuery) ||
          plant.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  int get _sowableCount =>
      _plants.where((plant) => plant.tags.contains('Sowable')).length;

  int get _harvestSafeCount =>
      _plants.where((plant) => plant.harvestSafe).length;

  int get _quickHarvestCount =>
      _plants.where((plant) => plant.daysToHarvest <= 60).length;

  int get _lowWaterCount =>
      _plants.where((plant) => plant.waterNeed == 'Low').length;

  int get _gardenScore {
    final safeScore = _harvestSafeCount * 8;
    final quickScore = _quickHarvestCount * 5;
    final lowWaterScore = _lowWaterCount * 4;
    return (safeScore + quickScore + lowWaterScore).clamp(0, 100);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _query = '';
      _selectedFilter = 'All species';
      _showOnlyEasy = false;
      _showOnlyLowWater = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final visiblePlants = _visiblePlants;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EA),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _buildCommandCenter(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _buildTaskStrip(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _buildSearchAndToggles(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 58, child: _buildFilterScroller()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _buildResultsHeader(context, visiblePlants.length),
              ),
            ),
            if (visiblePlants.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyPlantState(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 900
                        ? 4
                        : width >= 650
                        ? 3
                        : 2;

                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _PlantCard(plant: visiblePlants[index]);
                      }, childCount: visiblePlants.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.64,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandCenter(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primaryContainer, scheme.secondaryContainer],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard_customize,
                  color: scheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Garden Command Center',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _ScoreBadge(score: _gardenScore),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Plan faster with task prompts, plant filters, spacing facts, and low-water recommendations.',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _MetricPill(label: 'Sowable', value: _sowableCount.toString()),
                const SizedBox(width: 8),
                _MetricPill(label: 'Safe', value: _harvestSafeCount.toString()),
                const SizedBox(width: 8),
                _MetricPill(
                  label: 'Quick',
                  value: _quickHarvestCount.toString(),
                ),
                const SizedBox(width: 8),
                _MetricPill(
                  label: 'Low water',
                  value: _lowWaterCount.toString(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _WarningList(warnings: _warnings),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStrip(BuildContext context) {
    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tasks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _TaskCard(task: _tasks[index]);
        },
      ),
    );
  }

  Widget _buildSearchAndToggles() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
            hintText: 'Search plants, seasons, water needs...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('Easy only'),
                selected: _showOnlyEasy,
                onSelected: (value) {
                  setState(() {
                    _showOnlyEasy = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: const Text('Low water'),
                selected: _showOnlyLowWater,
                onSelected: (value) {
                  setState(() {
                    _showOnlyLowWater = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterScroller() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      itemCount: _filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final filter = _filters[index];

        return ChoiceChip(
          label: Text(filter),
          selected: _selectedFilter == filter,
          onSelected: (_) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        );
      },
    );
  }

  Widget _buildResultsHeader(BuildContext context, int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$count matching plants',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white.withValues(alpha: 0.76),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toString(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          const Text(
            'score',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningList extends StatelessWidget {
  const _WarningList({required this.warnings});

  final List<GardenWarning> warnings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final warning in warnings) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(warning.icon, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${warning.title}: ${warning.subtitle}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final GardenTask task;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 246,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(task.icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.priority,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant});

  final PlantItem plant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${plant.name} selected'),
              duration: const Duration(milliseconds: 900),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: plant.harvestSafe
                    ? Colors.green.withValues(alpha: 0.12)
                    : scheme.surfaceContainerHighest,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Icon(
                      plant.harvestSafe
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      size: 16,
                      color: plant.harvestSafe ? Colors.green.shade700 : null,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        plant.harvestSafe ? 'Harvest-safe' : 'Check timing',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: plant.harvestSafe
                              ? Colors.green.shade800
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                child: Column(
                  children: [
                    Icon(plant.icon, size: 42, color: scheme.primary),
                    const SizedBox(height: 8),
                    Text(
                      plant.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      plant.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    _PlantFacts(plant: plant),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Add to bed'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantFacts extends StatelessWidget {
  const _PlantFacts({required this.plant});

  final PlantItem plant;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        _FactChip(label: '${plant.spacingCm}cm'),
        _FactChip(label: '${plant.daysToHarvest}d'),
        _FactChip(label: plant.waterNeed),
        _FactChip(label: plant.difficulty),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _EmptyPlantState extends StatelessWidget {
  const _EmptyPlantState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 42),
            const SizedBox(height: 10),
            Text(
              'No matching plants',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try clearing the search or changing the filters.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
