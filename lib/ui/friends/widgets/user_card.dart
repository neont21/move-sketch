import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/social/user.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/system_alert_dialog.dart';
import '../../core/widgets/user_avatar.dart';

class UserCard extends StatelessWidget {
  final UserSummary user;
  final String? subtitle;
  final bool isFriend;
  final bool isRequested;
  final bool isSent;
  final bool isBlocked;

  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onSendRequest;
  final VoidCallback? onCancelRequest;
  final VoidCallback? onUnblock;

  const UserCard({
    super.key,
    required this.user,
    this.subtitle,
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

  Widget _buildTitle(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (subtitle != null) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: user.nickname, style: textTheme.bodyMedium),
            const TextSpan(text: ' '),
            TextSpan(text: '@${user.username}', style: textTheme.labelMedium),
          ],
        ),
      );
    } else {
      return Text(user.nickname, style: textTheme.bodyMedium);
    }
  }

  Widget _buildSubtitle(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (subtitle != null) {
      return Text(subtitle!, style: textTheme.labelMedium);
    } else {
      return Text('@${user.username}', style: textTheme.labelMedium);
    }
  }

  Widget _buildTrailing(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.push(Routes.userProfile(user.username));
      },
      leading: UserAvatar(
        username: user.username,
        imageUrl: user.imageUrl,
        radius: 24,
      ),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
    );
  }
}
