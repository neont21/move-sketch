import 'package:firebase_core/firebase_core.dart';
import '../../../domain/models/social/block_status.dart';
import '../../../domain/models/social/friendship.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firestore/friendship_service.dart';
import '../../services/remote/firestore/user_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'friendship_repository.dart';

final class FriendshipRepositoryRemote implements FriendshipRepository {
  final FriendshipService friendshipService;
  final UserService userService;

  FriendshipRepositoryRemote({
    required this.friendshipService,
    required this.userService,
  });

  @override
  Future<Result<List<UserSummary>>> getFriends(String currentUserId) async {
    try {
      final friendIds = await friendshipService.getFriendUserIds(currentUserId);
      if (friendIds.isEmpty) {
        return const Result.ok([]);
      }

      final friendSummaries = await userService.getUserSummaries(friendIds);
      friendSummaries.sort((a, b) => a.nickname.compareTo(b.nickname));

      return Result.ok(friendSummaries);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '친구 목록 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('친구 목록 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<UserSummary>>> getReceivedFriendRequests(
    String currentUserId,
  ) async {
    try {
      final receivedRequests = await friendshipService.getReceivedRequests(
        currentUserId,
      );
      if (receivedRequests.isEmpty) {
        return const Result.ok([]);
      }

      final requesterIds = receivedRequests
          .map((request) => request.requesterId)
          .toList();
      final requesterSummaries = await userService.getUserSummaries(
        requesterIds,
      );

      final summaryMap = {
        for (final summary in requesterSummaries) summary.uid: summary,
      };
      final orderedSummaries = requesterIds
          .map((id) => summaryMap[id])
          .whereType<UserSummary>()
          .toList();

      return Result.ok(orderedSummaries);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '받은 친구 요청 목록 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('받은 친구 요청 목록 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<UserSummary>>> getSentFriendRequests(
    String currentUserId,
  ) async {
    try {
      final sentRequests = await friendshipService.getSentRequests(
        currentUserId,
      );
      if (sentRequests.isEmpty) {
        return const Result.ok([]);
      }

      final receiverIds = sentRequests
          .map((request) => request.receiverId)
          .toList();
      final receiverSummaries = await userService.getUserSummaries(receiverIds);

      final summaryMap = {
        for (final summary in receiverSummaries) summary.uid: summary,
      };
      final orderedSummaries = receiverIds
          .map((id) => summaryMap[id])
          .whereType<UserSummary>()
          .toList();

      return Result.ok(orderedSummaries);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '보낸 친구 요청 목록 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('보낸 친구 요청 목록 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Friendship?>> getFriendship({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final friendship = await friendshipService.getFriendship(
        myUid: currentUserId,
        otherUid: targetUserId,
      );
      return Result.ok(friendship);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '사용자와의 관계 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('사용자와의 관계 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<UserSummary>>> getMutualFriends({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final friendIds = await Future.wait([
        friendshipService.getFriendUserIds(currentUserId),
        friendshipService.getFriendUserIds(targetUserId),
      ]);

      final myFriends = friendIds[0].toSet();
      final otherFriends = friendIds[1].toSet();

      final mutualIds = myFriends.intersection(otherFriends).toList();
      if (mutualIds.isEmpty) {
        return const Result.ok([]);
      }

      final mutualSummaries = await userService.getUserSummaries(mutualIds);
      mutualSummaries.sort((a, b) => a.nickname.compareTo(b.nickname));

      return Result.ok(mutualSummaries);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '함께 아는 친구 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('함께 아는 친구 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<UserSummary>>> getRecommendedFriends(
    String currentUserId, {
    int limit = 10,
  }) async {
    try {
      final myFriendIds = await friendshipService.getFriendUserIds(
        currentUserId,
      );
      if (myFriendIds.isEmpty) {
        return const Result.ok([]);
      }

      final blockedUserIds = await friendshipService.getBlockedUserIds(
        currentUserId,
      );
      final excludeSet = {currentUserId, ...myFriendIds, ...blockedUserIds};

      final friendLists = await Future.wait(
        myFriendIds.map((id) => friendshipService.getFriendUserIds(id)),
      );

      final candidateFrequency = <String, int>{};
      for (final fofIds in friendLists) {
        for (final fofId in fofIds) {
          if (!excludeSet.contains(fofId)) {
            candidateFrequency[fofId] = (candidateFrequency[fofId] ?? 0) + 1;
          }
        }
      }
      if (candidateFrequency.isEmpty) {
        return const Result.ok([]);
      }

      final sortedCandidateIds = candidateFrequency.keys.toList()
        ..sort(
          (a, b) => candidateFrequency[b]!.compareTo(candidateFrequency[a]!),
        );

      final targetIds = sortedCandidateIds.take(limit).toList();
      final targetSummaries = await userService.getUserSummaries(targetIds);

      final summaryMap = {
        for (final summary in targetSummaries) summary.uid: summary,
      };
      final orderedSummaries = targetIds
          .map((id) => summaryMap[id])
          .whereType<UserSummary>()
          .toList();

      return Result.ok(orderedSummaries);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '추천 친구 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('추천 친구 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Friendship>> sendFriendRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (currentUserId == targetUserId) {
      return const Result.error(
        ValidationException('자기 자신에게는 친구 요청을 보낼 수 없습니다.'),
      );
    }

    try {
      final friendship = await friendshipService.requestFriendship(
        requesterId: currentUserId,
        receiverId: targetUserId,
      );
      return Result.ok(friendship);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '친구 요청 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('친구 요청 처리 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Friendship>> acceptFriendRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final friendshipId = FriendshipService.generateFriendshipId(
        currentUserId,
        targetUserId,
      );
      final friendship = await friendshipService.acceptFriendship(friendshipId);

      return Result.ok(friendship);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '친구 요청 수락 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('친구 요청 수락 처리 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> declineFriendRequest({
    required String currentUserId,
    required String targetUserId,
  }) => _deleteFriendshipRelationship(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
    errorMessage: '친구 요청 거절 처리 중 오류가 발생했습니다.',
  );

  @override
  Future<Result<void>> cancelFriendRequest({
    required String currentUserId,
    required String targetUserId,
  }) => _deleteFriendshipRelationship(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
    errorMessage: '친구 요청 취소 처리 중 오류가 발생했습니다.',
  );

  @override
  Future<Result<void>> removeFriend({
    required String currentUserId,
    required String targetUserId,
  }) => _deleteFriendshipRelationship(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
    errorMessage: '친구 삭제 처리 중 오류가 발생했습니다.',
  );

  Future<Result<void>> _deleteFriendshipRelationship({
    required String currentUserId,
    required String targetUserId,
    required String errorMessage,
  }) async {
    try {
      final friendshipId = FriendshipService.generateFriendshipId(
        currentUserId,
        targetUserId,
      );
      await friendshipService.deleteFriendship(friendshipId);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(e.toAppException(defaultMessage: errorMessage));
    } catch (e) {
      return Result.error(DatabaseException(errorMessage, cause: e));
    }
  }

  @override
  Future<Result<void>> blockUser({
    required String currentUserId,
    required UserSummary targetUser,
  }) async {
    if (currentUserId == targetUser.uid) {
      return const Result.error(ValidationException('자기 자신을 차단할 수 없습니다.'));
    }

    try {
      final block = BlockStatus.create(
        blockerUid: currentUserId,
        blockedUser: targetUser,
      );
      await friendshipService.blockUser(block);

      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '사용자 차단 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('사용자 차단 처리 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> unblockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final blockId = BlockStatus.createId(currentUserId, targetUserId);
      await friendshipService.unblockUser(blockId);

      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '사용자 차단 해제 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('사용자 차단 해제 처리 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<UserSummary>>> getBlockedUsers(
    String currentUserId,
  ) async {
    try {
      final blocks = await friendshipService.getBlockedUsers(currentUserId);
      if (blocks.isEmpty) {
        return const Result.ok([]);
      }
      final blockedSummaries = blocks
          .map((block) => block.blockedUser)
          .toList();

      return Result.ok(blockedSummaries);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '차단한 사용자 목록 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('차단한 사용자 목록 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<String>>> getBlockedUserIds(String currentUserId) async {
    try {
      final blockedIds = await friendshipService.getBlockedUserIds(
        currentUserId,
      );

      return Result.ok(blockedIds);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '차단한 사용자 ID 목록 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('차단한 사용자 ID 목록 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
