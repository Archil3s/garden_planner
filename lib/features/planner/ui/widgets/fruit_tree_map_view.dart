import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FruitTreeMapView extends StatefulWidget {
  const FruitTreeMapView({super.key});

  @override
  State<FruitTreeMapView> createState() => _FruitTreeMapViewState();
}

class _FruitTreeMapViewState extends State<FruitTreeMapView> {
  static const String storageKey = 'fruit_scout_entries_v2';

  final List<_FruitScoutEntry> entries = <_FruitScoutEntry>[];
  final TextEditingController notesController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  _GpsPoint? currentPoint;

  bool loadingLocation = false;
  bool locationUnavailable = false;
  bool showOnlyNearby = false;
  bool showOnlyNeedsRevisit = false;

  String selectedType = 'Apple';
  String selectedStatus = 'Fruiting';
  String selectedAccess = 'Unknown';
  String selectedFruitCategory = 'All';
  String filterType = 'All';
  String filterStatus = 'All';
  String filterAccess = 'All';

  static const List<_FruitTypeInfo> fruitTypes = [
    _FruitTypeInfo('Apple', 'Core'),
    _FruitTypeInfo('Crabapple', 'Core'),
    _FruitTypeInfo('Pear', 'Core'),
    _FruitTypeInfo('Asian Pear', 'Core'),
    _FruitTypeInfo('Quince', 'Core'),
    _FruitTypeInfo('Peach', 'Stone'),
    _FruitTypeInfo('Nectarine', 'Stone'),
    _FruitTypeInfo('Apricot', 'Stone'),
    _FruitTypeInfo('Plum', 'Stone'),
    _FruitTypeInfo('Cherry', 'Stone'),
    _FruitTypeInfo('Damson', 'Stone'),
    _FruitTypeInfo('Fig', 'Mediterranean'),
    _FruitTypeInfo('Mulberry', 'Mediterranean'),
    _FruitTypeInfo('Persimmon', 'Mediterranean'),
    _FruitTypeInfo('Pomegranate', 'Mediterranean'),
    _FruitTypeInfo('Olive', 'Mediterranean'),
    _FruitTypeInfo('Lemon', 'Citrus'),
    _FruitTypeInfo('Lime', 'Citrus'),
    _FruitTypeInfo('Orange', 'Citrus'),
    _FruitTypeInfo('Mandarin', 'Citrus'),
    _FruitTypeInfo('Tangerine', 'Citrus'),
    _FruitTypeInfo('Grapefruit', 'Citrus'),
    _FruitTypeInfo('Kumquat', 'Citrus'),
    _FruitTypeInfo('Yuzu', 'Citrus'),
    _FruitTypeInfo('Grape', 'Vine'),
    _FruitTypeInfo('Kiwi', 'Vine'),
    _FruitTypeInfo('Passionfruit', 'Vine'),
    _FruitTypeInfo('Blueberry', 'Berry'),
    _FruitTypeInfo('Blackberry', 'Berry'),
    _FruitTypeInfo('Raspberry', 'Berry'),
    _FruitTypeInfo('Boysenberry', 'Berry'),
    _FruitTypeInfo('Gooseberry', 'Berry'),
    _FruitTypeInfo('Currant', 'Berry'),
    _FruitTypeInfo('Elderberry', 'Berry'),
    _FruitTypeInfo('Strawberry', 'Berry'),
    _FruitTypeInfo('Feijoa', 'Subtropical'),
    _FruitTypeInfo('Guava', 'Subtropical'),
    _FruitTypeInfo('Loquat', 'Subtropical'),
    _FruitTypeInfo('Avocado', 'Subtropical'),
    _FruitTypeInfo('Banana', 'Subtropical'),
    _FruitTypeInfo('Mango', 'Subtropical'),
    _FruitTypeInfo('Papaya', 'Subtropical'),
    _FruitTypeInfo('Pawpaw', 'Subtropical'),
    _FruitTypeInfo('Lychee', 'Subtropical'),
    _FruitTypeInfo('Cherimoya', 'Subtropical'),
    _FruitTypeInfo('Almond', 'Nut'),
    _FruitTypeInfo('Walnut', 'Nut'),
    _FruitTypeInfo('Hazelnut', 'Nut'),
    _FruitTypeInfo('Chestnut', 'Nut'),
    _FruitTypeInfo('Pecan', 'Nut'),
    _FruitTypeInfo('Macadamia', 'Nut'),
    _FruitTypeInfo('Unknown Fruit', 'Other'),
    _FruitTypeInfo('Other', 'Other'),
  ];

