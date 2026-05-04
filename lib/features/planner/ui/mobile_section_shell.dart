import 'dart:async';

import 'package:flutter/material.dart';

import 'package:garden_planner/features/planner/controller/garden_controller.dart';
import 'package:garden_planner/features/planner/services/planting_selection_bridge.dart';
import 'package:garden_planner/features/planner/services/project_storage_service.dart';
import 'package:garden_planner/features/planner/ui/garden_screen.dart';
import 'package:garden_planner/features/planner/ui/widgets/fruit_tree_map_view.dart';
import 'package:garden_planner/features/planner/ui/widgets/mobile_bed_designer_strict.dart';
import 'package:garden_planner/features/planner/ui/widgets/plant_info_library_view.dart';

class MobileSectionShell extends StatefulWidget {
  const MobileSectionShell({super.key});

  @override
  State<MobileSectionShell> createState() => _MobileSectionShellState();
}

class _MobileSectionShellState extends State<MobileSectionShell> {
  final ProjectStorageService storage = ProjectStorageService();

  late final GardenController controller;

  int selectedIndex = 2;
  int renderedIndex = 2;

  bool loadingSavedProject = false;
  bool saving = false;

  Timer? autosaveTimer;
  Timer? renderTimer;

  String? selectedPlantName;
  String statusMessage = 'Ready.';

  @override
  void initState() {
    super.initState();

    controller = GardenController();
    controller.addListener(_controllerChanged);
    _selectDefaultBed();

    PlantingSelectionBridge.pendingPlant.addListener(_syncPendingPlant);

    // Show the app immediately. Saved data loads in the background.
    unawaited(_loadSavedProjectInBackground());
  }

  @override
  void dispose() {
    autosaveTimer?.cancel();
    renderTimer?.cancel();
    PlantingSelectionBridge.pendingPlant.removeListener(_syncPendingPlant);
    controller.removeListener(_controllerChanged);
    controller.dispose();
    super.dispose();
  }

  void _controllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _selectDefaultBed() {
    if (controller.selectedBed == null && controller.beds.isNotEmpty) {
      controller.selectBed(controller.beds.first.id);
    }
  }

  void _syncPendingPlant() {
    final plant = PlantingSelectionBridge.pendingPlant.value?.trim();

    if (plant == null || plant.isEmpty) {
      return;
    }

    setState(() {
      selectedPlantName = plant;
    });
  }

  Future<void> _loadSavedProjectInBackground() async {
    if (loadingSavedProject) return;

    setState(() {
      loadingSavedProject = true;
      statusMessage = 'Loading saved project...';
    });

    try {
      final saved = await storage.loadProject().timeout(
        const Duration(milliseconds: 900),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (saved != null) {
        controller.project = saved;
        _selectDefaultBed();

        setState(() {
          statusMessage = 'Saved project loaded.';
        });
      } else {
        setState(() {
          statusMessage = 'Demo project loaded.';
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        statusMessage = 'Demo project loaded. Saved project skipped.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loadingSavedProject = false;
        });
      }
    }
  }

  void _openSection(int index) {
    if (selectedIndex == index && renderedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    // Paint the selected tab first. Build the heavy page on the next event turn.
    renderTimer?.cancel();
    renderTimer = Timer(Duration.zero, () {
      if (!mounted) return;
      if (selectedIndex != index) return;

      setState(() {
        renderedIndex = index;
      });
    });
  }

  Future<void> _saveProject({bool showSnackBar = true}) async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      await storage.saveProject(controller.project);

      if (!mounted) return;

      if (showSnackBar) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Garden project saved.')));
      } else {
        statusMessage = 'Autosaved.';
      }
    } catch (error) {
      if (!mounted) return;

      if (showSnackBar) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $error')));
      } else {
        statusMessage = 'Autosave failed.';
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  void _scheduleAutosave() {
    autosaveTimer?.cancel();
    autosaveTimer = Timer(const Duration(milliseconds: 1400), () {
      unawaited(_saveProject(showSnackBar: false));
    });
  }

  void _choosePlant(String cropName) {
    final cleanName = cropName.trim();

    if (cleanName.isEmpty) return;

    PlantingSelectionBridge.selectPlant(cleanName);

    setState(() {
      selectedPlantName = cleanName;
    });

    _openSection(2);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$cleanName selected. Draw inside the bed.'),
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  String get title {
    return switch (selectedIndex) {
      0 => 'Planner',
      1 => 'Plants',
      2 => 'Bed Designer',
      3 => 'Fruit Scout',
      _ => 'Garden Planner',
    };
  }

  Widget _buildPage(int index) {
    return switch (index) {
      0 => const GardenScreen(),
      1 => PlantInfoLibraryView(onPlantChosen: _choosePlant),
      2 => MobileBedDesigner(
        controller: controller,
        selectedPlantName: selectedPlantName,
        onPickPlant: () => _openSection(1),
        onProjectChanged: _scheduleAutosave,
        onSave: () => _saveProject(),
      ),
      3 => const FruitTreeMapView(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final body = RepaintBoundary(
      child: KeyedSubtree(
        key: ValueKey<int>(renderedIndex),
        child: _buildPage(renderedIndex),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EA),
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        backgroundColor: const Color(0xFFF7F2EA),
        surfaceTintColor: Colors.transparent,
        bottom: loadingSavedProject
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
        actions: [
          if (selectedPlantName != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Center(
                child: Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    selectedPlantName!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          if (selectedIndex == 2)
            IconButton(
              tooltip: 'Save',
              onPressed: saving ? null : () => _saveProject(),
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
            ),
        ],
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: _FastTabBar(
        selectedIndex: selectedIndex,
        onSelected: _openSection,
      ),
    );
  }
}

class _FastTabBar extends StatelessWidget {
  const _FastTabBar({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const List<_FastTabItemData> items = [
    _FastTabItemData(
      icon: Icons.yard_outlined,
      selectedIcon: Icons.yard,
      label: 'Planner',
    ),
    _FastTabItemData(
      icon: Icons.eco_outlined,
      selectedIcon: Icons.eco,
      label: 'Plants',
    ),
    _FastTabItemData(
      icon: Icons.brush_outlined,
      selectedIcon: Icons.brush,
      label: 'Design',
    ),
    _FastTabItemData(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      label: 'Fruit Scout',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: _FastTabItem(
                    data: items[index],
                    selected: selectedIndex == index,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FastTabItemData {
  const _FastTabItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _FastTabItem extends StatelessWidget {
  const _FastTabItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _FastTabItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    final background = selected ? scheme.primaryContainer : Colors.transparent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selected ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Icon(
                  selected ? data.selectedIcon : data.icon,
                  color: foreground,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
