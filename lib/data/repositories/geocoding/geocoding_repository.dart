import '../../../domain/models/session/location_point.dart';

/// GPS 좌표를 행정구역명으로 역지오코딩하는 기능을 추상화한 저장소 인터페이스입니다.
abstract interface class GeocodingRepository {
  /// 위도([latitude]) 및 경도([longitude]) 좌표를 동/구 단위의 한글 행정구역명으로 역지오코딩합니다.
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  });

  /// 세션의 출발지([start]), 경유지([waypoint]), 도착지([end]) 좌표를 `[출발, 경유, 도착]` 순서의 지명 태그로 변환합니다.
  ///
  /// 역지오코딩 실패 시 해당 항목을 `'알 수 없는 위치'`로 채웁니다.
  Future<List<String>> resolveSessionLocationTags({
    required LocationPoint start,
    required LocationPoint waypoint,
    required LocationPoint end,
  });
}
