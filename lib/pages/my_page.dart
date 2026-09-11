import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/mock_user.dart';
import '../widgets/profile_grid.dart';
import 'modify_profile_modal.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final MockUser user = MockUser(
    id: '@daniil_a_np',
    name: '다닐루쉬카',
    description: '가댜가댜',
  );

  List<MockUser> friends = [];

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.go('/me/settings');
            },
            icon: Icon(Icons.settings, color: colorScheme.tertiaryContainer),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: textTheme.bodyLarge),
                      Text(user.id, style: textTheme.labelMedium),
                      Container(height: 4),
                      user.description != null
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 12,
                                ),
                                child: Text(
                                  user.description!,
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.imageURL != null
                      ? NetworkImage(user.imageURL!)
                      : AssetImage('assets/default_profile.png'),
                ),
              ],
            ),
            Divider(color: Colors.transparent),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            Dialog(child: ModifyProfileModal()),
                      );
                    },
                    child: Text(
                      '프로필 편집',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.go('/me/friends');
                    },
                    child: Text(
                      '친구 ${friends.length}명',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.transparent,),
            Divider(),
            Expanded(child: ProfileGrid(userId: user.id)),
          ],
        ),
      ),
    );
  }
}
