class CropBlock {
  const CropBlock({
    required this.id,
    required this.cropName,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final String id;
  final String cropName;
  final double x;
  final double y;
  final double width;
  final double height;

  CropBlock copyWith({
    String? id,
    String? cropName,
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return CropBlock(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  factory CropBlock.fromJson(Map<String, dynamic> json) {
    return CropBlock(
      id: json['id']?.toString() ?? '',
      cropName: json['cropName']?.toString() ?? '',
      x: _readDouble(json['x']),
      y: _readDouble(json['y']),
      width: _readDouble(json['width'], fallback: 1),
      height: _readDouble(json['height'], fallback: 0.5),
    );
  }

  static double _readDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}
