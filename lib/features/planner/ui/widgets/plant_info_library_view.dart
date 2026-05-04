import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:garden_planner/core/models/crop_spacing.dart';
import 'package:garden_planner/core/models/plant_profile_data.dart';
import 'package:garden_planner/core/plant_icons/generated_plant_icon.dart';
import 'package:garden_planner/core/plant_icons/generated_plant_svgs.dart';
import 'package:garden_planner/features/planner/services/planting_selection_bridge.dart';

class PlantInfoLibraryView extends StatefulWidget {
  const PlantInfoLibraryView({super.key, this.onPlantChosen});

  final ValueChanged<String>? onPlantChosen;

  @override
  State<PlantInfoLibraryView> createState() => _PlantInfoLibraryViewState();
}

class _PlantInfoLibraryViewState extends State<PlantInfoLibraryView> {
  static const String _favoritesKey = 'plant_library.favorite_keys';
  static const String _recentKey = 'plant_library.recent_keys';

  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _category = 'All';
  String _filter = 'All';
  String _sort = 'A-Z';

  final Set<String> _favoriteKeys = <String>{};
  final List<String> _recentKeys = <String>[];

  late final List<_PlantEntry> _plants =
      generatedPlantSvgs.keys.map(_entryFromKey).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  static const List<String> _categories = [
    'All',
    'Vegetables',
    'Herbs',
    'Fruit',
    'Trees',
    'Flowers',
  ];

  static const List<String> _filters = [
    'All',
    'Favorites',
    'Recent',
    'Recommended',
    'Spacing',
    'Containers',
    'Sow depth',
    'Warnings',
  ];

