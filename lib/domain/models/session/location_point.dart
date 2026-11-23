import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/services/local/database/app_database.dart';
import '../../../utils/date_time_utils.dart';

/// 운동 세션 중 GPS 센서로부터 수집된 단일 위치 좌표 및 부가 측정 정보를 나타내는 불변 모델입니다.
@immutable
final class LocationPoint {
  /// 위도 좌표. (WGS84 도 단위)
  final double latitude;

  /// 경도 좌표. (WGS84 도 단위)
  final double longitude;

  /// 해발 고도. (미터 단위, 수신 불가 시 null)
  final double? altitude;

  /// 이동 속도. (초당 미터 m/s 단위, 수신 불가 시 null)
  final double? speed;

  /// 이동 방위각. (북쪽 기준 0~360도, 수신 불가 시 null)
  final double? heading;

  /// 위치 측정 수평 정확도 반경. (미터 단위, 수신 불가 시 null)
  final double? accuracy;

  /// 위치 데이터가 측정된 일시.
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

  /// 지도 렌더링을 위해 좌표 정보를 [LatLng] 객체로 변환합니다.
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// 시속 단위로 환산된 이동 속도. (km/h, speed가 null인 경우 null)
  double? get speedInKmh => speed != null ? speed! * 3.6 : null;

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': Timestamp.fromDate(timestamp),
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

  /// Drift 로컬 데이터베이스의 [LocationPointsTableData] 엔티티로부터 [LocationPoint]를 생성합니다.
  factory LocationPoint.fromEntity(LocationPointsTableData entity) {
    return LocationPoint(
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      altitude: entity.altitude,
      speed: entity.speed,
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
          altitude == other.altitude &&
          speed == other.speed &&
          heading == other.heading &&
          accuracy == other.accuracy &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(
    latitude,
    longitude,
    altitude,
    speed,
    heading,
    accuracy,
    timestamp,
  );
}
