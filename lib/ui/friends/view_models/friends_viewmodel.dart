import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class FriendsState {
  final List<UserSummary> friends;
  final List<UserSummary> receivedRequests;
  final bool isProcessing;

  const FriendsState({
    required this.friends,
    required this.receivedRequests,
    this.isProcessing = false,
  });

  FriendsState copyWith({
    List<UserSummary>? friends,
    List<UserSummary>? receivedRequests,
    bool? isProcessing,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class FriendsViewModel extends AsyncNotifier<FriendsState> {
  @override
  Future<FriendsState> build() async {
    final user = await ref.watch(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final friendshipRepository = ref.watch(friendshipRepositoryProvider);

    final (friendsResult, requestsResult) = await (
      friendshipRepository.getFriends(user.uid),
      friendshipRepository.getReceivedFriendRequests(user.uid),
    ).wait;

    final List<UserSummary> friends = switch (friendsResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    final List<UserSummary> requests = switch (requestsResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    return FriendsState(friends: friends, receivedRequests: requests);
  }

  Future<Result<void>> acceptFriendRequest(String requesterId) async {
    final current = state.value;
    if (current == null || current.isProcessing) {
      return const Result.ok(null);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final friendshipRepository = ref.read(friendshipRepositoryProvider);
    final result = await friendshipRepository.acceptFriendRequest(
      currentUserId: user.uid,
      targetUserId: requesterId,
    );

    switch (result) {
      case Ok():
        final acceptedUser = current.receivedRequests.firstWhere(
          (user) => user.uid == requesterId,
          orElse: () => UserSummary(uid: requesterId, username: '', nickname: ''),
        );
        final updatedRequests = current.receivedRequests
            .where((user) => user.uid != requesterId)
            .toList();
        final updatedFriends = [
          ...current.friends,
          if (acceptedUser.username.isNotEmpty) acceptedUser,
        ]..sort((a, b) => a.nickname.compareTo(b.nickname));

        state = AsyncData(
          current.copyWith(
            friends: updatedFriends,
            receivedRequests: updatedRequests,
            isProcessing: false,
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> declineFriendRequest(String requesterId) async {
    final current = state.value;
    if (current == null || current.isProcessing) {
      return const Result.ok(null);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final friendshipRepository = ref.read(friendshipRepositoryProvider);
    final result = await friendshipRepository.declineFriendRequest(
      currentUserId: user.uid,
      targetUserId: requesterId,
    );

    switch (result) {
      case Ok():
        final updatedRequests = current.receivedRequests
            .where((user) => user.uid != requesterId)
            .toList();

        state = AsyncData(
          current.copyWith(
            receivedRequests: updatedRequests,
            isProcessing: false,
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> removeFriend(String friendId) async {
    final current = state.value;
    if (current == null || current.isProcessing) {
      return const Result.ok(null);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final friendshipRepository = ref.read(friendshipRepositoryProvider);
    final result = await friendshipRepository.removeFriend(
      currentUserId: user.uid,
      targetUserId: friendId,
    );

    switch (result) {
      case Ok():
        final updatedFriends = current.friends
            .where((user) => user.uid != friendId)
            .toList();

        state = AsyncData(
          current.copyWith(friends: updatedFriends, isProcessing: false),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }
}

final friendsViewModelProvider =
    AsyncNotifierProvider.autoDispose<FriendsViewModel, FriendsState>(() {
      return FriendsViewModel();
    });
