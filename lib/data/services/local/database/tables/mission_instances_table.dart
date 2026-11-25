import 'package:drift/drift.dart';

import '../../../../../domain/models/enums/mission_axis.dart';
import 'tracking_sessions_table.dart';

/// 활성 운동 세션에 바인딩된 개별 미션의 실시간 진척도를 저장하는 Drift 테이블 정의입니다.
class MissionInstancesTable extends Table {
  /// 미션 인스턴스 고유 식별자. (기본키)
  TextColumn get id => text()();

  /// 소속 운동 세션의 외래키. (세션 삭제 시 CASCADE 연쇄 삭제)
  TextColumn get sessionId => text().references(
    TrackingSessionsTable,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 기반이 되는 미션 템플릿 식별자.
  TextColumn get missionTemplateId => text()();

  /// 미션 성과 평가 축.
  TextColumn get axis => textEnum<MissionAxis>()();

  /// 상대적 평가에 사용되는 세션 시작 기준값.
  RealColumn get baselineValue => real().nullable()();

  /// 현재 세션에서 누적 기록된 측정값.
  RealColumn get currentValue => real().withDefault(const Constant(0.0))();

  /// 현재 측정값 기준으로 달성된 최고 티어 단계.
  IntColumn get achievedTier => integer().withDefault(const Constant(0))();

  /// 달성한 티어에 따라 해금된 스케치 파츠 식별자.
  TextColumn get partId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
