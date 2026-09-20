import 'package:drift/drift.dart';

import '../../../domain/models/enums/session_status.dart';
import '../../../domain/models/session/location_point.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../domain/models/session/tracking_session.dart';
import 'database/daos/session_dao.dart';
import 'database/app_database.dart';

class SessionService {
  final SessionDao _dao;

  SessionService(this._dao);

  Future<void> startSession({required TrackingSession session}) {
    final sessionCompanion = TrackingSessionsTableCompanion.insert(
      id: session.id,
      userId: session.userId,
      activityType: session.activityType,
      status: session.status,
      startedAt: session.startedAt,
      elapsedDurationSeconds: Value(session.elapsedDuration.inSeconds),
      distanceInMeters: Value(session.distanceInMeters),
      caloriesBurned: Value(session.caloriesBurned),
    );

    final missionCompanions = session.missions
        .map(
          (m) => MissionInstancesTableCompanion.insert(
            id: m.id,
            sessionId: m.sessionId,
            missionTemplateId: m.missionTemplateId,
            axis: m.axis,
            baselineValue: Value(m.baselineValue),
            currentValue: Value(m.currentValue),
            achievedTier: Value(m.achievedTier),
            partId: Value(m.partId),
          ),
        )
        .toList();

    return _dao.startSession(
      session: sessionCompanion,
      missions: missionCompanions,
    );
  }

  Future<TrackingSession?> getActiveSession() async {
    final sessionRow = await _dao.getActiveSession();
    if (sessionRow == null) {
      return null;
    }

    final pointsRows = await _dao.getPoints(sessionRow.id);
    final missionRows = await _dao.getMissions(sessionRow.id);

    return TrackingSession.fromEntity(
      sessionRow: sessionRow,
      pointsRows: pointsRows,
      missionsRows: missionRows,
    );
  }

  Future<void> insertPoint({
    required String sessionId,
    required LocationPoint point,
  }) {
    return _dao.insertPoint(
      LocationPointsTableCompanion.insert(
        sessionId: sessionId,
        latitude: point.latitude,
        longitude: point.longitude,
        timestamp: point.timestamp,
        altitude: Value(point.altitude),
        speed: Value(point.speed),
      ),
    );
  }

  Future<void> updateSessionProgress({
    required String sessionId,
    required int elapsedSeconds,
    required double distance,
    required int calories,
    int? pace,
    double? speed,
  }) {
    return _dao.updateSessionProgress(
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
      distance: distance,
      calories: calories,
      pace: pace,
      speed: speed,
    );
  }

  Future<void> updateMission(MissionInstance mission) {
    return _dao.updateMissionProgress(
      MissionInstancesTableCompanion(
        id: Value(mission.id),
        currentValue: Value(mission.currentValue),
        achievedTier: Value(mission.achievedTier),
        partId: Value(mission.partId),
      ),
    );
  }

  Future<void> updateSessionStatus({
    required String sessionId,
    required SessionStatus status,
  }) {
    return _dao.updateSessionStatus(sessionId: sessionId, status: status);
  }

  Future<List<LocationPoint>> getPoints(String sessionId) async {
    final rows = await _dao.getPoints(sessionId);
    return rows.map(LocationPoint.fromEntity).toList();
  }

  Future<List<MissionInstance>> getMissions(String sessionId) async {
    final rows = await _dao.getMissions(sessionId);
    return rows.map(MissionInstance.fromEntity).toList();
  }

  Future<void> deleteSession(String sessionId) {
    return _dao.deleteSession(sessionId);
  }
}
