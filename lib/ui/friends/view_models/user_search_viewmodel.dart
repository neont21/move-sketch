import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/friendship_status.dart';
import '../../../domain/models/social/recommended_user.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class UserSearchState {
  final List<RecommendedUser> recommendedUsers;
  final List<UserSummary> searchResults;
  final Set<String> friendIds;
  final Set<String> sentRequestIds;
  final Set<String> receivedRequestIds;
  final String searchQuery;
  final bool isSearching;
  final bool isProcessing;

  const UserSearchState({
    required this.recommendedUsers,
    this.searchResults = const [],
    this.friendIds = const {},
    this.sentRequestIds = const {},
    this.receivedRequestIds = const {},
    this.searchQuery = '',
    this.isSearching = false,
    this.isProcessing = false,
  });

  UserSearchState copyWith({
    List<RecommendedUser>? recommendedUsers,
    List<UserSummary>? searchResults,
    Set<String>? friendIds,
    Set<String>? sentRequestIds,
    Set<String>? receivedRequestIds,
    String? searchQuery,
    bool? isSearching,
    bool? isProcessing,
  }) {
    return UserSearchState(
      recommendedUsers: recommendedUsers ?? this.recommendedUsers,
      searchResults: searchResults ?? this.searchResults,
      friendIds: friendIds ?? this.friendIds,
      sentRequestIds: sentRequestIds ?? this.sentRequestIds,
      receivedRequestIds: receivedRequestIds ?? this.receivedRequestIds,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class UserSearchViewModel extends AsyncNotifier<UserSearchState> {
  @override
  Future<UserSearchState> build() async {
    final user = await ref.watch(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final friendshipRepository = ref.read(friendshipRepositoryProvider);

    final (
      recommendedResult,
      friendsResult,
      sentRequestsResult,
      receivedRequestsResult,
    ) = await (
      friendshipRepository.getRecommendedFriends(user.uid),
      friendshipRepository.getFriends(user.uid),
      friendshipRepository.getSentFriendRequests(user.uid),
      friendshipRepository.getReceivedFriendRequests(user.uid),
    ).wait;

    final recommentedUsers = switch (recommendedResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    final friendIds = switch (friendsResult) {
      Ok(:final value) => value.map((user) => user.uid).toSet(),
      Error(:final error) => throw error,
    };

    final sentRequestIds = switch (sentRequestsResult) {
      Ok(:final value) => value.map((user) => user.uid).toSet(),
      Error(:final error) => throw error,
    };

    final receivedRequestIds = switch (receivedRequestsResult) {
      Ok(:final value) => value.map((user) => user.uid).toSet(),
      Error(:final error) => throw error,
    };

    return UserSearchState(
      friendIds: friendIds,
      recommendedUsers: recommentedUsers,
      sentRequestIds: sentRequestIds,
      receivedRequestIds: receivedRequestIds,
    );
  }

  Future<Result<void>> search(String query) async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = AsyncData(
        current.copyWith(
          searchQuery: '',
          searchResults: const [],
          isSearching: false,
        ),
      );
      return const Result.ok(null);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }

    state = AsyncData(
      current.copyWith(searchQuery: trimmed, isSearching: true),
    );

    final userRepository = ref.read(userRepositoryProvider);
    final result = await userRepository.searchUsers(
      currentUserId: user.uid,
      query: trimmed,
    );

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          current.copyWith(
            searchQuery: trimmed,
            searchResults: value,
            isSearching: false,
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isSearching: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> sendFriendRequest(String targetUserId) async {
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
    final result = await friendshipRepository.sendFriendRequest(
      currentUserId: user.uid,
      targetUserId: targetUserId,
    );

    switch (result) {
      case Ok(:final value):
        final updatedSent = Set<String>.from(current.sentRequestIds);
        final updatedFriends = Set<String>.from(current.friendIds);
        final updatedReceived = Set<String>.from(current.receivedRequestIds);

        if (value.status == FriendshipStatus.accepted) {
          updatedFriends.add(targetUserId);
          updatedReceived.remove(targetUserId);
        } else {
          updatedSent.add(targetUserId);
        }

        state = AsyncData(
          current.copyWith(
            sentRequestIds: updatedSent,
            friendIds: updatedFriends,
            receivedRequestIds: updatedReceived,
            isProcessing: false,
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> cancelFriendRequest(String targetUserId) async {
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
    final result = await friendshipRepository.cancelFriendRequest(
      currentUserId: user.uid,
      targetUserId: targetUserId,
    );

    switch (result) {
      case Ok():
        final updatedSent = Set<String>.from(current.sentRequestIds)
          ..remove(targetUserId);

        state = AsyncData(
          current.copyWith(sentRequestIds: updatedSent, isProcessing: false),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> acceptFriendRequest(String targetUserId) async {
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
      targetUserId: targetUserId,
    );

    switch (result) {
      case Ok():
        final updatedReceived = Set<String>.from(current.receivedRequestIds)
          ..remove(targetUserId);
        final updatedFriends = Set<String>.from(current.friendIds)
          ..add(targetUserId);

        state = AsyncData(
          current.copyWith(
            receivedRequestIds: updatedReceived,
            friendIds: updatedFriends,
            isProcessing: false,
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> declineFriendRequest(String targetUserId) async {
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
      targetUserId: targetUserId,
    );

    switch (result) {
      case Ok():
        final updatedReceived = Set<String>.from(current.receivedRequestIds)
          ..remove(targetUserId);

        state = AsyncData(
          current.copyWith(
            receivedRequestIds: updatedReceived,
            isProcessing: false,
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }
}

final userSearchViewModelProvider =
    AsyncNotifierProvider.autoDispose<UserSearchViewModel, UserSearchState>(() {
      return UserSearchViewModel();
    });
