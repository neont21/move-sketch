import 'package:drift/drift.dart';
import '../../../../../domain/models/enums/sync_status.dart';
import '../app_database.dart';
import '../tables/offline_session_queue_table.dart';

part 'offline_session_queue_dao.g.dart';

@DriftAccessor(tables: [OfflineSessionQueueTable])
class OfflineSessionQueueDao extends DatabaseAccessor<AppDatabase>
    with _$OfflineSessionQueueDaoMixin {
  OfflineSessionQueueDao(super.db);

  Future<void> enqueueSession(OfflineSessionQueueTableCompanion session) {
    return into(offlineSessionQueueTable).insertOnConflictUpdate(session);
  }

  Future<List<OfflineSessionQueueTableData>> getPendingSessions(
    String userId,
  ) =>
      (select(offlineSessionQueueTable)
            ..where(
              (table) =>
                  table.userId.equals(userId) &
                  table.syncStatus.equalsValue(SyncStatus.synced).not(),
            )
            ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
          .get();

  Future<OfflineSessionQueueTableData?> getQueueItemById(String sessionId) =>
      (select(
        offlineSessionQueueTable,
      )..where((table) => table.id.equals(sessionId))).getSingleOrNull();

  Future<void> updateSyncStatus({
    required String sessionId,
    required SyncStatus status,
    DateTime? lastAttemptedAt,
    String? errorMessage,
    bool incrementRetry = false,
  }) async {
    final existing = await getQueueItemById(sessionId);
    final int nextRetryCount = incrementRetry
        ? ((existing?.retryCount ?? 0) + 1)
        : (existing?.retryCount ?? 0);

    await (update(
      offlineSessionQueueTable,
    )..where((table) => table.id.equals(sessionId))).write(
      OfflineSessionQueueTableCompanion(
        syncStatus: Value(status),
        lastAttemptedAt: Value(lastAttemptedAt),
        errorMessage: Value(errorMessage),
        retryCount: Value(nextRetryCount),
      ),
    );
  }

  Future<void> deleteQueueItem(String sessionId) {
    return (delete(
      offlineSessionQueueTable,
    )..where((table) => table.id.equals(sessionId))).go();
  }

  Stream<int> watchPendingCount(String userId) {
    final countExpression = offlineSessionQueueTable.id.count();
    final query = selectOnly(offlineSessionQueueTable)
      ..addColumns([countExpression])
      ..where(
        offlineSessionQueueTable.userId.equals(userId) &
            offlineSessionQueueTable.syncStatus
                .equalsValue(SyncStatus.synced)
                .not(),
      );

    return query.map((row) => row.read(countExpression) ?? 0).watchSingle();
  }
}
