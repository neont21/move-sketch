abstract interface class GeocodingRepository {
  /// 위/경도 좌표를 동/구 단위의 한글 행정구역으로 역지오코딩한다.
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}