  static const List<String> fruitStatuses = [
    'Flowering',
    'Fruiting',
    'Harvested',
    'Dormant',
    'Unknown',
  ];

  static const List<String> accessTypes = [
    'Public',
    'Ask permission',
    'Private',
    'Unknown',
  ];

  List<String> get fruitTypeNames =>
      fruitTypes.map((item) => item.name).toList();

  List<String> get fruitCategories {
    final categories = fruitTypes.map((item) => item.category).toSet().toList()
      ..sort();

    return ['All', ...categories];
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();

    // Disabled during Android startup.
    // GPS should be requested only after the user opens/uses Fruit Scout.
  }

  @override
  void dispose() {
    notesController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;

    setState(() {
      entries
        ..clear()
        ..addAll(
          decoded.map((item) {
            return _FruitScoutEntry.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          }),
        );
    });
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      storageKey,
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> _refreshLocation() async {
    setState(() {
      loadingLocation = true;
      locationUnavailable = false;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          loadingLocation = false;
          locationUnavailable = true;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          loadingLocation = false;
          locationUnavailable = true;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        currentPoint = _GpsPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          capturedAt: DateTime.now(),
        );
        loadingLocation = false;
        locationUnavailable = false;
      });
    } on MissingPluginException {
      setState(() {
        loadingLocation = false;
        locationUnavailable = true;
      });
    } catch (_) {
      setState(() {
        loadingLocation = false;
        locationUnavailable = true;
      });
    }
  }

  Future<void> _saveHere() async {
    if (currentPoint == null) {
      await _refreshLocation();
    }

    final point = currentPoint;
    final seasonStatus = _seasonStatusForFruit(selectedType);
    final harvestWindow = _harvestWindowForFruit(selectedType);

    if (point == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS location is unavailable.'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    final entry = _FruitScoutEntry(
      id: 'fruit-${DateTime.now().microsecondsSinceEpoch}',
      type: selectedType,
      status: selectedStatus,
      access: selectedAccess,
      notes: notesController.text.trim(),
      latitude: point.latitude,
      longitude: point.longitude,
      accuracyMeters: point.accuracyMeters,
      needsRevisit: selectedStatus == 'Unknown',
      lastVisitedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      entries.add(entry);
      notesController.clear();
    });

    await _saveEntries();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$selectedType saved.'),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _editEntry(_FruitScoutEntry entry) async {
    final updated = await _openEditSheet(entry);

    if (updated == null) return;

    setState(() {
      final index = entries.indexWhere((item) => item.id == entry.id);

      if (index != -1) {
        entries[index] = updated;
      }
    });

    await _saveEntries();
  }

  Future<_FruitScoutEntry?> _openEditSheet(_FruitScoutEntry entry) async {
    final notes = TextEditingController(text: entry.notes);
    var type = entry.type;
    var status = entry.status;
    var access = entry.access;
    var needsRevisit = entry.needsRevisit;

    final result = await showModalBottomSheet<_FruitScoutEntry>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF4),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 18),
              child: SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      'Edit fruit tree',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Fruit type',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    _FruitTypePicker(
                      values: fruitTypes,
                      selected: type,
                      selectedCategory: 'All',
                      onCategoryChanged: (_) {},
                      onSelected: (value) {
                        setSheetState(() {
                          type = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    _ChoiceWrap(
                      values: fruitStatuses,
                      selected: status,
                      onSelected: (value) {
                        setSheetState(() {
                          status = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Access',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    _ChoiceWrap(
                      values: accessTypes,
                      selected: access,
                      onSelected: (value) {
                        setSheetState(() {
                          access = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      value: needsRevisit,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Needs revisit',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'Show this tree in the revisit filter.',
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          needsRevisit = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: notes,
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Landmark, access notes, harvest detail...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _CoordinateBox(
                      latitude: entry.latitude,
                      longitude: entry.longitude,
                      accuracyMeters: entry.accuracyMeters,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(
                          entry.copyWith(
                            type: type,
                            status: status,
                            access: access,
                            notes: notes.text.trim(),
                            needsRevisit: needsRevisit,
                            updatedAt: DateTime.now(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    notes.dispose();
    return result;
  }

  Future<void> _deleteEntry(_FruitScoutEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove saved tree?'),
          content: Text('Remove ${entry.type} from your Fruit Scout list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _removeEntryNow(entry);
  }

  Future<void> _removeEntryNow(_FruitScoutEntry entry) async {
    final index = entries.indexWhere((item) => item.id == entry.id);

    if (index == -1) return;

    setState(() {
      entries.removeAt(index);
    });

    await _saveEntries();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.type} removed.'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final insertIndex = index.clamp(0, entries.length);

            setState(() {
              entries.insert(insertIndex, entry);
            });

            await _saveEntries();
          },
        ),
      ),
    );
  }

  Future<void> _markVisitedToday(_FruitScoutEntry entry) async {
    setState(() {
      final index = entries.indexWhere((item) => item.id == entry.id);

      if (index != -1) {
        entries[index] = entry.copyWith(
          lastVisitedAt: DateTime.now(),
          needsRevisit: false,
          updatedAt: DateTime.now(),
        );
      }
    });

    await _saveEntries();
  }

  Future<void> _toggleNeedsRevisit(_FruitScoutEntry entry) async {
    setState(() {
      final index = entries.indexWhere((item) => item.id == entry.id);

      if (index != -1) {
        entries[index] = entry.copyWith(
          needsRevisit: !entry.needsRevisit,
          updatedAt: DateTime.now(),
        );
      }
    });

    await _saveEntries();
  }

  Future<void> _copyCoordinates(_FruitScoutEntry entry) async {
    await Clipboard.setData(
      ClipboardData(text: '${entry.latitude}, ${entry.longitude}'),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GPS copied.'),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _openMaps(_FruitScoutEntry entry) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${entry.latitude},${entry.longitude}',
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched) {
      await _copyCoordinates(entry);
    }
  }

  Future<void> _copyCsv() async {
    final csv = StringBuffer();

    csv.writeln(
      'type,status,access,needs_revisit,latitude,longitude,accuracy_m,notes,last_visited,created_at,updated_at',
    );

    for (final entry in entries) {
      csv.writeln(
        [
          _csv(entry.type),
          _csv(entry.status),
          _csv(entry.access),
          entry.needsRevisit,
          entry.latitude,
          entry.longitude,
          entry.accuracyMeters,
          _csv(entry.notes),
          _csv(entry.lastVisitedAt?.toIso8601String() ?? ''),
          _csv(entry.createdAt.toIso8601String()),
          _csv(entry.updatedAt.toIso8601String()),
        ].join(','),
      );
    }

    await Clipboard.setData(ClipboardData(text: csv.toString()));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fruit Scout CSV copied.'),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }

  String _csv(Object value) {
    final text = value.toString().replaceAll('"', '""');
    return '"$text"';
  }

  double? _distanceTo(_FruitScoutEntry entry) {
    final here = currentPoint;

    if (here == null) return null;

    return _distanceMeters(
      here.latitude,
      here.longitude,
      entry.latitude,
      entry.longitude,
    );
  }

  List<_FruitScoutEntry> get _filteredEntries {
    final query = searchController.text.trim().toLowerCase();

    final filtered = entries.where((entry) {
      if (filterType != 'All' && entry.type != filterType) return false;
      if (filterStatus != 'All' && entry.status != filterStatus) return false;
      if (filterAccess != 'All' && entry.access != filterAccess) return false;
      if (showOnlyNeedsRevisit && !entry.needsRevisit) return false;

      if (showOnlyNearby) {
        final distance = _distanceTo(entry);

        if (distance == null || distance > 1000) return false;
      }

      if (query.isEmpty) return true;

      return entry.type.toLowerCase().contains(query) ||
          entry.status.toLowerCase().contains(query) ||
          entry.access.toLowerCase().contains(query) ||
          entry.notes.toLowerCase().contains(query);
    }).toList();

    if (currentPoint == null) {
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return filtered;
    }

    filtered.sort((a, b) {
      final ad = _distanceTo(a) ?? double.infinity;
      final bd = _distanceTo(b) ?? double.infinity;

      return ad.compareTo(bd);
    });

    return filtered;
  }

  String _distanceLabel(double? meters) {
    if (meters == null) return 'Distance unavailable';

    if (meters < 1000) {
      return '${meters.round()}m away';
    }

    return '${(meters / 1000).toStringAsFixed(1)}km away';
  }

  _ScoutStats get _stats {
    final fruiting = entries
        .where((entry) => entry.status == 'Fruiting')
        .length;
    final public = entries.where((entry) => entry.access == 'Public').length;
    final revisit = entries.where((entry) => entry.needsRevisit).length;

    return _ScoutStats(
      total: entries.length,
      fruiting: fruiting,
      publicAccess: public,
      needsRevisit: revisit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;

    final status = loadingLocation
        ? 'Finding GPS...'
        : locationUnavailable
        ? 'GPS unavailable'
        : currentPoint == null
        ? '${entries.length} saved trees'
        : '${entries.length} saved trees ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ nearby first';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EA),
      body: SafeArea(
        child: Column(
          children: [
            _ScoutHeader(
              status: status,
              point: currentPoint,
              loading: loadingLocation,
              onRefresh: _refreshLocation,
              onExportCsv: _copyCsv,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
                children: [
                  _ScoutStatsCard(stats: _stats),
                  const SizedBox(height: 12),
                  _ScoutCaptureCard(
                    selectedType: selectedType,
                    selectedStatus: selectedStatus,
                    selectedAccess: selectedAccess,
                    selectedFruitCategory: selectedFruitCategory,
                    notesController: notesController,
                    fruitTypes: fruitTypes,
                    fruitCategories: fruitCategories,
                    fruitStatuses: fruitStatuses,
                    accessTypes: accessTypes,
                    currentPoint: currentPoint,
                    loadingLocation: loadingLocation,
                    onFruitCategoryChanged: (value) {
                      setState(() {
                        selectedFruitCategory = value;
                      });
                    },
                    onTypeChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                    onStatusChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                    onAccessChanged: (value) {
                      setState(() {
                        selectedAccess = value;
                      });
                    },
                    onSave: _saveHere,
                    onRefresh: _refreshLocation,
                  ),
                  const SizedBox(height: 12),
                  _FilterPanel(
                    searchController: searchController,
                    fruitTypes: ['All', ...fruitTypeNames],
                    statuses: ['All', ...fruitStatuses],
                    accessTypes: ['All', ...accessTypes],
                    selectedType: filterType,
                    selectedStatus: filterStatus,
                    selectedAccess: filterAccess,
                    showOnlyNearby: showOnlyNearby,
                    showOnlyNeedsRevisit: showOnlyNeedsRevisit,
                    onSearchChanged: (_) => setState(() {}),
                    onTypeChanged: (value) {
                      setState(() {
                        filterType = value;
                      });
                    },
                    onStatusChanged: (value) {
                      setState(() {
                        filterStatus = value;
                      });
                    },
                    onAccessChanged: (value) {
                      setState(() {
                        filterAccess = value;
                      });
                    },
                    onNearbyChanged: (value) {
                      setState(() {
                        showOnlyNearby = value;
                      });
                    },
                    onNeedsRevisitChanged: (value) {
                      setState(() {
                        showOnlyNeedsRevisit = value;
                      });
                    },
                    onClear: () {
                      setState(() {
                        searchController.clear();
                        filterType = 'All';
                        filterStatus = 'All';
                        filterAccess = 'All';
                        showOnlyNearby = false;
                        showOnlyNeedsRevisit = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saved Trees (${filtered.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    const _EmptyState()
                  else
                    for (final entry in filtered) ...[
                      Dismissible(
                        key: ValueKey(entry.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.delete_outline),
                              SizedBox(width: 8),
                              Text(
                                'Remove',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (_) async {
                          await _deleteEntry(entry);
                          return false;
                        },
                        child: _FruitEntryCard(
                          entry: entry,
                          distanceLabel: _distanceLabel(_distanceTo(entry)),
                          onOpenMaps: () => _openMaps(entry),
                          onCopy: () => _copyCoordinates(entry),
                          onEdit: () => _editEntry(entry),
                          onDelete: () => _deleteEntry(entry),
                          onVisited: () => _markVisitedToday(entry),
                          onToggleRevisit: () => _toggleNeedsRevisit(entry),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FruitTypeInfo {
  const _FruitTypeInfo(this.name, this.category);

  final String name;
  final String category;
}

class _ScoutStats {
  const _ScoutStats({
    required this.total,
    required this.fruiting,
    required this.publicAccess,
    required this.needsRevisit,
  });

  final int total;
  final int fruiting;
  final int publicAccess;
  final int needsRevisit;
}

class _ScoutHeader extends StatelessWidget {
  const _ScoutHeader({
    required this.status,
    required this.point,
    required this.loading,
    required this.onRefresh,
    required this.onExportCsv,
  });

  final String status;
  final _GpsPoint? point;
  final bool loading;
  final VoidCallback onRefresh;
  final VoidCallback onExportCsv;

  @override
  Widget build(BuildContext context) {
    final gps = point == null
        ? status
        : '${point!.latitude.toStringAsFixed(6)}, '
              '${point!.longitude.toStringAsFixed(6)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.explore_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Fruit Scout\n$gps',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton.outlined(
                onPressed: onExportCsv,
                icon: const Icon(Icons.table_chart_outlined),
                tooltip: 'Copy CSV',
              ),
              const SizedBox(width: 6),
              if (loading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton.outlined(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.my_location),
                  tooltip: 'Refresh GPS',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoutStatsCard extends StatelessWidget {
  const _ScoutStatsCard({required this.stats});

  final _ScoutStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFEAF6EA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _StatItem(label: 'Saved', value: stats.total.toString()),
            _StatItem(label: 'Fruiting', value: stats.fruiting.toString()),
            _StatItem(label: 'Public', value: stats.publicAccess.toString()),
            _StatItem(label: 'Revisit', value: stats.needsRevisit.toString()),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ScoutCaptureCard extends StatelessWidget {
  const _ScoutCaptureCard({
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedAccess,
    required this.selectedFruitCategory,
    required this.notesController,
    required this.fruitTypes,
    required this.fruitCategories,
    required this.fruitStatuses,
    required this.accessTypes,
    required this.currentPoint,
    required this.loadingLocation,
    required this.onFruitCategoryChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onAccessChanged,
    required this.onSave,
    required this.onRefresh,
  });

  final String selectedType;
  final String selectedStatus;
  final String selectedAccess;
  final String selectedFruitCategory;
  final TextEditingController notesController;
  final List<_FruitTypeInfo> fruitTypes;
  final List<String> fruitCategories;
  final List<String> fruitStatuses;
  final List<String> accessTypes;
  final _GpsPoint? currentPoint;
  final bool loadingLocation;
  final ValueChanged<String> onFruitCategoryChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onAccessChanged;
  final VoidCallback onSave;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final point = currentPoint;
    final seasonStatus = _seasonStatusForFruit(selectedType);
    final harvestWindow = _harvestWindowForFruit(selectedType);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save a tree here',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _CoordinateBox(
              latitude: point?.latitude,
              longitude: point?.longitude,
              accuracyMeters: point?.accuracyMeters,
            ),
            const SizedBox(height: 14),
            const Text(
              'Fruit type',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            _FruitTypePicker(
              values: fruitTypes,
              selected: selectedType,
              selectedCategory: selectedFruitCategory,
              onCategoryChanged: onFruitCategoryChanged,
              onSelected: onTypeChanged,
            ),
            const SizedBox(height: 14),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _ChoiceWrap(
              values: fruitStatuses,
              selected: selectedStatus,
              onSelected: onStatusChanged,
            ),
            const SizedBox(height: 14),
            const Text('Access', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _ChoiceWrap(
              values: accessTypes,
              selected: selectedAccess,
              onSelected: onAccessChanged,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notesController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Landmark, fruit quality, access, season...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: loadingLocation ? null : onRefresh,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Refresh GPS'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: loadingLocation ? null : onSave,
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Save here'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FruitTypePicker extends StatefulWidget {
  const _FruitTypePicker({
    required this.values,
    required this.selected,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSelected,
  });

  final List<_FruitTypeInfo> values;
  final String selected;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSelected;

  @override
  State<_FruitTypePicker> createState() => _FruitTypePickerState();
}

class _FruitTypePickerState extends State<_FruitTypePicker> {
  String search = '';

  List<String> get categories {
    final values = widget.values.map((item) => item.category).toSet().toList()
      ..sort();

    return ['All', ...values];
  }

  List<_FruitTypeInfo> get filteredValues {
    final query = search.trim().toLowerCase();

    return widget.values.where((value) {
      final matchesCategory =
          widget.selectedCategory == 'All' ||
          widget.selectedCategory == value.category;

      final matchesSearch =
          query.isEmpty || value.name.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredValues;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search fruit type',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            setState(() {
              search = value;
            });
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];

              return ChoiceChip(
                selected: widget.selectedCategory == category,
                label: Text(category),
                onSelected: (_) => widget.onCategoryChanged(category),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final value in filtered)
              _FruitTypeSvgButton(
                label: value.name,
                category: value.category,
                assetPath: _fruitScoutSvgAsset(value.name),
                selected: widget.selected == value.name,
                onTap: () => widget.onSelected(value.name),
              ),
          ],
        ),
      ],
    );
  }
}

class _FruitTypeSvgButton extends StatelessWidget {
  const _FruitTypeSvgButton({
    required this.label,
    required this.category,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String category;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 96,
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF6EA) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE4DED2),
              width: selected ? 2.5 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 160),
                child: SvgPicture.asset(assetPath, width: 42, height: 42),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.black.withValues(alpha: 0.56),
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

class _SeasonHint extends StatelessWidget {
  const _SeasonHint({required this.status, required this.window});

  final String status;
  final String window;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _seasonColorForStatus(status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(_seasonIconForStatus(status)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$status â€¢ Harvest: $window',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          ChoiceChip(
            selected: selected == value,
            label: Text(value),
            onSelected: (_) => onSelected(value),
          ),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.searchController,
    required this.fruitTypes,
    required this.statuses,
    required this.accessTypes,
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedAccess,
    required this.showOnlyNearby,
    required this.showOnlyNeedsRevisit,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onAccessChanged,
    required this.onNearbyChanged,
    required this.onNeedsRevisitChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final List<String> fruitTypes;
  final List<String> statuses;
  final List<String> accessTypes;
  final String selectedType;
  final String selectedStatus;
  final String selectedAccess;
  final bool showOnlyNearby;
  final bool showOnlyNeedsRevisit;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onAccessChanged;
  final ValueChanged<bool> onNearbyChanged;
  final ValueChanged<bool> onNeedsRevisitChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Find saved trees',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: onClear, child: const Text('Clear')),
              ],
            ),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search type, note, status...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 10),
            _CompactDropdown(
              label: 'Type',
              value: selectedType,
              values: fruitTypes,
              onChanged: onTypeChanged,
            ),
            const SizedBox(height: 8),
            _CompactDropdown(
              label: 'Status',
              value: selectedStatus,
              values: statuses,
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 8),
            _CompactDropdown(
              label: 'Access',
              value: selectedAccess,
              values: accessTypes,
              onChanged: onAccessChanged,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  selected: showOnlyNearby,
                  label: const Text('Within 1km'),
                  avatar: const Icon(Icons.near_me_outlined, size: 18),
                  onSelected: onNearbyChanged,
                ),
                FilterChip(
                  selected: showOnlyNeedsRevisit,
                  label: const Text('Needs revisit'),
                  avatar: const Icon(Icons.flag_outlined, size: 18),
                  onSelected: onNeedsRevisitChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactDropdown extends StatelessWidget {
  const _CompactDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: values.contains(value) ? value : values.first,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (final item in values)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: (next) {
        if (next == null) return;
        onChanged(next);
      },
    );
  }
}

class _CoordinateBox extends StatelessWidget {
  const _CoordinateBox({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  @override
  Widget build(BuildContext context) {
    final hasGps = latitude != null && longitude != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasGps ? const Color(0xFFEAF6EA) : const Color(0xFFFFF6DF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(hasGps ? Icons.gps_fixed : Icons.gps_not_fixed),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasGps
                    ? '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}\n'
                          'Accuracy: Ãƒâ€šÃ‚Â±${(accuracyMeters ?? 0).round()}m'
                    : 'No GPS fix yet. Tap Refresh GPS.',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FruitEntryCard extends StatelessWidget {
  const _FruitEntryCard({
    required this.entry,
    required this.distanceLabel,
    required this.onOpenMaps,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
    required this.onVisited,
    required this.onToggleRevisit,
  });

  final _FruitScoutEntry entry;
  final String distanceLabel;
  final VoidCallback onOpenMaps;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onVisited;
  final VoidCallback onToggleRevisit;

  @override
  Widget build(BuildContext context) {
    final lastVisited = entry.lastVisitedAt == null
        ? 'Never visited'
        : 'Visited ${_shortDate(entry.lastVisitedAt!)}';
    final seasonStatus = _seasonStatusForFruit(entry.type);
    final harvestWindow = _harvestWindowForFruit(entry.type);

    return Card(
      elevation: 0,
      color: entry.needsRevisit ? const Color(0xFFFFF6DF) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  _fruitScoutSvgAsset(entry.type),
                  width: 34,
                  height: 34,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  distanceLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.latitude.toStringAsFixed(6)}, '
              '${entry.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(entry.status),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: _seasonColorForStatus(seasonStatus),
                  avatar: Icon(_seasonIconForStatus(seasonStatus), size: 16),
                  label: Text(seasonStatus),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(harvestWindow),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(entry.access),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('Ãƒâ€šÃ‚Â±${entry.accuracyMeters.round()}m'),
                ),
                if (entry.needsRevisit)
                  const Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(Icons.flag_outlined, size: 16),
                    label: Text('Needs revisit'),
                  ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(lastVisited),
                ),
              ],
            ),
            if (entry.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(entry.notes),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Open Maps'),
                  onPressed: onOpenMaps,
                ),
                ActionChip(
                  avatar: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy GPS'),
                  onPressed: onCopy,
                ),
                ActionChip(
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Visited'),
                  onPressed: onVisited,
                ),
                ActionChip(
                  avatar: Icon(
                    entry.needsRevisit ? Icons.flag : Icons.flag_outlined,
                    size: 18,
                  ),
                  label: Text(entry.needsRevisit ? 'Clear revisit' : 'Revisit'),
                  onPressed: onToggleRevisit,
                ),
                ActionChip(
                  avatar: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  onPressed: onEdit,
                ),
                ActionChip(
                  avatar: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _shortDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No saved fruit trees match the current filters.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _FruitScoutEntry {
  const _FruitScoutEntry({
    required this.id,
    required this.type,
    required this.status,
    required this.access,
    required this.notes,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.needsRevisit,
    required this.lastVisitedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final String status;
  final String access;
  final String notes;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final bool needsRevisit;
  final DateTime? lastVisitedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  _FruitScoutEntry copyWith({
    String? type,
    String? status,
    String? access,
    String? notes,
    bool? needsRevisit,
    DateTime? lastVisitedAt,
    DateTime? updatedAt,
  }) {
    return _FruitScoutEntry(
      id: id,
      type: type ?? this.type,
      status: status ?? this.status,
      access: access ?? this.access,
      notes: notes ?? this.notes,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      needsRevisit: needsRevisit ?? this.needsRevisit,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'access': access,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'needsRevisit': needsRevisit,
      'lastVisitedAt': lastVisitedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory _FruitScoutEntry.fromJson(Map<String, dynamic> json) {
    return _FruitScoutEntry(
      id: json['id'] as String,
      type: (json['type'] as String?) ?? 'Unknown Fruit',
      status: (json['status'] as String?) ?? 'Unknown',
      access: (json['access'] as String?) ?? 'Unknown',
      notes: (json['notes'] as String?) ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyMeters: ((json['accuracyMeters'] as num?) ?? 0).toDouble(),
      needsRevisit: (json['needsRevisit'] as bool?) ?? false,
      lastVisitedAt: DateTime.tryParse(json['lastVisitedAt'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class _GpsPoint {
  const _GpsPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
}

String _fruitScoutSvgAsset(String value) {
  final key = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  return 'assets/fruit_scout_icons/$key.svg';
}

class _HarvestInfo {
  const _HarvestInfo({required this.months, required this.label});

  final List<int> months;
  final String label;
}

_HarvestInfo _harvestInfoForFruit(String type) {
  final key = type.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  const citrus = _HarvestInfo(months: [6, 7, 8], label: 'Winter / Junâ€“Aug');

  return switch (key) {
    'apple' ||
    'crabapple' => const _HarvestInfo(months: [2, 3, 4], label: 'Febâ€“Apr'),
    'pear' ||
    'asianpear' => const _HarvestInfo(months: [2, 3, 4], label: 'Febâ€“Apr'),
    'quince' => const _HarvestInfo(months: [3, 4, 5], label: 'Marâ€“May'),

    'peach' ||
    'nectarine' ||
    'plum' => const _HarvestInfo(months: [12, 1, 2, 3], label: 'Decâ€“Mar'),
    'apricot' => const _HarvestInfo(months: [12, 1, 2], label: 'Decâ€“Feb'),
    'cherry' => const _HarvestInfo(months: [11, 12, 1], label: 'Novâ€“Jan'),
    'damson' => const _HarvestInfo(months: [2, 3, 4], label: 'Febâ€“Apr'),

    'fig' => const _HarvestInfo(months: [1, 2, 3], label: 'Janâ€“Mar'),
    'mulberry' => const _HarvestInfo(months: [11, 12, 1], label: 'Novâ€“Jan'),
    'persimmon' => const _HarvestInfo(months: [4, 5, 6], label: 'Aprâ€“Jun'),
    'pomegranate' => const _HarvestInfo(months: [3, 4, 5], label: 'Marâ€“May'),
    'olive' => const _HarvestInfo(months: [4, 5, 6], label: 'Aprâ€“Jun'),

    'lemon' ||
    'lime' ||
    'orange' ||
    'mandarin' ||
    'tangerine' ||
    'grapefruit' ||
    'kumquat' ||
    'yuzu' => citrus,

    'grape' => const _HarvestInfo(months: [2, 3, 4], label: 'Febâ€“Apr'),
    'kiwi' => const _HarvestInfo(months: [4, 5, 6], label: 'Aprâ€“Jun'),
    'passionfruit' => const _HarvestInfo(
      months: [1, 2, 3, 4],
      label: 'Janâ€“Apr',
    ),

    'blueberry' => const _HarvestInfo(months: [12, 1, 2], label: 'Decâ€“Feb'),
    'blackberry' ||
    'raspberry' => const _HarvestInfo(months: [12, 1, 2, 3], label: 'Decâ€“Mar'),
    'boysenberry' ||
    'gooseberry' ||
    'currant' => const _HarvestInfo(months: [11, 12, 1], label: 'Novâ€“Jan'),
    'elderberry' => const _HarvestInfo(months: [1, 2, 3], label: 'Janâ€“Mar'),
    'strawberry' => const _HarvestInfo(
      months: [10, 11, 12, 1, 2, 3, 4],
      label: 'Octâ€“Apr',
    ),

    'feijoa' => const _HarvestInfo(months: [3, 4, 5, 6], label: 'Marâ€“Jun'),
    'guava' => const _HarvestInfo(months: [3, 4, 5, 6], label: 'Marâ€“Jun'),
    'loquat' => const _HarvestInfo(months: [9, 10, 11], label: 'Sepâ€“Nov'),
    'avocado' => const _HarvestInfo(
      months: [8, 9, 10, 11, 12, 1, 2, 3],
      label: 'Augâ€“Mar',
    ),
    'banana' || 'papaya' => const _HarvestInfo(
      months: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
      label: 'Year-round',
    ),
    'mango' => const _HarvestInfo(months: [1, 2, 3], label: 'Janâ€“Mar'),
    'pawpaw' => const _HarvestInfo(months: [2, 3, 4], label: 'Febâ€“Apr'),
    'lychee' => const _HarvestInfo(months: [1, 2], label: 'Janâ€“Feb'),
    'cherimoya' => const _HarvestInfo(
      months: [5, 6, 7, 8, 9],
      label: 'Mayâ€“Sep',
    ),

    'almond' ||
    'hazelnut' ||
    'chestnut' => const _HarvestInfo(months: [3, 4], label: 'Marâ€“Apr'),
    'walnut' => const _HarvestInfo(months: [3, 4, 5], label: 'Marâ€“May'),
    'pecan' => const _HarvestInfo(months: [4, 5], label: 'Aprâ€“May'),
    'macadamia' => const _HarvestInfo(
      months: [3, 4, 5, 6, 7, 8],
      label: 'Marâ€“Aug',
    ),

    _ => const _HarvestInfo(months: [], label: 'Season unknown'),
  };
}

String _harvestWindowForFruit(String type) {
  return _harvestInfoForFruit(type).label;
}

String _seasonStatusForFruit(String type, {DateTime? now}) {
  final info = _harvestInfoForFruit(type);

  if (info.months.isEmpty) {
    return 'Season unknown';
  }

  final month = (now ?? DateTime.now()).month;

  if (info.months.contains(month)) {
    return 'Fruiting now';
  }

  final soon = info.months.any((targetMonth) {
    return _monthsUntil(month, targetMonth) <= 1;
  });

  if (soon) {
    return 'Check soon';
  }

  return 'Out of season';
}

int _monthsUntil(int currentMonth, int targetMonth) {
  final diff = targetMonth - currentMonth;
  return diff >= 0 ? diff : diff + 12;
}

IconData _seasonIconForStatus(String status) {
  return switch (status) {
    'Fruiting now' => Icons.eco_outlined,
    'Check soon' => Icons.schedule_outlined,
    'Out of season' => Icons.event_busy_outlined,
    _ => Icons.help_outline,
  };
}

Color _seasonColorForStatus(String status) {
  return switch (status) {
    'Fruiting now' => const Color(0xFFEAF6EA),
    'Check soon' => const Color(0xFFFFF6DF),
    'Out of season' => const Color(0xFFF1EEE8),
    _ => const Color(0xFFF1EEE8),
  };
}

double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusMeters = 6371000.0;

  final dLat = _degreesToRadians(lat2 - lat1);
  final dLon = _degreesToRadians(lon2 - lon1);

  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degreesToRadians(lat1)) *
          math.cos(_degreesToRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusMeters * c;
}

double _degreesToRadians(double degrees) {
  return degrees * math.pi / 180.0;
}

