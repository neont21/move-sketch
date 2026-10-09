import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/activity_type.dart';
import '../../../domain/models/enums/mission_axis.dart';
import '../../../domain/models/enums/session_status.dart';
import '../../../domain/models/fixed/mission_template.dart';
import '../../../domain/models/session/location_point.dart';
import '../../../domain/models/session/mission_instance.dart';
import '../../../domain/models/session/tracking_session.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

@immutable
class SessionTrackingState {
  final TrackingSession session;
  final Duration elapsedDuration;
  final Duration movingDuration;
  final double distanceInMeters;
  final double elevationGainMeters;
  final int caloriesBurned;
  final int? currentPaceInSeconds;
  final int? averagePaceInSeconds;
  final double? currentSpeedKmh;
  final double? averageSpeedKmh;
  final List<LocationPoint> pathPoints;
  final List<MissionInstance> missions;
  final bool isPaused;
  final LocationPoint? initialLocation;

  const SessionTrackingState({
    required this.session,
    this.elapsedDuration = Duration.zero,
    this.movingDuration = Duration.zero,
    this.distanceInMeters = 0.0,
    this.elevationGainMeters = 0.0,
    this.caloriesBurned = 0,
    this.currentPaceInSeconds,
    this.averagePaceInSeconds,
    this.currentSpeedKmh,
    this.averageSpeedKmh,
    this.pathPoints = const [],
    this.missions = const [],
    this.isPaused = false,
    this.initialLocation,
  });

  double get distanceInKm => distanceInMeters / 1000.0;
  bool get isValidSession => distanceInMeters >= 10.0 && pathPoints.length >= 3;

  static Duration calculateMovingDurationFromPoints(
    List<LocationPoint> points,
  ) {
    if (points.length < 2) {
      return Duration.zero;
    }

    int totalMovingSeconds = 0;
    for (var i = 1; i < points.length; i++) {
      final previousPoint = points[i - 1];
      final currentPoint = points[i];

      final timeDiffSec = currentPoint.timestamp
          .difference(previousPoint.timestamp)
          .inSeconds;

      if (timeDiffSec <= 0 || timeDiffSec > 60) {
        continue;
      }

      final segmentDistance = Geolocator.distanceBetween(
        previousPoint.latitude,
        previousPoint.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );

      final speedMps = segmentDistance / timeDiffSec;
      if (segmentDistance >= 1.5 && speedMps >= 0.5) {
        totalMovingSeconds += timeDiffSec;
      }
    }

    return Duration(seconds: totalMovingSeconds);
  }

  static double calculateElevationGainFromPoints(List<LocationPoint> points) {
    if (points.length < 2) {
      return 0.0;
    }

    double totalGain = 0.0;

    for (var i = 1; i < points.length; i++) {
      final previousPoint = points[i - 1];
      final currentPoint = points[i];

      if (previousPoint.altitude == null || currentPoint.altitude == null) {
        continue;
      }

      final deltaAltitude = currentPoint.altitude! - previousPoint.altitude!;

      if (deltaAltitude >= 1.0) {
        final segmentDistance = Geolocator.distanceBetween(
          previousPoint.latitude,
          previousPoint.longitude,
          currentPoint.latitude,
          currentPoint.longitude,
        );

        if (segmentDistance > 0 && (deltaAltitude / segmentDistance) <= 0.35) {
          totalGain += deltaAltitude;
        }
      }
    }

    return totalGain;
  }

  factory SessionTrackingState.fromSession(
    TrackingSession session, {
    LocationPoint? initialLocation,
  }) {
    final restoredMovingDuration = calculateMovingDurationFromPoints(
      session.pathPoints,
    );
    final restoredElevationGain = calculateElevationGainFromPoints(
      session.pathPoints,
    );

    return SessionTrackingState(
      session: session,
      elapsedDuration: session.elapsedDuration,
      movingDuration: restoredMovingDuration,
      distanceInMeters: session.distanceInMeters,
      elevationGainMeters: restoredElevationGain,
      caloriesBurned: session.caloriesBurned,
      averagePaceInSeconds: session.averagePaceInSeconds,
      averageSpeedKmh: session.averageSpeedKmh,
      pathPoints: session.pathPoints,
      missions: session.missions,
      isPaused: session.isPaused,
      initialLocation: initialLocation,
    );
  }

