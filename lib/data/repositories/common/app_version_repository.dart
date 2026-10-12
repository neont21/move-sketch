import '../../../domain/models/app_version_policy.dart';
import '../../../utils/result.dart';

abstract interface class AppVersionRepository {
  /// 최신 앱 버전 정책을 조회합니다. (앱 실행 시 버전 검사)
  Future<Result<AppVersionPolicy>> getVersionPolicy();

  /// [관리] 최신 버전 정책 정보를 저장 및 업데이트합니다.
  Future<Result<void>> updateVersionPolicy(AppVersionPolicy policy);
}