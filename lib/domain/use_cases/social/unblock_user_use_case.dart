import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/friendship/friendship_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

/// 차단 목록에 등록된 사용자의 차단을 해제하는 유즈케이스 클래스입니다.
final class UnblockUserUseCase {
  /// 차단 관계 삭제 처리를 담당하는 저장소.
  final FriendshipRepository friendshipRepository;

  /// 현재 로그인된 사용자 식별자 확인을 위한 인증 저장소.
  final AuthRepository authRepository;

  UnblockUserUseCase({
    required this.friendshipRepository,
    required this.authRepository,
  });

  // 현재 인증된 사용자의 UID를 조회하며, 세션이 유효하지 않은 경우 AuthException을 반환합니다.
  Result<String> _getCurrentUserId() {
    final currentUserId = authRepository.currentUid;
    if (currentUserId == null || currentUserId.isEmpty) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }
    return Result.ok(currentUserId);
  }

  /// 대상 사용자([targetUserId])에 대한 차단을 해제합니다.
  Future<Result<void>> execute(String targetUserId) async {
    final authCheckResult = _getCurrentUserId();
    switch (authCheckResult) {
      case Ok(:final value):
        return await friendshipRepository.unblockUser(
          currentUserId: value,
          targetUserId: targetUserId,
        );
      case Error(:final error):
        return Result.error(error);
    }
  }
}
