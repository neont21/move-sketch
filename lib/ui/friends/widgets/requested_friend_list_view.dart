import 'package:flutter/material.dart';
import '../../../domain/models/mock_user.dart';
import 'user_card.dart';

class RequestedFriendListView extends StatefulWidget {
  const RequestedFriendListView({super.key});

  @override
  State<RequestedFriendListView> createState() => _RequestedFriendListViewState();
}

class _RequestedFriendListViewState extends State<RequestedFriendListView> {
  final List<MockUser> _requestedList = [
    MockUser(id: '@user1', name: '사용자1'),
    MockUser(id: '@user2', name: '사용자2'),
    MockUser(id: '@user3', name: '사용자3'),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (_requestedList.isEmpty) {
      return const SizedBox.shrink();
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
