import 'package:firebase_messaging/firebase_messaging.dart';

/// 앱이 백그라운드 또는 종료 상태일 때 수신되는 FCM 원격 메시지를 처리하는 최상위 진입점 핸들러입니다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Firebase Cloud Messaging 푸시 알림 권한, 토큰 발급 및 메시지 스트림을 관리하는 서비스 클래스입니다.
class FirebaseMessagingService {
  /// FCM SDK 인스턴스.
  final FirebaseMessaging firebaseMessaging;

  FirebaseMessagingService({FirebaseMessaging? firebaseMessaging})
    : firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  /// 사용자에게 푸시 알림 수신 권한을 요청하고 허가 상태를 반환합니다.
  Future<NotificationSettings> requestPermission() {
    return firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// 앱이 포그라운드 상태일 때 수신되는 알림의 OS 표출 옵션을 설정합니다.
  Future<void> setForegroundOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) {
    return firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  /// FCM 백그라운드 메시지 핸들러([firebaseMessagingBackgroundHandler])를 등록합니다.
  void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// 현재 기기의 FCM 등록 토큰을 발급받아 반환합니다.
  Future<String?> getToken() {
    return firebaseMessaging.getToken();
  }

  /// iOS/macOS 플랫폼의 APNs 디바이스 토큰을 조회하여 반환합니다.
  Future<String?> getAPNSToken() {
    return firebaseMessaging.getAPNSToken();
  }

  /// FCM 토큰이 갱신될 때마다 새 토큰 문자열을 방출하는 스트림.
  Stream<String> get onTokenRefresh => firebaseMessaging.onTokenRefresh;

  /// 앱이 포그라운드 상태일 때 수신되는 원격 메시지를 방출하는 스트림.
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// 사용자가 알림 배너를 탭하여 백그라운드 상태의 앱을 열었을 때 메시지를 방출하는 스트림.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// 종료(Terminated) 상태에서 알림을 탭하여 앱이 실행된 경우 초기 [RemoteMessage]를 반환합니다.
  Future<RemoteMessage?> getInitialMessage() {
    return firebaseMessaging.getInitialMessage();
  }

  /// 현재 기기에 등록된 FCM 토큰을 폐기하여 무효화합니다.
  Future<void> deleteToken() {
    return firebaseMessaging.deleteToken();
  }
}
