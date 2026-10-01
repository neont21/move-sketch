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
  final bool isBlocked;
  final ValueChanged<Comment>? onReply;
  final VoidCallback? onDelete;

  const UserCommentTile({
    super.key,
    required this.comment,
    required this.sketchAuthor,
    this.isBlocked = false,
    this.onReply,
    this.onDelete,
  });

  Widget _buildMaskedTile(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String message = comment.isDeleted ? '삭제된 댓글입니다.' : '차단된 사용자의 댓글입니다.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Text(
        message,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.tertiaryContainer,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (comment.isDeleted || isBlocked) {
      return _buildMaskedTile(context);
    }

    final bool isAuthorDeleted = comment.author.username.startsWith('deleted_');

    return Padding(
      padding: (comment.isReply)
          ? const EdgeInsets.fromLTRB(16, 6, 0, 6)
          : const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comment.isReply) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 6),
              child: Icon(
                Icons.subdirectory_arrow_right,
                size: 18,
                color: colorScheme.outlineVariant,
              ),
            ),
          ],
          UserAvatar(
            username: comment.author.username,
            imageUrl: comment.author.imageUrl,
            onTap: () =>
                context.go(Routes.feedProfile(comment.author.username)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    GestureDetector(
                      onTap: isAuthorDeleted
                          ? null
                          : () {
                              context.go(
                                Routes.feedProfile(comment.author.username),
                              );
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
                    if (!comment.isReply && onReply != null)
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
                  child: Text(
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
