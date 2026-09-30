import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../profile/view_models/user_profile_viewmodel.dart';
import '../../settings/view_models/blocked_users_viewmodel.dart';
import '../view_models/friends_viewmodel.dart';
import '../view_models/user_search_viewmodel.dart';

abstract final class FriendshipActionHandler {
  static void _invalidateRelatedProviders(
    WidgetRef ref,
    String targetUsername,
  ) {
    ref.invalidate(friendsViewModelProvider);
    ref.invalidate(userSearchViewModelProvider);
    ref.invalidate(userProfileViewModelProvider(targetUsername));
    ref.invalidate(blockedUsersViewModelProvider);
  }

  static Future<Result<void>> sendRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final useCase = ref.read(sendFriendRequestUseCaseProvider);
    final result = await useCase.execute(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님에게 친구 요청을 보냈습니다.')),
        );

        _invalidateRelatedProviders(ref, targetUser.username);
        return const Result.ok(null);
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
        return Result.error(error);
    }
  }

  static Future<Result<void>> cancelRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final useCase = ref.read(cancelFriendRequestUseCaseProvider);
    final result = await useCase.execute(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(
            content: Text('${targetUser.nickname} 님에게 보낸 친구 요청을 취소했습니다.'),
          ),
        );

        _invalidateRelatedProviders(ref, targetUser.username);
        return const Result.ok(null);
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
        return Result.error(error);
    }
  }

  static Future<Result<void>> acceptRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final useCase = ref.read(acceptFriendRequestUseCaseProvider);
    final result = await useCase.execute(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님의 친구 요청을 수락했습니다.')),
        );

        _invalidateRelatedProviders(ref, targetUser.username);
        return const Result.ok(null);
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
        return Result.error(error);
    }
  }

  static Future<Result<void>> declineRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final useCase = ref.read(declineFriendRequestUseCaseProvider);
    final result = await useCase.execute(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님의 친구 요청을 거절했습니다.')),
        );

        _invalidateRelatedProviders(ref, targetUser.username);
        return const Result.ok(null);
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
        return Result.error(error);
    }
  }

  static Future<Result<void>> removeFriend(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final useCase = ref.read(removeFriendUseCaseProvider);
    final result = await useCase.execute(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님을 친구 목록에서 삭제했습니다.')),
        );

        _invalidateRelatedProviders(ref, targetUser.username);
        return const Result.ok(null);
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '친구 삭제 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
        return Result.error(error);
    }
  }

  static Future<Result<void>> blockUser(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final useCase = ref.read(blockUserUseCaseProvider);
    final result = await useCase.execute(targetUser);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님을 차단했습니다.')),
        );

        _invalidateRelatedProviders(ref, targetUser.username);
        return const Result.ok(null);
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '사용자 차단 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
        return Result.error(error);
    }
  }

  static Future<Result<void>> unblockUser(
    WidgetRef ref,
    BuildContext context,
    UserSummary targetUser,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final useCase = ref.read(unblockUserUseCaseProvider);
    final result = await useCase.execute(targetUser.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${targetUser.nickname} 님의 차단을 해제했습니다.')),
        );

        _invalidateRelatedProviders(ref, targetUser.username);
        return const Result.ok(null);
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '차단 해제 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
        return Result.error(error);
    }
  }
}
