// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackingSessionsTableTable get trackingSessionsTable =>
      attachedDatabase.trackingSessionsTable;
  $LocationPointsTableTable get locationPointsTable =>
      attachedDatabase.locationPointsTable;
  $MissionInstancesTableTable get missionInstancesTable =>
      attachedDatabase.missionInstancesTable;
  SessionDaoManager get managers => SessionDaoManager(this);
}

class SessionDaoManager {
  final _$SessionDaoMixin _db;
  SessionDaoManager(this._db);
  $$TrackingSessionsTableTableTableManager get trackingSessionsTable =>
      $$TrackingSessionsTableTableTableManager(
        _db.attachedDatabase,
        _db.trackingSessionsTable,
      );
  $$LocationPointsTableTableTableManager get locationPointsTable =>
      $$LocationPointsTableTableTableManager(
        _db.attachedDatabase,
        _db.locationPointsTable,
      );
  $$MissionInstancesTableTableTableManager get missionInstancesTable =>
      $$MissionInstancesTableTableTableManager(
        _db.attachedDatabase,
        _db.missionInstancesTable,
      );
}