  static const List<String> _sortModes = [
    'A-Z',
    'Category',
    'Favorites first',
    'Recently used',
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _favoriteKeys
        ..clear()
        ..addAll(prefs.getStringList(_favoritesKey) ?? const []);

      _recentKeys
        ..clear()
        ..addAll(prefs.getStringList(_recentKey) ?? const []);
    });
  }

  Future<void> _saveLocalState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_favoritesKey, _favoriteKeys.toList()..sort());
    await prefs.setStringList(_recentKey, _recentKeys.take(20).toList());
  }

  List<_PlantEntry> get _visiblePlants {
    final q = _query.trim().toLowerCase();

    final visible = _plants.where((plant) {
      final profile = PlantProfileData.forCrop(plant.name);
      final spacing = CropSpacing.spacingLabelForCrop(plant.name);

      final matchesQuery =
          q.isEmpty ||
          plant.name.toLowerCase().contains(q) ||
          plant.key.toLowerCase().contains(q) ||
          plant.category.toLowerCase().contains(q) ||
          profile.sun.toLowerCase().contains(q) ||
          profile.water.toLowerCase().contains(q) ||
          profile.soil.toLowerCase().contains(q);

      final matchesCategory = _category == 'All' || plant.category == _category;

      final matchesFilter = switch (_filter) {
        'All' => true,
        'Favorites' => _favoriteKeys.contains(plant.key),
        'Recent' => _recentKeys.contains(plant.key),
        'Recommended' => profile.recommendedLayout.trim().isNotEmpty,
        'Spacing' => spacing.trim().isNotEmpty,
        'Containers' => profile.container.trim().isNotEmpty,
        'Sow depth' => profile.sowDepth.trim().isNotEmpty,
        'Warnings' => profile.warnings.isNotEmpty,
        _ => true,
      };

      return matchesQuery && matchesCategory && matchesFilter;
    }).toList();

    visible.sort((a, b) {
      return switch (_sort) {
        'Category' => _categoryThenName(a, b),
        'Favorites first' => _favoriteThenName(a, b),
        'Recently used' => _recentThenName(a, b),
        _ => a.name.compareTo(b.name),
      };
    });

    return visible;
  }

  int _categoryThenName(_PlantEntry a, _PlantEntry b) {
    final category = a.category.compareTo(b.category);
    if (category != 0) return category;
    return a.name.compareTo(b.name);
  }

  int _favoriteThenName(_PlantEntry a, _PlantEntry b) {
    final af = _favoriteKeys.contains(a.key);
    final bf = _favoriteKeys.contains(b.key);

    if (af != bf) return af ? -1 : 1;
    return a.name.compareTo(b.name);
  }

  int _recentThenName(_PlantEntry a, _PlantEntry b) {
    final ai = _recentKeys.indexOf(a.key);
    final bi = _recentKeys.indexOf(b.key);

    if (ai == -1 && bi == -1) return a.name.compareTo(b.name);
    if (ai == -1) return 1;
    if (bi == -1) return -1;

    return ai.compareTo(bi);
  }

  int get _warningCount {
    return _plants
        .where(
          (plant) => PlantProfileData.forCrop(plant.name).warnings.isNotEmpty,
        )
        .length;
  }

  int get _containerCount {
    return _plants
        .where(
          (plant) =>
              PlantProfileData.forCrop(plant.name).container.trim().isNotEmpty,
        )
        .length;
  }

  _PlantEntry _entryFromKey(String key) {
    final lower = key.toLowerCase();
    final name = _titleCase(key.replaceAll('_', ' '));

    const herbs = {
      'basil',
      'bay_leaf',
      'chamomile',
      'chives',
      'cilantro',
      'dill',
      'fennel',
      'lavender',
      'lemongrass',
      'mint',
      'oregano',
      'parsley',
      'rosemary',
      'sage',
      'tarragon',
      'thyme',
    };

    const fruitWords = [
      'apple',
      'avocado',
      'banana',
      'blueberry',
      'cherry',
      'coconut',
      'fig',
      'grape',
      'lemon',
      'mango',
      'orange',
      'peach',
      'pear',
      'pomegranate',
      'raspberry',
      'strawberry',
      'tomato',
      'pepper',
      'cucumber',
      'pumpkin',
      'zucchini',
    ];

    const treeWords = [
      'tree',
      'birch',
      'bonsai',
      'magnolia',
      'maple',
      'oak',
      'palm',
      'pine',
      'willow',
      'bamboo',
    ];

    const flowerWords = ['blossom', 'lavender', 'chamomile'];

    final category = herbs.contains(lower)
        ? 'Herbs'
        : fruitWords.any(lower.contains)
        ? 'Fruit'
        : treeWords.any(lower.contains)
        ? 'Trees'
        : flowerWords.any(lower.contains)
        ? 'Flowers'
        : 'Vegetables';

    return _PlantEntry(key: key, name: name, category: category);
  }

  String _titleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .map((part) {
          if (part.length == 1) return part.toUpperCase();
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _toggleFavorite(_PlantEntry plant) async {
    setState(() {
      if (_favoriteKeys.contains(plant.key)) {
        _favoriteKeys.remove(plant.key);
      } else {
        _favoriteKeys.add(plant.key);
      }
    });

    await _saveLocalState();
  }

  Future<void> _markRecent(_PlantEntry plant) async {
    setState(() {
      _recentKeys.remove(plant.key);
      _recentKeys.insert(0, plant.key);

      if (_recentKeys.length > 20) {
        _recentKeys.removeRange(20, _recentKeys.length);
      }
    });

    await _saveLocalState();
  }

  Future<void> _usePlant(_PlantEntry plant) async {
    final cropName = plant.name.trim().isEmpty ? plant.key : plant.name;

    await _markRecent(plant);

    if (widget.onPlantChosen != null) {
      widget.onPlantChosen!(cropName);
      return;
    }

    PlantingSelectionBridge.selectPlant(cropName);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$cropName selected. Open the planner/map to place it.'),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _openPlantDetails(_PlantEntry plant) {
    final profile = PlantProfileData.forCrop(plant.name);
    final spacing = CropSpacing.spacingLabelForCrop(plant.name);
    final isFavorite = _favoriteKeys.contains(plant.key);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF4),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.84,
          minChildSize: 0.42,
          maxChildSize: 0.96,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                Center(
                  child: Container(
                    width: 108,
                    height: 108,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1EAE1),
                      shape: BoxShape.circle,
                    ),
                    child: GeneratedPlantIcon(cropName: plant.key, size: 74),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  plant.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.category,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniInfoChip(label: spacing),
                    _MiniInfoChip(label: profile.sun),
                    _MiniInfoChip(label: profile.water),
                    if (profile.warnings.isNotEmpty)
                      const _MiniInfoChip(label: 'Has warnings'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _usePlant(plant);
                        },
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Use on map / bed'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.outlined(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _toggleFavorite(plant);
                      },
                      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                      tooltip: isFavorite ? 'Remove favorite' : 'Favorite',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Growing details',
                  children: [
                    _InfoRow(label: 'Spacing', value: spacing),
                    _InfoRow(label: 'Layout', value: profile.recommendedLayout),
                    _InfoRow(label: 'Sow depth', value: profile.sowDepth),
                    _InfoRow(label: 'Sun', value: profile.sun),
                    _InfoRow(label: 'Water', value: profile.water),
                    _InfoRow(label: 'Soil', value: profile.soil),
                    _InfoRow(label: 'Rotation', value: profile.rotationFamily),
                    _InfoRow(label: 'Succession', value: profile.succession),
                    _InfoRow(label: 'Frost', value: profile.frost),
                    _InfoRow(label: 'Container', value: profile.container),
                    _InfoRow(label: 'Support', value: profile.support),
                    _InfoRow(label: 'Planner use', value: profile.plannerUse),
                    if (profile.warnings.isNotEmpty)
                      _InfoRow(
                        label: 'Warnings',
                        value: profile.warnings.join('\n'),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _resetFilters() {
    _searchController.clear();

    setState(() {
      _query = '';
      _category = 'All';
      _filter = 'All';
      _sort = 'A-Z';
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visiblePlants;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Material(
      color: const Color(0xFFFFF7EF),
      child: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: _HeaderCard(
                  visibleCount: visible.length,
                  totalCount: _plants.length,
                  favoriteCount: _favoriteKeys.length,
                  recentCount: _recentKeys.length,
                  warningCount: _warningCount,
                  containerCount: _containerCount,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search plants, sun, soil, water...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _ChipScroller(
                label: 'Category',
                values: _categories,
                selected: _category,
                onSelected: (value) => setState(() => _category = value),
              ),
            ),
            SliverToBoxAdapter(
              child: _ChipScroller(
                label: 'Filter',
                values: _filters,
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
            ),
            SliverToBoxAdapter(
              child: _ChipScroller(
                label: 'Sort',
                values: _sortModes,
                selected: _sort,
                onSelected: (value) => setState(() => _sort = value),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${visible.length} plants shown',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
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

                    if (width < 430) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final plant = visible[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == visible.length - 1 ? 0 : 12,
                            ),
                            child: _PlantListCard(
                              plant: plant,
                              favorite: _favoriteKeys.contains(plant.key),
                              recent: _recentKeys.contains(plant.key),
                              onTap: () => _openPlantDetails(plant),
                              onUse: () => _usePlant(plant),
                              onFavorite: () => _toggleFavorite(plant),
                            ),
                          );
                        }, childCount: visible.length),
                      );
                    }

                    final columns = width >= 900
                        ? 4
                        : width >= 680
                        ? 3
                        : 2;

                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final plant = visible[index];

                        return _PlantGridCard(
                          plant: plant,
                          favorite: _favoriteKeys.contains(plant.key),
                          recent: _recentKeys.contains(plant.key),
                          onTap: () => _openPlantDetails(plant),
                          onUse: () => _usePlant(plant),
                          onFavorite: () => _toggleFavorite(plant),
                        );
                      }, childCount: visible.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 252,
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
}

class _PlantEntry {
  const _PlantEntry({
    required this.key,
    required this.name,
    required this.category,
  });

  final String key;
  final String name;
  final String category;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.visibleCount,
    required this.totalCount,
    required this.favoriteCount,
    required this.recentCount,
    required this.warningCount,
    required this.containerCount,
  });

  final int visibleCount;
  final int totalCount;
  final int favoriteCount;
  final int recentCount;
  final int warningCount;
  final int containerCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFE9E0EA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFDCEFE0),
                  child: Icon(Icons.eco, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Plant Library Pro',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$visibleCount shown from $totalCount plants',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SmallChip(label: '$favoriteCount favorites'),
                _SmallChip(label: '$recentCount recent'),
                _SmallChip(label: '$warningCount warnings'),
                _SmallChip(label: '$containerCount containers'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: Colors.white,
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final clean = label.trim().isEmpty ? 'Not specified' : label.trim();

    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(
        clean,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ChipScroller extends StatelessWidget {
  const _ChipScroller({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: values.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Color(0xFF6D6258),
                ),
              ),
            );
          }

          final value = values[index - 1];

          return ChoiceChip(
            label: Text(value),
            selected: selected == value,
            onSelected: (_) => onSelected(value),
          );
        },
      ),
    );
  }
}

