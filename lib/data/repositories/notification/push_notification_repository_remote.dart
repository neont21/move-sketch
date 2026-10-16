import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = firebaseMessagingService.onTokenRefresh
          .listen((token) async {
            FirebaseCrashlytics.instance.log('FCM 기기 토큰 갱신 이벤트 수신');
            await _handleTokenRefresh(userId: userId, token: token);
          });

      final bool isApplePlatform =
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS;
      if (isApplePlatform) {
        final apnsToken = await _waitForApnsToken();
        if (apnsToken == null) {
          FirebaseCrashlytics.instance.log(
            'APNs 기기 토큰이 아직 준비되지 않았습니다 (시뮬레이터 환경이거나 APNs 등록 지연). '
            '추후 토큰 갱신 스트림(onTokenRefresh)을 통해 동기화됩니다.',
          );
          return const Result.ok(null);
        }
      }

      final String? currentToken = await firebaseMessagingService.getToken();
      if (currentToken != null) {
        await userService.updateFcmToken(uid: userId, fcmToken: currentToken);
        FirebaseCrashlytics.instance.log('FCM 기기 토큰 최초 발급 및 Firestore 동기화 완료');
      }

      return const Result.ok(null);
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
        FirebaseCrashlytics.instance.log(
          'FCM 초기화 중 APNs 토큰 미수신 예외 발생하여 onTokenRefresh를 통해 동기화를 대기합니다.',
        );
        return const Result.ok(null);
      }
      return Result.error(
        e.toAppException(defaultMessage: '푸시 알림 초기화 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('푸시 알림 초기화 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  Future<String?> _waitForApnsToken() async {
    String? apnsToken = await firebaseMessagingService.getAPNSToken();
    int retryCount = 0;
    while (apnsToken == null && retryCount < 3) {
      await Future<void>.delayed(const Duration(seconds: 1));
      apnsToken = await firebaseMessagingService.getAPNSToken();
      retryCount++;
    }
    return apnsToken;
  }

  Future<void> _handleTokenRefresh({
    required String userId,
    required String token,
  }) async {
    try {
      await userService.updateFcmToken(uid: userId, fcmToken: token);
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'FCM 토큰 갱신 시 Firestore 저장 실패 (userId: $userId)',
        fatal: false,
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
