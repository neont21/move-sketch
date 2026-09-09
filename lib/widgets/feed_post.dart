import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:move_sketch/models/mock_sketch.dart';
import 'package:move_sketch/theme.dart';
import 'package:move_sketch/widgets/bottom_sheet_button.dart';
import 'package:move_sketch/widgets/sketch_card.dart';
import '../models/mock_user.dart';

class FeedPost extends StatelessWidget {
  final MockSketch _sketch;
  final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
  final bool _isDetail;

  FeedPost({super.key, required this._sketch, this._isDetail=false});

  Row? metadata(BuildContext context) {
    if (_isDetail) {
      return null;
    }
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.star_outline, color: colorScheme.tertiaryContainer,
            size: 16),
        Text(
          '응원 ${_sketch.cheeredUser.length}',
          style: textTheme.labelMedium,
        ),
        SizedBox(width: 10),
        Icon(
          Icons.mode_comment_outlined,
          color: colorScheme.tertiaryContainer,
          size: 16,
        ),
        Text(
          '댓글 ${_sketch.cheeredUser.length}',
          style: textTheme.labelMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ActivityColors activityColors = context.activityColors;

    return Column(
      spacing: 20,
      children: [
        // 사용자
        Row(
          spacing: 8,
          children: [
            GestureDetector(
              onTap: () {
                context.go('/profile/${_sketch.author.id}');
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: const AssetImage(
                  'assets/default_profile.png',
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Text(_sketch.author.name, style: textTheme.bodyLarge),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _sketch.isJogging
                              ? activityColors.jogging
                              : activityColors.riding,
                        ),
                        color: _sketch.isJogging
                            ? activityColors.joggingFill
                            : activityColors.ridingFill,
                      ),
                      child: Text(
                        _sketch.isJogging ? '조깅' : '라이딩',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _sketch.isJogging
                              ? activityColors.joggingInk
                              : activityColors.ridingInk,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_sketch.location} · ${_sketch.weather} · ${DateFormat('MM/dd (E) HH:mm', 'ko').format(_sketch.createdAt)}',
                  style: textTheme.labelMedium,
                ),
              ],
            ),
            Spacer(),
            BottomSheetButton(authorId: _sketch.author.id, sketchIdIfPost: _sketch.sketchId,),
          ],
        ),
        GestureDetector(
          onTap: () {
            context.go('/feed/post/${_sketch.sketchId}');
          },
          child: Transform.rotate(
            angle: 0.03,
            child: SketchCard(
              imageProvider: (_sketch.sketchURL != null)
                  ? NetworkImage(_sketch.sketchURL!)
                  : AssetImage('assets/sample_sketch.png'),
              caption: _sketch.text,
            ),
          ),
        ),
        ?metadata(context),
        if (!_isDetail) Divider(color: Colors.transparent,),
      ],
    );
  }
}
