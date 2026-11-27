import 'dart:typed_data';

import '../../../domain/models/enums/sync_status.dart';
import '../../../domain/models/session/pending_session_task.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../utils/result.dart';

/// 오프라인 대기 세션의 로컬 큐 저장·조회·상태 갱신 및 삭제를 추상화한 저장소 인터페이스입니다.
abstract interface class OfflineSessionRepository {
  /// 세션 결과([sessionResult])와 스케치 이미지([sketchBytes])를 로컬 오프라인 큐에 적재합니다. (세션 종료 시 호출)
  Future<Result<void>> enqueuePendingSession({
    required SessionResult sessionResult,
    required Uint8List sketchBytes,
    SyncStatus syncStatus = SyncStatus.syncFailed,
  });

  /// 특정 사용자([userId])의 동기화 대기 중인 세션 작업 목록을 조회합니다.
  Future<Result<List<PendingSessionTask>>> getPendingSessions(String userId);

  /// 지정된 세션([sessionId])의 동기화 상태([status]) 및 재시도 횟수를 갱신합니다.
  Future<Result<void>> updateSyncStatus({
    required String sessionId,
    required SyncStatus status,
    DateTime? lastAttemptedAt,
    String? errorMessage,
    bool incrementRetry = false,
  });

  /// 원격 동기화 성공 후 로컬 대기 세션([sessionId])과 임시 이미지를 삭제합니다.
  Future<Result<void>> deletePendingSession(String sessionId);

  /// 특정 사용자([userId])의 동기화 대기 중인 세션 건수를 실시간으로 감시합니다.
  Stream<int> watchPendingCount(String userId);
}
