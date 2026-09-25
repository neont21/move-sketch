import '../../../domain/models/session/location_point.dart';
import '../../../utils/result.dart';

abstract interface class LocationRepository {
  /// 위치 서비스 활성화 여부를 확인한다.
  Future<bool> isLocationServiceEnabled();

  /// 위치 권한을 확인하고 요청한다.
  Future<bool> checkAndRequestPermission();

  /// 현재 좌표를 조회한다. (홈 탭 날씨 조회)
  Future<Result<LocationPoint>> getCurrentLocation();

  /// 캐시된 최근 위치를 즉시 조회한다. (세션 경로 시작점)
  Future<LocationPoint?> getLastKnownLocation();

  /// 실시간 좌표 스트림을 구독한다. (세션 경로 추적)
  Stream<LocationPoint> getPositionStream({int distanceFilterMeters = 0});

  /// 기기 앱 설정 화면을 연다.
  Future<bool> openAppSettings();

  /// 기기 위치 설정 화면을 연다.
  Future<bool> openLocationSettings();
}