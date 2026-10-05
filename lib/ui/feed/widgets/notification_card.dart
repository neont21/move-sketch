import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/enums/notification_type.dart';
import '../../../domain/models/social/app_notification.dart';
import '../../../routing/routes.dart';
import '../../../utils/date_time_utils.dart';
import '../../core/widgets/user_avatar.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String? get _destinationRoute {
    switch (notification.type) {
      case NotificationType.comment:
      case NotificationType.reply:
      case NotificationType.cheer:
        if (notification.targetSketchId != null) {
          return Routes.feedNotificationPost(notification.targetSketchId!);
        }
        return null;
      case NotificationType.requestFriend:
      case NotificationType.acceptFriend:
        return Routes.feedNotificationProfile(notification.sender.username);
      case NotificationType.unknown:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: notification.isRead
          ? colorScheme.surfaceContainer
          : colorScheme.primaryContainer.withValues(alpha: 0.2),
      onTap: () {
        onTap();
        final route = _destinationRoute;
        if (route != null) {
          context.go(route);
        }
      },
      leading: UserAvatar(
        username: notification.sender.username,
        imageUrl: notification.sender.imageUrl,
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: notification.sender.nickname,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: notification.type.notification,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      subtitle: Text(
        notification.createdAt.formattedFeedTime,
        style: textTheme.labelMedium,
      ),
    );
  }
}
