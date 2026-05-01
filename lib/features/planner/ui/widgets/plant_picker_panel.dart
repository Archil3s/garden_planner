import 'package:flutter/material.dart';

import '../../../../core/plant_icons/generated_plant_categories.dart';
import '../../../../core/plant_icons/generated_plant_icon.dart';
import '../../../../core/plant_icons/generated_plant_svgs.dart';
import '../../../../core/theme/garden_theme.dart';
import '../../controller/garden_controller.dart';

class PlantPickerPanel extends StatefulWidget {
  const PlantPickerPanel({
    super.key,
    required this.controller,
    required this.onPlantChosen,
  });

  final GardenController controller;
  final ValueChanged<String> onPlantChosen;

  @override
  State<PlantPickerPanel> createState() => _PlantPickerPanelState();
}

class _PlantPickerPanelState extends State<PlantPickerPanel> {
  String activeCategory = 'vegetables';
  String query = '';

  List<_PlantIconEntry> get visibleEntries {
    final keys = generatedPlantCategories[activeCategory] ?? const <String>[];
    final normalizedQuery = query.trim().toLowerCase();

    final entries = keys
        .where((key) => generatedPlantSvgs.containsKey(key))
        .map(
          (key) => _PlantIconEntry(
            key: key,
            name: _displayNameForKey(key),
            category: activeCategory,
          ),
        )
        .where((entry) {
          if (normalizedQuery.isEmpty) return true;

          return entry.key.toLowerCase().contains(normalizedQuery) ||
              entry.name.toLowerCase().contains(normalizedQuery);
        })
        .toList();

    return entries;
  }

  int _countForCategory(String category) {
    final keys = generatedPlantCategories[category] ?? const <String>[];

    return keys.where((key) => generatedPlantSvgs.containsKey(key)).length;
  }

  @override
  Widget build(BuildContext context) {
    final entries = visibleEntries;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GardenTheme.border, width: 1.5),
      ),
      child: Column(
        children: [
          _header(),
          _tabs(),
          _searchBox(),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text(
                      'No plants found',
                      style: TextStyle(
                        color: GardenTheme.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: entries.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 145,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.84,
                        ),
                    itemBuilder: (context, index) {
                      final entry = entries[index];

                      return _PlantIconCard(
                        entry: entry,
                        onTap: () => widget.onPlantChosen(entry.name),
                      );
                    },
                  ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _header() {
    final total =
        _countForCategory('vegetables') +
        _countForCategory('herbs') +
        _countForCategory('trees');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF7),
        border: Border(bottom: BorderSide(color: GardenTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: GardenTheme.good, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Plant Icons',
              style: TextStyle(
                color: GardenTheme.ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: GardenTheme.border),
            ),
            child: Text(
              '$total SVGs',
              style: const TextStyle(
                color: GardenTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF7),
        border: Border(bottom: BorderSide(color: GardenTheme.border)),
      ),
      child: Row(
        children: [
          _tab('Vegetables', 'vegetables'),
          _tab('Herbs', 'herbs'),
          _tab('Trees', 'trees'),
        ],
      ),
    );
  }

  Widget _tab(String label, String category) {
    final selected = activeCategory == category;
    final count = _countForCategory(category);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            activeCategory = category;
            query = '';
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? GardenTheme.good : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? GardenTheme.ink : GardenTheme.muted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: GardenTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: GardenTheme.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            query = value;
          });
        },
        controller: TextEditingController(text: query)
          ..selection = TextSelection.collapsed(offset: query.length),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search ${activeCategory.replaceAll('_', ' ')}',
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 17),
                  onPressed: () {
                    setState(() {
                      query = '';
                    });
                  },
                ),
          filled: true,
          fillColor: const Color(0xFFF5F0E8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: GardenTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: GardenTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: GardenTheme.good, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF7),
        border: Border(top: BorderSide(color: GardenTheme.border)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: GardenTheme.good, size: 16),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Tap a card, then draw inside the selected bed.',
              style: TextStyle(
                color: GardenTheme.muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _displayNameForKey(String key) {
    return key
        .split('_')
        .where((part) => part.trim().isNotEmpty)
        .map((part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1);
        })
        .join(' ');
  }
}

class _PlantIconCard extends StatelessWidget {
  const _PlantIconCard({required this.entry, required this.onTap});

  final _PlantIconEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: entry.name,
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: const Color(0xFFFEFCF7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GardenTheme.border, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: GeneratedPlantIcon(cropName: entry.key, size: 78),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  entry.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GardenTheme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantIconEntry {
  const _PlantIconEntry({
    required this.key,
    required this.name,
    required this.category,
  });

  final String key;
  final String name;
  final String category;
}
