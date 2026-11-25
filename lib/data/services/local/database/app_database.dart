import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../../domain/models/enums/activity_type.dart';
import '../../../../domain/models/enums/session_status.dart';
import '../../../../domain/models/enums/mission_axis.dart';
import '../../../../domain/models/enums/sync_status.dart';
import 'tables/offline_session_queue_table.dart';
import 'tables/tracking_sessions_table.dart';
import 'tables/location_points_table.dart';
import 'tables/mission_instances_table.dart';
import 'tables/visited_geohashes_table.dart';
import 'daos/session_dao.dart';
import 'daos/offline_session_queue_dao.dart';
import 'daos/exploration_dao.dart';

part 'app_database.g.dart';

/// 앱의 로컬 저장소를 총괄하는 Drift 데이터베이스 클래스입니다.
///
/// 활성 운동 세션, GPS 경로 좌표, 미션 인스턴스, 오프라인 동기화 대기 큐 및 Geohash 탐색 이력을 관리합니다.
@DriftDatabase(
  tables: [
    TrackingSessionsTable,
    LocationPointsTable,
    MissionInstancesTable,
    OfflineSessionQueueTable,
    VisitedGeohashesTable,
  ],
  daos: [SessionDao, OfflineSessionQueueDao, ExplorationDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // SQLite는 기본적으로 외래키가 비활성화되어 있으므로, CASCADE 삭제 동작 보장을 위해 매 오픈 시 활성화
      await customStatement('PRAGMA foreign_keys = ON;');
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(offlineSessionQueueTable);
      }
      if (from < 3) {
        await migrator.addColumn(
          trackingSessionsTable,
          trackingSessionsTable.movingDurationSeconds,
        );
      }
      if (from < 4) {
        await migrator.createTable(visitedGeohashesTable);
      }
    },
  );

  // 로컬 SQLite 데이터베이스 파일('move_sketch') 연결을 생성합니다.
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'move_sketch');
  }
}
