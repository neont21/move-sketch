import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/visited_geohashes_table.dart';

part 'exploration_dao.g.dart';

/// [VisitedGeohashesTable]에 접근하여 사용자의 과거 방문 Geohash 이력을 조회·갱신하는 Drift DAO 클래스입니다.
@DriftAccessor(tables: [VisitedGeohashesTable])
class ExplorationDao extends DatabaseAccessor<AppDatabase>
    with _$ExplorationDaoMixin {
  ExplorationDao(super.db);

  /// 지정된 사용자([userId])가 과거에 방문했던 모든 Geohash 코드 집합을 조회하여 반환합니다.
  Future<Set<String>> getVisitedGeohashSet(String userId) async {
    final query = selectOnly(visitedGeohashesTable)
      ..addColumns([visitedGeohashesTable.geohash])
      ..where(visitedGeohashesTable.userId.equals(userId));

    final rows = await query.get();
    return rows
        .map((row) => row.read(visitedGeohashesTable.geohash))
        .whereType<String>()
        .toSet();
  }

  /// 지정된 사용자([userId])가 방문한 고유 Geohash 타일의 총 개수를 반환합니다.
  Future<int> getVisitedGeohashCount(String userId) async {
    final countExpression = visitedGeohashesTable.geohash.count();
    final query = selectOnly(visitedGeohashesTable)
      ..addColumns([countExpression])
      ..where(visitedGeohashesTable.userId.equals(userId));

    final row = await query.getSingleOrNull();
    return row?.read(countExpression) ?? 0;
  }

  /// 사용자([userId])가 방문한 Geohash 목록([geohashes])을 단일 트랜잭션으로 삽입하거나 갱신(Upsert)합니다.
  ///
  /// 이미 방문 기록이 존재하는 타일인 경우 최근 방문 일시([visitedAt])를 갱신하고 방문 횟수([VisitedGeohashesTable.visitCount])를 1 증가시킵니다.
  Future<void> upsertVisitedGeohashes({
    required String userId,
    required Iterable<String> geohashes,
    required DateTime visitedAt,
  }) async {
    if (geohashes.isEmpty) {
      return;
    }

    await transaction(() async {
      for (final geohashCode in geohashes) {
        await into(visitedGeohashesTable).insert(
          VisitedGeohashesTableCompanion.insert(
            geohash: geohashCode,
            userId: userId,
            firstVisitedAt: visitedAt,
            lastVisitedAt: visitedAt,
          ),
          onConflict: DoUpdate(
            (existingRow) => VisitedGeohashesTableCompanion.custom(
              lastVisitedAt: Variable(visitedAt),
              visitCount: existingRow.visitCount + const Constant(1),
            ),
          ),
        );
      }
    });
  }
}
