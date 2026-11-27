import '../../../domain/models/session/location_point.dart';
import '../../../utils/result.dart';

/// 기기의 GPS 위치 권한, 단발성 좌표 조회 및 실시간 위치 스트림을 추상화한 저장소 인터페이스입니다.
abstract interface class LocationRepository {
  /// 위치 서비스 활성화 여부를 확인합니다.
  Future<bool> isLocationServiceEnabled();

  /// 위치 권한을 확인하고 미허용 시 권한을 요청합니다.
  Future<bool> checkAndRequestPermission();

  /// 현재 좌표를 조회하여 [LocationPoint]로 반환합니다. (홈 탭 날씨 조회 등)
  Future<Result<LocationPoint>> getCurrentLocation();

  /// 기기에 캐시된 최근 위치를 즉시 조회합니다. (세션 경로 시작점)
  Future<LocationPoint?> getLastKnownLocation();

  /// 실시간 위치 좌표 스트림을 제공합니다. (세션 경로 추적)
  Stream<LocationPoint> getPositionStream({
    int distanceFilterMeters = 0,
    String? notificationTitle,
    String? notificationText,
  });

  /// 기기 앱 설정 화면을 엽니다.
  Future<bool> openAppSettings();

  /// 기기 위치 설정 화면을 엽니다.
  Future<bool> openLocationSettings();
}
