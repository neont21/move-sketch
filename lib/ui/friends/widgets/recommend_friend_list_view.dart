import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/social/recommended_user.dart';
import 'friendship_action_handler.dart';
import 'user_card.dart';

class RecommendFriendListView extends ConsumerWidget {
  final List<RecommendedUser> recommends;
  final Set<String> friendIds;
  final Set<String> sentRequestIds;
  final Set<String> receivedRequestIds;

  const RecommendFriendListView({
    super.key,
    required this.recommends,
    this.friendIds = const {},
    this.sentRequestIds = const {},
    this.receivedRequestIds = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (recommends.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('알 수도 있는 사람 ${recommends.length}', style: textTheme.labelLarge),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommends.length,
          itemBuilder: (context, index) {
            final targetUser = recommends[index].user;
            bool isFriend = friendIds.contains(targetUser.uid);
            bool isSent = sentRequestIds.contains(targetUser.uid);
            bool isReceived = receivedRequestIds.contains(targetUser.uid);
            return UserCard(
              user: targetUser,
              subtitle: recommends[index].subtitle,
              isFriend: isFriend,
              isRequested: isReceived,
              isSent: isSent,
              onSendRequest: () =>
                  FriendshipActionHandler.sendRequest(ref, context, targetUser),
              onCancelRequest: () => FriendshipActionHandler.cancelRequest(
                ref,
                context,
                targetUser,
              ),
              onAccept: () => FriendshipActionHandler.acceptRequest(
                ref,
                context,
                targetUser,
              ),
              onDecline: () => FriendshipActionHandler.declineRequest(
                ref,
                context,
                targetUser,
              ),
            );
          },
        ),
      ],
    );
  }
}
