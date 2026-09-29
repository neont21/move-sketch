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
  final bool isTogglingCheer;
  final bool isSubmittingComment;

  const FeedPostState({
    required this.sketch,
    this.comments = const [],
    this.isTogglingCheer = false,
    this.isSubmittingComment = false,
  });

  FeedPostState copyWith({
    SketchPost? sketch,
    List<Comment>? comments,
    bool? isTogglingCheer,
    bool? isSubmittingComment,
  }) {
    return FeedPostState(
      sketch: sketch ?? this.sketch,
      comments: comments ?? this.comments,
      isTogglingCheer: isTogglingCheer ?? this.isTogglingCheer,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
    );
  }
}

class FeedPostViewModel extends AsyncNotifier<FeedPostState> {
  final String sketchId;

  FeedPostViewModel(this.sketchId);

  @override
  Future<FeedPostState> build() async {
    final user = await ref.watch(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final sketchPostRepository = ref.read(sketchPostRepositoryProvider);
    final (postResult, commentResult) = await (
      sketchPostRepository.getPostById(sketchId),
      sketchPostRepository.getComments(sketchId),
    ).wait;

    final SketchPost sketch;
    switch (postResult) {
      case Ok(:final value):
        if (value == null) {
          throw const NotFoundException('스케치를 찾을 수 없습니다.');
        }
        sketch = value;
      case Error(:final error):
        throw error;
    }

    final List<Comment> comments;
    switch (commentResult) {
      case Ok(:final value):
        final roots = value.where((c) => !c.isReply).toList();
        final replies = value.where((c) => c.isReply).toList();
        final sorted = <Comment>[];
        for (final root in roots) {
          sorted.add(root);
          sorted.addAll(replies.where((r) => r.parentCommentId == root.id));
        }
        comments = sorted;
      case Error():
        comments = const <Comment>[];
    }

    return FeedPostState(sketch: sketch, comments: comments);
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
        final hasReplies = current.comments.any(
          (comment) =>
              comment.parentCommentId == commentId && !comment.isDeleted,
        );
        final updatedComments = hasReplies
            ? current.comments.map((comment) {
                if (comment.id == commentId) {
                  return comment.copyWith(deletedAt: () => DateTime.now());
                }
                return comment;
              }).toList()
            : current.comments
                  .where((comment) => comment.id != commentId)
                  .toList();

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
