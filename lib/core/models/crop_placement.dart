class CropPlacement {
  const CropPlacement({
    required this.id,
    required this.cropName,
    required this.x,
    required this.y,
  });

  final String id;
  final String cropName;
  final double x;
  final double y;

  CropPlacement copyWith({String? id, String? cropName, double? x, double? y}) {
    return CropPlacement(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'cropName': cropName, 'x': x, 'y': y};
  }

  factory CropPlacement.fromJson(Map<String, dynamic> json) {
    return CropPlacement(
      id: json['id']?.toString() ?? '',
      cropName: json['cropName']?.toString() ?? '',
      x: _readDouble(json['x']),
      y: _readDouble(json['y']),
    );
  }

  static double _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
