import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/models/weather/weather_info.dart';
import '../../../utils/exceptions.dart';

class WeatherService {
  final http.Client _client;
  final String _apiKey;
  final String baseUrl;

  WeatherService({
    http.Client? client,
    String? apiKey,
    this.baseUrl = 'https://api.openweathermap.org/data/2.5',
  }) : _client = client ?? http.Client(),
       _apiKey = apiKey ?? const String.fromEnvironment('OPENWEATHER_API_KEY');

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

    throw ApiException(
      '날씨 정보를 불러오는 데 실패했습니다',
      statusCode: response.statusCode,
    );
  }
}