  SessionTrackingState copyWith({
    TrackingSession? session,
    Duration? elapsedDuration,
    Duration? movingDuration,
    double? distanceInMeters,
    double? elevationGainMeters,
    int? caloriesBurned,
    ValueGetter<int?>? currentPaceInSeconds,
    ValueGetter<int?>? averagePaceInSeconds,
    ValueGetter<double?>? currentSpeedKmh,
    ValueGetter<double?>? averageSpeedKmh,
    List<LocationPoint>? pathPoints,
    List<MissionInstance>? missions,
    bool? isPaused,
    LocationPoint? initialLocation,
  }) {
    return SessionTrackingState(
      session: session ?? this.session,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      movingDuration: movingDuration ?? this.movingDuration,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      currentPaceInSeconds: currentPaceInSeconds != null
          ? currentPaceInSeconds()
          : this.currentPaceInSeconds,
      averagePaceInSeconds: averagePaceInSeconds != null
          ? averagePaceInSeconds()
          : this.averagePaceInSeconds,
      currentSpeedKmh: currentSpeedKmh != null
          ? currentSpeedKmh()
          : this.currentSpeedKmh,
      averageSpeedKmh: averageSpeedKmh != null
          ? averageSpeedKmh()
          : this.averageSpeedKmh,
      pathPoints: pathPoints ?? this.pathPoints,
      missions: missions ?? this.missions,
      isPaused: isPaused ?? this.isPaused,
      initialLocation: initialLocation ?? this.initialLocation,
    );
  }
}

class SessionTrackingViewModel extends AsyncNotifier<SessionTrackingState> {
  Timer? _timer;
  StreamSubscription<LocationPoint>? _locationSubscription;

