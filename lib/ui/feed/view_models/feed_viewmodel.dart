import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class FeedState {
  final List<SketchPost> sketches;
  final bool isRefreshing;
  final bool isFetchingMore;
  final bool hasReachedMax;

  const FeedState({
    this.sketches = const [],
    this.isRefreshing = false,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
  });

  FeedState copyWith({
    List<SketchPost>? sketches,
    bool? isRefreshing,
    bool? isFetchingMore,
    bool? hasReachedMax,
  }) {
    return FeedState(
      sketches: sketches ?? this.sketches,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class FeedViewModel extends AsyncNotifier<FeedState> {
  static const int _pageSize = 20;

  @override
  Future<FeedState> build() async {
    final user = await ref.watch(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final result = await sketchPostRepository.getFeedPosts(
      currentUserId: user.uid,
      limit: _pageSize,
    );

    switch (result) {
      case Ok(:final value):
        return FeedState(sketches: value, hasReachedMax: value.length < _pageSize);
      case Error(:final error):
        throw error;
    }
  }

  Future<Result<void>> fetchMore() async {
    final current = state.value;

    if (current == null ||
        current.isFetchingMore ||
        current.hasReachedMax ||
        current.sketches.isEmpty) {
      return const Result.ok(null);
    }

    state = AsyncData(current.copyWith(isFetchingMore: true));
    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      state = AsyncData(current.copyWith(isFetchingMore: false));
      return const Result.ok(null);
    }

    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final lastCreatedAt = current.sketches.last.createdAt;

    final result = await sketchPostRepository.getFeedPosts(
      currentUserId: user.uid,
      limit: _pageSize,
      lastCreatedAt: lastCreatedAt,
    );

    if (!ref.mounted) {
      return const Result.ok(null);
    }

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          current.copyWith(
            sketches: [...current.sketches, ...value],
            isFetchingMore: false,
            hasReachedMax: value.isEmpty || value.length < _pageSize,
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isFetchingMore: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> refreshFeed() async {
    final current = state.value;
    if (current == null || current.isRefreshing) {
      return const Result.ok(null);
    }

    state = AsyncData(current.copyWith(isRefreshing: true));

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      state = AsyncData(current.copyWith(isRefreshing: false));
      return const Result.ok(null);
    }

    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final result = await sketchPostRepository
        .getFeedPosts(currentUserId: user.uid, limit: _pageSize);

    if (!ref.mounted) {
      return const Result.ok(null);
    }

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          FeedState(sketches: value, hasReachedMax: value.length < _pageSize),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isRefreshing: false));
        return Result.error(error);
    }
  }
}

final feedViewModelProvider = AsyncNotifierProvider<FeedViewModel, FeedState>(
  () {
    return FeedViewModel();
  },
);
