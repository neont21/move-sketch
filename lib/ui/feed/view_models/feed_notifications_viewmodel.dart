import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/app_notification.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class FeedNotificationsState {
  final List<AppNotification> notifications;
  final bool isProcessing;

  const FeedNotificationsState({
    required this.notifications,
    this.isProcessing = false,
  });

  FeedNotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isProcessing,
  }) {
    return FeedNotificationsState(
      notifications: notifications ?? this.notifications,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class FeedNotificationsViewModel extends AsyncNotifier<FeedNotificationsState> {
  @override
  Future<FeedNotificationsState> build() async {
    final user = await ref.watch(authViewModelProvider.future);
    if (user == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final notificationRepository = ref.read(notificationRepositoryProvider);
    final result = await notificationRepository.getNotifications(
      currentUserId: user.uid,
    );

    switch (result) {
      case Ok(:final value):
        return FeedNotificationsState(notifications: value);
      case Error(:final error):
        throw error;
    }
  }

  Future<Result<void>> markAsRead(String notificationId) async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    final updated = current.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.markAsRead();
      } else {
        return notification;
      }
    }).toList();

    state = AsyncData(current.copyWith(notifications: updated));

    final result = await ref
        .read(notificationRepositoryProvider)
        .markAsRead(notificationId);

    switch (result) {
      case Ok():
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current);
        return Result.error(error);
    }
  }

  Future<Result<void>> markAllAsRead() async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final result = await ref
        .read(notificationRepositoryProvider)
        .markAllAsRead(user.uid);

    switch (result) {
      case Ok():
        final updated = current.notifications
            .map((notification) => notification.markAsRead())
            .toList();

        state = AsyncData(
          current.copyWith(notifications: updated, isProcessing: false),
        );

        return Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> deleteNotification(String notificationId) async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    final updated = current.notifications
        .where((notification) => notification.id != notificationId)
        .toList();

    state = AsyncData(current.copyWith(notifications: updated));

    final result = await ref
        .read(notificationRepositoryProvider)
        .deleteNotification(notificationId);

    switch (result) {
      case Ok():
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current);
        return Result.error(error);
    }
  }

  Future<Result<void>> deleteReadNotifications() async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    final user = await ref.read(authViewModelProvider.future);
    if (user == null) {
      return const Result.error(AuthException('로그인된 사용자 세션이 없습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final result = await ref
        .read(notificationRepositoryProvider)
        .deleteReadNotifications(user.uid);

    switch (result) {
      case Ok():
        final updated = current.notifications
            .where((notification) => !notification.isRead)
            .toList();

        state = AsyncData(
          current.copyWith(notifications: updated, isProcessing: false),
        );
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }
}

final feedNotificationsViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      FeedNotificationsViewModel,
      FeedNotificationsState
    >(() {
      return FeedNotificationsViewModel();
    });

final hasUnreadNotificationsProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final user = await ref.watch(authViewModelProvider.future);
  if (user == null) {
    return false;
  }

  final result = await ref
      .read(notificationRepositoryProvider)
      .hasUnreadNotifications(user.uid);

  switch (result) {
    case Ok(:final value):
      return value;
    case Error():
      return false;
  }
});
