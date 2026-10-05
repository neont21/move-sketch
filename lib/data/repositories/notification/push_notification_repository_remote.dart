import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firebase_messaging_service.dart';
import '../../services/remote/firestore/user_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'push_notification_repository.dart';

final class PushNotificationRepositoryRemote
    implements PushNotificationRepository {
  final FirebaseMessagingService firebaseMessagingService;
  final UserService userService;

  StreamSubscription<String>? _tokenRefreshSubscription;

  PushNotificationRepositoryRemote({
    required this.firebaseMessagingService,
    required this.userService,
  });

  @override
  Stream<RemoteMessage> get onMessage => firebaseMessagingService.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      firebaseMessagingService.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() =>
      firebaseMessagingService.getInitialMessage();

  @override
  Future<Result<void>> initializePushNotifications(String userId) async {
    try {
      final settings = await firebaseMessagingService.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return const Result.ok(null);
      }

      await firebaseMessagingService.setForegroundOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      firebaseMessagingService.registerBackgroundHandler();

      final String? currentToken = await firebaseMessagingService.getToken();
      if (currentToken != null) {
        await userService.updateFcmToken(uid: userId, fcmToken: currentToken);
      }

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = firebaseMessagingService.onTokenRefresh
          .listen((token) async {
            try {
              await userService.updateFcmToken(uid: userId, fcmToken: token);
            } catch (e) {
              // TODO: Firebase Crashlytics: Push Token Refresh Update Error
            }
          });

      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '푸시 알림 초기화 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('푸시 알림 초기화 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> clearPushToken(String userId) async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;

    try {
      await userService.updateFcmToken(uid: userId, fcmToken: null);
      await firebaseMessagingService.deleteToken();

      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '푸시 토큰 삭제 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('푸시 토큰 삭제 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
  }
}
