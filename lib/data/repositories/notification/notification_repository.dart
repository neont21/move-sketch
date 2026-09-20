import '../../../domain/models/social/app_notification.dart';
import '../../../utils/result.dart';

abstract interface class NotificationRepository {
  /// 내 알림 목록을 페이징 조회한다. (피드 탭 > 알림)
  Future<Result<List<AppNotification>>> getNotifications({
    required String currentUserId,
    int limit = 30,
    DateTime? lastCreatedAt,
  });

  /// 안 읽은 알림의 존재 여부를 확인한다. (피드 탭 > 상단 인디케이터)
  Future<Result<bool>> hasUnreadNotifications(String currentUserId);

  /// 특정 알림을 읽음 처리한다.
  Future<Result<void>> markAsRead(String notificationId);

  /// 전체 알림을 일괄 읽음 처리한다. (피드 탭 > 알림 > 모두 읽음 표시)
  Future<Result<void>> markAllAsRead(String currentUserId);

  /// 특정 알림을 삭제한다.
  Future<Result<void>> deleteNotification(String notificationId);

  /// 읽은 알림을 일괄 삭제한다. (피드 탭 > 알림 > 읽은 알림 지우기)
  Future<Result<void>> deleteReadNotifications(String currentUserId);

  /// 알림을 생성한다.
  Future<Result<AppNotification?>> sendNotification(
    AppNotification notification,
  );
}
