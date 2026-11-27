import 'package:firebase_core/firebase_core.dart';

import '../../../domain/models/system/app_version_policy.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firestore/app_version_service.dart';

import 'app_version_repository.dart';
import 'firebase_exception_mapper.dart';

/// [AppVersionService]를 통해 Firestore에서 앱 버전 정책을 조회·갱신하는 [AppVersionRepository] 구현체입니다.
final class AppVersionRepositoryRemote implements AppVersionRepository {
  /// Firestore 버전 정책 원격 서비스.
  final AppVersionService appVersionService;

  AppVersionRepositoryRemote({required this.appVersionService});

  @override
  Future<Result<AppVersionPolicy>> getVersionPolicy() async {
    try {
      final policy = await appVersionService.getVersionPolicy();
      if (policy == null) {
        return const Result.error(NotFoundException('버전 정책을 찾을 수 없습니다.'));
      }

      return Result.ok(policy);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '버전 정보를 불러오는 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('버전 정보를 불러오는 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> updateVersionPolicy(AppVersionPolicy policy) async {
    try {
      await appVersionService.updateVersionPolicy(policy);

      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '버전 정책 저장 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('버전 정책 저장 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
