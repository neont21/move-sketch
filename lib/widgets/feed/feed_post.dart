import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/mock_sketch.dart';
import '../common/activity_badge.dart';
import '../common/bottom_sheet_button.dart';
import '../session/sketch_card.dart';
import '../../models/mock_user.dart';

class FeedPost extends StatelessWidget {
  final MockSketch sketch;
  final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
  final bool isDetail;

  FeedPost({super.key, required this.sketch, this.isDetail = false});

  Row? metadata(BuildContext context) {
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
        Text('응원 ${sketch.cheeredUser.length}', style: textTheme.labelMedium),
        SizedBox(width: 10),
        Icon(
          Icons.mode_comment_outlined,
          color: colorScheme.tertiaryContainer,
          size: 16,
        ),
        Text('댓글 ${sketch.comments.length}', style: textTheme.labelMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      spacing: 20,
      children: [
        Row(
          spacing: 8,
          children: [
            GestureDetector(
              onTap: () {
                context.go('/feed/profile/${sketch.author.id}');
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: const AssetImage('assets/default_profile.png'),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.go('/feed/profile/${sketch.author.id}');
                      },
                      child: Text(
                        sketch.author.name,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                    ActivityBadge(isJogging: sketch.isJogging),
                  ],
                ),
                Text(
                  '${sketch.location} · ${sketch.weather} · ${DateFormat('MM/dd (E) HH:mm', 'ko').format(sketch.createdAt)}',
                  style: textTheme.labelMedium,
                ),
              ],
            ),
            Spacer(),
            BottomSheetButton(
              authorId: sketch.author.id,
              sketchIdIfPost: sketch.sketchId,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            context.go('/feed/post/${sketch.sketchId}');
          },
          child: Transform.rotate(
            angle: 0.03,
            child: SketchCard(
              imageProvider: (sketch.sketchURL != null)
                  ? NetworkImage(sketch.sketchURL!)
                  : AssetImage('assets/sample_sketch.png'),
              caption: sketch.text,
            ),
          ),
        ),
        ?metadata(context),
        if (!isDetail) const SizedBox(height: 16,),
      ],
    );
  }
}
