import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/friendship/friendship_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

class DeclineFriendRequestUseCase {
  final FriendshipRepository friendshipRepository;
  final AuthRepository authRepository;

  DeclineFriendRequestUseCase({
    required this.friendshipRepository,
    required this.authRepository,
  });

  Result<String> _getCurrentUserId() {
    final currentUserId = authRepository.currentUid;
    if (currentUserId == null || currentUserId.isEmpty) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }
    return Result.ok(currentUserId);
  }

  Future<Result<void>> execute(String targetUserId) async {
    final authCheckResult = _getCurrentUserId();
    switch (authCheckResult) {
      case Ok(:final value):
        return await friendshipRepository.declineFriendRequest(
          currentUserId: value,
          targetUserId: targetUserId,
        );
      case Error(:final error):
        return Result.error(error);
    }
  }
}
