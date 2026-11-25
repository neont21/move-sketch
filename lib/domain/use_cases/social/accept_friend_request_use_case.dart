import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/friendship/friendship_repository.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../models/enums/notification_type.dart';
import '../../models/social/app_notification.dart';
import '../../models/social/friendship.dart';

/// 수신한 친구 요청을 수락 처리하고 요청자에게 수락 알림을 발송하는 유즈케이스 클래스입니다.
final class AcceptFriendRequestUseCase {
  /// 친구 관계 상태 변경을 담당하는 저장소.
  final FriendshipRepository friendshipRepository;

  /// 현재 로그인된 사용자 식별자 확인을 위한 인증 저장소.
  final AuthRepository authRepository;

  /// 알림 발신자 요약 프로필 조회를 위한 사용자 저장소.
  final UserRepository userRepository;

  /// 친구 수락 알림 전송을 담당하는 알림 저장소.
  final NotificationRepository notificationRepository;

  AcceptFriendRequestUseCase({
    required this.friendshipRepository,
    required this.authRepository,
    required this.userRepository,
    required this.notificationRepository,
  });

  // 현재 인증된 사용자의 UID를 조회하며, 세션이 유효하지 않은 경우 AuthException을 반환합니다.
  Result<String> _getCurrentUserId() {
    final currentUserId = authRepository.currentUid;
    if (currentUserId == null || currentUserId.isEmpty) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }
    return Result.ok(currentUserId);
  }

  // 친구 수락 성공 후 백그라운드로 상대방에게 수락 알림을 전송하며, 실패 시 Crashlytics에 비치명 오류로 기록합니다.
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
        type: NotificationType.acceptFriend,
      );

      final sentResult = await notificationRepository.sendNotification(
        notification,
      );

      switch (sentResult) {
        case Ok():
          break;
        case Error(:final error):
          FirebaseCrashlytics.instance.recordError(
            error,
            StackTrace.current,
            reason: '친구 수락 알림 전송 실패 (target: $targetUserId)',
            fatal: false,
          );
      }
    }());
  }

  /// 대상 사용자([targetUserId])가 보낸 친구 요청을 수락하고 갱신된 [Friendship]을 반환합니다.
  Future<Result<Friendship>> execute(String targetUserId) async {
    final authCheckResult = _getCurrentUserId();

    switch (authCheckResult) {
      case Ok(value: final currentUserId):
        final friendshipResult = await friendshipRepository.acceptFriendRequest(
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
