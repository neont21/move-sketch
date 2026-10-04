import 'dart:async';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/friendship/friendship_repository.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../models/enums/notification_type.dart';
import '../../models/social/app_notification.dart';
import '../../models/social/friendship.dart';

class SendFriendRequestUseCase {
  final FriendshipRepository friendshipRepository;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final NotificationRepository notificationRepository;

  SendFriendRequestUseCase({
    required this.friendshipRepository,
    required this.authRepository,
    required this.userRepository,
    required this.notificationRepository,
  });

  Result<String> _getCurrentUserId() {
    final currentUserId = authRepository.currentUid;
    if (currentUserId == null || currentUserId.isEmpty) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }
    return Result.ok(currentUserId);
  }

  void _dispatchNotification({required String targetUserId}) {
    unawaited(() async {
      final userResult = await userRepository.getCurrentUserProfile();

      final senderSummary = switch (userResult) {
        Ok(:final value) => value?.toSummary(),
        Error() => null,
      };

      if (senderSummary == null) {
        return;
      }

      final notification = AppNotification.create(
        recipientId: targetUserId,
        sender: senderSummary,
        type: NotificationType.requestFriend,
      );

      final sentResult = await notificationRepository.sendNotification(
        notification,
      );

      switch (sentResult) {
        case Ok():
          break;
        case Error():
          // TODO: Firebase Crashlytics: notification fail
          break;
      }
    }());
  }

  Future<Result<Friendship>> execute(String targetUserId) async {
    final authCheckResult = _getCurrentUserId();

    switch (authCheckResult) {
      case Ok(value: final currentUserId):
        final friendshipResult = await friendshipRepository.sendFriendRequest(
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        );

        switch (friendshipResult) {
          case Ok(value: final friendship):
            _dispatchNotification(targetUserId: targetUserId);
            return Result.ok(friendship);
          case Error(:final error):
            return Result.error(error);
        }

      case Error(:final error):
        return Result.error(error);
    }
  }
}
