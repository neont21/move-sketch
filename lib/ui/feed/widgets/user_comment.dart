import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/mock_comment.dart';
import '../../../domain/models/mock_user.dart';
import '../../core/widgets/bottom_sheet_button.dart';

class UserComment extends StatelessWidget {
  late final MockComment _comment;
  final ValueChanged<String>? onReply;
  UserComment({
    super.key,
    required MockUser user,
    required DateTime createdAt,
    required String sketchId,
    required String commentId,
    required String text,
    String? parentCommentId,
    this.onReply,
  }) {
    _comment = MockComment(
      user: user,
      createdAt: createdAt,
      sketchId: sketchId,
      commentId: commentId,
      text: text,
      parentCommentId: parentCommentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: (_comment.parentCommentId == null)
          ? const EdgeInsets.symmetric(vertical: 10)
          : const EdgeInsets.fromLTRB(40, 10, 0, 10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.go('/feed/profile/${_comment.user.id}');
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: const AssetImage('assets/default_profile.png'),
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
                        context.go('/feed/profile/${_comment.user.id}');
                      },
                    child: Text(_comment.user.name, style: textTheme.bodyLarge)),
                    Text(
                      DateFormat(
                        'MM/dd (E) HH:mm',
                        'ko',
                      ).format(_comment.createdAt),
                      style: textTheme.labelMedium,
                    ),
                    (_comment.parentCommentId == null && onReply != null)
                        ? GestureDetector(
                            onTap: () { onReply!(_comment.commentId);},
                            child: Text(
                              '답글',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    Spacer(),
                    // TODO: Provider 연결 후 sketch author id를 parentId로 전달
                    BottomSheetButton(authorId: _comment.user.id),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    _comment.text,
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
