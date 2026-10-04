import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/social/user.dart';
import '../../../routing/routes.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../feed/widgets/report_dialog.dart';
import 'system_alert_dialog.dart';

class BottomSheetButton extends ConsumerWidget {
  final UserSummary author;
  final UserSummary? sketchAuthorIfComment;
  final String? sketchIdIfPost;
  final String? commentIdIfComment;
  final VoidCallback? onDelete;

  const BottomSheetButton({
    super.key,
    required this.author,
    this.sketchAuthorIfComment,
    this.sketchIdIfPost,
    this.commentIdIfComment,
    this.onDelete,
  });

  List<ListTile> _buildItems(BuildContext context, UserSummary currentUser) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isAuthorDeleted = author.username.startsWith('deleted_');

    List<ListTile> menuItems = [];

    if (author == currentUser || sketchAuthorIfComment == currentUser) {
      if (sketchIdIfPost != null) {
        menuItems.add(
          ListTile(
            title: const Text('편집하기'),
            onTap: () {
              context.pop();
              context.push(Routes.sessionEdit(sketchIdIfPost!));
            },
          ),
        );
      }
      menuItems.add(
        ListTile(
          title: Text('삭제하기', style: TextStyle(color: colorScheme.error)),
          onTap: () {
            context.pop();
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: SystemAlertDialog(
                  title: '정말 삭제하시겠습니까?',
                  description: commentIdIfComment != null
                      ? '댓글을 삭제하면 되돌릴 수 없습니다.'
                      : '스케치를 삭제하면 되돌릴 수 없습니다.\n기록 탭의 데이터는 사라지지 않습니다.',
                  confirmText: '삭제',
                  onConfirm: () {
                    context.pop();
                    onDelete?.call();
                  },
                ),
              ),
            );
          },
        ),
      );
    }
    if (author != currentUser) {
      menuItems.add(
        ListTile(
          title: Text('신고하기', style: TextStyle(color: colorScheme.error)),
          onTap: () {
            context.pop();
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: ReportDialog(
                  targetUser: author,
                  reporter: currentUser,
                  sketchId: sketchIdIfPost,
                  commentId: commentIdIfComment,
                ),
              ),
            );
          },
        ),
      );
      if (!isAuthorDeleted) {
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
                    description:
                        '차단하시면 더이상 ${author.nickname} (@${author.username}) 님의 프로필과 스케치를 볼 수 없어요.',
                    confirmText: '차단',
                    onConfirm: () {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${author.nickname} 님을 차단하였습니다.'),
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
    }
    return menuItems;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final currentUser = ref.watch(currentUserProvider)?.toSummary();
    if (currentUser == null) {
      return SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildItems(context, currentUser),
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
