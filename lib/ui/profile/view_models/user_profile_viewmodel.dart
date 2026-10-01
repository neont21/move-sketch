import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/friendship_status.dart';
import '../../../domain/models/social/friendship.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class UserProfileState {
  final User user;
  final String currentUserId;
  final Friendship? friendship;
  final List<UserSummary> mutualFriends;
  final List<SketchPost> sketches;
  final bool isBlocked;
  final bool isProcessing;

  const UserProfileState({
    required this.user,
    required this.currentUserId,
    this.friendship,
    this.mutualFriends = const [],
    this.sketches = const [],
    this.isBlocked = false,
    this.isProcessing = false,
  });

  bool get isFriend => friendship?.status == FriendshipStatus.accepted;

  bool get isSentRequest =>
      friendship?.status == FriendshipStatus.pending &&
      friendship?.requesterId == currentUserId;

  bool get isReceivedRequest =>
      friendship?.status == FriendshipStatus.pending &&
      friendship?.receiverId == currentUserId;

  UserProfileState copyWith({
    User? user,
    String? currentUserId,
    Friendship? Function()? friendship,
    List<UserSummary>? mutualFriends,
    List<SketchPost>? sketches,
    bool? isBlocked,
    bool? isProcessing,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      currentUserId: currentUserId ?? this.currentUserId,
      friendship: friendship != null ? friendship() : this.friendship,
      mutualFriends: mutualFriends ?? this.mutualFriends,
      sketches: sketches ?? this.sketches,
      isBlocked: isBlocked ?? this.isBlocked,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class UserProfileViewModel extends AsyncNotifier<UserProfileState> {
  final String targetUsername;

  UserProfileViewModel(this.targetUsername);

  @override
  Future<UserProfileState> build() async {
    final user = await ref.watch(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final userRepository = ref.read(userRepositoryProvider);
    final friendshipRepository = ref.read(friendshipRepositoryProvider);
    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);

    final profileResult = await userRepository.getUserByUsername(
      targetUsername,
    );
    final targetUser = switch (profileResult) {
      Ok(:final value) =>
        value ?? (throw const NotFoundException('사용자를 찾을 수 없습니다.')),
      Error(:final error) => throw error,
    };

    if (targetUser.isDeleted) {
      throw const NotFoundException('탈퇴한 사용자입니다.');
    }

    final (friendshipResult, mutualFriendsResult, blockedUsersResult) = await (
      friendshipRepository.getFriendship(
        currentUserId: user.uid,
        targetUserId: targetUser.uid,
      ),
      friendshipRepository.getMutualFriends(
        currentUserId: user.uid,
        targetUserId: targetUser.uid,
      ),
      friendshipRepository.getBlockedUsers(user.uid),
    ).wait;

    final friendship = switch (friendshipResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    final mutualFriends = switch (mutualFriendsResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    final isBlocked = switch (blockedUsersResult) {
      Ok(:final value) => value.any((user) => user.uid == targetUser.uid),
      Error(:final error) => throw error,
    };

    List<SketchPost> sketches = const [];
    if (friendship?.status == FriendshipStatus.accepted) {
      final postsResult = await sketchPostRepository.getUserPosts(
        userId: targetUser.uid,
      );
      sketches = switch (postsResult) {
        Ok(:final value) => value,
        Error(:final error) => throw error,
      };
    }

    return UserProfileState(
      user: targetUser,
      currentUserId: user.uid,
      friendship: friendship,
      mutualFriends: mutualFriends,
      sketches: sketches,
      isBlocked: isBlocked,
    );
  }
}

final userProfileViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<UserProfileViewModel, UserProfileState, String>(
      (username) => UserProfileViewModel(username),
    );
