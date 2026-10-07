import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
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

  Future<void> refreshFriendshipStatus() async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return;
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

    final recommendedUsers = switch (recommendedResult) {
      Ok(:final value) => value,
      Error() => current.recommendedUsers,
    };

    final friendIds = switch (friendsResult) {
      Ok(:final value) => value.map((target) => target.uid).toSet(),
      Error() => current.friendIds,
    };

    final sentRequestIds = switch (sentRequestsResult) {
      Ok(:final value) => value.map((target) => target.uid).toSet(),
      Error() => current.sentRequestIds,
    };

    final receivedRequestIds = switch (receivedRequestsResult) {
      Ok(:final value) => value.map((target) => target.uid).toSet(),
      Error() => current.receivedRequestIds,
    };

    state = AsyncData(
      current.copyWith(
        recommendedUsers: recommendedUsers,
        friendIds: friendIds,
        sentRequestIds: sentRequestIds,
        receivedRequestIds: receivedRequestIds,
      ),
    );
  }
}

final userSearchViewModelProvider =
    AsyncNotifierProvider.autoDispose<UserSearchViewModel, UserSearchState>(() {
      return UserSearchViewModel();
    });
