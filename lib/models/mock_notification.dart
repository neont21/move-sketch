import 'package:move_sketch/models/mock_user.dart';

enum ActionType {
  comment(notification: '님이 내 기록에 댓글을 달았어요.'),
  reply(notification: '님이 내 댓글에 답글을 달았어요.'),
  cheer(notification: '님이 내 기록에 응원을 보냈어요.'),
  requestFriend(notification: '님이 친구 요청을 보냈어요.'),
  acceptFriend(notification: '님이 친구 요청을 수락했어요.');

  final String notification;

  const ActionType({required this.notification});
}

class MockNotification {
  MockUser user;
  DateTime createdAt;
  late ActionType action;
  String goTo;
  bool read;

  MockNotification({
    required this.user,
    required this.createdAt,
    required String action,
    required this.goTo,
    this.read=false,
}) {
    switch (action) {
      case 'comment':
        this.action = ActionType.comment;
      case 'reply':
        this.action = ActionType.reply;
      case 'cheer':
        this.action = ActionType.cheer;
      case 'requestFriend':
        this.action = ActionType.requestFriend;
      case 'acceptFriend':
        this.action = ActionType.acceptFriend;
      default:
        throw Exception('action error');
    }
  }
}