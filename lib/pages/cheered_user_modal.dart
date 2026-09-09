import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/models/mock_user.dart';

class CheeredUserModal extends StatelessWidget {
  final List<MockUser> _cheeredUser;
  const CheeredUserModal({super.key, required this._cheeredUser});

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
            Text('응원한 친구', style: textTheme.headlineSmall),
            (_cheeredUser.isEmpty)
                ? Text('아직 응원한 친구가 없습니다.', style: textTheme.labelMedium)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cheeredUser.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          context.go('/profile/${_cheeredUser[index].id}');
                        },
                        leading: GestureDetector(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: const AssetImage(
                              'assets/default_profile.png',
                            ),
                          ),
                        ),
                        title: Text(_cheeredUser[index].name, style: textTheme.bodyLarge,),
                        subtitle: Text(_cheeredUser[index].id, style: textTheme.labelMedium,),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
