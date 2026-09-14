import 'package:flutter/material.dart';
import '../models/mock_user.dart';
import '../dialogs/user_list_modal.dart';

final List<MockUser> mutualsList = [
  MockUser.byId('@user1'),
  MockUser.byId('@user2'),
  MockUser.byId('@user3'),
  MockUser.byId('@user4'),
  MockUser.byId('@user5'),
];

class MutualFriends extends StatelessWidget {
  final String userId;
  const MutualFriends({super.key, required this.userId});

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
          child: CircleAvatar(
            radius: 16,
            backgroundImage: mutualsList[0].imageURL != null
                ? NetworkImage(mutualsList[0].imageURL!)
                : AssetImage('assets/default_profile.png'),
          ),
        ),
      ),
    );
    images.add(const SizedBox(width: 40));
    if (mutualsList.length >= 2) {
      images.add(
        Positioned(
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surfaceContainer, width: 2),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: mutualsList[1].imageURL != null
                  ? NetworkImage(mutualsList[1].imageURL!)
                  : AssetImage('assets/default_profile.png'),
            ),
          ),
        ),
      );
      images.add(const SizedBox(width: 60));
    }
    if (mutualsList.length > 2) {
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
                '+${mutualsList.length - 2}',
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
    if (mutualsList.length == 1) {
      return mutualsList[0].name;
    } else if (mutualsList.length == 2) {
      return '${mutualsList[0].name}, ${mutualsList[1].name}';
    } else {
      return '${mutualsList[0].name}, ${mutualsList[1].name} 외 ${mutualsList.length - 2}명';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (mutualsList.isEmpty) {
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
                  child: UserListModal(
                    title: '함께 아는 친구',
                    userList: mutualsList,
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
