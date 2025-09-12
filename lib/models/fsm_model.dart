class FSM {
  final String id;
  final String locationName;
  final String lgaName;
  final String sewageSize;
  final DateTime createdAt;
  final double latitude;
  final double longitude;

  FSM({
    required this.id,
    required this.locationName,
    required this.lgaName,
    required this.sewageSize,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
  });

  // Factory constructor to create FSM from JSON
  factory FSM.fromJson(Map<String, dynamic> json) {
    return FSM(
      id: json['id'] ?? '',
      locationName: json['locationName'] ?? '',
      lgaName: json['lgaName'] ?? '',
      sewageSize: json['sewageSize'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }

  // Convert FSM to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationName': locationName,
      'lgaName': lgaName,
      'sewageSize': sewageSize,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Get sewage size color
  String get sewageSizeColor {
    switch (sewageSize.toLowerCase()) {
      case 'big':
        return 'Red';
      case 'medium':
        return 'Orange';
      case 'small':
        return 'Green';
      default:
        return 'Grey';
    }
  }

  // Get formatted date
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Get formatted time
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get formatted date and time
  String get formattedDateTime {
    return '${formattedDate} at ${formattedTime}';
  }
}
