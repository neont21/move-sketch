import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/social/comment.dart';
import '../../../domain/models/social/user.dart';
import '../../../routing/routes.dart';
import '../../../utils/date_time_utils.dart';
import '../../core/widgets/bottom_sheet_button.dart';
import '../../core/widgets/user_avatar.dart';

class UserCommentTile extends StatelessWidget {
  final Comment comment;
  final UserSummary sketchAuthor;
  final ValueChanged<Comment>? onReply;
  final VoidCallback? onDelete;

  const UserCommentTile({
    super.key,
    required this.comment,
    required this.sketchAuthor,
    this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: (comment.isReply)
          ? const EdgeInsets.fromLTRB(40, 10, 0, 10)
          : const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.go(Routes.feedProfile(comment.author.username));
            },
            child: UserAvatar(
              username: comment.author.username,
              imageUrl: comment.author.imageUrl,
              onTap: () =>
                  context.go(Routes.feedProfile(comment.author.username)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.go(Routes.feedProfile(comment.author.username));
                      },
                      child: Text(
                        comment.author.nickname,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      comment.createdAt.formattedFeedTime,
                      style: textTheme.labelMedium,
                    ),
                    if (comment.isReply && onReply != null)
                      GestureDetector(
                        onTap: () {
                          onReply!(comment);
                        },
                        child: Text(
                          '답글',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const Spacer(),
                    BottomSheetButton(
                      author: comment.author,
                      sketchAuthorIfComment: sketchAuthor,
                      commentIdIfComment: comment.id,
                      onDelete: onDelete,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: comment.isDeleted
                      ? Text(
                          '삭제된 댓글입니다.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outlineVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Text(
                          comment.text,
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.justify,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
