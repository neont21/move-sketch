import '../../../domain/models/weather/weather_info.dart';
import '../../../utils/result.dart';

abstract interface class WeatherRepository {
  Future<Result<WeatherInfo>> getCurrentWeather({
    required double latitude,
    required double longitude,
  });
}