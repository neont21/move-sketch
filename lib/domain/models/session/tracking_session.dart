import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../data/services/local/database/app_database.dart';
import '../enums/activity_type.dart';
import '../enums/session_status.dart';
import 'location_point.dart';
import 'mission_instance.dart';

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
    required List<MissionInstance> missions,
    String? customId,
  }) {
    final sessionId = customId ?? const Uuid().v7();
    return TrackingSession(
      id: sessionId,
      userId: userId,
      activityType: activityType,
      missions: missions.map((m) => m.sessionId == sessionId
          ? m
          : m.copyWith(sessionId: sessionId))
          .toList(),
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

  DateTime get endedAt => lastLocation?.timestamp ?? startedAt.add(elapsedDuration);

  bool get isValidSession => distanceInMeters >= 10.0 && pathPoints.length >= 3;

  TrackingSession addPoint(LocationPoint point) {
    return copyWith(pathPoints: [...pathPoints, point]);
  }

  factory TrackingSession.fromEntity({
    required TrackingSessionsTableData sessionRow,
    List<LocationPointsTableData> pointsRows = const [],
    List<MissionInstancesTableData> missionsRows = const [],
  }) {
    return TrackingSession(
      id: sessionRow.id,
      userId: sessionRow.userId,
      activityType: sessionRow.activityType,
      status: sessionRow.status,
      startedAt: sessionRow.startedAt,
      elapsedDuration: Duration(seconds: sessionRow.elapsedDurationSeconds),
      distanceInMeters: sessionRow.distanceInMeters,
      caloriesBurned: sessionRow.caloriesBurned,
      averagePaceInSeconds: sessionRow.averagePaceInSeconds,
      averageSpeedKmh: sessionRow.averageSpeedKmh,
      pathPoints: pointsRows.map(LocationPoint.fromEntity).toList(),
      missions: missionsRows.map(MissionInstance.fromEntity).toList(),
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
