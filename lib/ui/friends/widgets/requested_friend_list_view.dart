import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../view_models/friends_viewmodel.dart';
import 'user_card.dart';

class RequestedFriendListView extends ConsumerWidget {
  final List<UserSummary> requests;

  const RequestedFriendListView({super.key, required this.requests});

  void _onAcceptRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary requester,
  ) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(friendsViewModelProvider.notifier)
        .acceptFriendRequest(requester.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${requester.nickname} 님의 친구 요청을 수락했습니다.')),
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

  void _onDeclineRequest(
    WidgetRef ref,
    BuildContext context,
    UserSummary requester,
  ) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(friendsViewModelProvider.notifier)
        .declineFriendRequest(requester.uid);

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          SnackBar(content: Text('${requester.nickname} 님의 친구 요청을 거절했습니다.')),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('받은 요청 ${requests.length}', style: textTheme.labelLarge),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return UserCard(
              user: requests[index],
              isRequested: true,
              onAccept: () => _onAcceptRequest(ref, context, requests[index]),
              onDecline: () => _onDeclineRequest(ref, context, requests[index]),
            );
          },
        ),
        const Divider(height: 16),
        const SizedBox(height: 16),
      ],
    );
  }
}
