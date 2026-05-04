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
  bool bootstrapping = false;
  bool saving = false;

  Timer? autosaveTimer;

  final Set<int> openedTabs = <int>{};

  String? selectedPlantName;
  String statusMessage = 'Ready.';

  @override
  void initState() {
    super.initState();
    PlantingSelectionBridge.pendingPlant.addListener(_syncPendingPlant);
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

  Future<void> _bootstrapAndOpen(int index) async {
    if (controller != null) {
      setState(() {
        selectedIndex = index;
        openedTabs.add(index);
      });
      return;
    }

    if (bootstrapping) return;

    setState(() {
      bootstrapping = true;
      selectedIndex = index;
    });

    // Let Android draw the first frame before creating/loading the project.
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final nextController = GardenController();
    nextController.addListener(_controllerChanged);

    controller = nextController;

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

    if (!mounted) return;

    setState(() {
      bootstrapping = false;
      selectedIndex = index;
      openedTabs.add(index);
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
      _saveProject(showSnackBar: false);
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

    _bootstrapAndOpen(2);

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
    if (!openedTabs.contains(index)) {
      return const SizedBox.shrink();
    }

    return switch (index) {
      0 => const GardenScreen(),
      1 => PlantInfoLibraryView(onPlantChosen: _choosePlant),
      2 => MobileBedDesigner(
        controller: activeController,
        selectedPlantName: selectedPlantName,
        onPickPlant: () => _bootstrapAndOpen(1),
        onProjectChanged: _scheduleAutosave,
        onSave: () => _saveProject(),
      ),
      3 => const FruitTreeMapView(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _startupBody() {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Garden Planner',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Open only the section you need. This keeps Android startup light.',
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: bootstrapping
                        ? null
                        : () => _bootstrapAndOpen(2),
                    icon: bootstrapping
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.brush_outlined),
                    label: const Text('Open Bed Designer'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: bootstrapping
                        ? null
                        : () => _bootstrapAndOpen(1),
                    icon: const Icon(Icons.eco_outlined),
                    label: const Text('Open Plants'),
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

    final body = activeController == null
        ? _startupBody()
        : IndexedStack(
            index: selectedIndex,
            children: List<Widget>.generate(
              4,
              (index) => _buildPage(index, activeController),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _bootstrapAndOpen,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'Plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.brush_outlined),
            selectedIcon: Icon(Icons.brush),
            label: 'Design',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Fruit Scout',
          ),
        ],
      ),
    );
  }
}
