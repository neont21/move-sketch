import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class MyProfileState {
  final User user;
  final int friendCount;
  final List<SketchPost> sketches;
  final bool isProcessing;

  const MyProfileState({
    required this.user,
    this.friendCount = 0,
    this.sketches = const [],
    this.isProcessing = false,
  });

  MyProfileState copyWith({
    User? user,
    int? friendCount,
    List<SketchPost>? sketches,
    bool? isProcessing,
  }) {
    return MyProfileState(
      user: user ?? this.user,
      friendCount: friendCount ?? this.friendCount,
      sketches: sketches ?? this.sketches,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class MyProfileViewModel extends AsyncNotifier<MyProfileState> {
  @override
  Future<MyProfileState> build() async {
    final currentUser = await ref.watch(authViewModelProvider.future);
    if (currentUser == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final friendshipRepository = ref.read(friendshipRepositoryProvider);
    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);

    final (friendsResult, sketchResult) = await (
      friendshipRepository.getFriends(currentUser.uid),
      sketchPostRepository.getUserPosts(userId: currentUser.uid),
    ).wait;

    final int friendCount = switch (friendsResult) {
      Ok(:final value) => value.length,
      Error(:final error) => throw error,
    };

    final List<SketchPost> sketches = switch (sketchResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    return MyProfileState(
      user: currentUser,
      friendCount: friendCount,
      sketches: sketches,
    );
  }
}

final myProfileViewModelProvider =
    AsyncNotifierProvider.autoDispose<MyProfileViewModel, MyProfileState>(() {
      return MyProfileViewModel();
    });
