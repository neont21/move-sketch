import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:move_sketch/widgets/bottom_sheet_button.dart';
import '../models/mock_comment.dart';

import '../models/mock_user.dart';

class UserComment extends StatelessWidget {
  late final MockComment _comment;
  UserComment({
    super.key,
    required MockUser user,
    required DateTime createdAt,
    required String sketchId,
    required String commentId,
    required String text,
    String? parentCommentId,
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
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: (_comment.parentCommentId == null)
          ? EdgeInsets.symmetric(vertical: 10)
          : EdgeInsets.fromLTRB(40, 10, 0, 10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.go('/profile/${_comment.user.id}');
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
                // 이름
                Row(
                  spacing: 12,
                  children: [
                    Text(_comment.user.name, style: textTheme.bodyLarge),
                    Text(
                      DateFormat(
                        'MM/dd (E) HH:mm',
                        'ko',
                      ).format(_comment.createdAt),
                      style: textTheme.labelMedium,
                    ),
                    (_comment.parentCommentId == null)
                        ? GestureDetector(
                            onTap: () {
                              // TODO: 답글 토글. callback function 써서 commentId 전달
                            },
                            child: Text(
                              '답글',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : Container(),
                    Spacer(),
                    // TODO: Provider 연결 후 sketch author id를 parentId로 전달
                    BottomSheetButton(authorId: _comment.user.id),
                  ],
                ),
                // 내용
                Padding(
                  padding: EdgeInsets.only(right: 20),
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
