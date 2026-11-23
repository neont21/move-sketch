import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/date_time_utils.dart';
import '../enums/activity_type.dart';
import '../enums/mission_axis.dart';
import '../enums/sync_status.dart';
import '../fixed/sketch_composition.dart';
import 'location_point.dart';
import 'mission_instance.dart';

/// 종료된 운동 세션의 주행 통계, 위치 좌표, 미션 달성 내역 및 완성된 스케치 결과를 나타내는 불변 모델입니다.
@immutable
class SessionResult {
  /// 세션 결과 고유 식별자.
  final String id;

  /// 운동을 수행한 사용자의 고유 식별자.
  final String userId;

  /// 운동 활동 종목.
  final ActivityType activityType;

  /// 운동 세션 시작 일시.
  final DateTime startedAt;

  /// 운동 세션 종료 일시.
  final DateTime endedAt;

  /// 일시정지를 포함한 세션 전체 경과 시간.
  final Duration elapsedDuration;

  /// 일시정지를 제외하고 순수하게 이동한 활동 시간.
  final Duration movingDuration;

  /// 총 이동 거리. (미터 단위)
  final double distanceInMeters;

  /// 세션 동안 소모된 추정 칼로리. (kcal)
  final int caloriesBurned;

  /// 조깅 세션의 1km당 평균 페이스. (초 단위, 라이딩인 경우 `null`)
  final int? averagePaceInSeconds;

  /// 라이딩 세션의 평균 이동 시속. (km/h 단위, 조깅인 경우 `null`)
  final double? averageSpeedKmh;

  /// 운동 세션 출발 지점 위치 좌표.
  final LocationPoint startLocation;

  /// 세션 경로의 중간 경유 지점 위치 좌표.
  final LocationPoint waypoint;

  /// 운동 세션 도착 지점 위치 좌표.
  final LocationPoint endLocation;

  /// 미션 달성 티어에 따라 조합된 스케치 파츠 레이어 구성 정보.
  final SketchComposition sketchComposition;

  /// 세션에서 수행된 미션 평가 인스턴스 목록.
  final List<MissionInstance> missions;

  /// 전체 이동 경로의 구글 인코딩 폴리라인(Encoded Polyline) 문자열.
  final String? routePolyline;

  /// 원격 스토리지에 업로드된 완성 스케치 이미지 다운로드 URL.
  final String? resultSketchImageUrl;

  /// 사용자 본인만 열람 가능한 비공개 운동 메모.
  final String? secretMemo;

  /// 피드로 공유되었는지 여부.
  final bool isShared;

  /// 세션 경로가 속한 행정구역 또는 지역 위치 태그 목록.
  final List<String> locationTags;

  /// 원격 서버 동기화 상태.
  final SyncStatus syncStatus;

  /// 결과 데이터 최초 생성 일시.
  final DateTime createdAt;

  /// 결과 데이터 최종 수정 일시.
  final DateTime? updatedAt;

  /// 논리 삭제 일시. (정상 데이터인 경우 `null`)
  final DateTime? deletedAt;

  const SessionResult({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.startedAt,
    required this.endedAt,
    required this.elapsedDuration,
    Duration? movingDuration,
    required this.distanceInMeters,
    required this.caloriesBurned,
    required this.startLocation,
    required this.waypoint,
    required this.endLocation,
    required this.sketchComposition,
    required this.missions,
    required this.createdAt,
    required this.isShared,
    this.locationTags = const [],
    this.averagePaceInSeconds,
    this.averageSpeedKmh,
    this.routePolyline,
    this.resultSketchImageUrl,
    this.secretMemo,
    this.syncStatus = SyncStatus.synced,
    this.updatedAt,
    this.deletedAt,
  }) : movingDuration = movingDuration ?? elapsedDuration;

  /// 킬로미터 단위로 환산된 총 이동 거리.
  double get distanceInKm => distanceInMeters / 1000.0;

