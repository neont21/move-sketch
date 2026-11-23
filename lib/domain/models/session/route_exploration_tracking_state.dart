import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../utils/geohash_helper.dart';
import 'location_point.dart';

/// 세션 동안 과거에 방문하지 않은 신규 도로 및 경로 탐색 거리를 Geohash 격자 기반으로 추적하는 불변 모델입니다.
@immutable
final class RouteExplorationTrackingState {
  /// 단일 Geohash 타일 내에서 신규 탐색 거리로 인정받을 수 있는 최대 한도 거리. (미터)
  static const double maxSingleTileExplorationMeters = 50.0;

  // GPS 노이즈 및 비정상 구간을 걸러내기 위한 내부 임계값.
  static const double _minReplaySegmentDistanceMeters = 1.0;
  static const double _minReplayMovingSpeedMps = 0.2;
  static const double _maxReplayValidSpeedMps = 35.0; // 약 126km/h 초과 GPS 튐 무시.
  static const int _maxReplayGapMilliseconds = 60000; // 60초 초과 백그라운드 공백 무시.

  /// 세션 시작 이전에 이미 방문했던 Geohash 타일 코드 집합.
  final Set<String> pastVisitedGeohashes;

  /// 현재 세션 동안 새롭게 방문하여 등록된 Geohash 타일 코드 집합.
  final Set<String> sessionExploredGeohashes;

  /// 현재 신규 거리를 탐색 중인 활성 Geohash 타일 코드.
  final String? activeExploringGeohash;

  /// 현재 활성 타일 내에서 누적된 신규 탐색 거리. (미터)
  final double activeTileAccumulatedMeters;

  /// 현재 세션에서 새롭게 탐색한 총 유효 거리. (미터)
  final double exploredDistanceMeters;

  const RouteExplorationTrackingState({
    this.pastVisitedGeohashes = const {},
    this.sessionExploredGeohashes = const {},
    this.activeExploringGeohash,
    this.activeTileAccumulatedMeters = 0.0,
    this.exploredDistanceMeters = 0.0,
  });

  /// 킬로미터(km) 단위로 환산된 총 탐색 거리.
  double get exploredDistanceKm => exploredDistanceMeters / 1000.0;

  /// 기록된 세션 위치 좌표 목록([points])을 기반으로 신규 경로 탐색 상태를 결정론적으로 재생산(Replay)하여 복원합니다.
  factory RouteExplorationTrackingState.fromSessionPoints({
    required Set<String> pastVisitedGeohashes,
    required List<LocationPoint> points,
  }) {
    final normalizedPastSet = Set<String>.unmodifiable(pastVisitedGeohashes);
    var currentState = RouteExplorationTrackingState(
      pastVisitedGeohashes: normalizedPastSet,
    );

    if (points.length < 2) {
      return currentState;
    }

    for (int index = 1; index < points.length; index++) {
      final previousPoint = points[index - 1];
      final currentPoint = points[index];

      final timeDiffMillis = currentPoint.timestamp
          .difference(previousPoint.timestamp)
          .inMilliseconds;
      if (timeDiffMillis <= 500 || timeDiffMillis > _maxReplayGapMilliseconds) {
        continue;
      }

      final segmentDistance = Geolocator.distanceBetween(
        previousPoint.latitude,
        previousPoint.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );

      final timeDiffSeconds = timeDiffMillis / 1000.0;
      final speedMps = segmentDistance / timeDiffSeconds;

      if (speedMps > _maxReplayValidSpeedMps) {
        continue;
      }

      final isStationaryBySensor =
          currentPoint.speed != null &&
          currentPoint.speed! < _minReplayMovingSpeedMps;

      if (!isStationaryBySensor &&
          segmentDistance >= _minReplaySegmentDistanceMeters &&
          speedMps >= _minReplayMovingSpeedMps) {
        currentState = currentState.evaluate(
          latitude: currentPoint.latitude,
          longitude: currentPoint.longitude,
          deltaDistanceMeters: segmentDistance,
        );
      }
    }

    return currentState;
  }

  /// 새로운 위치 좌표와 이동 거리를 전달받아 신규 경로 탐색 상태를 갱신합니다.
  RouteExplorationTrackingState evaluate({
    required double latitude,
    required double longitude,
    required double deltaDistanceMeters,
  }) {
    if (deltaDistanceMeters <= 0) {
      return this;
    }

    final currentGeohash = GeohashHelper.encode(latitude, longitude);

    if (pastVisitedGeohashes.contains(currentGeohash)) {
      if (activeExploringGeohash == null &&
          activeTileAccumulatedMeters == 0.0) {
        return this;
      }
      return RouteExplorationTrackingState(
        pastVisitedGeohashes: pastVisitedGeohashes,
        sessionExploredGeohashes: sessionExploredGeohashes,
        activeExploringGeohash: null,
        activeTileAccumulatedMeters: 0.0,
        exploredDistanceMeters: exploredDistanceMeters,
      );
    }

    if (currentGeohash == activeExploringGeohash) {
      final remainingQuota =
          maxSingleTileExplorationMeters - activeTileAccumulatedMeters;
      if (remainingQuota <= 0) {
        return this;
      }

      final addedMeters = math.min(deltaDistanceMeters, remainingQuota);
      return RouteExplorationTrackingState(
        pastVisitedGeohashes: pastVisitedGeohashes,
        sessionExploredGeohashes: sessionExploredGeohashes,
        activeExploringGeohash: activeExploringGeohash,
        activeTileAccumulatedMeters: activeTileAccumulatedMeters + addedMeters,
        exploredDistanceMeters: exploredDistanceMeters + addedMeters,
      );
    }

    if (sessionExploredGeohashes.contains(currentGeohash)) {
      return RouteExplorationTrackingState(
        pastVisitedGeohashes: pastVisitedGeohashes,
        sessionExploredGeohashes: sessionExploredGeohashes,
        activeExploringGeohash: null,
        activeTileAccumulatedMeters: 0.0,
        exploredDistanceMeters: exploredDistanceMeters,
      );
    }

    final addedMeters = math.min(
      deltaDistanceMeters,
      maxSingleTileExplorationMeters,
    );
    final updatedSessionSet = Set<String>.unmodifiable({
      ...sessionExploredGeohashes,
      currentGeohash,
    });

    return RouteExplorationTrackingState(
      pastVisitedGeohashes: pastVisitedGeohashes,
      sessionExploredGeohashes: updatedSessionSet,
      activeExploringGeohash: currentGeohash,
      activeTileAccumulatedMeters: addedMeters,
      exploredDistanceMeters: exploredDistanceMeters + addedMeters,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteExplorationTrackingState &&
          runtimeType == other.runtimeType &&
          setEquals(pastVisitedGeohashes, other.pastVisitedGeohashes) &&
          setEquals(sessionExploredGeohashes, other.sessionExploredGeohashes) &&
          activeExploringGeohash == other.activeExploringGeohash &&
          activeTileAccumulatedMeters == other.activeTileAccumulatedMeters &&
          exploredDistanceMeters == other.exploredDistanceMeters;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(pastVisitedGeohashes),
    Object.hashAll(sessionExploredGeohashes),
    activeExploringGeohash,
    activeTileAccumulatedMeters,
    exploredDistanceMeters,
  );
}
