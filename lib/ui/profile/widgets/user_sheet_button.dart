import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/mock_user.dart';
import '../../core/widgets/system_alert_dialog.dart';
import '../../feed/widgets/report_dialog.dart';

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
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: SystemAlertDialog(
                  title: '정말 삭제하시겠습니까?',
                  description: '삭제하시면 다시 친구가 될 때까지 $userId 님의 스케치를 볼 수 없어요.',
                  confirmText: '삭제',
                  onConfirm: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$userId 님을 친구 목록에서 삭제하였습니다.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }
    menuItems.add(
      ListTile(
        title: Text('신고하기', style: TextStyle(color: colorScheme.error)),
        onTap: () {
          context.pop();
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: ReportDialog(userId: user.id, targetUserId: userId),
            ),
          );
        },
      ),
    );
    menuItems.add(
      ListTile(
        title: Text('차단하기', style: TextStyle(color: colorScheme.error)),
        onTap: () {
          context.pop();
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: SystemAlertDialog(
                title: '정말 차단하시겠습니까?',
                description: '차단하시면 더이상 $userId 님의 프로필과 스케치를 볼 수 없어요.',
                confirmText: '차단',
                onConfirm: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$userId 님을 차단하였습니다.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ),
          );
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
