import '../../../domain/models/social/friendship.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/result.dart';

abstract interface class FriendshipRepository {
  /// 현재 사용자의 친구 목록을 조회한다. (나 탭 > 친구)
  Future<Result<List<UserSummary>>> getFriends(String currentUserId);

  /// 현재 사용자가 받은 친구 요청 목록을 조회한다. (나 탭 > 친구)
  Future<Result<List<UserSummary>>> getReceivedFriendRequests(
    String currentUserId,
  );

  /// 현재 사용자가 보낸 친구 요청 목록을 최신순으로 조회한다.
  Future<Result<List<UserSummary>>> getSentFriendRequests(String currentUserId);

  /// 특정 상대와의 친구 관계를 조회한다. (사용자 검색 및 사용자 프로필)
  Future<Result<Friendship?>> getFriendship({
    required String currentUserId,
    required String targetUserId,
  });

  /// 함께 아는 친구를 조회한다. (사용자 프로필)
  Future<Result<List<UserSummary>>> getMutualFriends({
    required String currentUserId,
    required String targetUserId,
  });

  /// 추천 친구 목록을 조회한다. (사용자 검색)
  Future<Result<List<UserSummary>>> getRecommendedFriends(
    String currentUserId, {
    int limit = 10,
  });

  /// 친구 요청을 전송하며, 상대가 요청을 보낸 상태라면 자동 수락 처리한다.
  Future<Result<Friendship>> sendFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 받은 친구 요청을 수락한다.
  Future<Result<Friendship>> acceptFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 받은 친구 요청을 거절한다.
  Future<Result<void>> declineFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 보낸 친구 요청을 취소한다.
  Future<Result<void>> cancelFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 친구 관계를 삭제한다.
  Future<Result<void>> removeFriend({
    required String currentUserId,
    required String targetUserId,
  });

  /// 상대를 차단하며 친구였을 경우 친구 관계도 삭제한다.
  Future<Result<void>> blockUser({
    required String currentUserId,
    required UserSummary targetUser,
  });

  /// 사용자 차단을 해제하며 친구 관계는 복구되지 않는다.
  Future<Result<void>> unblockUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// 내가 차단한 사용자 목록을 조회한다. (설정 > 차단한 사용자)
  Future<Result<List<UserSummary>>> getBlockedUsers(String currentUserId);

  /// 내가 차단한 사용자와 나를 차단한 사용자의 UID를 조회한다. (사용자 검색)
  Future<Result<List<String>>> getBlockedUserIds(String currentUserId);
}
