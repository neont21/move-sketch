import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/social/user.dart';
import 'friendship_action_handler.dart';
import 'user_card.dart';

class SearchedFriendListView extends ConsumerWidget {
  final List<UserSummary> searchedUsers;
  final Set<String> friendIds;
  final Set<String> sentRequestIds;
  final Set<String> receivedRequestIds;

  const SearchedFriendListView({
    super.key,
    required this.searchedUsers,
    this.friendIds = const {},
    this.sentRequestIds = const {},
    this.receivedRequestIds = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (searchedUsers.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('검색 결과 0', style: textTheme.labelLarge),
          const SizedBox(height: 48),
          Center(child: Text('검색 결과가 없습니다.')),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('검색 결과 ${searchedUsers.length}', style: textTheme.labelLarge),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: searchedUsers.length,
          itemBuilder: (context, index) {
            final targetUser = searchedUsers[index];
            bool isFriend = friendIds.contains(targetUser.uid);
            bool isSent = sentRequestIds.contains(targetUser.uid);
            bool isReceived = receivedRequestIds.contains(targetUser.uid);
            return UserCard(
              user: targetUser,
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
