import 'package:flutter/material.dart';
import '../models/mock_user.dart';
import '../widgets/user_card.dart';

class RequestedFriendList extends StatefulWidget {
  const RequestedFriendList({super.key});

  @override
  State<RequestedFriendList> createState() => _RequestedFriendListState();
}

class _RequestedFriendListState extends State<RequestedFriendList> {
  final List<MockUser> _requestedList = [
    MockUser(id: '@user1', name: '사용자1'),
    MockUser(id: '@user2', name: '사용자2'),
    MockUser(id: '@user3', name: '사용자3'),
  ];

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    if (_requestedList.isEmpty) {
      return Container();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('받은 요청 ${_requestedList.length}', style: textTheme.labelLarge),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _requestedList.length,
          itemBuilder: (context, index) {
            return UserCard(user: _requestedList[index], isRequested: true);
          },
        ),
        Divider(),
      ],
    );
  }
}
