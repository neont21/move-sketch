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
import '../../models/social/comment.dart';
import '../../models/social/user.dart';

/// 스케치 게시물에 댓글 또는 답글을 등록하고 대상자에게 알림을 발송하는 유즈케이스 클래스입니다.
final class AddCommentUseCase {
  /// 댓글 저장 및 게시물 댓글 수 갱신을 담당하는 저장소.
  final SketchPostRepository sketchPostRepository;

  /// 현재 로그인된 사용자 식별자 확인을 위한 인증 저장소.
  final AuthRepository authRepository;

  /// 댓글 작성자 요약 프로필 조회를 위한 사용자 저장소.
  final UserRepository userRepository;

  /// 댓글 및 답글 알림 전송을 담당하는 알림 저장소.
  final NotificationRepository notificationRepository;

  AddCommentUseCase({
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

  // 댓글/답글 등록 완료 후 수신 대상자에게 알림을 비동기 전송하며, 실패 시 Crashlytics에 비치명 오류로 기록합니다.
  void _dispatchNotification({
    required String targetUserId,
    required String sketchId,
    required String commentId,
    required UserSummary sender,
    required NotificationType type,
  }) {
    unawaited(() async {
      final notification = AppNotification.create(
        recipientId: targetUserId,
        sender: sender,
        type: type,
        targetSketchId: sketchId,
        targetCommentId: commentId,
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
            reason: '댓글/답글 알림 전송 실패 (target: $targetUserId, sketch: $sketchId)',
            fatal: false,
          );
      }
    }());
  }

  /// 스케치 게시물([sketchId])에 댓글 또는 답글([parentCommentId])을 작성하여 저장합니다.
  ///
  /// 공백 입력을 검증한 뒤 작성자 프로필을 조회하여 [Comment]를 생성하며,
  /// 답글인 경우 원댓글 작성자([parentCommentAuthorId])와 게시물 작성자([sketchAuthorId])에게 중복 없이 알림을 전송합니다.
  Future<Result<Comment>> execute({
    required String sketchId,
    required String sketchAuthorId,
    required String text,
    String? parentCommentId,
    String? parentCommentAuthorId,
  }) async {
    final authCheckResult = _getCurrentUserId();

    switch (authCheckResult) {
      case Ok(value: final currentUserId):
        final trimmedText = text.trim();
        if (trimmedText.isEmpty) {
          return const Result.error(ValidationException('댓글 내용을 입력해 주세요.'));
        }

        final userResult = await userRepository.getCurrentUserProfile();
        final currentUser = switch (userResult) {
          Ok(:final value) => value?.toSummary(),
          Error() => null,
        };

        if (currentUser == null) {
          return const Result.error(NotFoundException('사용자 프로필을 찾을 수 없습니다.'));
        }

        final newComment = Comment.create(
          sketchId: sketchId,
          author: currentUser,
          text: trimmedText,
          parentCommentId: parentCommentId,
        );

        final commentResult = await sketchPostRepository.addComment(
          sketchId: sketchId,
          comment: newComment,
        );

        switch (commentResult) {
          case Ok(value: final savedComment):
            if (savedComment.isReply) {
              if (parentCommentAuthorId != null &&
                  parentCommentAuthorId != currentUserId) {
                _dispatchNotification(
                  targetUserId: parentCommentAuthorId,
                  sketchId: sketchId,
                  commentId: savedComment.id,
                  sender: currentUser,
                  type: NotificationType.reply,
                );
              }
              if (sketchAuthorId != currentUserId &&
                  sketchAuthorId != parentCommentAuthorId) {
                _dispatchNotification(
                  targetUserId: sketchAuthorId,
                  sketchId: sketchId,
                  commentId: savedComment.id,
                  sender: currentUser,
                  type: NotificationType.comment,
                );
              }
            } else {
              if (sketchAuthorId != currentUserId) {
                _dispatchNotification(
                  targetUserId: sketchAuthorId,
                  sketchId: sketchId,
                  commentId: savedComment.id,
                  sender: currentUser,
                  type: NotificationType.comment,
                );
              }
            }
            return Result.ok(savedComment);
          case Error(:final error):
            return Result.error(error);
        }
      case Error(:final error):
        return Result.error(error);
    }
  }
}
