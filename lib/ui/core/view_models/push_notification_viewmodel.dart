import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../data/repositories/notification/push_notification_repository.dart';
import '../../../data/repositories/session/session_repository.dart';
import '../../../domain/models/enums/notification_type.dart';
import '../../../routing/routes.dart';
import '../../../utils/result.dart';

/// FCM 푸시 알림 권한·초기화 상태 및 인앱 배너/딥링크 이동 대상을 보관하는 불변 상태 모델입니다.
@immutable
final class PushNotificationState {
  /// 현재 기기의 푸시 알림 권한 승인 상태.
  final AuthorizationStatus authorizationStatus;

  /// 푸시 알림 리스너 및 토큰 동기화 초기화 완료 여부.
  final bool isInitialized;

  /// 포그라운드 수신 시 화면 상단에 표시할 인앱 알림 본문.
  final String? inAppNotificationBody;

  /// 알림 탭 또는 인앱 배너 클릭 시 이동할 대상 라우트 경로.
  final String? destinationRoute;

  const PushNotificationState({
    this.authorizationStatus = AuthorizationStatus.notDetermined,
    this.isInitialized = false,
    this.inAppNotificationBody,
    this.destinationRoute,
  });

  PushNotificationState copyWith({
    AuthorizationStatus? authorizationStatus,
    bool? isInitialized,
    ValueGetter<String?>? inAppNotificationBody,
    ValueGetter<String?>? destinationRoute,
  }) {
    return PushNotificationState(
      authorizationStatus: authorizationStatus ?? this.authorizationStatus,
      isInitialized: isInitialized ?? this.isInitialized,
      inAppNotificationBody: inAppNotificationBody != null
          ? inAppNotificationBody()
          : this.inAppNotificationBody,
      destinationRoute: destinationRoute != null
          ? destinationRoute()
          : this.destinationRoute,
    );
  }
}

/// FCM 푸시 알림 초기화, 포그라운드 배너 수신, 알림 탭 딥링크 라우팅 및 토큰 해제를 관리하는 ViewModel입니다.
final class PushNotificationViewModel extends Notifier<PushNotificationState> {
  PushNotificationRepository get _pushNotificationRepository =>
      ref.read(pushNotificationRepositoryProvider);
  SessionRepository get _sessionRepository =>
      ref.read(sessionRepositoryProvider);

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _notificationOpenedSubscription;

  @override
  PushNotificationState build() {
    ref.onDispose(() {
      _foregroundMessageSubscription?.cancel();
      _notificationOpenedSubscription?.cancel();
    });
    return const PushNotificationState();
  }

