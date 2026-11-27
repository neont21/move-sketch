import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../utils/result.dart';

/// FCM 푸시 알림 초기화, 기기 토큰 관리 및 수신 스트림 구독을 추상화한 저장소 인터페이스입니다.
abstract interface class PushNotificationRepository {
  /// 푸시 알림 권한 및 옵션을 초기화하고, 사용자([userId])의 기기 등록 토큰을 Firestore에 동기화합니다.
  Future<Result<void>> initializePushNotifications(String userId);

  /// 사용자([userId])의 FCM 기기 등록 토큰을 Firestore 및 로컬에서 삭제하여 무효화합니다.
  Future<Result<void>> clearPushToken(String userId);

  /// 앱 포그라운드 실행 중 수신되는 푸시 메시지 스트림.
  Stream<RemoteMessage> get onMessage;

  /// 백그라운드 상태에서 알림 배너를 탭하여 앱을 열 때 전달되는 푸시 메시지 스트림.
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// 앱이 완전히 종료된 상태에서 알림 배너를 탭하여 실행된 초기 푸시 메시지를 조회합니다.
  Future<RemoteMessage?> getInitialMessage();

  /// 토큰 갱신 스트림 구독 등 내부 리소스를 해제합니다.
  void dispose();
}
