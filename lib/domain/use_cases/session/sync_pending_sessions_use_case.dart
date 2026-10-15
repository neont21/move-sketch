import '../../../data/repositories/network/network_connectivity_repository.dart';
import '../../../data/repositories/session/offline_session_repository.dart';
import '../../../data/repositories/session/session_repository.dart';
import '../../../data/repositories/session_result/session_result_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../models/enums/sync_status.dart';
import '../../models/session/pending_session_task.dart';
import '../../models/session/session_result.dart';

final class SyncPendingSessionsUseCase {
  final OfflineSessionRepository offlineSessionRepository;
  final SessionResultRepository sessionResultRepository;
  final SessionRepository sessionRepository;
  final NetworkConnectivityRepository networkConnectivityRepository;

  bool _isSyncing = false;

  SyncPendingSessionsUseCase({
    required this.offlineSessionRepository,
    required this.sessionResultRepository,
    required this.sessionRepository,
    required this.networkConnectivityRepository,
  });

  Future<Result<int>> execute(String userId) async {
    if (_isSyncing) {
      return const Result.ok(0);
    }

    final isConnected = await networkConnectivityRepository.isConnected();
    if (!isConnected) {
      return const Result.ok(0);
    }

    _isSyncing = true;
    int successCount = 0;

    try {
      final result = await offlineSessionRepository.getPendingSessions(userId);

      final List<PendingSessionTask> pendingTasks;
      switch (result) {
        case Ok(:final value):
          pendingTasks = value;
        case Error(:final error):
          return Result.error(error);
      }

      if (pendingTasks.isEmpty) {
        return const Result.ok(0);
      }

      for (final task in pendingTasks) {
        final syncResult = await _syncPendingTask(task);
        switch (syncResult) {
          case Ok():
            successCount++;
          case Error():
            break;
        }
      }

      return Result.ok(successCount);
    } finally {
      _isSyncing = false;
    }
  }

  Future<Result<SessionResult>> _syncPendingTask(
    PendingSessionTask task,
  ) async {
    final sessionId = task.sessionId;

    await offlineSessionRepository.updateSyncStatus(
      sessionId: sessionId,
      status: SyncStatus.syncing,
      lastAttemptedAt: DateTime.now(),
    );

    Result<SessionResult> result;
    try {
      result = await sessionResultRepository
          .saveResult(result: task.sessionResult, sketchBytes: task.sketchBytes)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      result = const Result.error(NetworkException('세션 결과 전송 시간이 초과되었습니다.'));
    }

    switch (result) {
      case Ok(:final value):
        await offlineSessionRepository.deletePendingSession(sessionId);
        await sessionRepository.discardSession(sessionId);

        return Result.ok(value.copyWith(syncStatus: SyncStatus.synced));
      case Error(:final error):
        await offlineSessionRepository.updateSyncStatus(
          sessionId: sessionId,
          status: SyncStatus.syncFailed,
          lastAttemptedAt: DateTime.now(),
          errorMessage: error.toString(),
          incrementRetry: true,
        );

        return Result.error(error);
    }
  }
}
