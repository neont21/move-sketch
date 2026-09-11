import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/mock_user.dart';

// final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
final MockUser user = MockUser(id: '@user_id', name: '테스트');
final List<MockUser> friendsList = [
  MockUser(id: '@edenjint3927', name: '후이')
];

class UserSheetButton extends StatelessWidget {
  final String _userId;
  const UserSheetButton({super.key, required this._userId});

List<ListTile> buildBottomSheet(BuildContext context) {
    List<ListTile> menuItems = [];
    if (friendsList.any((user) => user.id == _userId)) {
      menuItems.add(ListTile(
        title: Text('친구 삭제'),
        onTap: () {
          // TODO: implement delete
          context.pop();
        },
      ));
    }
    menuItems.add(ListTile(
      title: Text('신고하기'),
      onTap: () {
        // TODO: implement delete
        context.pop();
      },
    ));
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
                  children: buildBottomSheet(context),
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
