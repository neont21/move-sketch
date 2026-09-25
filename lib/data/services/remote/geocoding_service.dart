import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final http.Client _client;
  final String baseUrl;

  GeocodingService({
    http.Client? client,
    this.baseUrl = 'https://nominatim.openstreetmap.org',
  }) : _client = client ?? http.Client();

  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
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
    } catch (_) {
      // TODO: Firebase Crashlytics: Geocoding Error
    }

    return '알 수 없는 위치';
  }
}