  /// 논리적으로 삭제 처리된 세션인지 여부.
  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'activityType': activityType.name,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': Timestamp.fromDate(endedAt),
      'elapsedSeconds': elapsedDuration.inSeconds,
      'movingSeconds': movingDuration.inSeconds,
      'distanceInMeters': distanceInMeters,
      'caloriesBurned': caloriesBurned,
      'averagePaceInSeconds': averagePaceInSeconds,
      'averageSpeedKmh': averageSpeedKmh,
      'startLocation': startLocation.toMap(),
      'waypoint': waypoint.toMap(),
      'endLocation': endLocation.toMap(),
      'sketchComposition': sketchComposition.toMap(),
      'missions': missions.map((m) => m.toMap()).toList(),
      'routePolyline': routePolyline,
      'resultSketchImageUrl': resultSketchImageUrl,
      'secretMemo': secretMemo,
      'isShared': isShared,
      'locationTags': locationTags,
      'syncStatus': syncStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory SessionResult.fromMap(Map<String, dynamic> map, {String? id}) {
    final parsedMissions =
        (map['missions'] as List<dynamic>?)
            ?.map(
              (element) =>
                  MissionInstance.fromMap(element as Map<String, dynamic>),
            )
            .toList() ??
        [];

    final int? storedMovingSeconds = (map['movingSeconds'] as num?)?.toInt();
    final int movingSeconds;
    if (storedMovingSeconds != null) {
      movingSeconds = storedMovingSeconds;
    } else {
      final durationMission = parsedMissions
          .where((mission) => mission.axis == MissionAxis.duration)
          .firstOrNull;
      if (durationMission != null && durationMission.currentValue > 0) {
        movingSeconds = (durationMission.currentValue * 60).round();
      } else {
        movingSeconds = (map['elapsedSeconds'] as num?)?.toInt() ?? 0;
      }
    }

    return SessionResult(
      id: (map['id'] as String?) ?? id ?? '',
      userId: map['userId'] as String,
      activityType: ActivityType.fromString(map['activityType'] as String?),
      startedAt: parseDateTime(map['startedAt']).toLocal(),
      endedAt: parseDateTime(map['endedAt']).toLocal(),
      elapsedDuration: Duration(
        seconds: (map['elapsedSeconds'] as num?)?.toInt() ?? 0,
      ),
      movingDuration: Duration(seconds: movingSeconds),
      distanceInMeters: (map['distanceInMeters'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ?? 0,
      averagePaceInSeconds: (map['averagePaceInSeconds'] as num?)?.toInt(),
      averageSpeedKmh: (map['averageSpeedKmh'] as num?)?.toDouble(),
      startLocation: LocationPoint.fromMap(
        map['startLocation'] as Map<String, dynamic>,
      ),
      waypoint: LocationPoint.fromMap(map['waypoint'] as Map<String, dynamic>),
      endLocation: LocationPoint.fromMap(
        map['endLocation'] as Map<String, dynamic>,
      ),
      sketchComposition: SketchComposition.fromMap(
        map['sketchComposition'] as Map<String, dynamic>,
      ),
      missions: parsedMissions,
      routePolyline: map['routePolyline'] as String?,
      resultSketchImageUrl: map['resultSketchImageUrl'] as String?,
      secretMemo: map['secretMemo'] as String?,
      isShared: map['isShared'] as bool? ?? false,
      locationTags:
          (map['locationTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      syncStatus: SyncStatus.fromString(map['syncStatus'] as String?),
      createdAt: parseDateTime(map['createdAt']).toLocal(),
      updatedAt: tryParseDateTime(map['updatedAt'])?.toLocal(),
      deletedAt: tryParseDateTime(map['deletedAt'])?.toLocal(),
    );
  }

  SessionResult copyWith({
    String? id,
    String? userId,
    ActivityType? activityType,
    DateTime? startedAt,
    DateTime? endedAt,
    Duration? elapsedDuration,
    Duration? movingDuration,
    double? distanceInMeters,
    int? caloriesBurned,
    ValueGetter<int?>? averagePaceInSeconds,
    ValueGetter<double?>? averageSpeedKmh,
    LocationPoint? startLocation,
    LocationPoint? waypoint,
    LocationPoint? endLocation,
    SketchComposition? sketchComposition,
    List<MissionInstance>? missions,
    ValueGetter<String?>? routePolyline,
    ValueGetter<String?>? resultSketchImageUrl,
    ValueGetter<String?>? secretMemo,
    bool? isShared,
    List<String>? locationTags,
    ValueGetter<String?>? sharedPostId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    ValueGetter<DateTime?>? updatedAt,
    ValueGetter<DateTime?>? deletedAt,
  }) {
    return SessionResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
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
      startLocation: startLocation ?? this.startLocation,
      waypoint: waypoint ?? this.waypoint,
      endLocation: endLocation ?? this.endLocation,
      sketchComposition: sketchComposition ?? this.sketchComposition,
      missions: missions ?? this.missions,
      routePolyline: routePolyline != null
          ? routePolyline()
          : this.routePolyline,
      resultSketchImageUrl: resultSketchImageUrl != null
          ? resultSketchImageUrl()
          : this.resultSketchImageUrl,
      secretMemo: secretMemo != null ? secretMemo() : this.secretMemo,
      isShared: isShared ?? this.isShared,
      locationTags: locationTags ?? this.locationTags,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          activityType == other.activityType &&
          startedAt == other.startedAt &&
          endedAt == other.endedAt &&
          elapsedDuration == other.elapsedDuration &&
          movingDuration == other.movingDuration &&
          distanceInMeters == other.distanceInMeters &&
          caloriesBurned == other.caloriesBurned &&
          averagePaceInSeconds == other.averagePaceInSeconds &&
          averageSpeedKmh == other.averageSpeedKmh &&
          startLocation == other.startLocation &&
          waypoint == other.waypoint &&
          endLocation == other.endLocation &&
          sketchComposition == other.sketchComposition &&
          listEquals(missions, other.missions) &&
          routePolyline == other.routePolyline &&
          resultSketchImageUrl == other.resultSketchImageUrl &&
          secretMemo == other.secretMemo &&
          isShared == other.isShared &&
          listEquals(locationTags, other.locationTags) &&
          syncStatus == other.syncStatus &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    activityType,
    startedAt,
    endedAt,
    elapsedDuration,
    movingDuration,
    distanceInMeters,
    caloriesBurned,
    averagePaceInSeconds,
    averageSpeedKmh,
    startLocation,
    waypoint,
    endLocation,
    sketchComposition,
    Object.hashAll(missions),
    routePolyline,
    resultSketchImageUrl,
    secretMemo,
    isShared,
    Object.hashAll(locationTags),
    syncStatus,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
}
