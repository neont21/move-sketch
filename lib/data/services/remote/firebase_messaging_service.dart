import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

final class FirebaseMessagingService {
  final FirebaseMessaging firebaseMessaging;

  FirebaseMessagingService({FirebaseMessaging? firebaseMessaging})
    : firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  Future<NotificationSettings> requestPermission() {
    return firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

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

  void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<String?> getToken() {
    return firebaseMessaging.getToken();
  }

  Stream<String> get onTokenRefresh => firebaseMessaging.onTokenRefresh;

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() {
    return firebaseMessaging.getInitialMessage();
  }

  Future<void> deleteToken() {
    return firebaseMessaging.deleteToken();
  }
}
