import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/comment.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class FeedPostState {
  final SketchPost sketch;
  final List<Comment> comments;
  final Set<String> blockedUserIds;
  final bool isTogglingCheer;
  final bool isSubmittingComment;

  const FeedPostState({
    required this.sketch,
    this.comments = const [],
    this.blockedUserIds = const {},
    this.isTogglingCheer = false,
    this.isSubmittingComment = false,
  });

  FeedPostState copyWith({
    SketchPost? sketch,
    List<Comment>? comments,
    Set<String>? blockedUserIds,
    bool? isTogglingCheer,
    bool? isSubmittingComment,
  }) {
    return FeedPostState(
      sketch: sketch ?? this.sketch,
      comments: comments ?? this.comments,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
      isTogglingCheer: isTogglingCheer ?? this.isTogglingCheer,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
    );
  }
}

class FeedPostViewModel extends AsyncNotifier<FeedPostState> {
  final String sketchId;

  FeedPostViewModel(this.sketchId);

  List<Comment> _organizeComments(
    List<Comment> rawComments,
    Set<String> blockedUserIds,
  ) {
    bool isActive(Comment comment) =>
        !comment.isDeleted && !blockedUserIds.contains(comment.authorUid);
    final roots = rawComments.where((comment) => !comment.isReply).toList();
    final replies = rawComments.where((comment) => comment.isReply).toList();

    final activeReplies = replies.where(isActive).toList();
    final parentIdsWithActiveReplies = activeReplies
        .map((reply) => reply.parentCommentId!)
        .toSet();

    final visibleRoots = roots.where((root) {
      if (isActive(root)) {
        return true;
      }
      return parentIdsWithActiveReplies.contains(root.id);
    }).toList();

    final List<Comment> organized = [];
    for (final root in visibleRoots) {
      organized.add(root);
      organized.addAll(
        activeReplies.where((reply) => reply.parentCommentId == root.id),
      );
    }
    return organized;
  }

  @override
  Future<FeedPostState> build() async {
    final user = await ref.watch(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final friendshipRepository = ref.read(friendshipRepositoryProvider);

    final (postResult, commentResult, blockedIdsResult) = await (
      sketchPostRepository.getPostById(sketchId),
      sketchPostRepository.getComments(sketchId),
      friendshipRepository.getBlockedUserIds(user.uid),
    ).wait;

    final SketchPost sketch = switch (postResult) {
      Ok(:final value) =>
        value ?? (throw const NotFoundException('스케치를 찾을 수 없습니다.')),
      Error(:final error) => throw error,
    };

    final List<Comment> rawComments = switch (commentResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    final Set<String> blockedUserIds = switch (blockedIdsResult) {
      Ok(:final value) => value.toSet(),
      Error() => const <String>{},
    };

    final List<Comment> organizedComments = _organizeComments(
      rawComments,
      blockedUserIds,
    );

    return FeedPostState(
      sketch: sketch,
      comments: organizedComments,
      blockedUserIds: blockedUserIds,
    );
  }

  Future<Result<void>> toggleCheer() async {
    final current = state.value;
    if (current == null || current.isTogglingCheer) {
      return const Result.ok(null);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return const Result.ok(null);
    }

    final isCheered = current.sketch.isCheeredBy(user.uid);
    state = AsyncData(
      current.copyWith(
        sketch: current.sketch.toggleCheer(user.uid),
        isTogglingCheer: true,
      ),
    );

    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final result = await sketchPostRepository.toggleCheer(
      sketchId: sketchId,
      userId: user.uid,
      isCheered: !isCheered,
    );

    switch (result) {
      case Ok():
        state = AsyncData(state.value!.copyWith(isTogglingCheer: false));
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isTogglingCheer: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> addComment({
    required String text,
    String? parentCommentId,
  }) async {
    final current = state.value;
    if (current == null || current.isSubmittingComment) {
      return const Result.ok(null);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return const Result.ok(null);
    }

    final comment = Comment.create(
      sketchId: sketchId,
      author: user.toSummary(),
      text: text.trim(),
      parentCommentId: parentCommentId,
    );

    state = AsyncData(current.copyWith(isSubmittingComment: true));

    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final result = await sketchPostRepository.addComment(
      sketchId: sketchId,
      comment: comment,
    );

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          current.copyWith(
            comments: [...current.comments, value],
            sketch: current.sketch.copyWith(
              commentCount: current.sketch.commentCount + 1,
            ),
            isSubmittingComment: false,
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isSubmittingComment: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> deleteComment(String commentId) async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final result = await sketchPostRepository.deleteComment(
      sketchId: sketchId,
      commentId: commentId,
    );

    switch (result) {
      case Ok():
        final updatedRawComments = current.comments.map((comment) {
          if (comment.id == commentId) {
            return comment.copyWith(deletedAt: () => DateTime.now());
          }
          return comment;
        }).toList();
        final updatedComments = _organizeComments(
          updatedRawComments,
          current.blockedUserIds,
        );

        state = AsyncData(
          current.copyWith(
            comments: updatedComments,
            sketch: current.sketch.copyWith(
              commentCount: current.sketch.commentCount - 1,
            ),
          ),
        );
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> deletePost() async {
    final deleteSketchPostUseCase = ref.read(deleteSketchPostUseCaseProvider);
    return deleteSketchPostUseCase.execute(sketchId);
  }
}

final feedPostViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<FeedPostViewModel, FeedPostState, String>(
      (sketchId) => FeedPostViewModel(sketchId),
    );
