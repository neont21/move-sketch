import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/comment.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../friends/widgets/user_list_dialog.dart';
import '../../history/view_models/history_viewmodel.dart';
import '../../home/view_models/home_viewmodel.dart';
import '../view_models/feed_post_viewmodel.dart';
import '../view_models/feed_viewmodel.dart';
import 'cheer_button.dart';
import 'feed_post_card.dart';
import 'user_comment_tile.dart';

class FeedPostScreen extends ConsumerStatefulWidget {
  final String sketchId;

  const FeedPostScreen({super.key, required this.sketchId});

  @override
  ConsumerState<FeedPostScreen> createState() => _FeedPostScreenState();
}

class _FeedPostScreenState extends ConsumerState<FeedPostScreen> {
  late final TextEditingController _commentController;
  Comment? _replyTarget;

  @override
  void initState() {
    super.initState();

    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();

    super.dispose();
  }

  Future<void> _showCheeredUser(Set<String> cheeredUserIds) async {
    final List<UserSummary> users;

    if (cheeredUserIds.isEmpty) {
      users = [];
    } else {
      final result = await ref
          .read(sketchPostRepositoryProvider)
          .getCheeredUsers(cheeredUserIds.toList());

      users = switch (result) {
        Ok(:final value) => value,
        Error() => const [],
      };
    }

    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: UserListDialog(title: '응원한 친구', userList: users),
      ),
    );
  }

  Future<void> _toggleCheer() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(feedPostViewModelProvider(widget.sketchId).notifier)
        .toggleCheer();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        ref.read(feedViewModelProvider.notifier).refreshFeed();
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '응원 처리 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(feedPostViewModelProvider(widget.sketchId).notifier)
        .addComment(text: text, parentCommentId: _replyTarget?.id);

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        _commentController.clear();
        setState(() {
          _replyTarget = null;
        });
        ref.read(feedViewModelProvider.notifier).refreshFeed();
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '댓글 작성 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(feedPostViewModelProvider(widget.sketchId).notifier)
        .deleteComment(commentId);

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        ref.read(feedViewModelProvider.notifier).refreshFeed();
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '댓글 삭제 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _deleteSketch() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(feedPostViewModelProvider(widget.sketchId).notifier)
        .deletePost();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        ref.invalidate(feedViewModelProvider);
        ref.invalidate(historyViewModelProvider);
        ref.invalidate(homeViewModelProvider);

        if (mounted) {
          context.pop();
        }
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '스케치 삭제 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final feedPostState = ref.watch(feedPostViewModelProvider(widget.sketchId));
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    return Scaffold(
      appBar: AppBar(),
      body: feedPostState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            error is AppException ? error.message : '게시물을 불러올 수 없습니다.',
          ),
        ),
        data: (state) {
          final sketch = state.sketch;
          final comments = state.comments;
          final isMyPost = sketch.authorId == currentUser.uid;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                spacing: 20,
                children: [
                  FeedPostCard(
                    sketch: sketch,
                    isDetail: true,
                    onDelete: _deleteSketch,
                  ),
                  CheerButton(
                    isMyPost: isMyPost,
                    isCheered: sketch.isCheeredBy(currentUser.uid),
                    isLoading: state.isTogglingCheer,
                    cheerCount: sketch.cheerCount,
                    onToggle: _toggleCheer,
                    onTapCount: () => _showCheeredUser(sketch.cheeredUserIds),
                  ),
                  const Divider(),
                  ...comments.map(
                    (comment) => UserCommentTile(
                      comment: comment,
                      sketchAuthor: sketch.author,
                      onReply: (comment) => setState(() {
                        _replyTarget = comment;
                      }),
                      onDelete: () => _deleteComment(comment.id),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: (feedPostState.hasError)
          ? null
          : SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyTarget != null)
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadiusGeometry.vertical(
                          top: const Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _replyTarget?.author.nickname,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                TextSpan(
                                  text: '에게 답글 다는 중',
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _replyTarget = null;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: textTheme.labelLarge?.fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            onChanged: (_) => setState(() {}),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              if (feedPostState.value?.isSubmittingComment !=
                                      true &&
                                  _commentController.text.trim().isNotEmpty) {
                                _submitComment();
                              }
                            },
                            style: textTheme.bodyMedium,
                            minLines: 1,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: '댓글을 입력하세요.',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              feedPostState.value?.isSubmittingComment ==
                                      true ||
                                  _commentController.text.trim().isEmpty
                              ? null
                              : _submitComment,
                          icon: feedPostState.value?.isSubmittingComment == true
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.arrow_upward),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            disabledBackgroundColor:
                                colorScheme.primaryContainer,
                            disabledForegroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
