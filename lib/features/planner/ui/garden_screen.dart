import 'package:flutter/material.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class PlantItem {
  final String name;
  final String subtitle;
  final String emoji;
  final bool harvestSafe;
  final List<String> tags;

  const PlantItem({
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.harvestSafe,
    required this.tags,
  });
}

class _GardenScreenState extends State<GardenScreen> {
  String _selectedFilter = 'All species';

  final List<String> _filters = const [
    'All species',
    'Allium',
    'Berry',
    'Brassica',
    'Recommended now',
    'Sowable',
    'Harvest-safe',
  ];

  final List<PlantItem> _plants = const [
    PlantItem(
      name: 'Broccoli',
      subtitle: 'Broccoli types • 6 types',
      emoji: '🥦',
      harvestSafe: true,
      tags: ['Brassica', 'Recommended now', 'Harvest-safe'],
    ),
    PlantItem(
      name: 'Broccolini',
      subtitle: 'Broccoli types • 6 types',
      emoji: '🌱',
      harvestSafe: true,
      tags: ['Brassica', 'Sowable', 'Harvest-safe'],
    ),
    PlantItem(
      name: 'Carrot',
      subtitle: 'Root vegetable',
      emoji: '🥕',
      harvestSafe: true,
      tags: ['Recommended now', 'Sowable', 'Harvest-safe'],
    ),
    PlantItem(
      name: 'Tomato',
      subtitle: 'Warm-season crop',
      emoji: '🍅',
      harvestSafe: false,
      tags: ['Sowable'],
    ),
    PlantItem(
      name: 'Onion',
      subtitle: 'Allium crop',
      emoji: '🧅',
      harvestSafe: true,
      tags: ['Allium', 'Harvest-safe'],
    ),
    PlantItem(
      name: 'Strawberry',
      subtitle: 'Berry crop',
      emoji: '🍓',
      harvestSafe: true,
      tags: ['Berry', 'Harvest-safe'],
    ),
  ];

  List<PlantItem> get _visiblePlants {
    if (_selectedFilter == 'All species') return _plants;
    return _plants
        .where((plant) => plant.tags.contains(_selectedFilter))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Garden Planner'), centerTitle: false),
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
              child: SizedBox(height: 92, child: _buildFilterScroller()),
            ),
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
                      return _PlantCard(plant: _visiblePlants[index]);
                    }, childCount: _visiblePlants.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick plants for your bed',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Use the filters, then tap a plant card. The screen now scrolls correctly on mobile.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterScroller() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      children: [
        for (final filter in _filters)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          ),
      ],
    );
  }
}

class _PlantCard extends StatelessWidget {
  final PlantItem plant;

  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Theme.of(context).dividerColor),
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
          children: [
            Container(
              height: 38,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerLeft,
              color: plant.harvestSafe
                  ? Colors.green.withOpacity(0.12)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  Flexible(
                    child: Text(
                      plant.harvestSafe ? 'Harvest-safe' : 'Check timing',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: plant.harvestSafe ? Colors.green.shade800 : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      child: Text(
                        plant.emoji,
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 6),
                    Text(
                      plant.subtitle,
                      textAlign: TextAlign.center,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () {},
                        child: const FittedBox(
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
