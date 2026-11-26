import 'package:drift/drift.dart';

import '../../../domain/models/enums/session_status.dart';
import '../../../domain/models/session/location_point.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../domain/models/session/tracking_session.dart';
import 'database/daos/session_dao.dart';
import 'database/app_database.dart';

/// [SessionDao]를 통해 진행 중인 운동 세션 도메인 모델과 로컬 SQLite 테이블 간 변환·영속화를 담당하는 서비스 클래스입니다.
class SessionService {
  final SessionDao _dao;

  SessionService(this._dao);

  /// 신규 운동 세션([session])과 초기 미션 목록을 로컬 데이터베이스에 저장하여 시작합니다.
  Future<void> startSession({required TrackingSession session}) {
    final sessionCompanion = TrackingSessionsTableCompanion.insert(
      id: session.id,
      userId: session.userId,
      activityType: session.activityType,
      status: session.status,
      startedAt: session.startedAt,
      elapsedDurationSeconds: Value(session.elapsedDuration.inSeconds),
      movingDurationSeconds: Value(session.movingDuration.inSeconds),
      distanceInMeters: Value(session.distanceInMeters),
      caloriesBurned: Value(session.caloriesBurned),
    );

    final missionCompanions = session.missions
        .map(
          (mission) => MissionInstancesTableCompanion.insert(
            id: mission.id,
            sessionId: mission.sessionId,
            missionTemplateId: mission.missionTemplateId,
            axis: mission.axis,
            baselineValue: Value(mission.baselineValue),
            currentValue: Value(mission.currentValue),
            achievedTier: Value(mission.achievedTier),
            partId: Value(mission.partId),
          ),
        )
        .toList();

    return _dao.startSession(
      session: sessionCompanion,
      missions: missionCompanions,
    );
  }

  /// 현재 진행 중이거나 일시정지된 활성 세션을 좌표·미션과 결합하여 [TrackingSession]으로 복원합니다.
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

  /// 세션 고유 식별자([sessionId])에 해당하는 세션을 조회하여 [TrackingSession]으로 반환합니다.
  Future<TrackingSession?> getSessionById(String sessionId) async {
    final sessionRow = await _dao.getSessionById(sessionId);
    if (sessionRow == null) {
      return null;
    }

    final pointsRows = await _dao.getPoints(sessionId);
    final missionRows = await _dao.getMissions(sessionId);

    return TrackingSession.fromEntity(
      sessionRow: sessionRow,
      pointsRows: pointsRows,
      missionsRows: missionRows,
    );
  }

  /// 진행 중인 세션([sessionId])에 새로운 GPS 위치 좌표([point])를 추가 저장합니다.
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

  /// 진행 중인 세션([sessionId])의 경과 시간, 순수 이동 시간, 거리, 칼로리 및 속도/페이스 지표를 갱신합니다.
  Future<void> updateSessionProgress({
    required String sessionId,
    required int elapsedSeconds,
    required int movingSeconds,
    required double distance,
    required int calories,
    int? pace,
    double? speed,
  }) {
    return _dao.updateSessionProgress(
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
      movingSeconds: movingSeconds,
      distance: distance,
      calories: calories,
      pace: pace,
      speed: speed,
    );
  }

  /// 개별 미션 인스턴스([mission])의 최신 측정값, 달성 티어 및 해금 파츠를 갱신합니다.
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

  /// 지정된 세션([sessionId])의 진행 상태([status])를 변경합니다.
  Future<void> updateSessionStatus({
    required String sessionId,
    required SessionStatus status,
  }) {
    return _dao.updateSessionStatus(sessionId: sessionId, status: status);
  }

  /// 지정된 세션([sessionId])에 기록된 모든 GPS 위치 좌표를 [LocationPoint] 목록으로 반환합니다.
  Future<List<LocationPoint>> getPoints(String sessionId) async {
    final rows = await _dao.getPoints(sessionId);
    return rows.map(LocationPoint.fromEntity).toList();
  }

  /// 지정된 세션([sessionId])에 귀속된 모든 미션을 [MissionInstance] 목록으로 반환합니다.
  Future<List<MissionInstance>> getMissions(String sessionId) async {
    final rows = await _dao.getMissions(sessionId);
    return rows.map(MissionInstance.fromEntity).toList();
  }

  /// 지정된 세션([sessionId]) 및 종속된 좌표·미션 데이터를 삭제합니다.
  Future<void> deleteSession(String sessionId) {
    return _dao.deleteSession(sessionId);
  }
}
