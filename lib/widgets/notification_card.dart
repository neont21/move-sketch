import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/mock_user.dart';
import '../models/mock_notification.dart';

class NotificationCard extends StatelessWidget {
  final MockUser _user;
  final ActionType _action;
  final DateTime _createdAt;
  final String _goTo;
  final bool _read;

  const NotificationCard({
    super.key,
    required this._user,
    required this._action,
    required this._createdAt,
    required this._goTo,
    this._read=false,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: _read ? colorScheme.surfaceContainer : colorScheme.outline,
      onTap: () {
        context.go(_goTo);
      },
      leading: GestureDetector(
        onTap: () {
          context.go('/profile/${_user.id}');
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
              text: _user.name,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: _action.notification, style: textTheme.bodyMedium),
          ],
        ),
      ),
      subtitle: Text(
        DateFormat('MM/dd (E) HH:mm', 'ko').format(_createdAt),
        style: textTheme.labelMedium,
      ),
    );
  }
}
