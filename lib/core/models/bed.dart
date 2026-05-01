import 'crop_block.dart';
import 'crop_placement.dart';

enum BedStatus { ok, warning, bad, hold }

enum BedIssueStatus { active, monitoring, resolved }

class BedIssue {
  const BedIssue({
    required this.id,
    required this.category,
    required this.symptoms,
    required this.severity,
    required this.dateSpotted,
    required this.treatment,
    required this.recheckDate,
    required this.status,
    required this.notes,
  });

  final String id;
  final String category;
  final List<String> symptoms;
  final String severity;
  final DateTime dateSpotted;
  final String treatment;
  final DateTime recheckDate;
  final BedIssueStatus status;
  final String notes;

  BedIssue copyWith({
    String? id,
    String? category,
    List<String>? symptoms,
    String? severity,
    DateTime? dateSpotted,
    String? treatment,
    DateTime? recheckDate,
    BedIssueStatus? status,
    String? notes,
  }) {
    return BedIssue(
      id: id ?? this.id,
      category: category ?? this.category,
      symptoms: symptoms ?? this.symptoms,
      severity: severity ?? this.severity,
      dateSpotted: dateSpotted ?? this.dateSpotted,
      treatment: treatment ?? this.treatment,
      recheckDate: recheckDate ?? this.recheckDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'symptoms': symptoms,
      'severity': severity,
      'dateSpotted': dateSpotted.toIso8601String(),
      'treatment': treatment,
      'recheckDate': recheckDate.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  factory BedIssue.fromJson(Map<String, dynamic> json) {
    return BedIssue(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      symptoms: _readStringList(json['symptoms']),
      severity: json['severity']?.toString() ?? '2 Mild',
      dateSpotted: _readDate(json['dateSpotted']),
      treatment: json['treatment']?.toString() ?? '',
      recheckDate: _readDate(json['recheckDate']),
      status: _readStatus(json['status']),
      notes: json['notes']?.toString() ?? '',
    );
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) return const [];

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static DateTime _readDate(Object? value) {
    if (value is DateTime) return value;

    final raw = value?.toString();
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.now();
    }

    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  static BedIssueStatus _readStatus(Object? value) {
    final raw = value?.toString();

    for (final status in BedIssueStatus.values) {
      if (status.name == raw) {
        return status;
      }
    }

    return BedIssueStatus.active;
  }
}

class Bed {
  const Bed({
    required this.id,
    required this.number,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.zone,
    required this.status,
    required this.healthPercent,
    required this.crops,
    this.cropPlacements = const [],
    this.cropBlocks = const [],
    this.issues = const [],
  });

  final String id;
  final int number;
  final String name;

  final double x;
  final double y;

  final double width;
  final double height;

  final String zone;
  final BedStatus status;
  final double healthPercent;
  final List<String> crops;

  final List<CropPlacement> cropPlacements;
  final List<CropBlock> cropBlocks;
  final List<BedIssue> issues;

  Bed copyWith({
    String? id,
    int? number,
    String? name,
    double? x,
    double? y,
    double? width,
    double? height,
    String? zone,
    BedStatus? status,
    double? healthPercent,
    List<String>? crops,
    List<CropPlacement>? cropPlacements,
    List<CropBlock>? cropBlocks,
    List<BedIssue>? issues,
  }) {
    return Bed(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      zone: zone ?? this.zone,
      status: status ?? this.status,
      healthPercent: healthPercent ?? this.healthPercent,
      crops: crops ?? this.crops,
      cropPlacements: cropPlacements ?? this.cropPlacements,
      cropBlocks: cropBlocks ?? this.cropBlocks,
      issues: issues ?? this.issues,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'number': number,
      'name': name,
      'zone': zone,
      'status': status.name,
      'healthPercent': healthPercent,
      'crops': crops,
      'cropPlacements': cropPlacements
          .map((placement) => placement.toJson())
          .toList(),
      'cropBlocks': cropBlocks.map((block) => block.toJson()).toList(),
      'issues': issues.map((issue) => issue.toJson()).toList(),
    };
  }

  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      id: json['id']?.toString() ?? '',
      x: _readDouble(json['x']),
      y: _readDouble(json['y']),
      width: _readDouble(json['width']),
      height: _readDouble(json['height']),
      number: _readInt(json['number']),
      name: json['name']?.toString() ?? 'Untitled Bed',
      zone: json['zone']?.toString() ?? 'Main Garden',
      status: _readStatus(json['status']),
      healthPercent: _readDouble(json['healthPercent'], fallback: 1.0),
      crops: _readStringList(json['crops']),
      cropPlacements: _readCropPlacements(json['cropPlacements']),
      cropBlocks: _readCropBlocks(json['cropBlocks']),
      issues: _readBedIssues(json['issues']),
    );
  }

  static BedStatus _readStatus(Object? value) {
    final raw = value?.toString();

    for (final status in BedStatus.values) {
      if (status.name == raw) {
        return status;
      }
    }

    return BedStatus.ok;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) return const [];

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<CropPlacement> _readCropPlacements(Object? value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((item) => CropPlacement.fromJson(Map<String, dynamic>.from(item)))
        .where((placement) => placement.id.trim().isNotEmpty)
        .toList();
  }

  static List<CropBlock> _readCropBlocks(Object? value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((item) => CropBlock.fromJson(Map<String, dynamic>.from(item)))
        .where((block) => block.id.trim().isNotEmpty)
        .toList();
  }

  static List<BedIssue> _readBedIssues(Object? value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((item) => BedIssue.fromJson(Map<String, dynamic>.from(item)))
        .where((issue) => issue.id.trim().isNotEmpty)
        .toList();
  }

  static double _readDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static int _readInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
