import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/mock_user.dart';
import '../models/mock_notification.dart';
import '../widgets/notification_card.dart';

class FeedNotificationsPage extends StatelessWidget {
  FeedNotificationsPage({super.key});

  final List<MockNotification> _recentNotifications = [
    MockNotification(
      user: MockUser(id: '@edenjint3927', name: '후이'),
      createdAt: DateTime.now(),
      action: 'comment',
      goTo: '/feed/notifications/post/test1',
    ),
    MockNotification(
      user: MockUser(id: '@edenjint3927', name: '후이'),
      createdAt: DateTime.now(),
      action: 'cheer',
      goTo: '/feed/notifications/post/test1',
    ),
    MockNotification(
      user: MockUser(id: '@whoami', name: '익명의라이더'),
      createdAt: DateTime.now(),
      action: 'requestFriend',
      goTo: '/profile/whoami',
      read: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Text('알림'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: _recentNotifications.length,
                itemBuilder: (context, index) {
                  return NotificationCard(
                    user: _recentNotifications[index].user,
                    action: _recentNotifications[index].action,
                    createdAt: _recentNotifications[index].createdAt,
                    goTo: _recentNotifications[index].goTo,
                    read: _recentNotifications[index].read,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
