import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../routing/routes.dart';
import '../../../utils/date_time_utils.dart';
import '../../core/widgets/activity_badge.dart';
import '../../core/widgets/bottom_sheet_button.dart';
import '../../core/widgets/user_avatar.dart';
import '../../session/widgets/sketch_card.dart';

class FeedPostCard extends StatelessWidget {
  final SketchPost sketch;
  final bool isDetail;
  final VoidCallback? onDelete;

  const FeedPostCard({super.key, required this.sketch, this.isDetail = false, this.onDelete});

  Row? _metadata(BuildContext context) {
    if (isDetail) {
      return null;
    }
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.star_outline,
          color: colorScheme.tertiaryContainer,
          size: 16,
        ),
        Text('응원 ${sketch.cheerCount}', style: textTheme.labelMedium),
        SizedBox(width: 10),
        Icon(
          Icons.mode_comment_outlined,
          color: colorScheme.tertiaryContainer,
          size: 16,
        ),
        Text('댓글 ${sketch.commentCount}', style: textTheme.labelMedium),
      ],
    );
  }

  double _calculateRotationAngle(String id) {
    final hash = id.hashCode.abs();
    final normalized = ((hash % 1000) / 500.0) - 1.0;

    return normalized * 0.06;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final metaText = [
      sketch.locationTag,
      if (sketch.weather != null) sketch.weather!.shortSummary,
      sketch.createdAt.formattedFeedTime,
    ].join(' · ');

    return Column(
      spacing: 20,
      children: [
        Row(
          spacing: 8,
          children: [
            UserAvatar(
              username: sketch.author.username,
              imageUrl: sketch.author.imageUrl,
              onTap: () =>
                  context.go(Routes.feedProfile(sketch.author.username)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.go(Routes.feedProfile(sketch.author.username));
                      },
                      child: Text(
                        sketch.author.nickname,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                    ActivityBadge(activityType: sketch.activityType),
                  ],
                ),
                Text(metaText, style: textTheme.labelMedium),
              ],
            ),
            Spacer(),
            BottomSheetButton(
              author: sketch.author,
              sketchIdIfPost: sketch.id,
              onDelete: onDelete,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            context.go(Routes.feedPost(sketch.id));
          },
          child: Transform.rotate(
            angle:_calculateRotationAngle(sketch.id),
            child: SketchCard(
              imageProvider: NetworkImage(sketch.sketchUrl),
              caption: sketch.caption,
            ),
          ),
        ),
        ?_metadata(context),
        if (!isDetail) const SizedBox(height: 16),
      ],
    );
  }
}
