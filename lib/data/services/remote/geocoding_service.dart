import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;

/// OpenStreetMap Nominatim API를 호출하여 GPS 좌표를 한국어 행정구역명으로 변환하는 서비스 클래스입니다.
class GeocodingService {
  final http.Client _client;

  /// 역지오코딩 요청을 보낼 API 기본 URL.
  final String baseUrl;

  DateTime _lastRequestTime = DateTime(2000);

  GeocodingService({
    http.Client? client,
    this.baseUrl = 'https://nominatim.openstreetmap.org',
  }) : _client = client ?? http.Client();

  /// 위도([latitude])와 경도([longitude])를 기반으로 한국어 행정구역명을 조회합니다.
  ///
  /// Nominatim API 사용 정책(초당 최대 1회 요청)을 준수하기 위해 직전 요청과 1.1초 미만 간격이면 대기하며,
  /// 네트워크 오류나 응답 파싱 실패 시 Crashlytics에 비치명 오류를 기록하고 `'알 수 없는 위치'`를 반환합니다.
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRequestTime);
    if (elapsed < const Duration(milliseconds: 1100)) {
      await Future.delayed(const Duration(milliseconds: 1100) - elapsed);
    }
    _lastRequestTime = DateTime.now();
    try {
      final uri = Uri.parse('$baseUrl/reverse').replace(
        queryParameters: {
          'format': 'jsonv2',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'zoom': '16',
          'addressdetails': '1',
        },
      );

      final response = await _client
          .get(
            uri,
            headers: {
              'Accept-Language': 'ko',
              'User-Agent': 'MoveSketch/1.0 (contact@movesketch.app)',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final borough = address['borough'] as String?;
          final suburb = address['suburb'] as String?;
          final cityDistrict = address['city_district'] as String?;
          final neighbourhood = address['neighbourhood'] as String?;
          final quarter = address['quarter'] as String?;
          final village = address['village'] as String?;
          final city = address['city'] as String?;
          final county = address['county'] as String?;
          final town = address['town'] as String?;

          final districtPart =
              borough ?? suburb ?? cityDistrict ?? county ?? city ?? town;
          final townPart = neighbourhood ?? quarter ?? village;

          if (districtPart != null && townPart != null) {
            return '$districtPart $townPart';
          } else if (districtPart != null) {
            return districtPart;
          } else if (townPart != null) {
            return townPart;
          }
        }
      }
    } catch (e, trace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        trace,
        reason: 'Nominatim 역지오코딩 통신 오류 (lat: $latitude, lon: $longitude)',
        fatal: false,
      );
    }

    return '알 수 없는 위치';
  }
}
