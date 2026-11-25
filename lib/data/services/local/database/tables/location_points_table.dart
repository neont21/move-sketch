import 'package:drift/drift.dart';

import 'tracking_sessions_table.dart';

/// 활성 운동 세션 중 수집된 GPS 위치 좌표 시퀀스를 저장하는 Drift 테이블 정의입니다.
class LocationPointsTable extends Table {
  /// 좌표 삽입 순서를 보장하는 자동 증가 기본키.
  IntColumn get sequenceId => integer().autoIncrement()();

  /// 소속 운동 세션의 외래키. (세션 삭제 시 CASCADE 연쇄 삭제)
  TextColumn get sessionId => text().references(
    TrackingSessionsTable,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 위도 좌표. (WGS84 도 단위)
  RealColumn get latitude => real()();

  /// 경도 좌표. (WGS84 도 단위)
  RealColumn get longitude => real()();

  /// 위치 좌표가 측정된 일시.
  DateTimeColumn get timestamp => dateTime()();

  /// 해발 고도. (미터 단위)
  RealColumn get altitude => real().nullable()();

  /// 이동 속도. (초당 미터 m/s 단위)
  RealColumn get speed => real().nullable()();
}
