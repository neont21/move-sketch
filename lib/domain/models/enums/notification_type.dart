enum NotificationType {
  comment(
    notification: '님이 내 스케치에 댓글을 달았어요.',
    base: '/feed/notifications/post/',
  ),
  reply(notification: '님이 내 댓글에 답글을 달았어요.', base: '/feed/notifications/post/'),
  cheer(notification: '님이 내 스케치에 응원을 보냈어요.', base: '/feed/notifications/post/'),
  requestFriend(
    notification: '님이 친구 요청을 보냈어요.',
    base: '/feed/notifications/profile/',
  ),
  acceptFriend(
    notification: '님이 친구 요청을 수락했어요.',
    base: '/feed/notifications/profile/',
  ),
  reminder(
    notification: '오늘의 운동을 시작해 볼까요?',
    base: '/session-start'
  ),
  unknown(notification: '님의 알 수 없는 알림.', base: '/');

  final String notification;
  final String base;

  const NotificationType({required this.notification, required this.base});

  static NotificationType fromString(String? value) {
    return NotificationType.values.firstWhere(
      (type) => type.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => NotificationType.unknown,
    );
  }
}
