import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/mock_user.dart';

// final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
final MockUser user = MockUser(id: '@user_id', name: '테스트');

class BottomSheetButton extends StatelessWidget {
  final String authorId;
  final String? parentId;
  final String? sketchIdIfPost;
  const BottomSheetButton({
    super.key,
    required this.authorId,
    this.parentId,
    this.sketchIdIfPost,
  });

  List<ListTile> buildBottomSheet(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    List<ListTile> menuItems = [];

    if (authorId == user.id || parentId == user.id) {
      if (sketchIdIfPost != null) {
        menuItems.add(
          ListTile(
            title: Text('편집하기', style: textTheme.bodyLarge),
            onTap: () {
              context.pop();
              context.push('/edit/$sketchIdIfPost');
            },
          ),
        );
      }
      menuItems.add(
        ListTile(
          title: Text('삭제하기'),
          onTap: () {
            // TODO: implement delete
            context.pop();
          },
        ),
      );
    }
    if (authorId != user.id) {
      menuItems.add(
        ListTile(
          title: Text('신고하기'),
          onTap: () {
            // TODO: implement report
            context.pop();
          },
        ),
      );
    }
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: buildBottomSheet(context),
              ),
            );
          },
        );
      },
      visualDensity: VisualDensity.compact,
      icon: Icon(Icons.more_horiz, color: colorScheme.tertiaryContainer),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
