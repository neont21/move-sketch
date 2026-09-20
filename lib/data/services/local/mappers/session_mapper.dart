import '../../../../domain/models/session/location_point.dart';
import '../../../../domain/models/session/mission_instance.dart';
import '../../../../domain/models/session/tracking_session.dart';
import '../app_database.dart';

class SessionMapper {
  static TrackingSession toDomain({
    required TrackingSessionsTableData sessionRow,
    required List<LocationPointsTableData> pointsRows,
    required List<MissionInstancesTableData> missionsRows,
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
      pathPoints: pointsRows.map((p) => LocationPoint(
        latitude: p.latitude,
        longitude: p.longitude,
        timestamp: p.timestamp,
        altitude: p.altitude,
        speed: p.speed,
      )).toList(),
      missions: missionsRows.map((m) => MissionInstance(
        id: m.id,
        sessionId: m.sessionId,
        missionTemplateId: m.missionTemplateId,
        axis: m.axis,
        baselineValue: m.baselineValue,
        currentValue: m.currentValue,
        achievedTier: m.achievedTier,
        partId: m.partId,
      )).toList(),
    );
  }
}