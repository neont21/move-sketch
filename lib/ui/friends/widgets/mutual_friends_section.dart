import 'package:flutter/material.dart';
import '../../../domain/models/social/user.dart';
import '../../core/widgets/user_avatar.dart';
import 'user_list_dialog.dart';

class MutualFriendsSection extends StatelessWidget {
  final List<UserSummary> mutualFriends;

  const MutualFriendsSection({super.key, required this.mutualFriends});

  List<Widget> _buildMutualFriendsImage(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    List<Widget> images = [];

    images.add(
      Positioned(
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.surfaceContainer, width: 2),
          ),
          child: UserAvatar(
            username: mutualFriends[0].username,
            imageUrl: mutualFriends[0].imageUrl,
            radius: 16,
          ),
        ),
      ),
    );
    images.add(const SizedBox(width: 40));
    if (mutualFriends.length >= 2) {
      images.add(
        Positioned(
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surfaceContainer, width: 2),
            ),
            child: UserAvatar(
              username: mutualFriends[1].username,
              imageUrl: mutualFriends[1].imageUrl,
              radius: 16,
            ),
          ),
        ),
      );
      images.add(const SizedBox(width: 60));
    }
    if (mutualFriends.length > 2) {
      images.add(
        Positioned(
          left: 40,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surfaceContainer, width: 2),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.outline,
              child: Text(
                '+${mutualFriends.length - 2}',
                style: textTheme.bodySmall,
              ),
            ),
          ),
        ),
      );
      images.add(const SizedBox(width: 80));
    }

    return images;
  }

  String _buildMutualFriendsText() {
    if (mutualFriends.length == 1) {
      return mutualFriends[0].nickname;
    } else if (mutualFriends.length == 2) {
      return '${mutualFriends[0].nickname}, ${mutualFriends[1].nickname}';
    } else {
      return '${mutualFriends[0].nickname}, ${mutualFriends[1].nickname} 외 ${mutualFriends.length - 2}명';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (mutualFriends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '함께 아는 친구',
          style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: UserListDialog(
                    title: '함께 아는 친구',
                    userList: mutualFriends,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: _buildMutualFriendsImage(context),
                ),
                Text(
                  _buildMutualFriendsText(),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
