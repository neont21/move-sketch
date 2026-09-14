import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/mock_user.dart';

// final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
final MockUser user = MockUser(id: '@user_id', name: '테스트');
final List<MockUser> friendsList = [MockUser(id: '@edenjint3927', name: '후이')];

class UserSheetButton extends StatelessWidget {
  final String userId;
  const UserSheetButton({super.key, required this.userId});

  List<ListTile> buildBottomSheet(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<ListTile> menuItems = [];
    if (friendsList.any((user) => user.id == userId)) {
      menuItems.add(
        ListTile(
          title: Text('친구 삭제'),
          onTap: () {
            // TODO: implement delete
            context.pop();
          },
        ),
      );
    }
    menuItems.add(
      ListTile(
        title: Text('신고하기', style: TextStyle(color: colorScheme.error),),
        onTap: () {
          // TODO: implement delete
          context.pop();
        },
      ),
    );
    menuItems.add(
      ListTile(
        title: Text('차단하기', style: TextStyle(color: colorScheme.error),),
        onTap: () {
          // TODO: implement delete
          context.pop();
        },
      ),
    );
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
