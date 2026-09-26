import 'package:latlong2/latlong.dart';
import '../../../domain/models/enums/activity_type.dart';
import '../../../domain/models/enums/session_status.dart';
import '../../../domain/models/fixed/sketch_parts.dart';
import '../../../domain/models/session/location_point.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/local/session_service.dart';
import 'session_repository.dart';

final class SessionRepositoryLocal implements SessionRepository {
  final SessionService sessionService;

  SessionRepositoryLocal({required this.sessionService});

  @override
  Future<Result<TrackingSession?>> getActiveSession() async {
    try {
      final TrackingSession? session = await sessionService.getActiveSession();

      return Result.ok(session);
    } catch (e) {
      return Result.error(
        DatabaseException('활성 세션 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<TrackingSession?>> getSession(String sessionId) async {
    try {
      final session = await sessionService.getSessionById(sessionId);
      return Result.ok(session);
    } catch (e) {
      return Result.error(SessionException('세션 조회에 실패했습니다.', cause: e));
    }
  }

  @override
  Future<Result<TrackingSession>> startSession({
    required String userId,
    required ActivityType activityType,
    required List<MissionInstance> missions,
  }) async {
    try {
      final session = TrackingSession.start(
        userId: userId,
        activityType: activityType,
        missions: missions,
      );

      await sessionService.startSession(session: session);

      return Result.ok(session);
    } catch (e) {
      return Result.error(SessionException('세션을 시작하지 못했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> recordPoint({
    required String sessionId,
    required LocationPoint point,
    required Duration elapsedDuration,
    required double totalDistanceInMeters,
    required int caloriesBurned,
    int? averagePaceInSeconds,
    double? averageSpeedKmh,
  }) async {
    try {
      await sessionService.insertPoint(sessionId: sessionId, point: point);
      await sessionService.updateSessionProgress(
        sessionId: sessionId,
        elapsedSeconds: elapsedDuration.inSeconds,
        distance: totalDistanceInMeters,
        calories: caloriesBurned,
        pace: averagePaceInSeconds,
        speed: averageSpeedKmh,
      );

      return const Result.ok(null);
    } catch (e) {
      return Result.error(
        SessionException('좌표 기록 및 세션 진행 상태 갱신에 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> updateMission(MissionInstance mission) async {
    try {
      await sessionService.updateMission(mission);

      return const Result.ok(null);
    } catch (e) {
      return Result.error(SessionException('미션 진행 상태 갱신에 실패했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> pauseSession(
    String sessionId, {
    bool isAuto = false,
  }) async {
    try {
      await sessionService.updateSessionStatus(
        sessionId: sessionId,
        status: isAuto ? SessionStatus.pausedAuto : SessionStatus.pausedManual,
      );

      return const Result.ok(null);
    } catch (e) {
      return Result.error(SessionException('세션 일시정지 처리에 실패했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> resumeSession(String sessionId) async {
    try {
      await sessionService.updateSessionStatus(
        sessionId: sessionId,
        status: SessionStatus.active,
      );

      return const Result.ok(null);
    } catch (e) {
      return Result.error(SessionException('세션 재개에 실패했습니다.', cause: e));
    }
  }

  @override
  Future<Result<SessionResult>> completeSession({
    required String sessionId,
    required SketchComposition sketchComposition,
    String? routePolyline,
    String? resultSketchImageUrl,
  }) async {
    try {
      final session = await sessionService.getSessionById(sessionId);
      if (session == null) {
        return Result.error(
          NotFoundException('완료할 활성 세션(id: $sessionId)을 찾을 수 없습니다.'),
        );
      }

      if (!session.isValidSession) {
        return const Result.error(ValidationException('세션이 너무 짧아 기록되지 않았습니다.'));
      }

      final now = DateTime.now();
      final waypoint = _calculateFurthestWaypoint(session.pathPoints);

      final result = SessionResult(
        id: session.id,
        userId: session.userId,
        activityType: session.activityType,
        startedAt: session.startedAt,
        endedAt: now,
        elapsedDuration: session.elapsedDuration,
        distanceInMeters: session.distanceInMeters,
        caloriesBurned: session.caloriesBurned,
        averagePaceInSeconds: session.averagePaceInSeconds,
        averageSpeedKmh: session.averageSpeedKmh,
        sketchComposition: sketchComposition,
        startLocation: session.pathPoints.first,
        waypoint: waypoint,
        endLocation: session.pathPoints.last,
        routePolyline: routePolyline,
        resultSketchImageUrl: resultSketchImageUrl,
        missions: List.unmodifiable(session.missions),
        createdAt: now,
        isShared: false,
      );

      await sessionService.updateSessionStatus(
        sessionId: sessionId,
        status: SessionStatus.completed,
      );

      return Result.ok(result);
    } catch (e) {
      return Result.error(SessionException('세션 완료 처리 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<void>> discardSession(String sessionId) async {
    try {
      await sessionService.deleteSession(sessionId);

      return const Result.ok(null);
    } catch (e) {
      return Result.error(
        DatabaseException('세션 데이터 삭제 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  LocationPoint _calculateFurthestWaypoint(List<LocationPoint> pathPoints) {
    final start = pathPoints.first.toLatLng();
    final end = pathPoints.last.toLatLng();
    const distance = Distance();

    LocationPoint waypoint = pathPoints[1];
    double maxDistanceSum = -1.0;

    for (int i = 1; i < pathPoints.length - 1; i++) {
      final current = pathPoints[i].toLatLng();
      final total =
          distance.as(LengthUnit.Meter, start, current) +
          distance.as(LengthUnit.Meter, end, current);

      if (total > maxDistanceSum) {
        maxDistanceSum = total;
        waypoint = pathPoints[i];
      }
    }
    return waypoint;
  }
}
