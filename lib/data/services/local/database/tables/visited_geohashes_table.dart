import 'package:drift/drift.dart';

/// 사용자별 과거 방문 Geohash 타일 이력과 누적 방문 횟수를 저장하는 Drift 테이블 정의입니다.
class VisitedGeohashesTable extends Table {
  /// Geohash Base32 격자 코드. (복합 기본키)
  TextColumn get geohash => text()();

  /// 방문한 사용자의 고유 식별자. (복합 기본키)
  TextColumn get userId => text()();

  /// 해당 타일을 최초로 방문한 일시.
  DateTimeColumn get firstVisitedAt => dateTime()();

  /// 해당 타일을 가장 최근에 방문한 일시.
  DateTimeColumn get lastVisitedAt => dateTime()();

  /// 해당 타일에 누적 방문한 총 세션 횟수.
  IntColumn get visitCount => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {geohash, userId};
}
