import '../../../domain/models/weather/weather_info.dart';
import '../../../utils/result.dart';

/// 현재 위치 기반 기상 정보 조회를 추상화한 저장소 인터페이스입니다.
abstract interface class WeatherRepository {
  /// 위도([latitude]) 및 경도([longitude]) 지역의 현재 기상 정보를 조회하여 [WeatherInfo]로 반환합니다.
  Future<Result<WeatherInfo>> getCurrentWeather({
    required double latitude,
    required double longitude,
  });
}
