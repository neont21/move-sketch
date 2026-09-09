import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/mock_user.dart';

// final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
final MockUser user = MockUser(id: '@user_id', name: '테스트');

class BottomSheetButton extends StatelessWidget {
  final String _authorId;
  final String? _sketchIdIfPost;
  final String? _parentId;
  const BottomSheetButton({super.key, required this._authorId, this._parentId, this._sketchIdIfPost});

  List<ListTile> buildBottomSheet(BuildContext context, {required String authorId, String? parentId}) {
    TextTheme textTheme = Theme.of(context).textTheme;

    List<ListTile> menuItems = [];

    if (authorId == user.id || parentId == user.id) {
      if (_sketchIdIfPost != null) {
        menuItems.add(ListTile(
          title: Text('편집하기', style: textTheme.bodyLarge),
          onTap: () {
            context.pop();
            context.go('/feed/post/$_sketchIdIfPost/edit');
          },
        ));
      }
      menuItems.add(ListTile(
        title: Text('삭제하기'),
        onTap: () {
          // TODO: implement delete
          context.pop();
        },
      ));
    }
    if (authorId != user.id) {
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return
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
                    ...buildBottomSheet(context, authorId: _authorId, parentId: _parentId)
                  ],
                ),
              );
            });
      },
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.more_horiz,
        color: colorScheme.tertiaryContainer,
      ),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
