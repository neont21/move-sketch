import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/dependencies.dart';
import '../../../data/repositories/notification/push_notification_repository.dart';
import '../../../data/repositories/session/session_repository.dart';
import '../../../domain/models/enums/notification_type.dart';
import '../../../routing/app_router.dart';
import '../../../routing/routes.dart';
import '../../../utils/result.dart';

@immutable
class PushNotificationState {
  final AuthorizationStatus authorizationStatus;
  final bool isInitialized;

  const PushNotificationState({
    this.authorizationStatus = AuthorizationStatus.notDetermined,
    this.isInitialized = false,
  });

  PushNotificationState copyWith({
    AuthorizationStatus? authorizationStatus,
    bool? isInitialized,
  }) {
    return PushNotificationState(
      authorizationStatus: authorizationStatus ?? this.authorizationStatus,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

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

  Future<void> initialize(String userId) async {
    final result = await _pushNotificationRepository
        .initializePushNotifications(userId);

    switch (result) {
      case Ok():
        state = state.copyWith(isInitialized: true);
        break;
      case Error():
        // TODO: Firebase Crashlytics: Push Notification Init Error
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

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final isSessionRunning = await _isSessionOngoing();
    if (isSessionRunning) {
      return;
    }

    final String? title = message.notification?.title;
    final String? body = message.notification?.body;
    if (body == null) {
      return;
    }

    final String destinationRoute = _determineDestinationRoute(message);

    _showInAppNotificationSnackBar(
      title: title,
      body: body,
      destinationRoute: destinationRoute,
    );
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final String destinationRoute = _determineDestinationRoute(message);
    _navigateToRoute(destinationRoute);
  }

  Future<bool> _isSessionOngoing() async {
    final result = await _sessionRepository.getActiveSession();

    return switch (result) {
      Ok(:final value) => value != null && value.status.isOngoing,
      Error() => false,
    };
  }

  String _determineDestinationRoute(RemoteMessage message) {
    final String? typeString = message.data['type'] as String?;
    final NotificationType notificationType = NotificationType.fromString(
      typeString,
    );

    final String? targetPostId =
        (message.data['targetPostId'] ?? message.data['sketchId']) as String?;
    final String? senderUsername = message.data['senderUsername'] as String?;

    return switch (notificationType) {
      NotificationType.comment ||
      NotificationType.reply ||
      NotificationType.cheer =>
        (targetPostId != null && targetPostId.isNotEmpty)
            ? Routes.feedNotificationPost(targetPostId)
            : Routes.feedNotifications,
      NotificationType.requestFriend || NotificationType.acceptFriend =>
        (senderUsername != null && senderUsername.isNotEmpty)
            ? Routes.feedNotificationProfile(senderUsername)
            : Routes.feedNotifications,
      NotificationType.unknown => Routes.feedNotifications,
    };
  }

  void _showInAppNotificationSnackBar({
    String? title,
    required String body,
    required String destinationRoute,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(title != null ? '$title: $body' : body),
        action: SnackBarAction(
          label: '보기',
          onPressed: () {
            _navigateToRoute(destinationRoute);
          },
        ),
      ),
    );
  }

  void _navigateToRoute(String destinationRoute) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }

    context.push(destinationRoute);
  }

  Future<void> clearPushToken(String userId) async {
    _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = null;

    _notificationOpenedSubscription?.cancel();
    _notificationOpenedSubscription = null;

    final result = await _pushNotificationRepository.clearPushToken(userId);

    switch (result) {
      case Ok():
        state = state.copyWith(isInitialized: false);
        break;
      case Error():
        // TODO: Firebase Crashlytics: Push Token Invalidation Error
        break;
    }
  }
}

final pushNotificationViewModelProvider =
    NotifierProvider<PushNotificationViewModel, PushNotificationState>(() {
      return PushNotificationViewModel();
    });
