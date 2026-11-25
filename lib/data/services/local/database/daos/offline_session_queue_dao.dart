import 'package:drift/drift.dart';

import '../../../../../domain/models/enums/sync_status.dart';
import '../app_database.dart';
import '../tables/offline_session_queue_table.dart';

part 'offline_session_queue_dao.g.dart';

/// [OfflineSessionQueueTable]에 접근하여 미동기화 세션 대기 큐를 관리하는 Drift DAO 클래스입니다.
@DriftAccessor(tables: [OfflineSessionQueueTable])
class OfflineSessionQueueDao extends DatabaseAccessor<AppDatabase>
    with _$OfflineSessionQueueDaoMixin {
  OfflineSessionQueueDao(super.db);

  /// 완료된 세션 대기 항목([session])을 큐에 삽입하거나 기존 항목을 덮어씁니다.
  Future<void> enqueueSession(OfflineSessionQueueTableCompanion session) {
    return into(offlineSessionQueueTable).insertOnConflictUpdate(session);
  }

  /// 지정된 사용자([userId])의 동기화가 완료되지 않은([SyncStatus.synced] 제외) 대기 항목을 생성 시각 오름차순으로 조회합니다.
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

  /// 세션 식별자([sessionId])에 해당하는 단일 큐 항목을 조회합니다.
  Future<OfflineSessionQueueTableData?> getQueueItemById(String sessionId) =>
      (select(
        offlineSessionQueueTable,
      )..where((table) => table.id.equals(sessionId))).getSingleOrNull();

  /// 지정된 세션([sessionId])의 동기화 상태([status]), 시도 일시 및 오류 메시지를 갱신합니다.
  ///
  /// [incrementRetry]가 `true`인 경우 기존 재시도 횟수를 1 증가시켜 저장합니다.
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

  /// 동기화가 완료되었거나 폐기된 세션 항목([sessionId])을 대기 큐에서 삭제합니다.
  Future<void> deleteQueueItem(String sessionId) {
    return (delete(
      offlineSessionQueueTable,
    )..where((table) => table.id.equals(sessionId))).go();
  }

  /// 지정된 사용자([userId])의 미동기화 대기 작업 개수를 실시간 스트림으로 감시합니다.
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
