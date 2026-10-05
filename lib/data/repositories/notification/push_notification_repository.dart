import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../utils/result.dart';

abstract interface class PushNotificationRepository {
  /// 푸시 알림 환경을 초기화하고, 기기 등록 토큰을 조회하여 Firestore에 저장 및 갱신을 구독한다.
  Future<Result<void>> initializePushNotifications(String userId);

  /// 사용자의 FCM 기기 등록 토큰을 Firestore 및 로컬에서 삭제하여 무효화한다.
  Future<Result<void>> clearPushToken(String userId);

  /// 앱 실행 중에 수신되는 푸시 메시지 스트림을 구독한다.
  Stream<RemoteMessage> get onMessage;

  /// 백그라운드 상태에서 알림 배너를 탭하여 앱이 열리는 푸시 메시지 스트림을 구독한다.
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// 앱이 완전히 종료된 상태에서 알림 배너를 탭하여 실행된 초기 푸시 메시지를 조회한다.
  Future<RemoteMessage?> getInitialMessage();

  /// 리소스를 해제한다.
  void dispose();
}