import '../../../domain/models/app_version_policy.dart';
import '../../../utils/result.dart';

abstract interface class AppVersionRepository {
  /// 최신 앱 버전 정책을 조회합니다. (앱 실행 시 버전 검사)
  Future<Result<AppVersionPolicy>> getVersionPolicy();
}