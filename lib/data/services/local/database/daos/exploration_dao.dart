import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/visited_geohashes_table.dart';

part 'exploration_dao.g.dart';

@DriftAccessor(tables: [VisitedGeohashesTable])
class ExplorationDao extends DatabaseAccessor<AppDatabase>
    with _$ExplorationDaoMixin {
  ExplorationDao(super.db);

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

  Future<int> getVisitedGeohashCount(String userId) async {
    final countExpression = visitedGeohashesTable.geohash.count();
    final query = selectOnly(visitedGeohashesTable)
      ..addColumns([countExpression])
      ..where(visitedGeohashesTable.userId.equals(userId));

    final row = await query.getSingleOrNull();
    return row?.read(countExpression) ?? 0;
  }

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
