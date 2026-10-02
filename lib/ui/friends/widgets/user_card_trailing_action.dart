import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/system_alert_dialog.dart';

class UserCardTrailingAction extends StatelessWidget {
  final bool isFriend;
  final bool isRequested;
  final bool isSent;
  final bool isBlocked;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onSendRequest;
  final VoidCallback? onCancelRequest;
  final VoidCallback? onUnblock;

  const UserCardTrailingAction({
    super.key,
    this.isFriend = false,
    this.isRequested = false,
    this.isSent = false,
    this.isBlocked = false,
    this.onAccept,
    this.onDecline,
    this.onSendRequest,
    this.onCancelRequest,
    this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (isRequested) {
      return Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: onDecline,
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            child: Text('거절', style: textTheme.bodySmall),
          ),
          OutlinedButton(
            onPressed: onAccept,
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(
              '수락',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    } else if (isSent) {
      return OutlinedButton(
        onPressed: onCancelRequest,
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        child: Text('요청 취소', style: textTheme.bodySmall),
      );
    } else if (isFriend) {
      return Icon(Icons.chevron_right, color: colorScheme.tertiaryContainer);
    } else if (isBlocked) {
      return OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: SystemAlertDialog(
                title: '차단을 해제할까요?',
                description: '차단을 해제하면 서로의 프로필을 다시 볼 수 있어요.',
                confirmText: '차단 해제',
                onConfirm: () {
                  context.pop();
                  onUnblock?.call();
                },
              ),
            ),
          );
        },
        child: Text('차단 해제', style: textTheme.bodySmall),
      );
    } else {
      return OutlinedButton(
        onPressed: onSendRequest,
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: Text(
          '친구 요청',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary),
        ),
      );
    }
  }
}
