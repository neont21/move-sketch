import 'dart:typed_data';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../data/repositories/exploration/exploration_repository.dart';
import '../../../data/repositories/session/offline_session_repository.dart';
import '../../../data/repositories/session/session_repository.dart';
import '../../../data/repositories/session_result/session_result_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/geohash_helper.dart';
import '../../../utils/result.dart';
import '../../models/enums/session_status.dart';
import '../../models/enums/sync_status.dart';
import '../../models/fixed/sketch_composition.dart';
import '../../models/session/session_result.dart';

/// 진행 중인 운동 세션을 완료 처리하고 로컬 큐 적재 및 원격 서버 동기화를 오케스트레이션하는 유즈케이스 클래스입니다.
final class CompleteSessionUseCase {
  /// 활성 세션의 조회, 완료 및 폐기를 담당하는 저장소.
  final SessionRepository sessionRepository;

  /// 완료된 세션 결과 및 스케치 이미지의 원격 업로드를 담당하는 저장소.
  final SessionResultRepository sessionResultRepository;

  /// 네트워크 장애 시 재전송을 위해 대기 작업을 관리하는 오프라인 큐 저장소.
  final OfflineSessionRepository offlineSessionRepository;

  /// 세션 중 방문한 신규 경로 Geohash 이력을 영속화하는 저장소.
  final ExplorationRepository explorationRepository;

  CompleteSessionUseCase({
    required this.sessionRepository,
    required this.sessionResultRepository,
    required this.offlineSessionRepository,
    required this.explorationRepository,
  });

  /// 세션을 최종 완료 처리하고 완성된 [SessionResult]를 반환합니다.
  ///
  /// 1. [sketchBytes] 유효성 검증 후 로컬 세션을 완료 상태로 확정합니다.
  /// 2. 경로 좌표의 Geohash를 추출하여 방문 탐색 이력에 누적 기록합니다.
  /// 3. 오프라인 대기 큐에 `syncing` 상태로 선적재한 뒤 원격 저장을 시도합니다. (10초 타임아웃)
  /// 4. 원격 저장 성공 시 대기 큐와 활성 세션을 정리하며, 실패 시 재시도 횟수를 늘리고 `syncFailed` 상태의 결과를 반환합니다.
  Future<Result<SessionResult>> execute({
    required String sessionId,
    required SketchComposition sketchComposition,
    required Uint8List sketchBytes,
    String? routePolyline,
  }) async {
    if (sketchBytes.isEmpty) {
      return const Result.error(ValidationException('스케치 이미지 데이터가 비어 있습니다.'));
    }

    final Set<String> visitedGeohashesToRecord = {};
    final preCompleteSessionResult = await sessionRepository.getSession(
      sessionId,
    );
    switch (preCompleteSessionResult) {
      case Ok(:final value):
        if (value != null && value.status != SessionStatus.completed) {
          for (final point in value.pathPoints) {
            visitedGeohashesToRecord.add(
              GeohashHelper.encode(point.latitude, point.longitude),
            );
          }
        }
      case Error():
        break;
    }

    final localResult = await sessionRepository.completeSession(
      sessionId: sessionId,
      sketchComposition: sketchComposition,
      routePolyline: routePolyline,
    );

    final SessionResult sessionResult;
    switch (localResult) {
      case Ok(:final value):
        sessionResult = value;
      case Error(:final error):
        return Result.error(error);
    }

    if (visitedGeohashesToRecord.isNotEmpty) {
      final recordResult = await explorationRepository.recordVisitedGeohashes(
        userId: sessionResult.userId,
        geohashes: visitedGeohashesToRecord,
        visitedAt: sessionResult.endedAt,
      );
      switch (recordResult) {
        case Ok():
          break;
        case Error(:final error):
          FirebaseCrashlytics.instance.recordError(
            error,
            StackTrace.current,
            reason: '세션 완료 후 방문 Geohash 이력 저장 실패',
            fatal: false,
          );
      }
    }

    await offlineSessionRepository.enqueuePendingSession(
      sessionResult: sessionResult,
      sketchBytes: sketchBytes,
      syncStatus: SyncStatus.syncing,
    );

    Result<SessionResult> remoteResult;
    try {
      remoteResult = await sessionResultRepository
          .saveResult(result: sessionResult, sketchBytes: sketchBytes)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      remoteResult = const Result.error(NetworkException('서버 연결 시간 초과'));
    }

    switch (remoteResult) {
      case Ok():
        await offlineSessionRepository.deletePendingSession(sessionId);
        await sessionRepository.discardSession(sessionId);
        return remoteResult;
      case Error(:final error):
        await offlineSessionRepository.updateSyncStatus(
          sessionId: sessionId,
          status: SyncStatus.syncFailed,
          lastAttemptedAt: DateTime.now(),
          errorMessage: error.toString(),
          incrementRetry: true,
        );

        return Result.ok(
          sessionResult.copyWith(syncStatus: SyncStatus.syncFailed),
        );
    }
  }
}
