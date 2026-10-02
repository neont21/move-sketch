import 'package:flutter/material.dart';

class FeedPostMetadata extends StatelessWidget {
  final int cheerCount;
  final int commentCount;

  const FeedPostMetadata({
    super.key,
    required this.cheerCount,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.star_outline,
          color: colorScheme.tertiaryContainer,
          size: 16,
        ),
        Text('응원 $cheerCount', style: textTheme.labelMedium),
        const SizedBox(width: 10),
        Icon(
          Icons.mode_comment_outlined,
          color: colorScheme.tertiaryContainer,
          size: 16,
        ),
        Text('댓글 $commentCount', style: textTheme.labelMedium),
      ],
    );
  }
}
