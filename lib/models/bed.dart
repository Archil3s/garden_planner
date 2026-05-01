import 'crop_placement.dart';

enum BedStatus { ok, warning, bad, hold }

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
  });

  final String id;
  final int number;
  final String name;

  /// Position on the garden canvas, measured in meters.
  final double x;
  final double y;

  /// Bed size, measured in meters.
  final double width;
  final double height;

  final String zone;
  final BedStatus status;
  final double healthPercent;
  final List<String> crops;

  /// Manual crop icon placements inside this bed.
  ///
  /// Each placement uses bed-local coordinates:
  /// x = meters from bed left edge
  /// y = meters from bed top edge
  final List<CropPlacement> cropPlacements;

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
