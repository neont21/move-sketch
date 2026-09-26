import '../../../domain/models/session/location_point.dart';

abstract interface class GeocodingRepository {
  /// 위/경도 좌표를 동/구 단위의 한글 행정구역으로 역지오코딩한다.
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  });

  /// 세션의 출발지/경유지/도착지 좌표를 [출발, 경유, 도착] 순서의 지명 태그로 변환한다.
  /// 역지오코딩 실패 시 해당 항목을 '알 수 없는 위치'로 채운다.
  /// 출발지와 도착지가 동일한 지점(왕복)이면 도착 태그를 출발 태그와 같게 처리한다.
  Future<List<String>> resolveSessionLocationTags({
    required LocationPoint start,
    required LocationPoint waypoint,
    required LocationPoint end,
  });
}