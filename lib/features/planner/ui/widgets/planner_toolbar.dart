import 'package:flutter/material.dart';

import '../../../../core/theme/garden_theme.dart';

enum BedViewMode { dashboard, seedlings, map, cards, info }

enum BedFilterMode { all, healthy, attention, issues, withCrops }

class PlannerToolbar extends StatelessWidget {
  const PlannerToolbar({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.filterMode,
    required this.onFilterModeChanged,
    required this.onAddBed,
    required this.onOpenSettings,
    required this.onSaveProject,
    required this.onLoadProject,
    required this.onImportJson,
    required this.onExportJson,
    required this.onClearSavedProject,
    required this.onResetDemoProject,
    required this.onUndo,
    required this.onRedo,
    required this.allowOverlap,
    required this.onAllowOverlapChanged,
    required this.zoomPercent,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
    required this.onDeleteSelected,
  });

  final BedViewMode viewMode;
  final ValueChanged<BedViewMode> onViewModeChanged;

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  final BedFilterMode filterMode;
  final ValueChanged<BedFilterMode> onFilterModeChanged;

  final VoidCallback onAddBed;
  final VoidCallback onOpenSettings;
  final VoidCallback onSaveProject;
  final VoidCallback onLoadProject;
  final VoidCallback onImportJson;
  final VoidCallback onExportJson;
  final VoidCallback onClearSavedProject;
  final VoidCallback onResetDemoProject;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool allowOverlap;
  final ValueChanged<bool> onAllowOverlapChanged;
  final int zoomPercent;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;
  final VoidCallback? onDeleteSelected;

  bool get _showBedTools {
    return viewMode == BedViewMode.map || viewMode == BedViewMode.cards;
  }

