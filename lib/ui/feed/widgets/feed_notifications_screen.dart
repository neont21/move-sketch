import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/social/app_notification.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/error_retry_view.dart';
import '../view_models/feed_notifications_viewmodel.dart';
import 'notification_card.dart';

class FeedNotificationsScreen extends ConsumerStatefulWidget {
  const FeedNotificationsScreen({super.key});

  @override
  ConsumerState<FeedNotificationsScreen> createState() =>
      _FeedNotificationsScreenState();
}

class _FeedNotificationsScreenState
    extends ConsumerState<FeedNotificationsScreen> {
  Future<void> _handleMarkAllAsRead() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(feedNotificationsViewModelProvider.notifier)
        .markAllAsRead();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        ref.invalidate(hasUnreadNotificationsProvider);
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '알림 읽음 처리 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleDeleteNotification(String notificationId) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(feedNotificationsViewModelProvider.notifier)
        .deleteNotification(notificationId);

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        ref.invalidate(hasUnreadNotificationsProvider);
      case Error(:final error):
        final message = error is AppException
            ? error.message
            : '알림 삭제 처리 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  Future<void> _handleDeleteReadNotifications() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(feedNotificationsViewModelProvider.notifier)
        .deleteReadNotifications();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '알림 삭제 처리 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Dismissible _buildDismissibleCard(AppNotification notification) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.onError),
      ),
      onDismissed: (_) {
        _handleDeleteNotification(notification.id);
      },
      child: NotificationCard(
        notification: notification,
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(feedNotificationsViewModelProvider.notifier)
                .markAsRead(notification.id);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final notificationsState = ref.watch(feedNotificationsViewModelProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.invalidate(hasUnreadNotificationsProvider);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('알림')),
        body: notificationsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorRetryView.fromError(
            error: error,
            defaultMessage: '알림을 불러올 수 없습니다.',
            onRetry: () => ref.invalidate(feedNotificationsViewModelProvider),
          ),
          data: (state) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text('새로운 알림이 없습니다.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildDismissibleCard(state.notifications[index]),
            );
          },
        ),
        bottomNavigationBar: notificationsState.maybeWhen(
          data: (state) {
            final hasUnread = state.notifications.any(
              (notification) => !notification.isRead,
            );
            final hasRead = state.notifications.any(
              (notification) => notification.isRead,
            );
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: state.isProcessing || !hasUnread
                          ? null
                          : _handleMarkAllAsRead,
                      child: Text('모두 읽음 표시', style: textTheme.labelMedium),
                    ),
                    OutlinedButton(
                      onPressed: state.isProcessing || !hasRead
                          ? null
                          : _handleDeleteReadNotifications,
                      child: Text('읽은 알림 지우기', style: textTheme.labelMedium),
                    ),
                  ],
                ),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
