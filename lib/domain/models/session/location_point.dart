import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../../../utils/date_time_utils.dart';

@immutable
class LocationPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  double? get speedInKmh => speed != null ? speed! * 3.6 : null;

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      heading: (map['heading'] as num?)?.toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      timestamp: parseDateTime(map['timestamp']).toLocal(),
    );
  }

  LocationPoint copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPoint &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(latitude, longitude, timestamp);
}
