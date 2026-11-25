/// 위도 및 경도 좌표를 Geohash Base32 격자 문자열로 인코딩하는 유틸리티입니다.
abstract final class GeohashHelper {
  static const String _base32Characters = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// 기본 Geohash 정밀도 자릿수. (8자리 기준 약 38m × 19m 격자 크기)
  static const int defaultPrecision = 8;

  /// 위도([latitude])와 경도([longitude])를 지정된 정밀도([precision])의 Geohash 문자열로 인코딩합니다.
  ///
  /// 좌표가 유효 범위(위도 -90~90, 경도 -180~180)를 벗어나면 [ArgumentError]를 던집니다.
  static String encode(
    double latitude,
    double longitude, {
    int precision = defaultPrecision,
  }) {
    if (latitude < -90.0 || latitude > 90.0) {
      throw ArgumentError.value(
        latitude,
        'latitude',
        '위도는 -90.0에서 90.0 사이여야 합니다.',
      );
    }
    if (longitude < -180.0 || longitude > 180.0) {
      throw ArgumentError.value(
        longitude,
        'longitude',
        '경도는 -180.0에서 180.0 사이여야 합니다.',
      );
    }

    double minLatitude = -90.0;
    double maxLatitude = 90.0;
    double minLongitude = -180.0;
    double maxLongitude = 180.0;

    final buffer = StringBuffer();
    bool isLongitudeBit = true;
    int characterIndex = 0;
    int bitCount = 0;

    while (buffer.length < precision) {
      if (isLongitudeBit) {
        final midLongitude = (minLongitude + maxLongitude) / 2.0;
        if (longitude >= midLongitude) {
          characterIndex = (characterIndex << 1) | 1;
          minLongitude = midLongitude;
        } else {
          characterIndex = (characterIndex << 1) | 0;
          maxLongitude = midLongitude;
        }
      } else {
        final midLatitude = (minLatitude + maxLatitude) / 2.0;
        if (latitude >= midLatitude) {
          characterIndex = (characterIndex << 1) | 1;
          minLatitude = midLatitude;
        } else {
          characterIndex = (characterIndex << 1) | 0;
          maxLatitude = midLatitude;
        }
      }

      isLongitudeBit = !isLongitudeBit;
      bitCount++;

      if (bitCount == 5) {
        buffer.write(_base32Characters[characterIndex]);
        bitCount = 0;
        characterIndex = 0;
      }
    }

    return buffer.toString();
  }
}
