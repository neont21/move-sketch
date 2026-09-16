import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/mock_user.dart';

class UserListDialog extends StatelessWidget {
  final String title;
  final List<MockUser> userList;
  const UserListDialog({super.key, required this.title, required this.userList});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 20,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.headlineSmall),
          (userList.isEmpty)
              ? Text('아직 $title가 없습니다.', style: textTheme.labelMedium)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        context.push('/profile/${userList[index].id}');
                      },
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: const AssetImage(
                          'assets/default_profile.png',
                        ),
                      ),
                      title: Text(
                        userList[index].name,
                        style: textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        userList[index].id,
                        style: textTheme.labelMedium,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
