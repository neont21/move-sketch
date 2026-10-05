import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import '../../../data/repositories/sketch_post/sketch_post_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../models/enums/notification_type.dart';
import '../../models/social/app_notification.dart';

class ToggleCheerUseCase {
  final SketchPostRepository sketchPostRepository;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final NotificationRepository notificationRepository;

  ToggleCheerUseCase({
    required this.sketchPostRepository,
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

  void _dispatchNotification({
    required String targetUserId,
    required String sketchId,
  }) {
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
        type: NotificationType.cheer,
        targetSketchId: sketchId,
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
            reason: '스케치 응원 알림 전송 실패 (target: $targetUserId, sketch: $sketchId)',
            fatal: false,
          );
      }
    }());
  }

  Future<Result<void>> execute({
    required String sketchId,
    required String sketchAuthorId,
    required bool isCurrentlyCheered,
  }) async {
    final authCheckResult = _getCurrentUserId();

    switch (authCheckResult) {
      case Ok(:final value):
        final toggleResult = await sketchPostRepository.toggleCheer(
          sketchId: sketchId,
          userId: value,
          isCheered: !isCurrentlyCheered,
        );
        switch (toggleResult) {
          case Ok():
            if (!isCurrentlyCheered) {
              _dispatchNotification(
                targetUserId: sketchAuthorId,
                sketchId: sketchId,
              );
            }
            return const Result.ok(null);
          case Error(:final error):
            return Result.error(error);
        }
      case Error(:final error):
        return Result.error(error);
    }
  }
}
