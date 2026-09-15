import 'package:flutter/material.dart';
import '../models/mock_user.dart';
import '../models/mock_notification.dart';
import '../widgets/notification_card.dart';

class FeedNotificationsPage extends StatefulWidget {
  FeedNotificationsPage({super.key});

  @override
  State<FeedNotificationsPage> createState() => _FeedNotificationsPageState();
}

class _FeedNotificationsPageState extends State<FeedNotificationsPage> {
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
      goTo: '/feed/notifications/profile/whoami',
      read: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('알림')),
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
                    onRead: () => setState(() {
                      _recentNotifications[index].read = true;
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  for (var item in _recentNotifications) {
                    item.read = true;
                  }
                });
              },
              child: Text('모두 읽음 표시', style: textTheme.labelMedium),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _recentNotifications.removeWhere((item) => item.read == true);
                });
              },
              child: Text('읽은 알림 지우기', style: textTheme.labelMedium),
            ),
          ],
        ),
      ),
    );
  }
}
