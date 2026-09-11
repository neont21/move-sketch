import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/mock_user.dart';
import '../widgets/mutual_friends.dart';
import '../widgets/profile_grid.dart';
import '../widgets/user_sheet_button.dart';

class UserProfilePage extends StatefulWidget {
  final String _userId;
  const UserProfilePage({super.key, required this._userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late MockUser _user;

  final List<MockUser> friendsList = [];
  final List<MockUser> sentRequestList = [];
  final List<MockUser> receivedRequestList = [MockUser.byId('@edenjint3927')];

  @override
  void initState() {
    super.initState();
    _user = MockUser.byId(widget._userId);
  }

  Widget _buildDescriptionOrButton(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (friendsList.any((user) => user.id == widget._userId)) {
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
          : Container();
    } else if (sentRequestList.any((user) => user.id == widget._userId)) {
      // 친구 요청 보냈을 때
      return OutlinedButton(
        onPressed: () {
          setState(() {
            sentRequestList.remove(_user);
          });
        },
        child: Text('친구 요청 취소', style: textTheme.bodyMedium),
      );
    } else if (receivedRequestList.any((user) => user.id == widget._userId)) {
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
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        actions: [UserSheetButton(userId: widget._userId)],
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
                      Text(_user.name, style: textTheme.bodyLarge),
                      Text(_user.id, style: textTheme.labelMedium),
                      Container(height: 4),
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
            Divider(color: Colors.transparent),
            friendsList.any((user) => user.id == widget._userId)
                ? Container()
                : MutualFriends(userId: widget._userId),
            Divider(),
            Expanded(
              child: friendsList.any((user) => user.id == widget._userId)
                  ? ProfileGrid(userId: widget._userId)
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
