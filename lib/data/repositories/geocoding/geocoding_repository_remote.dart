import '../../../domain/models/session/location_point.dart';
import '../../services/remote/geocoding_service.dart';
import 'geocoding_repository.dart';

/// [GeocodingService]를 통해 원격 역지오코딩 및 세션 경로 태그 조합을 수행하는 [GeocodingRepository] 구현체입니다.
final class GeocodingRepositoryRemote implements GeocodingRepository {
  final GeocodingService _geocodingService;

  GeocodingRepositoryRemote({GeocodingService? geocodingService})
    : _geocodingService = geocodingService ?? GeocodingService();

  @override
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) {
    return _geocodingService.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<List<String>> resolveSessionLocationTags({
    required LocationPoint start,
    required LocationPoint waypoint,
    required LocationPoint end,
  }) async {
    final startTag = await reverseGeocode(
      latitude: start.latitude,
      longitude: start.longitude,
    );
    final waypointTag = await reverseGeocode(
      latitude: waypoint.latitude,
      longitude: waypoint.longitude,
    );
    final isRoundTrip =
        (start.latitude - end.latitude).abs() < 0.0005 &&
        (start.longitude - end.longitude).abs() < 0.0005;
    final endTag = isRoundTrip
        ? startTag
        : await reverseGeocode(
            latitude: end.latitude,
            longitude: end.longitude,
          );
    return [startTag, waypointTag, endTag];
  }
}
