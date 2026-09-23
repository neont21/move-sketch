import 'dart:async';

import '../../../domain/models/session/location_point.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/hardware/location_service.dart';
import 'location_repository.dart';

final class LocationRepositoryLocal implements LocationRepository {
  final LocationService locationService;

  LocationRepositoryLocal({required this.locationService});

  @override
  Future<bool> isLocationServiceEnabled() {
    return locationService.isLocationServiceEnabled();
  }

  @override
  Future<bool> checkAndRequestPermission() {
    return locationService.checkAndRequestPermission();
  }

  @override
  Future<Result<LocationPoint>> getCurrentLocation() async {
    try {
      final isEnabled = await locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        return const Result.error(
          LocationException('기기의 위치 서비스(GPS)가 꺼져 있습니다.'),
        );
      }

      final hasPermission = await locationService.checkAndRequestPermission();
      if (!hasPermission) {
        return const Result.error(LocationException('위치 권한이 허용되지 않았습니다.'));
      }

      final loc = await locationService.getCurrentLocation();
      if (loc == null) {
        return const Result.error(LocationException('현재 위치 정보를 가져올 수 없습니다.'));
      }

      return Result.ok(loc);
    } on TimeoutException catch (e) {
      return Result.error(LocationException('위치 수신 시간이 초과되었습니다.', cause: e));
    } on AppException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(
        LocationException('현재 위치 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Stream<LocationPoint> getPositionStream({int distanceFilterMeters = 0}) {
    return locationService.getPositionStream(
      distanceFilterMeters: distanceFilterMeters,
    );
  }

  @override
  Future<bool> openAppSettings() {
    return locationService.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() {
    return locationService.openLocationSettings();
  }
}
