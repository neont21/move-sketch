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

final class CompleteSessionUseCase {
  final SessionRepository sessionRepository;
  final SessionResultRepository sessionResultRepository;
  final OfflineSessionRepository offlineSessionRepository;
  final ExplorationRepository explorationRepository;

  CompleteSessionUseCase({
    required this.sessionRepository,
    required this.sessionResultRepository,
    required this.offlineSessionRepository,
    required this.explorationRepository,
  });

  Future<Result<SessionResult>> execute({
    required String sessionId,
    required SketchComposition sketchComposition,
    required Uint8List sketchBytes,
    String? routePolyline,
  }) async {
    if (sketchBytes.isEmpty) {
      return const Result.error(
        ValidationException('스케치 이미지 데이터가 비어 있습니다.'),
      );
    }

    final Set<String> visitedGeohashesToRecord = {};
    final preCompleteSessionResult = await sessionRepository.getSession(
      sessionId,
    );
    switch (preCompleteSessionResult) {
      case Ok(:final value):
        if (value != null &&
            value.status != SessionStatus.completed) {
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
          .saveResult(
        result: sessionResult,
        sketchBytes: sketchBytes,
      )
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
