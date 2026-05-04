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

  GardenController? controller;

  int selectedIndex = 2;
  int renderedIndex = 2;

  bool loadingProject = true;
  bool saving = false;

  Timer? autosaveTimer;

  String? selectedPlantName;
  String statusMessage = 'Loading project...';

  @override
  void initState() {
    super.initState();
    PlantingSelectionBridge.pendingPlant.addListener(_syncPendingPlant);
    unawaited(_loadController());
  }

  @override
  void dispose() {
    autosaveTimer?.cancel();
    PlantingSelectionBridge.pendingPlant.removeListener(_syncPendingPlant);
    controller?.removeListener(_controllerChanged);
    controller?.dispose();
    super.dispose();
  }

  void _controllerChanged() {
    if (!mounted) return;
    setState(() {});
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

  Future<void> _loadController() async {
    if (controller != null) return;

    setState(() {
      loadingProject = true;
    });

    final nextController = GardenController();
    nextController.addListener(_controllerChanged);

    try {
      final saved = await storage.loadProject().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );

      if (saved != null) {
        nextController.project = saved;
        statusMessage = 'Saved project loaded.';
      } else {
        statusMessage = 'Demo project loaded.';
      }

      if (nextController.selectedBed == null &&
          nextController.beds.isNotEmpty) {
        nextController.selectBed(nextController.beds.first.id);
      }
    } catch (_) {
      statusMessage = 'Demo project loaded. Saved project skipped.';

      if (nextController.selectedBed == null &&
          nextController.beds.isNotEmpty) {
        nextController.selectBed(nextController.beds.first.id);
      }
    }

    if (!mounted) {
      nextController.dispose();
      return;
    }

    setState(() {
      controller = nextController;
      loadingProject = false;
      renderedIndex = selectedIndex;
    });
  }

  void _openSection(int index) {
    if (selectedIndex == index && renderedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    if (controller == null || loadingProject) {
      unawaited(_loadController());
      return;
    }

    // Let the custom tab bar paint immediately, then build the heavy page.
    Timer.run(() {
      if (!mounted) return;
      if (selectedIndex != index) return;

      setState(() {
        renderedIndex = index;
      });
    });
  }

  Future<void> _saveProject({bool showSnackBar = true}) async {
    final activeController = controller;
    if (activeController == null || saving) return;

    setState(() {
      saving = true;
    });

    try {
      await storage.saveProject(activeController.project);

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
    autosaveTimer = Timer(const Duration(milliseconds: 1200), () {
      unawaited(_saveProject(showSnackBar: false));
    });
  }

  void _choosePlant(String cropName) {
    final cleanName = cropName.trim();

    if (cleanName.isEmpty) {
      return;
    }

    PlantingSelectionBridge.selectPlant(cleanName);

    setState(() {
      selectedPlantName = cleanName;
    });

    _openSection(2);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$cleanName selected. Draw inside the bed.'),
        duration: const Duration(seconds: 2),
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

  Widget _buildPage(int index, GardenController activeController) {
    return switch (index) {
      0 => const GardenScreen(),
      1 => PlantInfoLibraryView(onPlantChosen: _choosePlant),
      2 => MobileBedDesigner(
        controller: activeController,
        selectedPlantName: selectedPlantName,
        onPickPlant: () => _openSection(1),
        onProjectChanged: _scheduleAutosave,
        onSave: () => _saveProject(),
      ),
      3 => const FruitTreeMapView(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _loadingBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeController = controller;

    final body = activeController == null || loadingProject
        ? _loadingBody()
        : RepaintBoundary(
            child: KeyedSubtree(
              key: ValueKey<int>(renderedIndex),
              child: _buildPage(renderedIndex, activeController),
            ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EA),
      appBar: AppBar(
        title: Text(activeController == null ? 'Garden Planner' : title),
        centerTitle: false,
        backgroundColor: const Color(0xFFF7F2EA),
        surfaceTintColor: Colors.transparent,
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
          if (activeController != null && selectedIndex == 2)
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
