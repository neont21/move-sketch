import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:move_sketch/models/mock_sketch.dart';
import 'package:move_sketch/theme.dart';
import 'package:move_sketch/widgets/sketch_card.dart';
import '../models/mock_user.dart';

class FeedPost extends StatelessWidget {
  final MockSketch _sketch;
  final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');

  FeedPost({super.key, required this._sketch});

  List<ListTile> buildBottomSheet(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    List<ListTile> menuItems = [];

    if (_sketch.author.id == user.id) {
      menuItems.add(ListTile(
        title: Text('편집하기', style: textTheme.bodyLarge),
        onTap: () {
          context.pop();
          context.go('/feed/post/${_sketch.sketchId}/edit');
        },
      ));
      menuItems.add(ListTile(
        title: Text('삭제하기'),
        onTap: () {
          // TODO: implement delete
          context.pop();
        },
      ));
    } else {
      menuItems.add(ListTile(
        title: Text('신고하기'),
        onTap: () {
          // TODO: implement report
          context.pop();
        },
      ));
    }
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    ActivityColors activityColors = context.activityColors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
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
              IconButton(
                onPressed: () {
                  showModalBottomSheet(context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...buildBottomSheet(context)
                            ],
                          ),
                        );
                  });
                },
                icon: Icon(Icons.more_horiz),
                color: colorScheme.tertiaryContainer,
              ),
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
          Row(
            children: [
              Icon(Icons.star_outline, color: colorScheme.tertiaryContainer, size: 16),
              Text(
                '응원 ${_sketch.cheeredUser?.length ?? 0}',
                style: textTheme.labelMedium,
              ),
              SizedBox(width: 10),
              Icon(
                Icons.mode_comment_outlined,
                color: colorScheme.tertiaryContainer,
                size: 16,
              ),
              Text(
                '댓글 ${_sketch.cheeredUser?.length ?? 0}',
                style: textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
