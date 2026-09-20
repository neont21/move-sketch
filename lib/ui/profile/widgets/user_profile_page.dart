import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/mock_sketch_list.dart';
import '../../../domain/models/mock_user.dart';
import '../../friends/widgets/mutual_friends.dart';
import 'profile_grid.dart';
import 'user_sheet_button.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late MockUser _user;

  final List<MockUser> friendsList = [MockUser.byId('@daniil_a_np')];
  final List<MockUser> sentRequestList = [];
  final List<MockUser> receivedRequestList = [MockUser.byId('@edenjint3927')];
  late final MockSketchList _sketchList = MockSketchList.byUser(_user.id);

  @override
  void initState() {
    super.initState();
    _user = MockUser.byId(widget.userId);
  }

  Widget _buildDescriptionOrButton(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (friendsList.any((user) => user.id == widget.userId)) {
      // 친구일 때
      return _user.description != null
          ? Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                child: Text(_user.description!, style: textTheme.bodyMedium),
              ),
            )
          : const SizedBox.shrink();
    } else if (sentRequestList.any((user) => user.id == widget.userId)) {
      // 친구 요청 보냈을 때
      return OutlinedButton(
        onPressed: () {
          setState(() {
            sentRequestList.remove(_user);
          });
        },
        child: Text('친구 요청 취소', style: textTheme.bodyMedium),
      );
    } else if (receivedRequestList.any((user) => user.id == widget.userId)) {
      // 친구 요청 받았을 때
      return OutlinedButton(
        onPressed: () {
          setState(() {
            friendsList.add(_user);
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: Text(
          '친구 수락',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
        ),
      );
    } else {
      // 완전히 남일 때
      return OutlinedButton(
        onPressed: () {
          setState(() {
            sentRequestList.add(_user);
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: Text(
          '친구 요청',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(actions: [UserSheetButton(userId: widget.userId)]),
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
                      Text(_user.name, style: textTheme.bodyLarge),
                      Text(_user.id, style: textTheme.labelMedium),
                      const SizedBox(height: 4),
                      _buildDescriptionOrButton(context),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _user.imageURL != null
                      ? NetworkImage(_user.imageURL!)
                      : AssetImage('assets/default_profile.png'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            friendsList.any((user) => user.id == widget.userId)
                ? const SizedBox.shrink()
                : MutualFriends(userId: widget.userId),
            Divider(),
            Expanded(
              child: friendsList.any((user) => user.id == widget.userId)
                  ? ProfileGrid(
                      userId: widget.userId,
                      sketchList: _sketchList,
                      onTap: (index) {
                        context.go(
                          '/feed/post/${_sketchList.sketches[index].sketchId}',
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        '친구가 되면 기록을 볼 수 있어요',
                        style: textTheme.labelMedium,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
