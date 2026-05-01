import 'dart:convert';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import '../../../core/models/bed.dart';
import '../../../core/models/crop_block.dart';
import '../../../core/models/crop_placement.dart';
import '../../../core/models/crop_spacing.dart';
import '../../../core/models/garden_project.dart';
import '../../../core/models/seedling.dart';

class GardenController extends ChangeNotifier {
  int _cropBlockIdNonce = 0;

  String _nextCropBlockId() {
    _cropBlockIdNonce += 1;
    return 'block-${DateTime.now().microsecondsSinceEpoch}-$_cropBlockIdNonce';
  }

  GardenController({GardenProject? initialProject})
    : project = initialProject ?? GardenProject.demo();

  GardenProject project;

  final List<GardenProject> _undoStack = [];
  final List<GardenProject> _redoStack = [];

  bool allowOverlap = true;

  List<Bed> get beds => project.beds;

  List<Seedling> get seedlings => project.seedlings;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  String? selectedBedId;

  Bed? get selectedBed {
    if (selectedBedId == null) return null;

    for (final bed in beds) {
      if (bed.id == selectedBedId) {
        return bed;
      }
    }

    return null;
  }

  List<String> overlappingBedIds() {
    final ids = <String>{};

    for (var i = 0; i < beds.length; i++) {
      for (var j = i + 1; j < beds.length; j++) {
        final a = beds[i];
        final b = beds[j];

        if (_bedsOverlap(a, b)) {
          ids.add(a.id);
          ids.add(b.id);
        }
      }
    }

    return ids.toList();
  }

  bool bedOverlaps(String bedId) {
    return overlappingBedIds().contains(bedId);
  }

  int get overlapCount => overlappingBedIds().length;

  void toggleAllowOverlap(bool value) {
    if (allowOverlap == value) return;

    allowOverlap = value;
    notifyListeners();
  }

