import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/social/user.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/user_avatar.dart';

class UserListDialog extends StatelessWidget {
  final String title;
  final List<UserSummary> userList;
  const UserListDialog({
    super.key,
    required this.title,
    required this.userList,
  });

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
                    final user = userList[index];
                    return ListTile(
                      onTap: () {
                        context.push(Routes.userProfile(user.username));
                      },
                      leading: UserAvatar(
                        username: user.username,
                        imageUrl: user.imageUrl,
                      ),
                      title: Text(user.nickname, style: textTheme.bodyLarge),
                      subtitle: Text(
                        '@${user.username}',
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
