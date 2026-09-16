import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../models/enums/activity_type.dart';
import '../../models/enums/session_status.dart';
import '../../models/enums/mission_axis.dart';

import 'tables/tracking_sessions_table.dart';
import 'tables/location_points_table.dart';
import 'tables/mission_instances_table.dart';
import 'daos/session_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [TrackingSessionsTable, LocationPointsTable, MissionInstancesTable],
  daos: [SessionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'move_sketch');
  }
}