  String exportProjectJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(project.toJson());
  }

  void undo() {
    if (_undoStack.isEmpty) return;

    _redoStack.add(project);
    project = _undoStack.removeLast();
    selectedBedId = null;

    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    _undoStack.add(project);
    project = _redoStack.removeLast();
    selectedBedId = null;

    notifyListeners();
  }

  void loadProject(GardenProject nextProject, {bool recordHistory = true}) {
    if (recordHistory) {
      _recordHistory();
    }

    project = nextProject;
    selectedBedId = null;

    notifyListeners();
  }

  void resetToDemoProject() {
    _recordHistory();

    project = GardenProject.demo();
    selectedBedId = null;

    notifyListeners();
  }

  void loadProjectFromJson(String rawJson) {
    final decoded = jsonDecode(rawJson);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Project JSON must be an object.');
    }

    _recordHistory();

    project = GardenProject.fromJson(decoded);
    selectedBedId = null;

    notifyListeners();
  }

  void updateProjectSettings({
    required String name,
    required double widthMeters,
    required double heightMeters,
    required String locationName,
    required double latitude,
    required double longitude,
  }) {
    _recordHistory();

    final safeWidth = _clampDouble(widthMeters, 5.0, 100.0);
    final safeHeight = _clampDouble(heightMeters, 5.0, 100.0);
    final safeLatitude = _clampDouble(latitude, -90.0, 90.0);
    final safeLongitude = _clampDouble(longitude, -180.0, 180.0);

    final updatedBeds = beds.map((bed) {
      final clampedWidth = _clampDouble(bed.width, 1.0, safeWidth);
      final clampedHeight = _clampDouble(bed.height, 1.0, safeHeight);

      final clampedX = _clampDouble(bed.x, 0.0, safeWidth - clampedWidth);
      final clampedY = _clampDouble(bed.y, 0.0, safeHeight - clampedHeight);

      return bed.copyWith(
        x: clampedX,
        y: clampedY,
        width: clampedWidth,
        height: clampedHeight,
      );
    }).toList();

    project = project.copyWith(
      name: name.trim().isEmpty ? project.name : name.trim(),
      widthMeters: safeWidth,
      heightMeters: safeHeight,
      locationName: locationName.trim().isEmpty
          ? GardenProject.defaultLocationName
          : locationName.trim(),
      latitude: safeLatitude,
      longitude: safeLongitude,
      beds: updatedBeds,
      updatedAt: DateTime.now(),
    );

    if (selectedBedId != null &&
        !updatedBeds.any((bed) => bed.id == selectedBedId)) {
      selectedBedId = null;
    }

    notifyListeners();
  }

  void transplantSeedlingToBed({
    required String seedlingId,
    required String bedId,
    bool addCropBlockToMap = false,
  }) {
    final seedlingIndex = seedlings.indexWhere(
      (seedling) => seedling.id == seedlingId,
    );

    if (seedlingIndex == -1) return;

    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final seedling = seedlings[seedlingIndex];
    final bed = beds[bedIndex];

    final cropName = seedling.cropName.trim().isEmpty
        ? 'Seedling'
        : seedling.cropName.trim();

    final existingCropNames = bed.crops
        .map((crop) => crop.trim().toLowerCase())
        .where((crop) => crop.isNotEmpty)
        .toSet();

    final updatedCrops = existingCropNames.contains(cropName.toLowerCase())
        ? bed.crops
        : [...bed.crops, cropName];

    final updatedSeedlings = [...seedlings];

    updatedSeedlings[seedlingIndex] = seedling.copyWith(
      bedId: bed.id,
      transplantedAt: DateTime.now(),
    );

    var updatedBed = bed.copyWith(crops: updatedCrops);

    if (addCropBlockToMap) {
      final spacing = CropSpacing.spacingMetersForCrop(cropName);
      final blockWidth = _clampDouble(spacing * 8, spacing, bed.width);
      final blockHeight = _clampDouble(spacing * 2, spacing, bed.height);

      final nextPosition = _nextCropBlockPosition(
        bed: updatedBed,
        cropName: cropName,
        blockWidth: blockWidth,
        blockHeight: blockHeight,
        spacing: spacing,
      );

      final block = CropBlock(
        id: _nextCropBlockId(),
        cropName: cropName,
        x: nextPosition.dx,
        y: nextPosition.dy,
        width: blockWidth,
        height: blockHeight,
      );

      updatedBed = updatedBed.copyWith(
        cropBlocks: [...updatedBed.cropBlocks, block],
      );
    }

    final updatedBeds = [...beds];
    updatedBeds[bedIndex] = updatedBed;

    _recordHistory();

    project = project.copyWith(
      beds: updatedBeds,
      seedlings: updatedSeedlings,
      updatedAt: DateTime.now(),
    );

    selectedBedId = bed.id;

    notifyListeners();
  }

  void addSeedling(Seedling seedling) {
    _recordHistory();

    final safeSeedling = seedling.id.trim().isEmpty
        ? seedling.copyWith(
            id: 'seedling-${DateTime.now().microsecondsSinceEpoch}',
          )
        : seedling;

    project = project.copyWith(
      seedlings: [...seedlings, safeSeedling],
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  void updateSeedling(String id, Seedling Function(Seedling seedling) update) {
    final index = seedlings.indexWhere((seedling) => seedling.id == id);
    if (index == -1) return;

    final current = seedlings[index];
    final updated = update(current);

    _recordHistory();

    final updatedSeedlings = [...seedlings];
    updatedSeedlings[index] = updated;

    project = project.copyWith(
      seedlings: updatedSeedlings,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  void deleteSeedling(String id) {
    final updatedSeedlings = seedlings
        .where((seedling) => seedling.id != id)
        .toList();

    if (updatedSeedlings.length == seedlings.length) return;

    _recordHistory();

    project = project.copyWith(
      seedlings: updatedSeedlings,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  void addBed(Bed bed) {
    _recordHistory();

    project = project.copyWith(beds: [...beds, bed], updatedAt: DateTime.now());

    selectedBedId = bed.id;
    notifyListeners();
  }

  void addDefaultBed() {
    addCustomBed(
      name: 'New Bed ${beds.length + 1}',
      zone: 'Main Garden',
      width: 4,
      height: 2,
      crops: const [],
      status: BedStatus.ok,
    );
  }

  void addBedIssueToBed({required String bedId, required BedIssue issue}) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];
    final safeIssue = issue.id.trim().isEmpty
        ? issue.copyWith(id: 'issue-${DateTime.now().microsecondsSinceEpoch}')
        : issue;

    _recordHistory();

    final updatedBeds = [...beds];
    updatedBeds[bedIndex] = bed.copyWith(issues: [...bed.issues, safeIssue]);

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void updateBedIssueInBed({
    required String bedId,
    required String issueId,
    required BedIssue Function(BedIssue issue) update,
  }) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];
    final issueIndex = bed.issues.indexWhere((issue) => issue.id == issueId);
    if (issueIndex == -1) return;

    final currentIssue = bed.issues[issueIndex];
    final updatedIssue = update(currentIssue);

    if (updatedIssue == currentIssue) return;

    _recordHistory();

    final updatedIssues = [...bed.issues];
    updatedIssues[issueIndex] = updatedIssue;

    final updatedBeds = [...beds];
    updatedBeds[bedIndex] = bed.copyWith(issues: updatedIssues);

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void resolveBedIssue({
    required String bedId,
    required String issueId,
    String? notes,
  }) {
    updateBedIssueInBed(
      bedId: bedId,
      issueId: issueId,
      update: (issue) {
        final trimmedNotes = notes?.trim();

        return issue.copyWith(
          status: BedIssueStatus.resolved,
          notes: trimmedNotes == null || trimmedNotes.isEmpty
              ? issue.notes
              : trimmedNotes,
        );
      },
    );
  }

  void addCustomBed({
    required String name,
    required String zone,
    required double width,
    required double height,
    required List<String> crops,
    required BedStatus status,
  }) {
    final nextNumber = beds.length + 1;

    final safeWidth = _clampDouble(width, 1.0, project.widthMeters);
    final safeHeight = _clampDouble(height, 1.0, project.heightMeters);

    final x = _clampDouble(
      1.0 + nextNumber,
      0.0,
      project.widthMeters - safeWidth,
    );

    final y = _clampDouble(
      1.0 + nextNumber,
      0.0,
      project.heightMeters - safeHeight,
    );

    addBed(
      Bed(
        id: 'bed-$nextNumber',
        number: nextNumber,
        name: name.trim().isEmpty ? 'New Bed $nextNumber' : name.trim(),
        x: x,
        y: y,
        width: safeWidth,
        height: safeHeight,
        zone: zone.trim().isEmpty ? 'Main Garden' : zone.trim(),
        status: status,
        healthPercent: status == BedStatus.ok ? 1.0 : 0.7,
        crops: crops,
      ),
    );
  }

  void selectBed(String id) {
    if (selectedBedId == id) return;

    selectedBedId = id;
    notifyListeners();
  }

  void clearSelection() {
    if (selectedBedId == null) return;

    selectedBedId = null;
    notifyListeners();
  }

  void deleteSelectedBed() {
    if (selectedBedId == null) return;

    _recordHistory();

    project = project.copyWith(
      beds: beds.where((bed) => bed.id != selectedBedId).toList(),
      updatedAt: DateTime.now(),
    );

    selectedBedId = null;
    notifyListeners();
  }

  void moveBed(String id, {required double dx, required double dy}) {
    final index = beds.indexWhere((bed) => bed.id == id);
    if (index == -1) return;

    final bed = beds[index];

    setBedPosition(id, x: bed.x + dx, y: bed.y + dy, snap: false);
  }

  void setBedPosition(
    String id, {
    required double x,
    required double y,
    bool snap = false,
  }) {
    final index = beds.indexWhere((bed) => bed.id == id);
    if (index == -1) return;

    final bed = beds[index];

    var nextX = _clampDouble(x, 0.0, project.widthMeters - bed.width);
    var nextY = _clampDouble(y, 0.0, project.heightMeters - bed.height);

    if (snap) {
      nextX = _clampDouble(
        _snap(nextX, 0.5),
        0.0,
        project.widthMeters - bed.width,
      );

      nextY = _clampDouble(
        _snap(nextY, 0.5),
        0.0,
        project.heightMeters - bed.height,
      );
    }

    if (nextX == bed.x && nextY == bed.y) return;

    final updatedBed = bed.copyWith(x: nextX, y: nextY);

    if (!allowOverlap && _wouldOverlap(updatedBed, bed.id)) return;

    _recordHistory();

    final updatedBeds = [...beds];
    updatedBeds[index] = updatedBed;

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void resizeBed(
    String id, {
    required double width,
    required double height,
    bool snap = true,
  }) {
    final index = beds.indexWhere((bed) => bed.id == id);
    if (index == -1) return;

    final bed = beds[index];

    final maxWidth = project.widthMeters - bed.x;
    final maxHeight = project.heightMeters - bed.y;

    var nextWidth = _clampDouble(width, 1.0, maxWidth);
    var nextHeight = _clampDouble(height, 1.0, maxHeight);

    if (snap) {
      nextWidth = _clampDouble(_snap(nextWidth, 0.5), 1.0, maxWidth);
      nextHeight = _clampDouble(_snap(nextHeight, 0.5), 1.0, maxHeight);
    }

    if (nextWidth == bed.width && nextHeight == bed.height) return;

    final updatedBed = bed.copyWith(width: nextWidth, height: nextHeight);

    if (!allowOverlap && _wouldOverlap(updatedBed, bed.id)) return;

    _recordHistory();

    final updatedBeds = [...beds];
    updatedBeds[index] = updatedBed;

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void snapBedToGrid(String id, {double step = 0.5}) {
    final index = beds.indexWhere((bed) => bed.id == id);
    if (index == -1) return;

    final bed = beds[index];

    final snappedX = _clampDouble(
      _snap(bed.x, step),
      0.0,
      project.widthMeters - bed.width,
    );

    final snappedY = _clampDouble(
      _snap(bed.y, step),
      0.0,
      project.heightMeters - bed.height,
    );

    if (snappedX == bed.x && snappedY == bed.y) return;

    final updatedBed = bed.copyWith(x: snappedX, y: snappedY);

    if (!allowOverlap && _wouldOverlap(updatedBed, bed.id)) return;

    _recordHistory();

    final updatedBeds = [...beds];
    updatedBeds[index] = updatedBed;

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void updateSelectedBedName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    _updateSelectedBed((bed) => bed.copyWith(name: trimmed));
  }

  void updateSelectedBedZone(String value) {
    final trimmed = value.trim();

    _updateSelectedBed(
      (bed) => bed.copyWith(zone: trimmed.isEmpty ? 'Main Garden' : trimmed),
    );
  }

  void updateSelectedBedWidth(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;

    _updateSelectedBed((bed) {
      final maxWidth = project.widthMeters - bed.x;
      final nextWidth = _clampDouble(parsed, 1.0, maxWidth);

      return bed.copyWith(width: nextWidth);
    });
  }

  void updateSelectedBedHeight(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;

    _updateSelectedBed((bed) {
      final maxHeight = project.heightMeters - bed.y;
      final nextHeight = _clampDouble(parsed, 1.0, maxHeight);

      return bed.copyWith(height: nextHeight);
    });
  }

  void updateSelectedBedCropsFromText(String value) {
    final crops = value
        .split(',')
        .map((crop) => crop.trim())
        .where((crop) => crop.isNotEmpty)
        .toList();

    _updateSelectedBed((bed) => bed.copyWith(crops: crops));
  }

  void removeCropFromSelectedBed(String cropToRemove) {
    final target = cropToRemove.trim();
    if (target.isEmpty) return;

    _updateSelectedBed((bed) {
      final updatedCrops = bed.crops
          .where((crop) => crop.trim().toLowerCase() != target.toLowerCase())
          .toList();

      final updatedPlacements = bed.cropPlacements
          .where(
            (placement) =>
                placement.cropName.trim().toLowerCase() != target.toLowerCase(),
          )
          .toList();

      final updatedBlocks = bed.cropBlocks
          .where(
            (block) =>
                block.cropName.trim().toLowerCase() != target.toLowerCase(),
          )
          .toList();

      return bed.copyWith(
        crops: updatedCrops,
        cropPlacements: updatedPlacements,
        cropBlocks: updatedBlocks,
      );
    });
  }

  void addCropPlacementToSelectedBed(String cropName) {
    if (selectedBedId == null) return;

    final targetCrop = cropName.trim();
    if (targetCrop.isEmpty) return;

    final index = beds.indexWhere((bed) => bed.id == selectedBedId);
    if (index == -1) return;

    final bed = beds[index];
    final spacing = CropSpacing.spacingMetersForCrop(targetCrop);

    final nextPosition = _nextCropPlacementPosition(
      bed: bed,
      cropName: targetCrop,
      spacing: spacing,
    );

    final existingCropsLower = bed.crops
        .map((crop) => crop.trim().toLowerCase())
        .where((crop) => crop.isNotEmpty)
        .toSet();

    final updatedCrops = existingCropsLower.contains(targetCrop.toLowerCase())
        ? bed.crops
        : [...bed.crops, targetCrop];

    final placement = CropPlacement(
      id: 'crop-${DateTime.now().microsecondsSinceEpoch}',
      cropName: targetCrop,
      x: nextPosition.dx,
      y: nextPosition.dy,
    );

    _recordHistory();

    final updatedBeds = [...beds];

    updatedBeds[index] = bed.copyWith(
      crops: updatedCrops,
      cropPlacements: [...bed.cropPlacements, placement],
    );

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void moveCropPlacement({
    required String bedId,
    required String placementId,
    required double x,
    required double y,
  }) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];

    final placementIndex = bed.cropPlacements.indexWhere(
      (placement) => placement.id == placementId,
    );

    if (placementIndex == -1) return;

    final placement = bed.cropPlacements[placementIndex];
    final spacing = CropSpacing.spacingMetersForCrop(placement.cropName);

    final snappedX = _snapCropCoordinate(
      value: x,
      spacing: spacing,
      max: bed.width,
    );

    final snappedY = _snapCropCoordinate(
      value: y,
      spacing: spacing,
      max: bed.height,
    );

    if (snappedX == placement.x && snappedY == placement.y) return;

    _recordHistory();

    final updatedPlacements = [...bed.cropPlacements];

    updatedPlacements[placementIndex] = placement.copyWith(
      x: snappedX,
      y: snappedY,
    );

    final updatedBeds = [...beds];

    updatedBeds[bedIndex] = bed.copyWith(cropPlacements: updatedPlacements);

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void removeCropPlacement({
    required String bedId,
    required String placementId,
  }) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];

    final updatedPlacements = bed.cropPlacements
        .where((placement) => placement.id != placementId)
        .toList();

    if (updatedPlacements.length == bed.cropPlacements.length) return;

    _recordHistory();

    final updatedBeds = [...beds];

    updatedBeds[bedIndex] = bed.copyWith(cropPlacements: updatedPlacements);

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void addCropBlockToSelectedBed(String cropName) {
    if (selectedBedId == null) return;

    final targetCrop = cropName.trim();
    if (targetCrop.isEmpty) return;

    final bedIndex = beds.indexWhere((bed) => bed.id == selectedBedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];
    final spacing = CropSpacing.spacingMetersForCrop(targetCrop);

    final existingCropsLower = bed.crops
        .map((crop) => crop.trim().toLowerCase())
        .where((crop) => crop.isNotEmpty)
        .toSet();

    final updatedCrops = existingCropsLower.contains(targetCrop.toLowerCase())
        ? bed.crops
        : [...bed.crops, targetCrop];

    final blockWidth = _clampDouble(spacing * 8, spacing, bed.width);
    final blockHeight = _clampDouble(spacing * 2, spacing, bed.height);

    final nextPosition = _nextCropBlockPosition(
      bed: bed,
      cropName: targetCrop,
      blockWidth: blockWidth,
      blockHeight: blockHeight,
      spacing: spacing,
    );

    final block = CropBlock(
      id: _nextCropBlockId(),
      cropName: targetCrop,
      x: nextPosition.dx,
      y: nextPosition.dy,
      width: blockWidth,
      height: blockHeight,
    );

    _recordHistory();

    final updatedBeds = [...beds];

    updatedBeds[bedIndex] = bed.copyWith(
      crops: updatedCrops,
      cropBlocks: [...bed.cropBlocks, block],
    );

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void addCropBlockToBedAt({
    required String bedId,
    required String cropName,
    required double x,
    required double y,
  }) {
    final targetCrop = cropName.trim();
    if (targetCrop.isEmpty) return;

    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];
    final spacing = CropSpacing.spacingMetersForCrop(targetCrop);

    final existingCropsLower = bed.crops
        .map((crop) => crop.trim().toLowerCase())
        .where((crop) => crop.isNotEmpty)
        .toSet();

    final updatedCrops = existingCropsLower.contains(targetCrop.toLowerCase())
        ? bed.crops
        : [...bed.crops, targetCrop];

    final blockWidth = _clampDouble(
      spacing * 12,
      _clampDouble(2.8, spacing, bed.width),
      bed.width,
    );

    final blockHeight = _clampDouble(
      spacing * 4,
      _clampDouble(1.25, spacing, bed.height),
      bed.height,
    );

    final localX = _clampDouble(
      x - bed.x - blockWidth / 2,
      0,
      bed.width - blockWidth,
    );

    final localY = _clampDouble(
      y - bed.y - blockHeight / 2,
      0,
      bed.height - blockHeight,
    );

    final block = CropBlock(
      id: _nextCropBlockId(),
      cropName: targetCrop,
      x: localX,
      y: localY,
      width: blockWidth,
      height: blockHeight,
    );

    _recordHistory();

    final updatedBeds = [...beds];

    updatedBeds[bedIndex] = bed.copyWith(
      crops: updatedCrops,
      cropBlocks: [...bed.cropBlocks, block],
    );

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    selectedBedId = bed.id;

    notifyListeners();
  }

  void addExactCropBlockToBed({
    required String bedId,
    required String cropName,
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    final targetCrop = cropName.trim();
    if (targetCrop.isEmpty) return;

    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];

    final safeWidth = _clampDouble(width, 0.04, bed.width);
    final safeHeight = _clampDouble(height, 0.04, bed.height);

    final safeX = _clampDouble(x, 0, bed.width - safeWidth);
    final safeY = _clampDouble(y, 0, bed.height - safeHeight);

    final existingCropsLower = bed.crops
        .map((crop) => crop.trim().toLowerCase())
        .where((crop) => crop.isNotEmpty)
        .toSet();

    final updatedCrops = existingCropsLower.contains(targetCrop.toLowerCase())
        ? bed.crops
        : [...bed.crops, targetCrop];

    final block = CropBlock(
      id: 'single-plant-${_nextCropBlockId()}',
      cropName: targetCrop,
      x: safeX,
      y: safeY,
      width: safeWidth,
      height: safeHeight,
    );

    _recordHistory();

    final updatedBeds = [...beds];

    updatedBeds[bedIndex] = bed.copyWith(
      crops: updatedCrops,
      cropBlocks: [...bed.cropBlocks, block],
    );

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    selectedBedId = bed.id;

    notifyListeners();
  }

  void addCropRowToBedRect({
    required String bedId,
    required String cropName,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
  }) {
    final targetCrop = cropName.trim();
    if (targetCrop.isEmpty) return;

    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];
    final spacing = CropSpacing.spacingMetersForCrop(targetCrop);

    final existingCropsLower = bed.crops
        .map((crop) => crop.trim().toLowerCase())
        .where((crop) => crop.isNotEmpty)
        .toSet();

    final updatedCrops = existingCropsLower.contains(targetCrop.toLowerCase())
        ? bed.crops
        : [...bed.crops, targetCrop];

    late final CropBlock block;

    if (CropSpacing.isLargeCanopyCrop(targetCrop)) {
      final size = _clampDouble(
        spacing,
        _clampDouble(
          1.2,
          spacing * 0.5,
          bed.width < bed.height ? bed.width : bed.height,
        ),
        bed.width < bed.height ? bed.width : bed.height,
      );

      final centerX = ((startX + endX) / 2) - bed.x;
      final centerY = ((startY + endY) / 2) - bed.y;

      final blockX = _clampDouble(centerX - size / 2, 0, bed.width - size);
      final blockY = _clampDouble(centerY - size / 2, 0, bed.height - size);

      block = CropBlock(
        id: _nextCropBlockId(),
        cropName: targetCrop,
        x: blockX,
        y: blockY,
        width: size,
        height: size,
      );
    } else {
      final dx = (endX - startX).abs();
      final dy = (endY - startY).abs();
      final horizontal = dx >= dy;

      final rowThickness = _clampDouble(
        spacing * 2.2,
        _clampDouble(0.65, spacing, horizontal ? bed.height : bed.width),
        horizontal ? bed.height : bed.width,
      );

      final minRowLength = _clampDouble(
        spacing * 6,
        spacing,
        horizontal ? bed.width : bed.height,
      );

      final rawLength = horizontal ? dx : dy;
      final rowLength = _clampDouble(
        rawLength < minRowLength ? minRowLength : rawLength,
        spacing,
        horizontal ? bed.width : bed.height,
      );

      final centerX = ((startX + endX) / 2) - bed.x;
      final centerY = ((startY + endY) / 2) - bed.y;

      late final double blockX;
      late final double blockY;
      late final double blockWidth;
      late final double blockHeight;

      if (horizontal) {
        blockWidth = rowLength;
        blockHeight = rowThickness;

        blockX = _clampDouble(
          centerX - blockWidth / 2,
          0,
          bed.width - blockWidth,
        );

        blockY = _clampDouble(
          centerY - blockHeight / 2,
          0,
          bed.height - blockHeight,
        );
      } else {
        blockWidth = rowThickness;
        blockHeight = rowLength;

        blockX = _clampDouble(
          centerX - blockWidth / 2,
          0,
          bed.width - blockWidth,
        );

        blockY = _clampDouble(
          centerY - blockHeight / 2,
          0,
          bed.height - blockHeight,
        );
      }

      block = CropBlock(
        id: _nextCropBlockId(),
        cropName: targetCrop,
        x: blockX,
        y: blockY,
        width: blockWidth,
        height: blockHeight,
      );
    }

    _recordHistory();

    final updatedBeds = [...beds];

    updatedBeds[bedIndex] = bed.copyWith(
      crops: updatedCrops,
      cropBlocks: [...bed.cropBlocks, block],
    );

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    selectedBedId = bed.id;

    notifyListeners();
  }

  void moveCropBlock({
    required String bedId,
    required String blockId,
    required double x,
    required double y,
  }) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];

    final blockIndex = bed.cropBlocks.indexWhere(
      (block) => block.id == blockId,
    );

    if (blockIndex == -1) return;

    final block = bed.cropBlocks[blockIndex];

    final maxX = bed.width - block.width;
    final maxY = bed.height - block.height;

    final nextX = _clampDouble(x, 0, maxX < 0 ? 0 : maxX);
    final nextY = _clampDouble(y, 0, maxY < 0 ? 0 : maxY);

    if (nextX == block.x && nextY == block.y) return;

    final updatedBlocks = [...bed.cropBlocks];
    updatedBlocks[blockIndex] = block.copyWith(x: nextX, y: nextY);

    _recordHistory();

    final updatedBeds = [...beds];
    updatedBeds[bedIndex] = bed.copyWith(cropBlocks: updatedBlocks);

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    selectedBedId = bed.id;

    notifyListeners();
  }

  void duplicateCropBlock({required String bedId, required String blockId}) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];

    final blockIndex = bed.cropBlocks.indexWhere(
      (block) => block.id == blockId,
    );

    if (blockIndex == -1) return;

    final block = bed.cropBlocks[blockIndex];
    final spacing = CropSpacing.spacingMetersForCrop(block.cropName);

    final maxX = bed.width - block.width;
    final maxY = bed.height - block.height;

    final nextX = _clampDouble(block.x + spacing, 0, maxX < 0 ? 0 : maxX);

    var nextY = block.y;

    if (nextX == block.x) {
      nextY = _clampDouble(block.y + spacing, 0, maxY < 0 ? 0 : maxY);
    }

    final duplicate = block.copyWith(
      id: _nextCropBlockId(),
      x: nextX,
      y: nextY,
    );

    _recordHistory();

    final updatedBeds = [...beds];

    updatedBeds[bedIndex] = bed.copyWith(
      cropBlocks: [...bed.cropBlocks, duplicate],
    );

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    selectedBedId = bed.id;

    notifyListeners();
  }

  void centerCropBlock({required String bedId, required String blockId}) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];

    final blockIndex = bed.cropBlocks.indexWhere(
      (block) => block.id == blockId,
    );

    if (blockIndex == -1) return;

    final block = bed.cropBlocks[blockIndex];

    final nextX = _clampDouble(
      (bed.width - block.width) / 2,
      0,
      bed.width - block.width < 0 ? 0 : bed.width - block.width,
    );

    final nextY = _clampDouble(
      (bed.height - block.height) / 2,
      0,
      bed.height - block.height < 0 ? 0 : bed.height - block.height,
    );

    if (nextX == block.x && nextY == block.y) return;

    _recordHistory();

    final updatedBlocks = [...bed.cropBlocks];

    updatedBlocks[blockIndex] = block.copyWith(x: nextX, y: nextY);

    final updatedBeds = [...beds];
    updatedBeds[bedIndex] = bed.copyWith(cropBlocks: updatedBlocks);

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    selectedBedId = bed.id;

    notifyListeners();
  }

  void removeCropBlock({required String bedId, required String blockId}) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) return;

    final bed = beds[bedIndex];

    final updatedBlocks = bed.cropBlocks
        .where((block) => block.id != blockId)
        .toList();

    if (updatedBlocks.length == bed.cropBlocks.length) return;

    _recordHistory();

    final updatedBeds = [...beds];

    updatedBeds[bedIndex] = bed.copyWith(cropBlocks: updatedBlocks);

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  void updateSelectedBedStatus(BedStatus status) {
    _updateSelectedBed((bed) => bed.copyWith(status: status));
  }

  void updateSelectedBedHealth(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;

    final normalized = _clampDouble(parsed / 100, 0.0, 1.0);

    _updateSelectedBed((bed) => bed.copyWith(healthPercent: normalized));
  }

  void _updateSelectedBed(Bed Function(Bed bed) update) {
    if (selectedBedId == null) return;

    final index = beds.indexWhere((bed) => bed.id == selectedBedId);
    if (index == -1) return;

    final currentBed = beds[index];
    final updatedBed = update(currentBed);

    if (updatedBed == currentBed) return;

    if (!allowOverlap && _wouldOverlap(updatedBed, currentBed.id)) return;

    _recordHistory();

    final updatedBeds = [...beds];
    updatedBeds[index] = updatedBed;

    project = project.copyWith(beds: updatedBeds, updatedAt: DateTime.now());

    notifyListeners();
  }

  Offset _nextCropPlacementPosition({
    required Bed bed,
    required String cropName,
    required double spacing,
  }) {
    final existingForCrop = bed.cropPlacements
        .where(
          (placement) =>
              placement.cropName.trim().toLowerCase() ==
              cropName.trim().toLowerCase(),
        )
        .length;

    final columnCount = (bed.width / spacing).floor();
    final safeColumnCount = columnCount < 1 ? 1 : columnCount;

    final column = existingForCrop % safeColumnCount;
    final row = existingForCrop ~/ safeColumnCount;

    final rawX = spacing / 2 + column * spacing;
    final rawY = spacing / 2 + row * spacing;

    return Offset(
      _clampDouble(rawX, spacing / 2, bed.width - spacing / 2),
      _clampDouble(rawY, spacing / 2, bed.height - spacing / 2),
    );
  }

  Offset _nextCropBlockPosition({
    required Bed bed,
    required String cropName,
    required double blockWidth,
    required double blockHeight,
    required double spacing,
  }) {
    final existingForCrop = bed.cropBlocks
        .where(
          (block) =>
              block.cropName.trim().toLowerCase() ==
              cropName.trim().toLowerCase(),
        )
        .length;

    final availableWidth = bed.width - blockWidth;
    final availableHeight = bed.height - blockHeight;

    final columnCount = availableWidth <= 0
        ? 1
        : ((availableWidth / spacing).floor() + 1).clamp(1, 9999);

    final column = existingForCrop % columnCount;
    final row = existingForCrop ~/ columnCount;

    final rawX = column * spacing;
    final rawY = row * spacing;

    return Offset(
      _clampDouble(rawX, 0, availableWidth),
      _clampDouble(rawY, 0, availableHeight),
    );
  }

  double _snapCropCoordinate({
    required double value,
    required double spacing,
    required double max,
  }) {
    if (max <= 0) return 0;
    if (spacing <= 0) return _clampDouble(value, 0, max);

    final halfSpacing = spacing / 2;

    if (max <= halfSpacing) {
      return max / 2;
    }

    final snapped =
        ((value - halfSpacing) / spacing).round() * spacing + halfSpacing;

    return _clampDouble(snapped, halfSpacing, max - halfSpacing);
  }

  double _snapCropBlockCoordinate({
    required double value,
    required double spacing,
    required double min,
    required double max,
  }) {
    if (max < min) return min;
    if (spacing <= 0) return _clampDouble(value, min, max);

    final snapped = (value / spacing).round() * spacing;

    return _clampDouble(snapped, min, max);
  }

  double _snapCropBlockSize({
    required double value,
    required double spacing,
    required double min,
    required double max,
  }) {
    if (max < min) return min;
    if (spacing <= 0) return _clampDouble(value, min, max);

    final snapped = (value / spacing).round() * spacing;

    return _clampDouble(snapped, min, max);
  }

  bool _wouldOverlap(Bed candidate, String candidateId) {
    for (final other in beds) {
      if (other.id == candidateId) continue;

      if (_bedsOverlap(candidate, other)) {
        return true;
      }
    }

    return false;
  }

  bool _bedsOverlap(Bed a, Bed b) {
    final leftA = a.x;
    final rightA = a.x + a.width;
    final topA = a.y;
    final bottomA = a.y + a.height;

    final leftB = b.x;
    final rightB = b.x + b.width;
    final topB = b.y;
    final bottomB = b.y + b.height;

    return leftA < rightB && rightA > leftB && topA < bottomB && bottomA > topB;
  }

  void _recordHistory() {
    _undoStack.add(project);
    _redoStack.clear();

    const maxHistory = 50;

    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
  }

  double _snap(double value, double step) {
    return (value / step).round() * step;
  }

  double _clampDouble(double value, double min, double max) {
    if (max < min) return min;
    return value.clamp(min, max).toDouble();
  }
}
