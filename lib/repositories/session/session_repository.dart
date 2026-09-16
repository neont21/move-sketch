import '../../models/enums/activity_type.dart';
import '../../models/fixed/sketch_parts.dart';
import '../../models/session/location_point.dart';
import '../../models/session/mission_instance.dart';
import '../../models/session/session_result.dart';
import '../../models/session/tracking_session.dart';

abstract interface class SessionRepository {
  /// 진행 중인 세션이 있는지 조회한다. (세션 종료 또는 세션 복구 시 1회 호출)
  Future<TrackingSession?> getActiveSession();

  /// 세션 항목을 추가하고 선택한 미션 항목들도 선택한 만큼 추가한다. (세션 시작 시점 1회 호출)
  Future<TrackingSession> startSession({
    required String userId,
    required ActivityType activityType,
    required List<MissionInstance> initialMissions,
  });

  /// 좌표 목록에 좌표를 추가한다. (실시간 반복 호출 필요)
  Future<void> recordPoint({
    required String sessionId,
    required LocationPoint point,
    required Duration elapsedDuration,
    required double totalDistanceInMeters,
    required int caloriesBurned,
    int? averagePaceInSeconds,
    double? averageSpeedKmh,
  });

  /// 미션 진행 상태를 업데이트 한다. (실시간 반복 호출 필요)
  Future<void> updateMission(MissionInstance mission);

  /// 세션 상태를 자동/수동 일시 정지로 업데이트 한다. (일시정지 시 호출)
  Future<void> pauseSession(String sessionId, {bool isAuto = false});

  /// 세션 상태를 진행 중으로 업데이트 한다. (일시정지 해제 시 호출)
  Future<void> resumeSession(String sessionId);

  /// 세션 데이터를 기록을 위한 형태로 변환한다. (세션 종료 시 1회 호출)
  Future<SessionResult> completeSession({
    required String sessionId,
    required SketchComposition sketchComposition,
    String? routePolyline,
    String? mapThumbnailPath,
    String? resultSketchImagePath,
    String? locationTag,
  });

  /// 세션 기록 후 raw data를 폐기한다. (세션 종료 후 서버 업로드 시 1회 호출)
  Future<void> discardSession(String sessionId);
}