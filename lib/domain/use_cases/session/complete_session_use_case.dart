import 'dart:typed_data';
import '../../../data/repositories/session/session_repository.dart';
import '../../../data/repositories/session_result/session_result_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../models/fixed/sketch_parts.dart';
import '../../models/session/session_result.dart';

final class CompleteSessionUseCase {
  final SessionRepository sessionRepository;
  final SessionResultRepository sessionResultRepository;

  CompleteSessionUseCase({
    required this.sessionRepository,
    required this.sessionResultRepository,
  });

  /// 세션 종료 및 스케치 결과 정산 오케스트레이션
  Future<Result<SessionResult>> execute({
    required String sessionId,
    required SketchComposition sketchComposition,
    required Uint8List sketchBytes,
    required Uint8List routeBytes,
    String? routePolyline,
  }) async {
    if (sketchBytes.isEmpty || routeBytes.isEmpty) {
      return const Result.error(
        ValidationException('스케치 또는 경로 이미지 데이터가 비어 있습니다.'),
      );
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

    final remoteResult = await sessionResultRepository.saveResult(
      result: sessionResult,
      sketchBytes: sketchBytes,
      routeBytes: routeBytes,
    );

    switch (remoteResult) {
      case Ok():
        await sessionRepository.discardSession(sessionId);
        return remoteResult;
      case Error(:final error):
        return Result.error(error);
    }
  }
}
