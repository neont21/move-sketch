import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/models/mock_user.dart';

class MutualFriendsModal extends StatelessWidget {
  final List<MockUser> _mutualsList;
  const MutualFriendsModal({super.key, required this._mutualsList});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('함께 아는 친구', style: textTheme.headlineSmall),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _mutualsList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    context.push('/profile/${_mutualsList[index].id}');
                  },
                  leading: GestureDetector(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: const AssetImage(
                        'assets/default_profile.png',
                      ),
                    ),
                  ),
                  title: Text(
                    _mutualsList[index].name,
                    style: textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    _mutualsList[index].id,
                    style: textTheme.labelMedium,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
