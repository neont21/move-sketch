import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../domain/models/weather/weather_info.dart';
import '../../../utils/exceptions.dart';

/// OpenWeatherMap REST API를 호출하여 현재 기상 정보를 조회하는 서비스 클래스입니다.
class WeatherService {
  final http.Client _client;
  final String _apiKey;

  /// OpenWeatherMap API 기본 엔드포인트 URL.
  final String baseUrl;

  WeatherService({
    http.Client? client,
    String? apiKey,
    this.baseUrl = 'https://api.openweathermap.org/data/2.5',
  }) : _client = client ?? http.Client(),
       _apiKey = apiKey ?? const String.fromEnvironment('OPENWEATHER_API_KEY');

  /// 위도([latitude])와 경도([longitude])에 해당하는 지역의 현재 기상 정보를 조회하여 [WeatherInfo]로 반환합니다.
  ///
  /// API 키가 누락된 경우 [NetworkException]을, 비정상 HTTP 응답 시 [ApiException]을 던집니다. (10초 타임아웃)
  Future<WeatherInfo> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    if (_apiKey.isEmpty) {
      throw const NetworkException('OpenWeatherMap API key가 설정되지 않았습니다.');
    }

    final uri = Uri.parse('$baseUrl/weather').replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': _apiKey,
        'units': 'metric',
        'lang': 'kr',
      },
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherInfo.fromOpenWeatherMap(data);
    }

    throw ApiException('날씨 정보를 불러오는 데 실패했습니다', statusCode: response.statusCode);
  }
}
