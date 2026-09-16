import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/session/location_point.dart';

class LocationService {
  LocationPoint _toLocationPoint(Position pos) {
    return LocationPoint(
      latitude: pos.latitude,
      longitude: pos.longitude,
      timestamp: pos.timestamp,
      altitude: pos.altitude,
      speed: pos.speed,
      heading: pos.heading,
      accuracy: pos.accuracy,
    );
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<LocationPoint?> getCurrentLocation() async {
    try {
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return _toLocationPoint(pos);
    } on TimeoutException catch (e) {
      debugPrint('[LocationService] 현재 위치 조회 시간 만료: $e');
      throw Exception('[LocationService] 현재 위치 조회 시간 만료: $e');
    } on LocationServiceDisabledException catch (e) {
      debugPrint('[LocationService] 기기 위치 정보 사용 불가: $e');
      throw Exception('[LocationService] 기기 위치 정보 사용 불가: $e');
    } catch (e) {
      debugPrint('[LocationService] 현재 위치 조회 실패: $e');
      throw Exception('[LocationService] 현재 위치 조회 실패: $e');
    }
  }

  Stream<LocationPoint> getPositionStream({int distanceFilterMeters = 0}) {
    late final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'MoveSketch 세션 기록 중',
          notificationText: '운동 경로를 실시간으로 측정하고 있습니다.',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      );
    }
    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).where((pos) => pos.accuracy <= 25.0).map(_toLocationPoint);
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
