import 'package:drift/drift.dart';
import '../../../../../domain/models/enums/session_status.dart';
import '../app_database.dart';
import '../tables/tracking_sessions_table.dart';
import '../tables/location_points_table.dart';
import '../tables/mission_instances_table.dart';

part 'session_dao.g.dart';

@DriftAccessor(
  tables: [TrackingSessionsTable, LocationPointsTable, MissionInstancesTable],
)
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

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

  Future<TrackingSessionsTableData?> getSessionById(String sessionId) {
    return (select(
      trackingSessionsTable,
    )..where((session) => session.id.equals(sessionId))).getSingleOrNull();
  }

  Future<void> insertPoint(LocationPointsTableCompanion point) {
    return into(locationPointsTable).insert(point);
  }

  Future<void> updateSessionProgress({
    required String sessionId,
    required int elapsedSeconds,
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
        distanceInMeters: Value(distance),
        caloriesBurned: Value(calories),
        averagePaceInSeconds: Value(pace),
        averageSpeedKmh: Value(speed),
      ),
    );
  }

  Future<void> updateMissionProgress(MissionInstancesTableCompanion mission) {
    return (update(
      missionInstancesTable,
    )..where((table) => table.id.equals(mission.id.value))).write(mission);
  }

  Future<void> updateSessionStatus({
    required String sessionId,
    required SessionStatus status,
  }) {
    return (update(trackingSessionsTable)
          ..where((table) => table.id.equals(sessionId)))
        .write(TrackingSessionsTableCompanion(status: Value(status)));
  }

  Future<List<LocationPointsTableData>> getPoints(String sessionId) {
    return (select(locationPointsTable)
          ..where((table) => table.sessionId.equals(sessionId))
          ..orderBy([(table) => OrderingTerm.asc(table.sequenceId)]))
        .get();
  }

  Future<List<MissionInstancesTableData>> getMissions(String sessionId) {
    return (select(
      missionInstancesTable,
    )..where((table) => table.sessionId.equals(sessionId))).get();
  }

  Future<void> deleteSession(String sessionId) {
    return (delete(
      trackingSessionsTable,
    )..where((table) => table.id.equals(sessionId))).go();
  }
}