  /// 사용자([userId])의 푸시 알림 권한 및 수신 리스너를 초기화합니다.
  Future<void> initialize(String userId) async {
    final result = await _pushNotificationRepository
        .initializePushNotifications(userId);

    switch (result) {
      case Ok():
        state = state.copyWith(isInitialized: true);
      case Error(:final error):
        FirebaseCrashlytics.instance.recordError(
          error,
          StackTrace.current,
          reason: 'FCM 푸시 알림 초기화 실패 (사용자: $userId)',
          fatal: false,
        );
        return;
    }

    _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = _pushNotificationRepository.onMessage
        .listen((message) async {
          await _handleForegroundMessage(message);
        });

    _notificationOpenedSubscription?.cancel();
    _notificationOpenedSubscription = _pushNotificationRepository
        .onMessageOpenedApp
        .listen((message) {
          _handleNotificationNavigation(message);
        });

    _pushNotificationRepository.getInitialMessage().then((message) {
      if (message != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationNavigation(message);
        });
      }
    });
  }

  // 포그라운드 메시지 수신 시 운동 세션 진행 여부와 알림 유형을 확인한 뒤 인앱 배너 상태를 갱신합니다.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    FirebaseCrashlytics.instance.log(
      'FCM 포그라운드 메시지 수신: type=${message.data['type']}, targetSketchId=${message.data['targetSketchId']}',
    );

    final notificationType = NotificationType.fromString(
      message.data['type'] as String?,
    );
    if (notificationType == NotificationType.reminder) {
      return;
    }

    final isSessionRunning = await _isSessionOngoing();
    if (isSessionRunning) {
      return;
    }

    final String? body = message.notification?.body;
    if (body == null) {
      return;
    }

    final String destinationRoute = _determineDestinationRoute(message);

    state = state.copyWith(
      inAppNotificationBody: () => body,
      destinationRoute: () => destinationRoute,
    );
  }

  // 알림 탭으로 앱이 열릴 때 목적지 라우트 상태를 갱신해 화면 이동을 트리거합니다.
  void _handleNotificationNavigation(RemoteMessage message) {
    final String destinationRoute = _determineDestinationRoute(message);
    state = state.copyWith(destinationRoute: () => destinationRoute);
  }

  /// 현재 표시 중인 인앱 알림 본문 및 대기 중인 이동 경로 상태를 초기화합니다.
  void clearNotification() {
    if (state.inAppNotificationBody != null || state.destinationRoute != null) {
      state = state.copyWith(
        inAppNotificationBody: () => null,
        destinationRoute: () => null,
      );
    }
  }

  // 운동 세션 추적 중에는 인앱 배너를 띄우지 않도록 활성 세션 여부를 확인합니다.
  Future<bool> _isSessionOngoing() async {
    final result = await _sessionRepository.getActiveSession();

    return switch (result) {
      Ok(:final value) => value != null && value.status.isOngoing,
      Error() => false,
    };
  }

  // 푸시 메시지 payload의 type과 대상 ID를 해석해 앱 내 이동 경로를 결정합니다.
  String _determineDestinationRoute(RemoteMessage message) {
    final String? typeString = message.data['type'] as String?;
    final NotificationType notificationType = NotificationType.fromString(
      typeString,
    );

    final String? targetSketchId =
        (message.data['targetSketchId'] ?? message.data['sketchId']) as String?;
    final String? senderUsername = message.data['senderUsername'] as String?;
    final String? targetNoticeId = message.data['targetNoticeId'] as String?;

    return switch (notificationType) {
      NotificationType.comment ||
      NotificationType.reply ||
      NotificationType.cheer ||
      NotificationType.sketch =>
        (targetSketchId != null && targetSketchId.isNotEmpty)
            ? Routes.feedNotificationPost(targetSketchId)
            : Routes.feedNotifications,
      NotificationType.requestFriend || NotificationType.acceptFriend =>
        (senderUsername != null && senderUsername.isNotEmpty)
            ? Routes.feedNotificationProfile(senderUsername)
            : Routes.feedNotifications,
      NotificationType.reminder => Routes.sessionStart,
      NotificationType.notice =>
        (targetNoticeId != null && targetNoticeId.isNotEmpty)
            ? Routes.feedNotificationNotice(targetNoticeId)
            : Routes.feedNotifications,
      NotificationType.unknown => Routes.feedNotifications,
    };
  }

  /// 로그아웃·탈퇴 시 사용자([userId])의 FCM 토큰과 알림 스트림 구독을 해제합니다.
  Future<void> clearPushToken(String userId) async {
    if (kIsWeb) {
      state = state.copyWith(isInitialized: false);
      return;
    }

    _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = null;

    _notificationOpenedSubscription?.cancel();
    _notificationOpenedSubscription = null;

    final result = await _pushNotificationRepository.clearPushToken(userId);

    switch (result) {
      case Ok():
        state = state.copyWith(isInitialized: false);
      case Error(:final error):
        FirebaseCrashlytics.instance.recordError(
          error,
          StackTrace.current,
          reason: 'FCM 기기 토큰 무효화 실패 (사용자: $userId)',
          fatal: false,
        );
    }
  }
}

/// [PushNotificationViewModel] 상태를 제공하는 전역 [NotifierProvider].
final pushNotificationViewModelProvider =
    NotifierProvider<PushNotificationViewModel, PushNotificationState>(() {
      return PushNotificationViewModel();
    });