  bool get _showMapTools {
    return viewMode == BedViewMode.map;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 76),
      decoration: const BoxDecoration(
        color: GardenTheme.panel,
        border: Border(bottom: BorderSide(color: GardenTheme.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;

          if (compact) {
            return _CompactToolbar(
              viewMode: viewMode,
              onViewModeChanged: onViewModeChanged,
              searchQuery: searchQuery,
              onSearchChanged: onSearchChanged,
              filterMode: filterMode,
              onFilterModeChanged: onFilterModeChanged,
              onAddBed: onAddBed,
              onOpenSettings: onOpenSettings,
              onSaveProject: onSaveProject,
              onLoadProject: onLoadProject,
              onImportJson: onImportJson,
              onExportJson: onExportJson,
              onClearSavedProject: onClearSavedProject,
              onResetDemoProject: onResetDemoProject,
              onUndo: onUndo,
              onRedo: onRedo,
              allowOverlap: allowOverlap,
              onAllowOverlapChanged: onAllowOverlapChanged,
              zoomPercent: zoomPercent,
              onZoomIn: onZoomIn,
              onZoomOut: onZoomOut,
              onResetZoom: onResetZoom,
              onDeleteSelected: onDeleteSelected,
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _AreaTabs(value: viewMode, onChanged: onViewModeChanged),
                const SizedBox(width: 12),
                _PrimaryButton(
                  icon: Icons.add,
                  label: 'Add bed',
                  onPressed: onAddBed,
                ),
                if (_showBedTools) ...[
                  const SizedBox(width: 12),
                  _SearchBox(
                    initialValue: searchQuery,
                    compact: false,
                    onChanged: onSearchChanged,
                  ),
                  const SizedBox(width: 10),
                  _FilterMenu(
                    value: filterMode,
                    onChanged: onFilterModeChanged,
                  ),
                ],
                if (_showMapTools) ...[
                  const SizedBox(width: 12),
                  _ZoomControl(
                    zoomPercent: zoomPercent,
                    onZoomIn: onZoomIn,
                    onZoomOut: onZoomOut,
                    onResetZoom: onResetZoom,
                  ),
                  const SizedBox(width: 10),
                  _StatusPill(
                    icon: allowOverlap
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                    label: allowOverlap ? 'Overlap On' : 'Overlap Off',
                    color: allowOverlap ? GardenTheme.good : GardenTheme.bad,
                    background: allowOverlap
                        ? const Color(0xFFEEF8F0)
                        : const Color(0xFFFFF0EE),
                    onTap: () => onAllowOverlapChanged(!allowOverlap),
                  ),
                ],
                const SizedBox(width: 12),
                _IconAction(icon: Icons.undo, label: 'Undo', onPressed: onUndo),
                const SizedBox(width: 8),
                _IconAction(icon: Icons.redo, label: 'Redo', onPressed: onRedo),
                if (onDeleteSelected != null) ...[
                  const SizedBox(width: 8),
                  _DangerButton(
                    icon: Icons.delete_outline,
                    label: 'Delete bed',
                    onPressed: onDeleteSelected!,
                  ),
                ],
                const SizedBox(width: 12),
                _ProjectMenu(
                  onOpenSettings: onOpenSettings,
                  onSaveProject: onSaveProject,
                  onLoadProject: onLoadProject,
                  onImportJson: onImportJson,
                  onExportJson: onExportJson,
                  onClearSavedProject: onClearSavedProject,
                  onResetDemoProject: onResetDemoProject,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompactToolbar extends StatelessWidget {
  const _CompactToolbar({
    required this.viewMode,
    required this.onViewModeChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.filterMode,
    required this.onFilterModeChanged,
    required this.onAddBed,
    required this.onOpenSettings,
    required this.onSaveProject,
    required this.onLoadProject,
    required this.onImportJson,
    required this.onExportJson,
    required this.onClearSavedProject,
    required this.onResetDemoProject,
    required this.onUndo,
    required this.onRedo,
    required this.allowOverlap,
    required this.onAllowOverlapChanged,
    required this.zoomPercent,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
    required this.onDeleteSelected,
  });

  final BedViewMode viewMode;
  final ValueChanged<BedViewMode> onViewModeChanged;

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  final BedFilterMode filterMode;
  final ValueChanged<BedFilterMode> onFilterModeChanged;

  final VoidCallback onAddBed;
  final VoidCallback onOpenSettings;
  final VoidCallback onSaveProject;
  final VoidCallback onLoadProject;
  final VoidCallback onImportJson;
  final VoidCallback onExportJson;
  final VoidCallback onClearSavedProject;
  final VoidCallback onResetDemoProject;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool allowOverlap;
  final ValueChanged<bool> onAllowOverlapChanged;
  final int zoomPercent;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;
  final VoidCallback? onDeleteSelected;

  bool get _showBedTools {
    return viewMode == BedViewMode.map || viewMode == BedViewMode.cards;
  }

  bool get _showMapTools {
    return viewMode == BedViewMode.map;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _AreaTabs(value: viewMode, onChanged: onViewModeChanged),
                const SizedBox(width: 10),
                _PrimaryButton(
                  icon: Icons.add,
                  label: 'Add bed',
                  onPressed: onAddBed,
                ),
                const SizedBox(width: 10),
                _ProjectMenu(
                  onOpenSettings: onOpenSettings,
                  onSaveProject: onSaveProject,
                  onLoadProject: onLoadProject,
                  onImportJson: onImportJson,
                  onExportJson: onExportJson,
                  onClearSavedProject: onClearSavedProject,
                  onResetDemoProject: onResetDemoProject,
                ),
              ],
            ),
          ),
          if (_showBedTools) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SearchBox(
                    initialValue: searchQuery,
                    compact: true,
                    onChanged: onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterMenu(value: filterMode, onChanged: onFilterModeChanged),
              ],
            ),
          ],
          if (_showMapTools) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ZoomControl(
                    zoomPercent: zoomPercent,
                    onZoomIn: onZoomIn,
                    onZoomOut: onZoomOut,
                    onResetZoom: onResetZoom,
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    icon: allowOverlap
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                    label: allowOverlap ? 'Overlap On' : 'Overlap Off',
                    color: allowOverlap ? GardenTheme.good : GardenTheme.bad,
                    background: allowOverlap
                        ? const Color(0xFFEEF8F0)
                        : const Color(0xFFFFF0EE),
                    onTap: () => onAllowOverlapChanged(!allowOverlap),
                  ),
                  const SizedBox(width: 8),
                  _IconAction(
                    icon: Icons.undo,
                    label: 'Undo',
                    onPressed: onUndo,
                  ),
                  const SizedBox(width: 8),
                  _IconAction(
                    icon: Icons.redo,
                    label: 'Redo',
                    onPressed: onRedo,
                  ),
                  if (onDeleteSelected != null) ...[
                    const SizedBox(width: 8),
                    _DangerButton(
                      icon: Icons.delete_outline,
                      label: 'Delete bed',
                      onPressed: onDeleteSelected!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AreaTabs extends StatelessWidget {
  const _AreaTabs({required this.value, required this.onChanged});

  final BedViewMode value;
  final ValueChanged<BedViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GardenTheme.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AreaTab(
            label: 'Dashboard',
            icon: Icons.dashboard_customize_outlined,
            selected: value == BedViewMode.dashboard,
            onTap: () => onChanged(BedViewMode.dashboard),
          ),
          _AreaTab(
            label: 'Seedlings',
            icon: Icons.spa_outlined,
            selected: value == BedViewMode.seedlings,
            onTap: () => onChanged(BedViewMode.seedlings),
          ),
          _AreaTab(
            label: 'Map',
            icon: Icons.map_outlined,
            selected: value == BedViewMode.map,
            onTap: () => onChanged(BedViewMode.map),
          ),
          _AreaTab(
            label: 'Beds',
            icon: Icons.view_agenda_outlined,
            selected: value == BedViewMode.cards,
            onTap: () => onChanged(BedViewMode.cards),
          ),
        ],
      ),
    );
  }
}

class _AreaTab extends StatelessWidget {
  const _AreaTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? GardenTheme.ink : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? GardenTheme.cream : GardenTheme.ink,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? GardenTheme.cream : GardenTheme.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatefulWidget {
  const _SearchBox({
    required this.initialValue,
    required this.compact,
    required this.onChanged,
  });

  final String initialValue;
  final bool compact;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _SearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue &&
        controller.text != widget.initialValue) {
      controller.text = widget.initialValue;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.compact ? null : 360,
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: widget.onChanged,
        style: const TextStyle(
          color: GardenTheme.ink,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Search beds, crops, zones',
          prefixIcon: const Icon(
            Icons.search,
            color: GardenTheme.muted,
            size: 18,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: GardenTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: GardenTheme.ink, width: 1.3),
          ),
        ),
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({required this.value, required this.onChanged});

  final BedFilterMode value;
  final ValueChanged<BedFilterMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BedFilterMode>(
      tooltip: 'Filter beds',
      color: GardenTheme.panel,
      elevation: 10,
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: GardenTheme.border),
      ),
      onSelected: onChanged,
      itemBuilder: (context) {
        return [
          _filterItem(BedFilterMode.all, 'All beds', Icons.layers_outlined),
          _filterItem(BedFilterMode.healthy, 'Healthy', Icons.check_circle),
          _filterItem(
            BedFilterMode.attention,
            'Needs attention',
            Icons.warning_amber,
          ),
          _filterItem(BedFilterMode.issues, 'Issues / hold', Icons.block),
          _filterItem(BedFilterMode.withCrops, 'With crops', Icons.eco),
        ];
      },
      child: _PillButton(icon: Icons.filter_list, label: _filterLabel(value)),
    );
  }

  PopupMenuItem<BedFilterMode> _filterItem(
    BedFilterMode mode,
    String label,
    IconData icon,
  ) {
    final selected = mode == value;

    return PopupMenuItem<BedFilterMode>(
      value: mode,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle : icon,
            size: 17,
            color: selected ? GardenTheme.good : GardenTheme.ink,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: GardenTheme.ink,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(BedFilterMode mode) {
    switch (mode) {
      case BedFilterMode.all:
        return 'Filter';
      case BedFilterMode.healthy:
        return 'Healthy';
      case BedFilterMode.attention:
        return 'Attention';
      case BedFilterMode.issues:
        return 'Issues';
      case BedFilterMode.withCrops:
        return 'Crops';
    }
  }
}

class _ZoomControl extends StatelessWidget {
  const _ZoomControl({
    required this.zoomPercent,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  final int zoomPercent;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallIconButton(
            icon: Icons.remove,
            tooltip: 'Zoom out',
            onPressed: onZoomOut,
          ),
          InkWell(
            onTap: onResetZoom,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: GardenTheme.border),
                ),
              ),
              child: Text(
                '$zoomPercent%',
                style: const TextStyle(
                  color: GardenTheme.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          _SmallIconButton(
            icon: Icons.add,
            tooltip: 'Zoom in',
            onPressed: onZoomIn,
          ),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 38,
          height: 44,
          child: Icon(icon, size: 17, color: GardenTheme.ink),
        ),
      ),
    );
  }
}

