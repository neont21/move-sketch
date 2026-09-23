import 'package:flutter/material.dart';
import '../../../domain/models/mock_user.dart';
import 'user_card.dart';

class MyFriendListView extends StatefulWidget {
  const MyFriendListView({super.key});

  @override
  State<MyFriendListView> createState() => _MyFriendListViewState();
}

class _MyFriendListViewState extends State<MyFriendListView> {
  final List<MockUser> _friendList = [
    MockUser(id: '@friend1', name: '친구1'),
    MockUser(id: '@friend2', name: '친구2'),
    MockUser(id: '@friend3', name: '친구3'),
    MockUser(id: '@friend4', name: '친구4'),
    MockUser(id: '@friend5', name: '친구5'),
    MockUser(id: '@friend6', name: '친구6'),
    MockUser(id: '@friend7', name: '친구7'),
    MockUser(id: '@friend8', name: '친구8'),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('내 친구 ${_friendList.length}', style: textTheme.labelLarge),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _friendList.length,
          itemBuilder: (context, index) {
            return UserCard(user: _friendList[index], isFriend: true);
          },
        ),
      ],
    );
  }
}
