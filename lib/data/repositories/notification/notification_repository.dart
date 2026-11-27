import '../../../domain/models/social/app_notification.dart';
import '../../../utils/result.dart';

/// 사용자 인앱 알림의 조회, 읽음 처리, 삭제 및 발송을 추상화한 저장소 인터페이스입니다.
abstract interface class NotificationRepository {
  /// 사용자([currentUserId])의 알림 목록을 [lastCreatedAt] 기준 커서 페이징으로 조회합니다. (피드 탭 > 알림)
  Future<Result<List<AppNotification>>> getNotifications({
    required String currentUserId,
    int limit = 30,
    DateTime? lastCreatedAt,
  });

  /// 사용자([currentUserId])의 안 읽은 알림 존재 여부를 실시간으로 구독합니다. (피드 탭 > 상단 인디케이터)
  Stream<bool> watchHasUnreadNotifications(String currentUserId);

  /// 지정된 알림([notificationId])을 읽음 상태로 변경합니다.
  Future<Result<void>> markAsRead(String notificationId);

  /// 사용자([currentUserId])의 모든 알림을 일괄 읽음 처리합니다. (피드 탭 > 알림 > 모두 읽음 표시)
  Future<Result<void>> markAllAsRead(String currentUserId);

  /// 지정된 알림([notificationId])을 삭제합니다.
  Future<Result<void>> deleteNotification(String notificationId);

  /// 사용자([currentUserId])의 읽은 알림을 일괄 삭제합니다. (피드 탭 > 알림 > 읽은 알림 지우기)
  Future<Result<void>> deleteReadNotifications(String currentUserId);

  /// 신규 인앱 알림([notification])을 생성하여 발송합니다.
  Future<Result<AppNotification?>> sendNotification(
    AppNotification notification,
  );
}
