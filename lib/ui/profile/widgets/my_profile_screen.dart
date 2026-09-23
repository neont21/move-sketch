import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/mock_sketch_list.dart';
import '../../../domain/models/mock_user.dart';
import '../../../routing/routes.dart';
import 'profile_grid.dart';
import 'modify_profile_dialog.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final MockUser user = MockUser(
    id: '@daniil_a_np',
    name: '다닐루쉬카',
    description: '가댜가댜',
  );

  List<MockUser> friends = [];
  late final MockSketchList _sketchList = MockSketchList.byUser(user.id);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.go(Routes.meSettings);
            },
            icon: Icon(Icons.settings),
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
                      const SizedBox(height: 4),
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
                          : const SizedBox.shrink(),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            Dialog(child: ModifyProfileDialog()),
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
                      context.go(Routes.meFriends);
                    },
                    child: Text(
                      '친구 ${friends.length}명',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(),
            Expanded(child: ProfileGrid(userId: user.id, sketchList: _sketchList, onTap: (index) {
            context.go(Routes.mePost(_sketchList.sketches[index].sketchId));
            }, )),
          ],
        ),
      ),
    );
  }
}
