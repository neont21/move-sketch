import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../core/widgets/system_alert_dialog.dart';
import '../../feed/widgets/report_dialog.dart';
import '../../friends/widgets/friendship_action_handler.dart';

class UserSheetButton extends ConsumerWidget {
  final UserSummary targetUser;
  final bool isFriend;
  final bool isBlocked;

  const UserSheetButton({
    super.key,
    required this.targetUser,
    required this.isFriend,
    this.isBlocked = false,
  });

  List<ListTile> buildBottomSheet(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<ListTile> menuItems = [];

    if (isFriend) {
      menuItems.add(
        ListTile(
          title: Text('친구 삭제'),
          onTap: () {
            context.pop();
            showDialog(
              context: context,
              builder: (dialogContext) => Dialog(
                child: SystemAlertDialog(
                  title: '정말 삭제하시겠습니까?',
                  description:
                      '삭제하시면 다시 친구가 될 때까지 ${targetUser.nickname} (@${targetUser.username}) 님의 스케치를 볼 수 없어요.',
                  confirmText: '삭제',
                  onConfirm: () async {
                    dialogContext.pop();
                    await FriendshipActionHandler.removeFriend(
                      ref,
                      context,
                      targetUser,
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
          final currentUser = ref.read(authViewModelProvider).value;
          if (currentUser != null) {
            showDialog(
              context: context,
              builder: (dialogContext) => Dialog(
                child: ReportDialog(
                  targetUser: targetUser,
                  reporter: currentUser.toSummary(),
                ),
              ),
            );
          }
        },
      ),
    );
    if (isBlocked) {
      menuItems.add(
        ListTile(
          title: const Text('차단 해제'),
          onTap: () {
            context.pop();
            showDialog(
              context: context,
              builder: (dialogContext) => Dialog(
                child: SystemAlertDialog(
                  title: '차단을 해제할까요?',
                  description: '차단을 해제하면 서로의 프로필을 다시 볼 수 있어요.',
                  confirmText: '차단 해제',
                  onConfirm: () async {
                    dialogContext.pop();
                    await FriendshipActionHandler.unblockUser(
                      ref,
                      context,
                      targetUser,
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    } else {
      menuItems.add(
        ListTile(
          title: Text('차단하기', style: TextStyle(color: colorScheme.error)),
          onTap: () {
            context.pop();
            showDialog(
              context: context,
              builder: (dialogContext) => Dialog(
                child: SystemAlertDialog(
                  title: '정말 차단하시겠습니까?',
                  description:
                      '차단하시면 더이상 ${targetUser.nickname} (@${targetUser.username}) 님의 프로필과 스케치를 볼 수 없어요.',
                  confirmText: '차단',
                  onConfirm: () async {
                    dialogContext.pop();
                    final result = await FriendshipActionHandler.blockUser(
                      ref,
                      context,
                      targetUser,
                    );

                    switch (result) {
                      case Ok():
                        if (context.mounted) {
                          context.pop();
                        }
                      case Error():
                        break;
                    }
                  },
                ),
              ),
            );
          },
        ),
      );
    }

    return menuItems;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: buildBottomSheet(context, ref),
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
