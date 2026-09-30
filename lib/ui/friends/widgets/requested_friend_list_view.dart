import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/social/user.dart';
import 'friendship_action_handler.dart';
import 'user_card.dart';

class RequestedFriendListView extends ConsumerWidget {
  final List<UserSummary> requests;

  const RequestedFriendListView({super.key, required this.requests});

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
              onAccept: () => FriendshipActionHandler.acceptRequest(
                ref,
                context,
                requests[index],
              ),
              onDecline: () => FriendshipActionHandler.declineRequest(
                ref,
                context,
                requests[index],
              ),
            );
          },
        ),
        const Divider(height: 16),
        const SizedBox(height: 16),
      ],
    );
  }
}
