import 'bed.dart';

class GardenProject {
  final String id;
  final String name;
  final double widthMeters;
  final double heightMeters;
  final List<Bed> beds;
  final DateTime updatedAt;

  const GardenProject({
    required this.id,
    required this.name,
    required this.widthMeters,
    required this.heightMeters,
    required this.beds,
    required this.updatedAt,
  });

  factory GardenProject.demo() {
    return GardenProject(
      id: 'demo-project',
      name: 'Blenheim Garden Plan',
      widthMeters: 30,
      heightMeters: 18,
      updatedAt: DateTime.now(),
      beds: const [
        Bed(
          id: '1',
          number: 1,
          name: 'Strawberry Bed',
          x: 2,
          y: 2,
          width: 8,
          height: 4,
          zone: 'Berry Zone',
          status: BedStatus.ok,
          healthPercent: 0.9,
          crops: ['Strawberries'],
        ),
        Bed(
          id: '2',
          number: 2,
          name: 'Raspberry + Strawberry Bed',
          x: 2,
          y: 7,
          width: 8,
          height: 4,
          zone: 'Berry Zone',
          status: BedStatus.warning,
          healthPercent: 0.7,
          crops: ['Raspberries', 'Strawberries'],
        ),
        Bed(
          id: '3',
          number: 3,
          name: 'Broccoli Bed',
          x: 12,
          y: 4,
          width: 6,
          height: 4,
          zone: 'Main Garden',
          status: BedStatus.ok,
          healthPercent: 0.85,
          crops: ['Broccoli'],
        ),
      ],
    );
  }

  GardenProject copyWith({
    String? id,
    String? name,
    double? widthMeters,
    double? heightMeters,
    List<Bed>? beds,
    DateTime? updatedAt,
  }) {
    return GardenProject(
      id: id ?? this.id,
      name: name ?? this.name,
      widthMeters: widthMeters ?? this.widthMeters,
      heightMeters: heightMeters ?? this.heightMeters,
      beds: beds ?? this.beds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'widthMeters': widthMeters,
      'heightMeters': heightMeters,
      'beds': beds.map((bed) => bed.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GardenProject.fromJson(Map<String, dynamic> json) {
    return GardenProject(
      id: json['id'] as String? ?? 'project',
      name: json['name'] as String? ?? 'Untitled Garden Plan',
      widthMeters: _toDouble(json['widthMeters'], fallback: 30),
      heightMeters: _toDouble(json['heightMeters'], fallback: 18),
      beds: _bedsFromJson(json['beds']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
    );
  }

  static List<Bed> _bedsFromJson(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Bed.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return const [];
  }

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  static double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;

    return fallback;
  }
}
