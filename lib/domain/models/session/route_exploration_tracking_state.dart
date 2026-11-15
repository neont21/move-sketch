import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../utils/geohash_helper.dart';
import 'location_point.dart';

@immutable
final class RouteExplorationTrackingState {
  static const double maxSingleTileExplorationMeters = 50.0;
  static const double _minReplaySegmentDistanceMeters = 1.0;
  static const double _minReplayMovingSpeedMps = 0.2;
  static const double _maxReplayValidSpeedMps = 35.0;
  static const int _maxReplayGapMilliseconds = 60000;

  final Set<String> pastVisitedGeohashes;
  final Set<String> sessionExploredGeohashes;
  final String? activeExploringGeohash;
  final double activeTileAccumulatedMeters;
  final double exploredDistanceMeters;

  const RouteExplorationTrackingState({
    this.pastVisitedGeohashes = const {},
    this.sessionExploredGeohashes = const {},
    this.activeExploringGeohash,
    this.activeTileAccumulatedMeters = 0.0,
    this.exploredDistanceMeters = 0.0,
  });

  double get exploredDistanceKm => exploredDistanceMeters / 1000.0;

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
}
