class Seedling {
  const Seedling({
    required this.id,
    required this.seedKey,
    required this.cropName,
    required this.emoji,
    required this.category,
    required this.variety,
    required this.sowDate,
    required this.trayType,
    required this.trayCount,
    required this.location,
    required this.notes,
    this.bedId,
    this.lastWateredAt,
    this.lastFedAt,
    this.transplantedAt,
  });

  final String id;
  final String seedKey;
  final String cropName;
  final String emoji;
  final String category;
  final String variety;
  final DateTime sowDate;
  final String trayType;
  final int trayCount;
  final String location;
  final String notes;
  final String? bedId;
  final DateTime? lastWateredAt;
  final DateTime? lastFedAt;
  final DateTime? transplantedAt;

  bool get isTransplanted => transplantedAt != null;

  int daysSinceSowing(DateTime now) {
    return now
        .difference(DateTime(sowDate.year, sowDate.month, sowDate.day))
        .inDays;
  }

  Seedling copyWith({
    String? id,
    String? seedKey,
    String? cropName,
    String? emoji,
    String? category,
    String? variety,
    DateTime? sowDate,
    String? trayType,
    int? trayCount,
    String? location,
    String? notes,
    String? bedId,
    DateTime? lastWateredAt,
    DateTime? lastFedAt,
    DateTime? transplantedAt,
  }) {
    return Seedling(
      id: id ?? this.id,
      seedKey: seedKey ?? this.seedKey,
      cropName: cropName ?? this.cropName,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      variety: variety ?? this.variety,
      sowDate: sowDate ?? this.sowDate,
      trayType: trayType ?? this.trayType,
      trayCount: trayCount ?? this.trayCount,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      bedId: bedId ?? this.bedId,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      lastFedAt: lastFedAt ?? this.lastFedAt,
      transplantedAt: transplantedAt ?? this.transplantedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seedKey': seedKey,
      'cropName': cropName,
      'emoji': emoji,
      'category': category,
      'variety': variety,
      'sowDate': sowDate.toIso8601String(),
      'trayType': trayType,
      'trayCount': trayCount,
      'location': location,
      'notes': notes,
      'bedId': bedId,
      'lastWateredAt': lastWateredAt?.toIso8601String(),
      'lastFedAt': lastFedAt?.toIso8601String(),
      'transplantedAt': transplantedAt?.toIso8601String(),
    };
  }

  factory Seedling.fromJson(Map<String, dynamic> json) {
    return Seedling(
      id: _stringFromJson(json['id'], fallback: 'seedling'),
      seedKey: _stringFromJson(json['seedKey'], fallback: 'custom'),
      cropName: _stringFromJson(json['cropName'], fallback: 'Seedling'),
      emoji: _stringFromJson(json['emoji'], fallback: '🌱'),
      category: _stringFromJson(json['category'], fallback: 'Seedling'),
      variety: _stringFromJson(json['variety'], fallback: ''),
      sowDate: _dateFromJson(json['sowDate']) ?? DateTime.now(),
      trayType: _stringFromJson(json['trayType'], fallback: 'Tray'),
      trayCount: _intFromJson(json['trayCount'], fallback: 1),
      location: _stringFromJson(json['location'], fallback: 'Seedling area'),
      notes: _stringFromJson(json['notes'], fallback: ''),
      bedId: _nullableStringFromJson(json['bedId']),
      lastWateredAt: _dateFromJson(json['lastWateredAt']),
      lastFedAt: _dateFromJson(json['lastFedAt']),
      transplantedAt: _dateFromJson(json['transplantedAt']),
    );
  }

  static String _stringFromJson(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return fallback;
  }

  static String? _nullableStringFromJson(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static int _intFromJson(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;

    return fallback;
  }
}