class _PlantListCard extends StatelessWidget {
  const _PlantListCard({
    required this.plant,
    required this.favorite,
    required this.recent,
    required this.onTap,
    required this.onUse,
    required this.onFavorite,
  });

  final _PlantEntry plant;
  final bool favorite;
  final bool recent;
  final VoidCallback onTap;
  final VoidCallback onUse;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final spacing = CropSpacing.spacingLabelForCrop(plant.name);

    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFD9CDB8)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1EAE1),
                  shape: BoxShape.circle,
                ),
                child: GeneratedPlantIcon(cropName: plant.key, size: 52),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _PlantCardText(
                  plant: plant,
                  spacing: spacing,
                  favorite: favorite,
                  recent: recent,
                  onUse: onUse,
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(favorite ? Icons.star : Icons.star_border),
                tooltip: favorite ? 'Remove favorite' : 'Favorite',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantGridCard extends StatelessWidget {
  const _PlantGridCard({
    required this.plant,
    required this.favorite,
    required this.recent,
    required this.onTap,
    required this.onUse,
    required this.onFavorite,
  });

  final _PlantEntry plant;
  final bool favorite;
  final bool recent;
  final VoidCallback onTap;
  final VoidCallback onUse;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final spacing = CropSpacing.spacingLabelForCrop(plant.name);

    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFD9CDB8)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onFavorite,
                  icon: Icon(favorite ? Icons.star : Icons.star_border),
                  tooltip: favorite ? 'Remove favorite' : 'Favorite',
                ),
              ),
              Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1EAE1),
                  shape: BoxShape.circle,
                ),
                child: GeneratedPlantIcon(cropName: plant.key, size: 48),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _PlantCardText(
                  plant: plant,
                  spacing: spacing,
                  favorite: favorite,
                  recent: recent,
                  onUse: onUse,
                  centered: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantCardText extends StatelessWidget {
  const _PlantCardText({
    required this.plant,
    required this.spacing,
    required this.favorite,
    required this.recent,
    required this.onUse,
    this.centered = false,
  });

  final _PlantEntry plant;
  final String spacing;
  final bool favorite;
  final bool recent;
  final VoidCallback onUse;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          plant.name.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          plant.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          spacing,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: 4,
          runSpacing: 4,
          children: [
            if (favorite) const _TinyTag(label: 'Favorite'),
            if (recent) const _TinyTag(label: 'Recent'),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: onUse,
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Use on map'),
            ),
          ),
        ),
      ],
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.trim().isEmpty ? 'Not specified' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(cleanValue, style: const TextStyle(fontSize: 12)),
          ),
        ],
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
        child: Text(
          'No plants match the current filters.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
