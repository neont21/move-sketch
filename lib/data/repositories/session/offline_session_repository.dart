import 'dart:typed_data';
import '../../../domain/models/enums/sync_status.dart';
import '../../../domain/models/session/pending_session_task.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../utils/result.dart';

abstract interface class OfflineSessionRepository {
  /// 세션 결과와 스케치 이미지를 로컬 기기에 저장한다. (세션 종료)
  Future<Result<void>> enqueuePendingSession({
    required SessionResult sessionResult,
    required Uint8List sketchBytes,
    SyncStatus syncStatus = SyncStatus.syncFailed,
  });

  /// 특정 사용자의 동기화 대기 중인 세션 목록을 조회한다.
  Future<Result<List<PendingSessionTask>>> getPendingSessions(String userId);

  /// 동기화 상태 및 재시도 횟수를 갱신하다.
  Future<Result<void>> updateSyncStatus({
    required String sessionId,
    required SyncStatus status,
    DateTime? lastAttemptedAt,
    String? errorMessage,
    bool incrementRetry = false,
  });

  /// 동기화 성공 후 로컬 데이터를 삭제한다.
  Future<Result<void>> deletePendingSession(String sessionId);

  /// 특정 사용자의 동기화 대기 중인 세션 건수를 실시간 추적한다.
  Stream<int> watchPendingCount(String userId);
}
