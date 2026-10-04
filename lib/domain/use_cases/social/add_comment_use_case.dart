import 'dart:async';

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

class AddCommentUseCase {
  final SketchPostRepository sketchPostRepository;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final NotificationRepository notificationRepository;

  AddCommentUseCase({
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
    required String commentId,
    required UserSummary sender,
    required NotificationType type,
  }) {
    unawaited(() async {
      final notification = AppNotification.create(
        recipientId: targetUserId,
        sender: sender,
        type: type,
        targetPostId: sketchId,
        targetCommentId: commentId,
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
