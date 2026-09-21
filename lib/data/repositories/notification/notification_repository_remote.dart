import 'package:firebase_core/firebase_core.dart';
import '../../../domain/models/social/app_notification.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firestore/notification_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'notification_repository.dart';

final class NotificationRepositoryRemote implements NotificationRepository {
  final NotificationService notificationService;

  NotificationRepositoryRemote({required this.notificationService});

  @override
  Future<Result<List<AppNotification>>> getNotifications({
    required String currentUserId,
    int limit = 30,
    DateTime? lastCreatedAt,
  }) async {
    try {
      final notifications = await notificationService.getNotifications(
        userId: currentUserId,
        limit: limit,
        lastCreatedAt: lastCreatedAt,
      );
      return Result.ok(notifications);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '알림 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('알림 조회 중 오류가 발생했습니다.', cause: e));
    }
  }

  @override
  Future<Result<bool>> hasUnreadNotifications(String currentUserId) async {
    try {
      final hasUnread = await notificationService.hasUnreadNotifications(
        currentUserId,
      );
      return Result.ok(hasUnread);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '안 읽은 알림 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('안 읽은 알림 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await notificationService.markAsRead(notificationId);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '알림 읽음 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('알림 읽음 처리 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> markAllAsRead(String currentUserId) async {
    try {
      await notificationService.markAllAsRead(currentUserId);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '알림 일괄 읽음 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('알림 일괄 읽음 처리 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      await notificationService.deleteNotification(notificationId);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '알림 삭제 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('알림 삭제 처리 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> deleteReadNotifications(String currentUserId) async {
    try {
      await notificationService.deleteReadNotifications(currentUserId);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '알림 일괄 삭제 처리 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('알림 일괄 삭제 처리 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<AppNotification?>> sendNotification(
    AppNotification notification,
  ) async {
    try {
      final sentNotification = await notificationService.createNotification(
        notification,
      );
      return Result.ok(sentNotification);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '알림 전송 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('알림 전송 중 오류가 발생했습니다.', cause: e));
    }
  }
}
