import '../../../domain/models/social/friendship.dart';
import '../../../domain/models/social/recommended_user.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/result.dart';

/// 친구 관계, 친구 요청, 함께 아는 친구, 추천 친구, 차단 및 관심 친구 관리를 추상화한 저장소 인터페이스입니다.
abstract interface class FriendshipRepository {
  /// 사용자([currentUserId])의 친구 요약 목록을 조회합니다. (나 탭 > 친구)
  Future<Result<List<UserSummary>>> getFriends(String currentUserId);

  /// 사용자([currentUserId])가 받은 친구 요청자 요약 목록을 조회합니다. (나 탭 > 친구)
  Future<Result<List<UserSummary>>> getReceivedFriendRequests(
    String currentUserId,
  );

  /// 사용자([currentUserId])가 보낸 친구 요청 대상자 요약 목록을 최신순으로 조회합니다.
  Future<Result<List<UserSummary>>> getSentFriendRequests(String currentUserId);

  /// 현재 사용자([currentUserId])와 대상 사용자([targetUserId]) 간의 친구 관계를 조회합니다. (사용자 검색 및 프로필)
  Future<Result<Friendship?>> getFriendship({
    required String currentUserId,
    required String targetUserId,
  });

  /// 현재 사용자([currentUserId])와 대상 사용자([targetUserId])가 함께 아는 친구 목록을 조회합니다. (사용자 프로필)
  Future<Result<List<UserSummary>>> getMutualFriends({
    required String currentUserId,
    required String targetUserId,
  });

  /// 사용자([currentUserId])의 친구 네트워크 기반 추천 친구 목록을 조회합니다. (사용자 검색)
  Future<Result<List<RecommendedUser>>> getRecommendedFriends(
    String currentUserId, {
    int limit = 10,
  });

  /// 대상 사용자([targetUserId])에게 친구 요청을 전송합니다. (상대가 이미 요청을 보낸 상태면 자동 수락)
  Future<Result<Friendship>> sendFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 대상 사용자([targetUserId])로부터 받은 친구 요청을 수락합니다.
  Future<Result<Friendship>> acceptFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 대상 사용자([targetUserId])로부터 받은 친구 요청을 거절합니다.
  Future<Result<void>> declineFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 대상 사용자([targetUserId])에게 보낸 친구 요청을 취소합니다.
  Future<Result<void>> cancelFriendRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// 대상 사용자([targetUserId])와의 친구 관계를 삭제합니다.
  Future<Result<void>> removeFriend({
    required String currentUserId,
    required String targetUserId,
  });

  /// 대상 사용자([targetUser])를 차단합니다. (기존 친구 관계가 있는 경우 함께 삭제)
  Future<Result<void>> blockUser({
    required String currentUserId,
    required UserSummary targetUser,
  });

  /// 대상 사용자([targetUserId])에 대한 차단을 해제합니다. (삭제된 친구 관계는 복구되지 않음)
  Future<Result<void>> unblockUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// 사용자([currentUserId])가 차단한 사용자 목록을 조회합니다. (설정 > 차단한 사용자)
  Future<Result<List<UserSummary>>> getBlockedUsers(String currentUserId);

  /// 나([currentUserId])와 양방향 차단 관계에 있는 모든 사용자 UID 목록을 조회합니다. (사용자 검색)
  Future<Result<List<String>>> getBlockedUserIds(String currentUserId);

  /// 친구([targetUserId])에 대한 관심 친구 알림 설정을 토글하고 변경된 상태를 반환합니다. (사용자 프로필)
  Future<Result<bool>> toggleFavoriteFriend({
    required String currentUserId,
    required String targetUserId,
  });
}
