import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/friendship/friendship_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../models/social/friendship.dart';

class SendFriendRequestUseCase {
  final FriendshipRepository friendshipRepository;
  final AuthRepository authRepository;

  SendFriendRequestUseCase({
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

  Future<Result<Friendship>> execute(String targetUserId) async {
    final authCheckResult = _getCurrentUserId();
    switch (authCheckResult) {
      case Ok(:final value):
        return await friendshipRepository.sendFriendRequest(
          currentUserId: value,
          targetUserId: targetUserId,
        );
      case Error(:final error):
        return Result.error(error);
    }
  }
}
