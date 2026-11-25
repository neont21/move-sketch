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

/// 스케치 게시물에 대한 응원 상태를 토글하고 작성자에게 응원 알림을 발송하는 유즈케이스 클래스입니다.
final class ToggleCheerUseCase {
  /// 게시물 응원 상태 갱신을 담당하는 저장소.
  final SketchPostRepository sketchPostRepository;

  /// 현재 로그인된 사용자 식별자 확인을 위한 인증 저장소.
  final AuthRepository authRepository;

  /// 알림 발신자 요약 프로필 조회를 위한 사용자 저장소.
  final UserRepository userRepository;

  /// 응원 알림 전송을 담당하는 알림 저장소.
  final NotificationRepository notificationRepository;

  ToggleCheerUseCase({
    required this.sketchPostRepository,
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

  // 응원 활성화 성공 시 백그라운드로 게시물 작성자에게 응원 알림을 전송하며, 실패 시 Crashlytics에 비치명 오류로 기록합니다.
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
            reason:
                '스케치 응원 알림 전송 실패 (target: $targetUserId, sketch: $sketchId)',
            fatal: false,
          );
      }
    }());
  }

  /// 지정된 스케치 게시물([sketchId])의 응원 상태를 반전시켜 저장합니다.
  ///
  /// 현재 미응원 상태([isCurrentlyCheered] == `false`)에서 응원을 활성화할 때만 알림을 발송하며,
  /// 게시물 작성자([sketchAuthorId])가 본인인 경우에는 자가 알림을 보내지 않습니다.
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
            if (!isCurrentlyCheered && sketchAuthorId != value) {
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
