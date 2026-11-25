import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/friendship/friendship_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

/// 자신이 발송했던 대기 중 친구 요청을 철회(취소)하는 유즈케이스 클래스입니다.
final class CancelFriendRequestUseCase {
  /// 친구 요청 문서를 삭제하는 저장소.
  final FriendshipRepository friendshipRepository;

  /// 현재 로그인된 사용자 식별자 확인을 위한 인증 저장소.
  final AuthRepository authRepository;

  CancelFriendRequestUseCase({
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

  /// 대상 사용자([targetUserId])에게 보낸 친구 요청을 취소합니다.
  Future<Result<void>> execute(String targetUserId) async {
    final authCheckResult = _getCurrentUserId();
    switch (authCheckResult) {
      case Ok(:final value):
        return await friendshipRepository.cancelFriendRequest(
          currentUserId: value,
          targetUserId: targetUserId,
        );
      case Error(:final error):
        return Result.error(error);
    }
  }
}
