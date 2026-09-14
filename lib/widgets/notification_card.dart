import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/mock_user.dart';
import '../models/mock_notification.dart';

class NotificationCard extends StatelessWidget {
  final MockUser user;
  final ActionType action;
  final DateTime createdAt;
  final String goTo;
  final bool read;

  const NotificationCard({
    super.key,
    required this.user,
    required this.action,
    required this.createdAt,
    required this.goTo,
    this.read=false,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: read ? colorScheme.surfaceContainer : colorScheme.outline,
      onTap: () {
        context.go(goTo);
      },
      leading: GestureDetector(
        onTap: () {
          context.go('/profile/${user.id}');
        },
        child: CircleAvatar(
          radius: 20,
          backgroundImage: const AssetImage('assets/default_profile.png'),
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: user.name,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: action.notification, style: textTheme.bodyMedium),
          ],
        ),
      ),
      subtitle: Text(
        DateFormat('MM/dd (E) HH:mm', 'ko').format(createdAt),
        style: textTheme.labelMedium,
      ),
    );
  }
}
