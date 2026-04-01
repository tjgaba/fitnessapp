import 'package:geolocator/geolocator.dart';

class OutdoorWorkoutRecord {
  final String id;
  final DateTime startedAt;
  final int elapsedSeconds;
  final double straightLineDistanceMeters;
  final double routeDistanceMeters;
  final Position? startPosition;
  final Position? endPosition;
  final List<Position> routePoints;

  const OutdoorWorkoutRecord({
    required this.id,
    required this.startedAt,
    required this.elapsedSeconds,
    required this.straightLineDistanceMeters,
    required this.routeDistanceMeters,
    required this.startPosition,
    required this.endPosition,
    required this.routePoints,
  });

  factory OutdoorWorkoutRecord.fromJson(Map<String, dynamic> json) {
    final rawRoutePoints = json['routePoints'];
    return OutdoorWorkoutRecord(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      elapsedSeconds: (json['elapsedSeconds'] as num).toInt(),
      straightLineDistanceMeters:
          (json['straightLineDistanceMeters'] as num).toDouble(),
      routeDistanceMeters: (json['routeDistanceMeters'] as num).toDouble(),
      startPosition: _positionFromJson(json['startPosition']),
      endPosition: _positionFromJson(json['endPosition']),
      routePoints: rawRoutePoints is List
          ? rawRoutePoints
              .whereType<Map>()
              .map((item) => _positionFromJson(Map<String, dynamic>.from(item)))
              .whereType<Position>()
              .toList()
          : const <Position>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'elapsedSeconds': elapsedSeconds,
      'straightLineDistanceMeters': straightLineDistanceMeters,
      'routeDistanceMeters': routeDistanceMeters,
      'startPosition': _positionToJson(startPosition),
      'endPosition': _positionToJson(endPosition),
      'routePoints': routePoints.map(_positionToJson).toList(),
    };
  }

  static Map<String, dynamic>? _positionToJson(Position? position) {
    if (position == null) {
      return null;
    }

    return <String, dynamic>{
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': position.timestamp?.toIso8601String(),
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'altitudeAccuracy': position.altitudeAccuracy,
      'heading': position.heading,
      'headingAccuracy': position.headingAccuracy,
      'speed': position.speed,
      'speedAccuracy': position.speedAccuracy,
      'floor': position.floor,
      'isMocked': position.isMocked,
    };
  }

  static Position? _positionFromJson(dynamic json) {
    if (json is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(json);
    final timestamp = map['timestamp'] == null
        ? DateTime.now()
        : DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now();
    return Position(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: timestamp,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0,
      altitudeAccuracy: (map['altitudeAccuracy'] as num?)?.toDouble() ?? 0,
      heading: (map['heading'] as num?)?.toDouble() ?? 0,
      headingAccuracy: (map['headingAccuracy'] as num?)?.toDouble() ?? 0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0,
      speedAccuracy: (map['speedAccuracy'] as num?)?.toDouble() ?? 0,
      floor: (map['floor'] as num?)?.toInt(),
      isMocked: map['isMocked'] as bool? ?? false,
    );
  }
}