  List<MissionInstance> _evaluateMissions({
    required List<MissionInstance> missions,
    required ActivityType activityType,
    required double distanceInKm,
    required Duration elapsedDuration,
    required int? averagePaceInSeconds,
    required double? averageSpeedKmh,
  }) {
    final templates = MissionTemplate.getTemplatesFor(activityType);
    return missions.map((mission) {
      final template = templates
          .where((template) => template.id == mission.missionTemplateId)
          .firstOrNull;

      if (template == null ||
          (mission.axis == MissionAxis.pace && averagePaceInSeconds == null)) {
        return mission;
      }

      final double evalValue = switch (mission.axis) {
        MissionAxis.distance => distanceInKm,
        MissionAxis.duration => elapsedDuration.inMinutes.toDouble(),
        MissionAxis.pace => averagePaceInSeconds!.toDouble(),
        MissionAxis.speed => averageSpeedKmh ?? 0.0,
        MissionAxis.routeExploration => mission.currentValue,
        MissionAxis.interval => mission.currentValue,
        MissionAxis.sprint => mission.currentValue,
        MissionAxis.unknown => 0.0,
      };

      return mission.evaluateWith(evalValue, template);
    }).toList();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.value;

      if (current == null || current.isPaused) {
        return;
      }

      final newElapsedDuration =
          current.elapsedDuration + const Duration(seconds: 1);

      final lastPoint = current.pathPoints.lastOrNull;
      final isCurrentlyMoving =
          lastPoint != null &&
          (lastPoint.speed != null && lastPoint.speed! >= 0.5);
      final newMovingDuration = isCurrentlyMoving
          ? current.movingDuration + const Duration(seconds: 1)
          : current.movingDuration;

      final newCalories = switch (current.session.activityType) {
        ActivityType.jogging =>
          ((current.distanceInKm * 60) + (current.elevationGainMeters * 0.10))
              .round(),
        ActivityType.riding =>
          ((current.distanceInKm * 30) + (current.elevationGainMeters * 0.05))
              .round(),
      };

      final updatedMissions = _evaluateMissions(
        missions: current.missions,
        activityType: current.session.activityType,
        distanceInKm: current.distanceInKm,
        elapsedDuration: newMovingDuration,
        averagePaceInSeconds: current.averagePaceInSeconds,
        averageSpeedKmh: current.averageSpeedKmh,
      );

      state = AsyncData(
        current.copyWith(
          elapsedDuration: newElapsedDuration,
          movingDuration: newMovingDuration,
          caloriesBurned: newCalories,
          missions: updatedMissions,
        ),
      );
    });
  }

  void _onNewLocationPoint(LocationPoint point) {
    final current = state.value;
    if (current == null || current.isPaused) {
      return;
    }

    if (point.accuracy != null && point.accuracy! > 35) {
      return;
    }

    final lastPoint = current.pathPoints.lastOrNull;
    double deltaDistance = 0.0;
    double deltaElevationGain = 0.0;
    int elapsedSecondsDelta = 0;
    int movingSecondsDelta = 0;

    if (lastPoint != null) {
      deltaDistance = Geolocator.distanceBetween(
        lastPoint.latitude,
        lastPoint.longitude,
        point.latitude,
        point.longitude,
      );

      if (deltaDistance < 1.5) {
        return;
      }

      final timeDiffSec = point.timestamp
          .difference(lastPoint.timestamp)
          .inSeconds;

      if (timeDiffSec > 0 && (deltaDistance / timeDiffSec) > 35.0) {
        return;
      }

      if (timeDiffSec > 0) {
        elapsedSecondsDelta = timeDiffSec;
        final speedMps = deltaDistance / timeDiffSec;

        if (deltaDistance >= 1.5 && speedMps >= 0.5) {
          movingSecondsDelta = timeDiffSec;

          if (lastPoint.altitude != null && point.altitude != null) {
            final altitudeDifference = point.altitude! - lastPoint.altitude!;

            if (altitudeDifference >= 1.0 &&
                (altitudeDifference / deltaDistance) <= 0.35) {
              deltaElevationGain = altitudeDifference;
            }
          }
        } else {
          deltaDistance = 0.0;
        }
      }
    }

    final newDistance = current.distanceInMeters + deltaDistance;
    final newDistanceInKm = newDistance / 1000.0;
    final newElevationGain = current.elevationGainMeters + deltaElevationGain;
    final newElapsedDuration =
        current.elapsedDuration + Duration(seconds: elapsedSecondsDelta);
    final newMovingDuration =
        current.movingDuration + Duration(seconds: movingSecondsDelta);
    final activeSeconds = newMovingDuration.inSeconds;

    final newCalories = switch (current.session.activityType) {
      ActivityType.jogging =>
          ((newDistanceInKm * 60) + (newElevationGain * 0.10)).round(),
      ActivityType.riding =>
          ((newDistanceInKm * 30) + (newElevationGain * 0.05)).round(),
    };

    int? avgPace;
    int? curPace;
    double? avgSpeed;
    double? curSpeed;

    switch (current.session.activityType) {
      case ActivityType.jogging:
        if (newDistance > 30 && activeSeconds > 0) {
          avgPace = (activeSeconds / newDistanceInKm).round();
        }
        if (point.speed != null && point.speed! > 0.5) {
          curPace = (1000.0 / point.speed!).round();
        } else {
          curPace = avgPace;
        }
      case ActivityType.riding:
        if (activeSeconds > 0) {
          avgSpeed = newDistanceInKm / (activeSeconds / 3600.0);
        }
        if (point.speed != null && point.speed! >= 0) {
          curSpeed = point.speed! * 3.6;
        } else {
          curSpeed = avgSpeed;
        }
    }

    final updatedPoints = [...current.pathPoints, point];

    final updatedMissions = _evaluateMissions(
      missions: current.missions,
      activityType: current.session.activityType,
      distanceInKm: newDistanceInKm,
      elapsedDuration: newMovingDuration,
      averagePaceInSeconds: avgPace,
      averageSpeedKmh: avgSpeed,
    );
    state = AsyncData(
      current.copyWith(
        elapsedDuration: newElapsedDuration,
        movingDuration: newMovingDuration,
        distanceInMeters: newDistance,
        elevationGainMeters: newElevationGain,
        caloriesBurned: newCalories,
        pathPoints: updatedPoints,
        currentPaceInSeconds: () => curPace,
        averagePaceInSeconds: () => avgPace,
        currentSpeedKmh: () => curSpeed,
        averageSpeedKmh: () => avgSpeed,
        missions: updatedMissions,
      ),
    );

    final sessionRepository = ref.read(sessionRepositoryProvider);
    sessionRepository.recordPoint(
      sessionId: current.session.id,
      point: point,
      elapsedDuration: newElapsedDuration,
      totalDistanceInMeters: newDistance,
      caloriesBurned: newCalories,
      averagePaceInSeconds: avgPace,
      averageSpeedKmh: avgSpeed,
    );

    for (final mission in updatedMissions) {
      sessionRepository.updateMission(mission);
    }
  }

  void _startLocationTracking() {
    _locationSubscription?.cancel();
    final locationRepository = ref.read(locationRepositoryProvider);

    _locationSubscription = locationRepository
        .getPositionStream(distanceFilterMeters: 2)
        .listen(
          (point) {
            _onNewLocationPoint(point);
          },
          onError: (error, trace) {
            FirebaseCrashlytics.instance.recordError(
              error,
              trace,
              reason: '운동 세션 GPS 위치 스트림 오류',
              fatal: false,
            );
          },
        );
  }

  @override
  Future<SessionTrackingState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
      _locationSubscription?.cancel();
    });

    final sessionRepository = ref.read(sessionRepositoryProvider);
    final result = await sessionRepository.getActiveSession();

    final TrackingSession? session;
    switch (result) {
      case Ok(:final value):
        session = value;
      case Error(:final error):
        throw error;
    }

    if (session == null) {
      throw const SessionException('세션이 시작되지 않았습니다.');
    }

    _startTimer();
    _startLocationTracking();

    FirebaseCrashlytics.instance.log(
      '운동 세션 트래킹 시작: sessionId=${session.id}, activityType=${session.activityType.name}',
    );
    final initialLoc = await ref
        .read(locationRepositoryProvider)
        .getLastKnownLocation();

    return SessionTrackingState.fromSession(
      session,
      initialLocation: initialLoc,
    );
  }

  Future<void> pauseSession() async {
    final current = state.value;
    if (current == null || current.isPaused) {
      return;
    }

    FirebaseCrashlytics.instance.log(
      '운동 세션 일시정지 (sessionId=${current.session.id})',
    );
    final sessionRepository = ref.read(sessionRepositoryProvider);
    await sessionRepository.pauseSession(current.session.id);

    state = AsyncData(
      current.copyWith(
        isPaused: true,
        session: current.session.copyWith(status: SessionStatus.pausedManual),
      ),
    );
  }

  Future<void> resumeSession() async {
    final current = state.value;
    if (current == null || !current.isPaused) {
      return;
    }

    FirebaseCrashlytics.instance.log(
      '운동 세션 재개 (sessionId=${current.session.id})',
    );
    final sessionRepository = ref.read(sessionRepositoryProvider);
    await sessionRepository.resumeSession(current.session.id);

    state = AsyncData(
      current.copyWith(
        isPaused: false,
        session: current.session.copyWith(status: SessionStatus.active),
      ),
    );
  }

  Future<void> discardSession() async {
    final current = state.value;
    if (current == null) {
      return;
    }

    _timer?.cancel();
    _locationSubscription?.cancel();

    FirebaseCrashlytics.instance.log(
      '운동 세션 폐기 (sessionId=${current.session.id})',
    );
    final sessionRepository = ref.read(sessionRepositoryProvider);
    await sessionRepository.discardSession(current.session.id);
  }
}

final sessionTrackingViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      SessionTrackingViewModel,
      SessionTrackingState
    >(() {
      return SessionTrackingViewModel();
    });
