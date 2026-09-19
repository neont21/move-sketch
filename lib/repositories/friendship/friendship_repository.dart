import '../../models/social/friendship.dart';
import '../../models/enums/block.dart';
import '../../models/social/user.dart';

abstract interface class FriendshipRepository {
  /// 현재 사용자의 친구 목록을 조회한다. (나 탭 > 친구)
  Future<List<User>> getFriends(String currentUserId);

  /// 현재 사용자가 받은 친구 요청 목록을 조회한다. (나 탭 > 친구)
  Future<List<Friendship>> getReceivedFriendRequests(String currentUserId);

  /// 특정 상대와의 친구 관계를 조회한다. (사용자 검색 및 사용자 프로필)
  Future<Friendship?> getFriendship({
    required String currentUserId,
    required String targetUserId,
  });

  /// 함께 아는 친구를 조회한다. (사용자 프로필)
  Future<List<User>> getMutualFriends({
    required String currentUserId,
    required String targetUserId,
  });

  /// 추천 친구 목록을 조회한다. (사용자 검색)
  Future<List<User>> getRecommendedFriends(String currentUserId, {int limit = 10});

  /// 친구 요청을 전송하며, 상대가 요청을 보낸 상태라면 자동 수락 처리한다.
  Future<Friendship> sendFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 받은 친구 요청을 수락한다.
  Future<Friendship> acceptFriendRequest(String friendshipId);

  /// 받은 친구 요청을 거절한다.
  Future<void> declineFriendRequest(String friendshipId);

  /// 보낸 친구 요청을 취소한다.
  Future<void> cancelFriendRequest(String friendshipId);

  /// 친구 관계를 삭제한다.
  Future<void> removeFriend(String friendshipId);

  /// 상대를 차단하며 친구였을 경우 친구 관계도 삭제한다.
  Future<void> blockUser({
    required String currentUserId,
    required UserSummary targetUser,
  });

  /// 사용자 차단을 해제하며 친구 관계는 복구되지 않는다.
  Future<void> unblockUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// 내가 차단한 사용자 목록을 조회한다. (설정 > 차단한 사용자)
  Future<List<Block>> getBlockedUsers(String currentUserId);

  /// 내가 차단한 사용자와 나를 차단한 사용자의 UID를 조회한다. (사용자 검색)
  Future<List<String>> getBlockedUserIds(String currentUserId);
}
