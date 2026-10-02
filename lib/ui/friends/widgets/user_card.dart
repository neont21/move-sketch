import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'user_card_trailing_action.dart';
import '../../../domain/models/social/user.dart';
import '../../../routing/routes.dart';
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
      trailing: UserCardTrailingAction(
        isFriend: isFriend,
        isRequested: isRequested,
        isSent: isSent,
        isBlocked: isBlocked,
        onAccept: onAccept,
        onDecline: onDecline,
        onSendRequest: onSendRequest,
        onCancelRequest: onCancelRequest,
        onUnblock: onUnblock,
      ),
    );
  }
}
