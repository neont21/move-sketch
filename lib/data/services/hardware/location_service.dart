import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/models/session/location_point.dart';

/// 기기의 GPS 위치 권한 확인, 단발성 좌표 조회 및 실시간 백그라운드 위치 스트림을 제공하는 서비스 클래스입니다.
class LocationService {
  // Geolocator의 Position 객체를 도메인 모델인 LocationPoint로 변환합니다.
  LocationPoint _toLocationPoint(Position position) {
    return LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      accuracy: position.accuracy,
    );
  }

  /// 기기의 전역 위치 서비스가 활성화되어 있는지 확인합니다.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 위치 권한 상태와 기기 위치 서비스 활성화 여부를 점검하고, 미허용 시 권한 요청을 수행합니다.
  Future<bool> checkAndRequestPermission() async {
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

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    return true;
  }

  /// 고정밀도 설정으로 현재 기기의 단일 GPS 위치 좌표를 조회합니다. (5초 타임아웃)
  Future<LocationPoint?> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      ),
    );
    return _toLocationPoint(position);
  }

  /// 기기에 캐싱된 최근 위치 좌표를 조회하되, [maxAge]를 초과한 오래된 좌표는 무시합니다.
  Future<LocationPoint?> getLastKnownLocation({
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) {
      return null;
    }
    if (DateTime.now().difference(position.timestamp) > maxAge) {
      return null;
    }
    return _toLocationPoint(position);
  }

  /// 플랫폼별 백그라운드 추적 설정을 적용하여 실시간 [LocationPoint] 스트림을 제공합니다.
  ///
  /// 수평 정확도 오차가 25m를 초과하는 저품질 GPS 신호는 스트림 단계에서 필터링됩니다.
  Stream<LocationPoint> getPositionStream({
    int distanceFilterMeters = 0,
    String? notificationTitle,
    String? notificationText,
  }) {
    late final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final ForegroundNotificationConfig? foregroundNotificationConfig =
          (notificationTitle != null && notificationText != null)
          ? ForegroundNotificationConfig(
              notificationTitle: notificationTitle,
              notificationText: notificationText,
              enableWakeLock: true,
              setOngoing: true,
            )
          : null;

      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: foregroundNotificationConfig,
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
    ).where((position) => position.accuracy <= 25.0).map(_toLocationPoint);
  }

  /// 사용자가 영구 거부한 권한을 직접 변경할 수 있도록 OS 앱 설정 화면을 엽니다.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// 기기의 위치 서비스 활성화 설정 화면을 엽니다.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
