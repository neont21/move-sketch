import '../../../domain/models/enums/activity_type.dart';
import '../../../domain/models/fixed/sketch_composition.dart';
import '../../../domain/models/session/location_point.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../utils/result.dart';

/// 실시간 운동 세션의 생명주기(시작, 좌표 기록, 일시정지, 완료, 폐기)를 추상화한 저장소 인터페이스입니다.
abstract interface class SessionRepository {
  /// 현재 진행 중이거나 일시정지된 활성 세션이 있는지 조회합니다. (앱 실행 시 세션 복구)
  Future<Result<TrackingSession?>> getActiveSession();

  /// 지정된 세션([sessionId])의 실시간 추적 데이터를 조회합니다. (세션 결과 화면)
  Future<Result<TrackingSession?>> getSession(String sessionId);

  /// 신규 운동 세션을 시작하고 초기 미션 목록([missions])을 함께 저장합니다. (세션 시작 시 1회 호출)
  Future<Result<TrackingSession>> startSession({
    required String userId,
    required ActivityType activityType,
    required List<MissionInstance> missions,
  });

  /// 세션([sessionId])에 새로운 GPS 좌표([point])와 누적 주행 통계를 기록합니다. (실시간 반복 호출)
  Future<Result<void>> recordPoint({
    required String sessionId,
    required LocationPoint point,
    required Duration elapsedDuration,
    required Duration movingDuration,
    required double totalDistanceInMeters,
    required int caloriesBurned,
    int? averagePaceInSeconds,
    double? averageSpeedKmh,
  });

  /// 개별 미션([mission])의 실시간 진행 상태를 갱신합니다. (실시간 반복 호출)
  Future<Result<void>> updateMission(MissionInstance mission);

  /// 세션([sessionId])의 상태를 자동([isAuto] == `true`) 또는 수동 일시정지로 변경합니다.
  Future<Result<void>> pauseSession(String sessionId, {bool isAuto = false});

  /// 일시정지된 세션([sessionId])을 다시 활성 진행 중 상태로 재개합니다.
  Future<Result<void>> resumeSession(String sessionId);

  /// 활성 세션([sessionId])을 완료 처리하고 최종 [SessionResult] 모델로 변환하여 반환합니다. (세션 종료 시 1회 호출)
  Future<Result<SessionResult>> completeSession({
    required String sessionId,
    required SketchComposition sketchComposition,
    String? routePolyline,
    String? resultSketchImageUrl,
  });

  /// 세션 완료 후 원격 업로드가 끝났거나 사용자가 취소한 세션([sessionId])의 원시 데이터를 폐기합니다.
  Future<Result<void>> discardSession(String sessionId);
}
