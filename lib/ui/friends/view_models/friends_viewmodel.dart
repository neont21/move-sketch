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
}

final friendsViewModelProvider =
    AsyncNotifierProvider.autoDispose<FriendsViewModel, FriendsState>(() {
      return FriendsViewModel();
    });
