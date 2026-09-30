import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/social/user.dart';
import '../../friends/widgets/friendship_action_handler.dart';

class UserProfileActionButton extends ConsumerWidget {
  final UserSummary targetUser;
  final bool isFriend;
  final bool isSentRequest;
  final bool isReceivedRequest;
  final bool isBlocked;
  final String? description;

  const UserProfileActionButton({
    super.key,
    required this.targetUser,
    required this.isFriend,
    required this.isSentRequest,
    required this.isReceivedRequest,
    required this.isBlocked,
    this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (isFriend) {
      if (description != null && description!.isNotEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: Text(description!, style: textTheme.bodyMedium),
          ),
        );
      }
      return const SizedBox.shrink();
    } else if (isSentRequest) {
      return OutlinedButton(
        onPressed: () =>
            FriendshipActionHandler.cancelRequest(ref, context, targetUser),
        child: Text('친구 요청 취소', style: textTheme.bodyMedium),
      );
    } else if (isReceivedRequest) {
      return Row(
        spacing: 20,
        children: [
          OutlinedButton(
            onPressed: () =>
                FriendshipActionHandler.acceptRequest(ref, context, targetUser),
            style: OutlinedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(
              '친구 수락',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () => FriendshipActionHandler.declineRequest(
              ref,
              context,
              targetUser,
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: colorScheme.onPrimary,
              foregroundColor: colorScheme.primary,
            ),
            child: Text(
              '친구 거절',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
            ),
          ),
        ],
      );
    } else if (isBlocked) {
      return Text(
        '차단된 사용자입니다.',
        style: textTheme.labelMedium?.copyWith(color: colorScheme.error),
      );
    } else {
      return OutlinedButton(
        onPressed: () =>
            FriendshipActionHandler.sendRequest(ref, context, targetUser),
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: Text(
          '친구 요청',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
        ),
      );
    }
  }
}
