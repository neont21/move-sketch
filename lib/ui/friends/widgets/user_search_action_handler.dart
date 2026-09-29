import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../view_models/user_search_viewmodel.dart';

abstract final class UserSearchActionHandler {
  static Future<void> sendRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(userSearchViewModelProvider.notifier)
        .sendFriendRequest(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님에게 친구 요청을 보냈습니다.')),
        );
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '친구 요청 전송 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  static Future<void> cancelRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(userSearchViewModelProvider.notifier)
        .cancelFriendRequest(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(
            content: Text('${targetUser.nickname} 님에게 보낸 친구 요청을 취소했습니다.'),
          ),
        );
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '친구 요청 취소 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  static Future<void> acceptRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(userSearchViewModelProvider.notifier)
        .acceptFriendRequest(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님의 친구 요청을 수락했습니다.')),
        );
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '친구 요청 수락 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  static Future<void> declineRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(userSearchViewModelProvider.notifier)
        .declineFriendRequest(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님의 친구 요청을 거절했습니다.')),
        );
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '친구 요청 거절 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }
}
