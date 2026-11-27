import '../../../domain/models/system/app_version_policy.dart';
import '../../../utils/result.dart';

/// 원격 앱 버전 업데이트 정책의 조회 및 갱신을 추상화한 저장소 인터페이스입니다.
abstract interface class AppVersionRepository {
  /// 최신 앱 버전 정책을 조회하여 [AppVersionPolicy]로 반환합니다. (앱 실행 시 버전 검사)
  Future<Result<AppVersionPolicy>> getVersionPolicy();

  /// 관리자 콘솔에서 수정한 최신 버전 정책([policy])을 저장 및 업데이트합니다.
  Future<Result<void>> updateVersionPolicy(AppVersionPolicy policy);
}
