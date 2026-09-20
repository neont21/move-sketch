import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/ui/feed/widgets/report_dialog.dart';
import '../../../domain/models/mock_user.dart';
import 'system_alert_dialog.dart';

// final MockUser user = MockUser(id: '@daniil_a_np', name: '다닐루쉬카');
final MockUser user = MockUser(id: '@user_id', name: '테스트');

class BottomSheetButton extends StatelessWidget {
  final String authorId;
  final String? parentId;
  final String? sketchIdIfPost;
  final String? commentIdIfComment;
  const BottomSheetButton({
    super.key,
    required this.authorId,
    this.parentId,
    this.sketchIdIfPost,
    this.commentIdIfComment,
  });

  List<ListTile> buildBottomSheet(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<ListTile> menuItems = [];

    if (authorId == user.id || parentId == user.id) {
      if (sketchIdIfPost != null) {
        menuItems.add(
          ListTile(
            title: Text('편집하기'),
            onTap: () {
              context.pop();
              context.push('/edit/$sketchIdIfPost');
            },
          ),
        );
      }
      menuItems.add(
        ListTile(
          title: Text('삭제하기', style: TextStyle(color: colorScheme.error),),
          onTap: () {
            context.pop();
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: SystemAlertDialog(
                  title: '정말 삭제하시겠습니까?',
                  description: '스케치를 삭제하면 되돌릴 수 없습니다.\n기록 탭의 데이터는 사라지지 않습니다.',
                  confirmText: '삭제',
                  onConfirm: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('스케치가 삭제되었습니다.'),
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
    if (authorId != user.id) {
      menuItems.add(
        ListTile(
          title: Text('신고하기', style: TextStyle(color: colorScheme.error),),
          onTap: () {
            // TODO: implement report
            context.pop();
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: ReportDialog(
                  userId: user.id,
                  targetUserId: authorId,
                  sketchId: sketchIdIfPost,
                  commentId: commentIdIfComment,
                ),
              ),
            );
          },
        ),
      );
      menuItems.add(
        ListTile(
          title: Text('차단하기', style: TextStyle(color: colorScheme.error),),
          onTap: () {
            context.pop();
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: SystemAlertDialog(
                  title: '정말 차단하시겠습니까?',
                  description: '차단하시면 더이상 $authorId 님의 프로필과 스케치를 볼 수 없어요.',
                  confirmText: '차단',
                  onConfirm: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$authorId 님을 차단하였습니다.'),
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
