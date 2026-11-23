/// 푸시 및 인앱 알림의 분류 유형과 메시지 템플릿, 딥링크 경로를 정의하는 열거형입니다.
enum NotificationType {
  /// 스케치 댓글 알림.
  comment(
    notification: '님이 내 스케치에 댓글을 달았어요.',
    base: '/feed/notifications/post/',
  ),
  /// 댓글 답글 알림.
  reply(notification: '님이 내 댓글에 답글을 달았어요.', base: '/feed/notifications/post/'),
  /// 스케치 응원 알림.
  cheer(notification: '님이 내 스케치에 응원을 보냈어요.', base: '/feed/notifications/post/'),
  /// 친구 스케치 게시 알림.
  sketch(notification: '님이 새로운 스케치를 게시했어요.', base: '/feed/notifications/post/'),
  /// 친구 요청 수신 알림.
  requestFriend(
    notification: '님이 친구 요청을 보냈어요.',
    base: '/feed/notifications/profile/',
  ),
  /// 친구 요청 수락 알림.
  acceptFriend(
    notification: '님이 친구 요청을 수락했어요.',
    base: '/feed/notifications/profile/',
  ),
  /// 정기 운동 독려 리마인더 알림.
  reminder(notification: '오늘의 운동을 시작해 볼까요?', base: '/session-start'),
  /// 시스템 공지사항 알림.
  notice(
    notification: '새로운 공지사항이 등록되었어요.',
    base: '/feed/notifications/notices/',
  ),
  /// 미정의 알림.
  unknown(notification: '님의 알 수 없는 알림.', base: '/');

  /// 알림 본문 메시지 템플릿.
  final String notification;
  /// 알림 탭 시 이동할 딥링크 베이스 경로.
  final String base;

  const NotificationType({required this.notification, required this.base});

  /// 문자열 [value]를 대소문자 구분 없이 매칭하여 [NotificationType]으로 변환합니다.
  ///
  /// 일치하는 항목이 없거나 [value]가 null인 경우 [NotificationType.unknown]을 반환합니다.
  static NotificationType fromString(String? value) {
    return NotificationType.values.firstWhere(
      (type) => type.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => NotificationType.unknown,
    );
  }
}
