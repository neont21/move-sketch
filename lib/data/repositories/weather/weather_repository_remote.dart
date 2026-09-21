import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../domain/models/weather/weather_info.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/weather_service.dart';
import 'weather_repository.dart';

final class WeatherRepositoryRemote implements WeatherRepository {
  final WeatherService weatherService;

  WeatherRepositoryRemote({required this.weatherService});

  @override
  Future<Result<WeatherInfo>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    if (latitude < -90.0 || latitude > 90.0) {
      return Result.error(
        const ValidationException('위도는 -90도에서 90도 사이여야 합니다.'),
      );
    }
    if (longitude < -180.0 || longitude > 180.0) {
      return Result.error(
        const ValidationException('경도는 -180도에서 180도 사이여야 합니다.'),
      );
    }

    try {
      final weatherInfo = await weatherService.fetchCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );
      return Result.ok(weatherInfo);
    } on SocketException catch (e) {
      return Result.error(
        NetworkException('인터넷 연결이 불안정합니다. 네트워크 상태를 확인해 주세요.', cause: e),
      );
    } on http.ClientException catch (e) {
      return Result.error(
        NetworkException('날씨 데이터를 가져오는 중 통신 오류가 발생했습니다.', cause: e),
      );
    } on TimeoutException catch (e) {
      return Result.error(NetworkException('날씨 서버 응답 시간이 초과되었습니다.', cause: e));
    } on HttpException catch (e) {
      return Result.error(NetworkException(e.message, cause: e));
    } on FormatException catch (e) {
      return Result.error(
        NetworkException('날씨 데이터 형식이 올바르지 않거나 API 키가 설정되지 않았습니다.', cause: e),
      );
    } on ApiException catch (e) {
      final exception = switch (e.statusCode) {
        401 => const NetworkException('유효하지 않은 날씨 API 키입니다.'),
        404 => const NotFoundException('해당 위치의 날씨 정보를 찾을 수 없습니다.'),
        429 => const NetworkException('날씨 API 요청 한도를 초과했습니다. 잠시 후 다시 시도해 주세요.'),
        _ => NetworkException(
          '날씨 정보를 불러오는 데 실패했습니다. (HTTP ${e.statusCode})',
          cause: e,
        ),
      };
      return Result.error(exception);
    } on AppException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(
        NetworkException('날씨 정보 조회 중 예기치 않은 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
