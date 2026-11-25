import 'package:drift/drift.dart';

import '../../../../../domain/models/enums/session_status.dart';
import '../app_database.dart';
import '../tables/tracking_sessions_table.dart';
import '../tables/location_points_table.dart';
import '../tables/mission_instances_table.dart';

part 'session_dao.g.dart';

/// 활성 운동 세션, 위치 좌표 및 미션 진척도 테이블을 트랜잭션 단위로 제어하는 Drift DAO 클래스입니다.
@DriftAccessor(
  tables: [TrackingSessionsTable, LocationPointsTable, MissionInstancesTable],
)
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  /// 신규 운동 세션([session])과 초기 미션 목록([missions])을 단일 트랜잭션으로 저장합니다.
  ///
  /// 기존에 종료되지 않은 활성·일시정지 상태의 잔여 세션이 남아 있다면 모두 정리한 뒤 새 세션을 삽입합니다.
  Future<void> startSession({
    required TrackingSessionsTableCompanion session,
    required List<MissionInstancesTableCompanion> missions,
  }) {
    return transaction(() async {
      await (delete(trackingSessionsTable)..where(
            (table) =>
                table.status.equalsValue(SessionStatus.active) |
                table.status.equalsValue(SessionStatus.pausedAuto) |
                table.status.equalsValue(SessionStatus.pausedManual),
          ))
          .go();

      await into(trackingSessionsTable).insert(session);

      for (final mission in missions) {
        await into(missionInstancesTable).insert(mission);
      }
    });
  }

  /// 현재 진행 중이거나 일시정지된 가장 최근 활성 세션을 조회하여 반환합니다.
  Future<TrackingSessionsTableData?> getActiveSession() {
    return (select(trackingSessionsTable)
          ..where(
            (table) =>
                table.status.equalsValue(SessionStatus.active) |
                table.status.equalsValue(SessionStatus.pausedAuto) |
                table.status.equalsValue(SessionStatus.pausedManual),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// 세션 고유 식별자([sessionId])에 해당하는 세션 행을 조회합니다.
  Future<TrackingSessionsTableData?> getSessionById(String sessionId) {
    return (select(
      trackingSessionsTable,
    )..where((session) => session.id.equals(sessionId))).getSingleOrNull();
  }

  /// 새로운 GPS 위치 좌표([point])를 삽입합니다.
  Future<void> insertPoint(LocationPointsTableCompanion point) {
    return into(locationPointsTable).insert(point);
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
    return (update(
      trackingSessionsTable,
    )..where((table) => table.id.equals(sessionId))).write(
      TrackingSessionsTableCompanion(
        elapsedDurationSeconds: Value(elapsedSeconds),
        movingDurationSeconds: Value(movingSeconds),
        distanceInMeters: Value(distance),
        caloriesBurned: Value(calories),
        averagePaceInSeconds: Value(pace),
        averageSpeedKmh: Value(speed),
      ),
    );
  }

  /// 개별 미션 인스턴스([mission])의 최신 측정값, 달성 티어 및 해금 파츠를 갱신합니다.
  Future<void> updateMissionProgress(MissionInstancesTableCompanion mission) {
    return (update(
      missionInstancesTable,
    )..where((table) => table.id.equals(mission.id.value))).write(mission);
  }

  /// 지정된 세션([sessionId])의 진행 상태([status])를 변경합니다.
  Future<void> updateSessionStatus({
    required String sessionId,
    required SessionStatus status,
  }) {
    return (update(trackingSessionsTable)
          ..where((table) => table.id.equals(sessionId)))
        .write(TrackingSessionsTableCompanion(status: Value(status)));
  }

  /// 지정된 세션([sessionId])에 기록된 모든 GPS 위치 좌표를 삽입 순서([LocationPointsTable.sequenceId]) 오름차순으로 조회합니다.
  Future<List<LocationPointsTableData>> getPoints(String sessionId) {
    return (select(locationPointsTable)
          ..where((table) => table.sessionId.equals(sessionId))
          ..orderBy([(table) => OrderingTerm.asc(table.sequenceId)]))
        .get();
  }

  /// 지정된 세션([sessionId])에 귀속된 모든 미션 인스턴스 목록을 조회합니다.
  Future<List<MissionInstancesTableData>> getMissions(String sessionId) {
    return (select(
      missionInstancesTable,
    )..where((table) => table.sessionId.equals(sessionId))).get();
  }

  /// 지정된 세션([sessionId])을 삭제합니다. (외래키 CASCADE 설정에 의해 하위 좌표 및 미션도 함께 삭제)
  Future<void> deleteSession(String sessionId) {
    return (delete(
      trackingSessionsTable,
    )..where((table) => table.id.equals(sessionId))).go();
  }
}
