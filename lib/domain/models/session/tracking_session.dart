import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../enums/activity_type.dart';
import '../enums/session_status.dart';
import '../fixed/sketch_parts.dart';
import 'location_point.dart';
import 'mission_instance.dart';
import 'session_result.dart';

@immutable
class TrackingSession {
  final String id;
  final String userId;
  final ActivityType activityType;
  final SessionStatus status;
  final DateTime startedAt;
  final Duration elapsedDuration;
  final double distanceInMeters;
  final int caloriesBurned;
  final int? averagePaceInSeconds;
  final double? averageSpeedKmh;

  final List<LocationPoint> pathPoints;
  final List<MissionInstance> missions;

  const TrackingSession({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.startedAt,
    this.status = SessionStatus.ready,
    this.elapsedDuration = Duration.zero,
    this.distanceInMeters = 0.0,
    this.caloriesBurned = 0,
    this.averagePaceInSeconds,
    this.averageSpeedKmh,
    this.pathPoints = const [],
    this.missions = const [],
  });

  factory TrackingSession.start({
    required String userId,
    required ActivityType activityType,
    String? customId,
  }) {
    return TrackingSession(
      id: customId ?? const Uuid().v7(),
      userId: userId,
      activityType: activityType,
      startedAt: DateTime.now(),
      status: SessionStatus.active,
    );
  }

  bool get isActive => status.isActive;
  bool get isPaused => status.isPaused;
  bool get isOngoing => status.isOngoing;
  LocationPoint? get startLocation =>
      pathPoints.isNotEmpty ? pathPoints.first : null;
  LocationPoint? get lastLocation =>
      pathPoints.isNotEmpty ? pathPoints.last : null;

  bool get isValidSession => distanceInMeters >= 10.0 && pathPoints.length >= 3;

  TrackingSession addPoint(LocationPoint point) {
    return copyWith(pathPoints: [...pathPoints, point]);
  }

  LocationPoint _calculateFurthestWaypoint() {
    assert(isValidSession, '유효하지 않은 세션에서는 경유지를 계산할 수 없습니다.');

    final start = pathPoints.first.toLatLng();
    final end = pathPoints.last.toLatLng();
    const distance = Distance();
    LocationPoint waypoint = pathPoints[1];
    double maxDistanceSum = -1.0;
    for (int i = 1; i < pathPoints.length - 1; i++) {
      final p = pathPoints[i];
      final current = p.toLatLng();
      final total =
          distance.as(LengthUnit.Meter, start, current) +
          distance.as(LengthUnit.Meter, end, current);
      if (total > maxDistanceSum) {
        maxDistanceSum = total;
        waypoint = p;
      }
    }
    return waypoint;
  }

  SessionResult toResult({
    required SketchComposition sketchComposition,
    String? routePolyline,
    String? routeImageUrl,
  }) {
    if (!isValidSession) {
      throw StateError('위치 좌표가 없어 결과를 생성할 수 없습니다.');
    }
    return SessionResult(
      id: id,
      userId: userId,
      activityType: activityType,
      startedAt: startedAt,
      endedAt: DateTime.now(),
      elapsedDuration: elapsedDuration,
      distanceInMeters: distanceInMeters,
      caloriesBurned: caloriesBurned,
      averagePaceInSeconds: averagePaceInSeconds,
      averageSpeedKmh: averageSpeedKmh,
      sketchComposition: sketchComposition,
      startLocation: pathPoints.first,
      waypoint: _calculateFurthestWaypoint(),
      endLocation: pathPoints.last,

      routePolyline: routePolyline,
      routeImageUrl: routeImageUrl,
      missions: List.unmodifiable(missions),
      createdAt: DateTime.now(),
      isShared: false,
    );
  }

  TrackingSession copyWith({
    SessionStatus? status,
    Duration? elapsedDuration,
    double? distanceInMeters,
    int? caloriesBurned,
    ValueGetter<int?>? averagePaceInSeconds,
    ValueGetter<double?>? averageSpeedKmh,
    List<LocationPoint>? pathPoints,
    List<MissionInstance>? missions,
  }) {
    return TrackingSession(
      id: id,
      userId: userId,
      activityType: activityType,
      startedAt: startedAt,
      status: status ?? this.status,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      averagePaceInSeconds: averagePaceInSeconds != null
          ? averagePaceInSeconds()
          : this.averagePaceInSeconds,
      averageSpeedKmh: averageSpeedKmh != null
          ? averageSpeedKmh()
          : this.averageSpeedKmh,
      pathPoints: pathPoints ?? this.pathPoints,
      missions: missions ?? this.missions,
    );
  }
}
