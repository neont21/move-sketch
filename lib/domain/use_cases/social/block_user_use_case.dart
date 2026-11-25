import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/friendship/friendship_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../models/social/user.dart';

/// 특정 사용자를 차단 목록에 등록하고 관련 친구 관계를 정리하는 유즈케이스 클래스입니다.
final class BlockUserUseCase {
  /// 차단 등록 및 친구 관계 해제를 담당하는 저장소.
  final FriendshipRepository friendshipRepository;

  /// 현재 로그인된 사용자 식별자 확인을 위한 인증 저장소.
  final AuthRepository authRepository;

  BlockUserUseCase({
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

  /// 대상 사용자([targetUser])를 차단 처리합니다.
  Future<Result<void>> execute(UserSummary targetUser) async {
    final authCheckResult = _getCurrentUserId();
    switch (authCheckResult) {
      case Ok(:final value):
        return await friendshipRepository.blockUser(
          currentUserId: value,
          targetUser: targetUser,
        );
      case Error(:final error):
        return Result.error(error);
    }
  }
}