class _ProjectMenu extends StatelessWidget {
  const _ProjectMenu({
    required this.onOpenSettings,
    required this.onSaveProject,
    required this.onLoadProject,
    required this.onImportJson,
    required this.onExportJson,
    required this.onClearSavedProject,
    required this.onResetDemoProject,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onSaveProject;
  final VoidCallback onLoadProject;
  final VoidCallback onImportJson;
  final VoidCallback onExportJson;
  final VoidCallback onClearSavedProject;
  final VoidCallback onResetDemoProject;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      tooltip: 'Project options',
      color: GardenTheme.panel,
      elevation: 10,
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: GardenTheme.border),
      ),
      onSelected: (action) => action.callback(),
      itemBuilder: (context) {
        return [
          _sectionHeader('Project'),
          _menuItem(
            label: 'Project Settings',
            icon: Icons.tune,
            callback: onOpenSettings,
          ),
          _menuItem(
            label: 'Save Project',
            icon: Icons.save_outlined,
            callback: onSaveProject,
          ),
          _menuItem(
            label: 'Load Project',
            icon: Icons.folder_open_outlined,
            callback: onLoadProject,
          ),
          const PopupMenuDivider(),
          _sectionHeader('Data'),
          _menuItem(
            label: 'Import JSON',
            icon: Icons.upload_file,
            callback: onImportJson,
          ),
          _menuItem(
            label: 'Export JSON',
            icon: Icons.download,
            callback: onExportJson,
          ),
          const PopupMenuDivider(),
          _sectionHeader('Reset'),
          _menuItem(
            label: 'Clear Saved Project',
            icon: Icons.cleaning_services_outlined,
            callback: onClearSavedProject,
          ),
          _menuItem(
            label: 'Reset Demo Project',
            icon: Icons.restart_alt,
            destructive: true,
            callback: onResetDemoProject,
          ),
        ];
      },
      child: _PillButton(icon: Icons.folder_outlined, label: 'Project'),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GardenTheme.ink,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: GardenTheme.cream, size: 16),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: GardenTheme.cream,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0EE),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GardenTheme.bad.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Icon(icon, color: GardenTheme.bad, size: 15),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: GardenTheme.bad,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GardenTheme.border),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: enabled
                    ? GardenTheme.ink
                    : GardenTheme.muted.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: enabled
                      ? GardenTheme.ink
                      : GardenTheme.muted.withValues(alpha: 0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GardenTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: GardenTheme.ink),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: GardenTheme.ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: GardenTheme.muted,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.26)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
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
        ),
      ),
    );
  }
}

class _MenuAction {
  const _MenuAction(this.callback);

  final VoidCallback callback;
}

PopupMenuItem<_MenuAction> _menuItem({
  required String label,
  required IconData icon,
  required VoidCallback callback,
  bool enabled = true,
  bool destructive = false,
}) {
  return PopupMenuItem<_MenuAction>(
    value: _MenuAction(callback),
    enabled: enabled,
    child: Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: !enabled
              ? GardenTheme.muted.withValues(alpha: 0.45)
              : destructive
              ? GardenTheme.bad
              : GardenTheme.ink,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: !enabled
                  ? GardenTheme.muted.withValues(alpha: 0.45)
                  : destructive
                  ? GardenTheme.bad
                  : GardenTheme.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

PopupMenuItem<_MenuAction> _sectionHeader(String label) {
  return PopupMenuItem<_MenuAction>(
    enabled: false,
    height: 28,
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: GardenTheme.muted,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    ),
  );
}
