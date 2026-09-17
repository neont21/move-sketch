import '../../models/enums/activity_type.dart';
import '../../models/enums/session_status.dart';
import '../../models/fixed/sketch_parts.dart';
import '../../models/session/location_point.dart';
import '../../models/session/mission_instance.dart';
import '../../models/session/session_result.dart';
import '../../models/session/tracking_session.dart';
import 'session_repository.dart';

class SessionRepositoryMock implements SessionRepository {
  TrackingSession? _currentSession;

  void setMockSession(TrackingSession? session) {
    _currentSession = session;
  }

  @override
  Future<TrackingSession?> getActiveSession() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (_currentSession != null && _currentSession!.isOngoing) {
      return _currentSession;
    }
    return null;
  }

  @override
  Future<TrackingSession> startSession({
    required String userId,
    required ActivityType activityType,
    required List<MissionInstance> initialMissions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    _currentSession = TrackingSession.start(
      userId: userId,
      activityType: activityType,
    ).copyWith(missions: initialMissions);

    return _currentSession!;
  }

  @override
  Future<void> recordPoint({
    required String sessionId,
    required LocationPoint point,
    required Duration elapsedDuration,
    required double totalDistanceInMeters,
    required int caloriesBurned,
    int? averagePaceInSeconds,
    double? averageSpeedKmh,
  }) async {
    if (_currentSession == null || _currentSession!.id != sessionId) return;

    _currentSession = _currentSession!
        .addPoint(point)
        .copyWith(
      elapsedDuration: elapsedDuration,
      distanceInMeters: totalDistanceInMeters,
      caloriesBurned: caloriesBurned,
      averagePaceInSeconds: () => averagePaceInSeconds,
      averageSpeedKmh: () => averageSpeedKmh,
    );
  }

  @override
  Future<void> updateMission(MissionInstance mission) async {
    if (_currentSession == null) return;

    final updatedMissions = _currentSession!.missions.map((m) {
      return m.id == mission.id ? mission : m;
    }).toList();

    _currentSession = _currentSession!.copyWith(missions: updatedMissions);
  }

  @override
  Future<void> pauseSession(String sessionId, {bool isAuto = false}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_currentSession?.id == sessionId) {
      _currentSession = _currentSession!.copyWith(status: SessionStatus.pausedAuto);
    }
  }
  @override
  Future<void> resumeSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_currentSession?.id == sessionId) {
      _currentSession = _currentSession!.copyWith(status: SessionStatus.active);
    }
  }

  @override
  Future<SessionResult> completeSession({
    required String sessionId,
    required SketchComposition sketchComposition,
    String? routePolyline,
    String? routeImageUrl,
    String? resultSketchImageUrl,
    String? locationTag,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (_currentSession == null || _currentSession!.id != sessionId) {
      throw StateError('완료할 세션이 존재하지 않습니다.');
    }

    final result = _currentSession!.toResult(
      sketchComposition: sketchComposition,
      routePolyline: routePolyline,
      routeImageUrl: routeImageUrl,
    );

    _currentSession = null;

    return result;
  }

  @override
  Future<void> discardSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_currentSession?.id == sessionId) {
      _currentSession = null;
    }
  }
}