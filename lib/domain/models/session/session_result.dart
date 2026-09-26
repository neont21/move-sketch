import 'package:flutter/foundation.dart';
import '../../../utils/date_time_utils.dart';
import '../enums/activity_type.dart';
import '../enums/sync_status.dart';
import '../fixed/sketch_parts.dart';
import 'location_point.dart';
import 'mission_instance.dart';

@immutable
class SessionResult {
  final String id;
  final String userId;
  final ActivityType activityType;

  final DateTime startedAt;
  final DateTime endedAt;
  final Duration elapsedDuration;
  final double distanceInMeters;
  final int caloriesBurned;
  final int? averagePaceInSeconds;
  final double? averageSpeedKmh;

  final LocationPoint startLocation;
  final LocationPoint waypoint;
  final LocationPoint endLocation;

  final SketchComposition sketchComposition;
  final List<MissionInstance> missions;

  final String? routePolyline;
  final String? resultSketchImageUrl;

  final String? secretMemo;
  final bool isShared;
  final List<String> locationTags;

  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const SessionResult({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.startedAt,
    required this.endedAt,
    required this.elapsedDuration,
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
  });

  double get distanceInKm => distanceInMeters / 1000.0;
  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'activityType': activityType.name,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'endedAt': endedAt.toUtc().toIso8601String(),
      'elapsedSeconds': elapsedDuration.inSeconds,
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
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'deletedAt': deletedAt?.toUtc().toIso8601String(),
    };
  }

  factory SessionResult.fromMap(Map<String, dynamic> map, {String? id}) {
    return SessionResult(
      id: (map['id'] as String?) ?? id ?? '',
      userId: map['userId'] as String,
      activityType: ActivityType.fromString(map['activityType'] as String?),
      startedAt: parseDateTime(map['startedAt']).toLocal(),
      endedAt: parseDateTime(map['endedAt']).toLocal(),
      elapsedDuration: Duration(
        seconds: (map['elapsedSeconds'] as num?)?.toInt() ?? 0,
      ),
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
      missions:
          (map['missions'] as List<dynamic>?)
              ?.map((e) => MissionInstance.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
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
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
