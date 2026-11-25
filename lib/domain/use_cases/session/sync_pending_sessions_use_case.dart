import '../../../data/repositories/network/network_connectivity_repository.dart';
import '../../../data/repositories/session/offline_session_repository.dart';
import '../../../data/repositories/session/session_repository.dart';
import '../../../data/repositories/session_result/session_result_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../models/enums/sync_status.dart';
import '../../models/session/pending_session_task.dart';
import '../../models/session/session_result.dart';

/// 오프라인 대기 큐에 적재된 미동기화 운동 세션들을 원격 서버로 일괄 재전송하는 유즈케이스 클래스입니다.
final class SyncPendingSessionsUseCase {
  /// 오프라인 대기 작업 조회, 상태 갱신 및 삭제를 담당하는 저장소.
  final OfflineSessionRepository offlineSessionRepository;

  /// 세션 결과 및 스케치 이미지의 원격 업로드를 담당하는 저장소.
  final SessionResultRepository sessionResultRepository;

  /// 동기화 완료 후 잔여 로컬 활성 세션을 정리하기 위한 저장소.
  final SessionRepository sessionRepository;

  /// 동기화 실행 전 네트워크 연결 상태를 확인하는 저장소.
  final NetworkConnectivityRepository networkConnectivityRepository;

  bool _isSyncing = false;

  SyncPendingSessionsUseCase({
    required this.offlineSessionRepository,
    required this.sessionResultRepository,
    required this.sessionRepository,
    required this.networkConnectivityRepository,
  });

  /// 지정된 사용자([userId])의 대기 중인 모든 세션을 순차 동기화하고 성공 건수를 반환합니다.
  ///
  /// 이미 동기화가 진행 중이거나 네트워크가 오프라인 상태인 경우 중복 실행을 방지하기 위해 `0`을 반환합니다.
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

  // 단일 대기 작업의 상태를 syncing으로 전환한 뒤 15초 타임아웃으로 원격 저장을 시도하고, 결과에 따라 큐 정리 또는 실패 기록을 수행합니다.
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
