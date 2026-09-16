import 'package:flutter/foundation.dart';
import '../../utils/date_time_utils.dart';
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
  final String? routeImageUrl;
  final String? resultSketchImagePath;
  final String? locationTag;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

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
    this.averagePaceInSeconds,
    this.averageSpeedKmh,
    this.routePolyline,
    this.routeImageUrl,
    this.resultSketchImagePath,
    this.locationTag,
    this.syncStatus = SyncStatus.synced,
    this.updatedAt,
  });

  double get distanceInKm => distanceInMeters / 1000.0;

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
      'routeImageUrl': routeImageUrl,
      'resultSketchImagePath': resultSketchImagePath,
      'locationTag': locationTag,
      'syncStatus': syncStatus.name,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
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
      waypoint: LocationPoint.fromMap(
        map['waypoint'] as Map<String, dynamic>,
      ),
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
      routeImageUrl: map['routeImageUrl'] as String?,
      resultSketchImagePath: map['resultSketchImagePath'] as String?,
      locationTag: map['locationTag'] as String?,
      syncStatus: SyncStatus.fromString(map['syncStatus'] as String?),
      createdAt: parseDateTime(map['createdAt']).toLocal(),
      updatedAt: tryParseDateTime(map['updatedAt'])?.toLocal(),
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
