import '../../services/remote/geocoding_service.dart';
import 'geocoding_repository.dart';

class GeocodingRepositoryRemote implements GeocodingRepository {
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
}
