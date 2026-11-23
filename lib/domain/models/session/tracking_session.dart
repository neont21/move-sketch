import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/services/local/database/app_database.dart';
import '../enums/activity_type.dart';
import '../enums/session_status.dart';
import 'location_point.dart';
import 'mission_instance.dart';

/// 현재 실시간으로 기록 중인 활성 운동 세션의 상태와 누적 주행 데이터를 나타내는 불변 모델입니다.
@immutable
class TrackingSession {
  /// 세션 고유 식별자.
  final String id;

  /// 운동을 수행 중인 사용자의 고유 식별자.
  final String userId;

  /// 진행 중인 운동 종목.
  final ActivityType activityType;

  /// 현재 세션의 기록 상태.
  final SessionStatus status;

  /// 운동 세션이 최초 시작된 일시.
  final DateTime startedAt;

  /// 일시정지를 포함한 세션 전체 경과 시간.
  final Duration elapsedDuration;

  /// 일시정지를 제외하고 순수하게 이동한 활동 시간.
  final Duration movingDuration;

  /// 현재까지 누적된 총 이동 거리. (미터 단위)
  final double distanceInMeters;

  /// 현재까지 소모된 추정 칼로리. (kcal)
  final int caloriesBurned;

  /// 조깅 종목의 현재까지 1km당 평균 페이스. (초 단위, 라이딩인 경우 `null`)
  final int? averagePaceInSeconds;

  /// 라이딩 종목의 현재까지 평균 이동 속도. (km/h 단위, 조깅인 경우 `null`)
  final double? averageSpeedKmh;

  /// 세션 시작 후 순차적으로 기록된 전체 위치 좌표 시퀀스.
  final List<LocationPoint> pathPoints;

  /// 실시간으로 진척도를 평가 중인 미션 인스턴스 목록.
  final List<MissionInstance> missions;

  const TrackingSession({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.startedAt,
    this.status = SessionStatus.ready,
    this.elapsedDuration = Duration.zero,
    this.movingDuration = Duration.zero,
    this.distanceInMeters = 0.0,
    this.caloriesBurned = 0,
    this.averagePaceInSeconds,
    this.averageSpeedKmh,
    this.pathPoints = const [],
    this.missions = const [],
  });

  /// 세션이 기록 중인 활성 상태인지 여부.
  bool get isActive => status.isActive;

  /// 세션이 일시정지 상태인지 여부.
  bool get isPaused => status.isPaused;

  /// 세션이 진행 중(기록 또는 일시정지)인지 여부.
  bool get isOngoing => status.isOngoing;

  /// 세션 최초 출발 위치 좌표. (기록된 좌표가 없으면 `null`)
  LocationPoint? get startLocation =>
      pathPoints.isNotEmpty ? pathPoints.first : null;

  /// 세션 가장 최근 위치 좌표. (기록된 좌표가 없으면 `null`)
  LocationPoint? get lastLocation =>
      pathPoints.isNotEmpty ? pathPoints.last : null;

  /// 세션 종료 또는 최근 측정 일시.
  DateTime get endedAt =>
      lastLocation?.timestamp ?? startedAt.add(elapsedDuration);

  /// 유효한 운동 세션으로 인정할 수 있는지 여부. (최소 10m 이상, 좌표 3개 이상)
  bool get isValidSession => distanceInMeters >= 10.0 && pathPoints.length >= 3;

  /// 신규 운동 세션을 활성([SessionStatus.active]) 상태로 시작하여 초기 [TrackingSession]을 생성합니다.
  factory TrackingSession.start({
    required String userId,
    required ActivityType activityType,
    required List<MissionInstance> missions,
    String? customId,
  }) {
    final sessionId = customId ?? const Uuid().v7();
    return TrackingSession(
      id: sessionId,
      userId: userId,
      activityType: activityType,
      missions: missions
          .map(
            (m) =>
                m.sessionId == sessionId ? m : m.copyWith(sessionId: sessionId),
          )
          .toList(),
      startedAt: DateTime.now(),
      status: SessionStatus.active,
    );
  }

  /// 새로운 위치 좌표([point])를 경로에 추가한 새 [TrackingSession] 인스턴스를 반환합니다.
  TrackingSession addPoint(LocationPoint point) {
    return copyWith(pathPoints: [...pathPoints, point]);
  }

  /// Drift 로컬 데이터베이스의 테이블 데이터들을 결합하여 [TrackingSession]을 복원합니다.
  factory TrackingSession.fromEntity({
    required TrackingSessionsTableData sessionRow,
    List<LocationPointsTableData> pointsRows = const [],
    List<MissionInstancesTableData> missionsRows = const [],
  }) {
    return TrackingSession(
      id: sessionRow.id,
      userId: sessionRow.userId,
      activityType: sessionRow.activityType,
      status: sessionRow.status,
      startedAt: sessionRow.startedAt,
      elapsedDuration: Duration(seconds: sessionRow.elapsedDurationSeconds),
      movingDuration: Duration(seconds: sessionRow.movingDurationSeconds),
      distanceInMeters: sessionRow.distanceInMeters,
      caloriesBurned: sessionRow.caloriesBurned,
      averagePaceInSeconds: sessionRow.averagePaceInSeconds,
      averageSpeedKmh: sessionRow.averageSpeedKmh,
      pathPoints: pointsRows.map(LocationPoint.fromEntity).toList(),
      missions: missionsRows.map(MissionInstance.fromEntity).toList(),
    );
  }

  TrackingSession copyWith({
    SessionStatus? status,
    Duration? elapsedDuration,
    Duration? movingDuration,
    double? distanceInMeters,
    int? caloriesBurned,
    ValueGetter<int?>? averagePaceInSeconds,
    ValueGetter<double?>? averageSpeedKmh,
    List<LocationPoint>? pathPoints,
    List<MissionInstance>? missions,
  }) {
    return TrackingSession(
      id: id,
      userId: userId,
      activityType: activityType,
      startedAt: startedAt,
      status: status ?? this.status,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      movingDuration: movingDuration ?? this.movingDuration,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      averagePaceInSeconds: averagePaceInSeconds != null
          ? averagePaceInSeconds()
          : this.averagePaceInSeconds,
      averageSpeedKmh: averageSpeedKmh != null
          ? averageSpeedKmh()
          : this.averageSpeedKmh,
      pathPoints: pathPoints ?? this.pathPoints,
      missions: missions ?? this.missions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          activityType == other.activityType &&
          status == other.status &&
          startedAt == other.startedAt &&
          elapsedDuration == other.elapsedDuration &&
          movingDuration == other.movingDuration &&
          distanceInMeters == other.distanceInMeters &&
          caloriesBurned == other.caloriesBurned &&
          averagePaceInSeconds == other.averagePaceInSeconds &&
          averageSpeedKmh == other.averageSpeedKmh &&
          listEquals(pathPoints, other.pathPoints) &&
          listEquals(missions, other.missions);

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    activityType,
    status,
    startedAt,
    elapsedDuration,
    movingDuration,
    distanceInMeters,
    caloriesBurned,
    averagePaceInSeconds,
    averageSpeedKmh,
    Object.hashAll(pathPoints),
    Object.hashAll(missions),
  ]);
}
