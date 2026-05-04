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
  final List<String> tags;
}

class _GardenScreenState extends State<GardenScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All species';
  String _query = '';

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
      tags: ['Herb', 'Sowable', 'Harvest-safe', 'Quick harvest'],
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
      if (normalizedQuery.isEmpty) return true;

      return plant.name.toLowerCase().contains(normalizedQuery) ||
          plant.subtitle.toLowerCase().contains(normalizedQuery) ||
          plant.season.toLowerCase().contains(normalizedQuery) ||
          plant.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  int get _sowableCount =>
      _plants.where((plant) => plant.tags.contains('Sowable')).length;

  int get _harvestSafeCount =>
      _plants.where((plant) => plant.harvestSafe).length;

  int get _quickHarvestCount =>
      _plants.where((plant) => plant.daysToHarvest <= 60).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                child: _buildHeader(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _buildSearch(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 58, child: _buildFilterScroller()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  '${visiblePlants.length} matching plants',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
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
                        childAspectRatio: 0.68,
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

  Widget _buildHeader(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
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
                  Icons.eco,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Smart Plant Planner',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Search, filter, and choose plants by spacing, harvest timing, water demand, and season.',
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
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
        hintText: 'Search plants, seasons, tags...',
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
                  fontSize: 11,
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
              'Try clearing the search or changing the filter.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
