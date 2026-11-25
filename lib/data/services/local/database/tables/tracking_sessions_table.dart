import 'package:drift/drift.dart';

import '../../../../../domain/models/enums/activity_type.dart';
import '../../../../../domain/models/enums/session_status.dart';

/// 현재 진행 중이거나 일시정지된 활성 운동 세션의 주행 통계를 저장하는 Drift 테이블 정의입니다.
class TrackingSessionsTable extends Table {
  /// 운동 세션 고유 식별자. (기본키)
  TextColumn get id => text()();

  /// 운동을 수행 중인 사용자의 고유 식별자.
  TextColumn get userId => text()();

  /// 운동 활동 종목.
  TextColumn get activityType => textEnum<ActivityType>()();

  /// 현재 세션의 기록 상태.
  TextColumn get status => textEnum<SessionStatus>()();

  /// 운동 세션이 최초 시작된 일시.
  DateTimeColumn get startedAt => dateTime()();

  /// 일시정지를 포함한 세션 전체 경과 시간. (초 단위)
  IntColumn get elapsedDurationSeconds =>
      integer().withDefault(const Constant(0))();

  /// 일시정지를 제외한 순수 이동 활동 시간. (초 단위)
  IntColumn get movingDurationSeconds =>
      integer().withDefault(const Constant(0))();

  /// 현재까지 누적된 총 이동 거리. (미터 단위)
  RealColumn get distanceInMeters => real().withDefault(const Constant(0.0))();

  /// 현재까지 소모된 추정 칼로리. (kcal)
  IntColumn get caloriesBurned => integer().withDefault(const Constant(0))();

  /// 조깅 세션의 현재까지 1km당 평균 페이스. (초 단위)
  IntColumn get averagePaceInSeconds => integer().nullable()();

  /// 라이딩 세션의 현재까지 평균 이동 시속. (km/h 단위)
  RealColumn get averageSpeedKmh => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
