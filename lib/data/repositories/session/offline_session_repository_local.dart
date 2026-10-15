import 'dart:convert';
import 'dart:typed_data';

import '../../../domain/models/enums/sync_status.dart';
import '../../../domain/models/session/pending_session_task.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/local/offline_session_service.dart';
import 'offline_session_repository.dart';

final class OfflineSessionRepositoryLocal implements OfflineSessionRepository {
  final OfflineSessionService offlineSessionService;

  OfflineSessionRepositoryLocal({required this.offlineSessionService});

  @override
  Future<Result<void>> enqueuePendingSession({
    required SessionResult sessionResult,
    required Uint8List sketchBytes,
    SyncStatus syncStatus = SyncStatus.syncFailed,
  }) async {
    try {
      final imagePath = await offlineSessionService.saveSketchImage(
        sessionId: sessionResult.id,
        bytes: sketchBytes,
      );

      await offlineSessionService.enqueueSession(
        sessionResult: sessionResult,
        sketchImagePath: imagePath,
        syncStatus: syncStatus,
      );

      return const Result.ok(null);
    } catch (error) {
      return Result.error(
        DatabaseException('오프라인 세션 임시 저장 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Future<Result<List<PendingSessionTask>>> getPendingSessions(
    String userId,
  ) async {
    try {
      final rows = await offlineSessionService.getPendingSessions(userId);
      final List<PendingSessionTask> tasks = [];

      for (final row in rows) {
        final imageBytes = await offlineSessionService.readSketchImage(
          row.sketchImagePath,
        );
        if (imageBytes == null || imageBytes.isEmpty) {
          continue;
        }

        final jsonMap = jsonDecode(row.sessionResultJson);
        final sessionResult = SessionResult.fromMap(jsonMap, id: row.id);

        tasks.add(
          PendingSessionTask(
            sessionResult: sessionResult,
            sketchBytes: imageBytes,
            retryCount: row.retryCount,
            syncStatus: row.syncStatus,
            createdAt: row.createdAt,
            lastAttemptedAt: row.lastAttemptedAt,
            errorMessage: row.errorMessage,
          ),
        );
      }

      return Result.ok(tasks);
    } catch (error) {
      return Result.error(
        DatabaseException('미전송 세션 목록을 불러오는 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> updateSyncStatus({
    required String sessionId,
    required SyncStatus status,
    DateTime? lastAttemptedAt,
    String? errorMessage,
    bool incrementRetry = false,
  }) async {
    try {
      await offlineSessionService.updateSyncStatus(
        sessionId: sessionId,
        status: status,
        lastAttemptedAt: lastAttemptedAt,
        errorMessage: errorMessage,
        incrementRetry: incrementRetry,
      );

      return const Result.ok(null);
    } catch (error) {
      return Result.error(
        DatabaseException('세션 동기화 상태 갱신 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> deletePendingSession(String sessionId) async {
    try {
      await offlineSessionService.deleteSession(sessionId);

      return const Result.ok(null);
    } catch (error) {
      return Result.error(
        DatabaseException('오프라인 세션 삭제 중 오류가 발생했습니다.', cause: error),
      );
    }
  }

  @override
  Stream<int> watchPendingCount(String userId) {
    return offlineSessionService.watchPendingCount(userId);
  }
}
