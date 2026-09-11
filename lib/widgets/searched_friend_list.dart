import 'package:flutter/material.dart';
import '../models/mock_user.dart';
import '../widgets/user_card.dart';

class SearchedFriendList extends StatefulWidget {
  const SearchedFriendList({super.key});

  @override
  State<SearchedFriendList> createState() => _RequestedFriendListState();
}

class _RequestedFriendListState extends State<SearchedFriendList> {
  final List<MockUser> _resultList = [
    MockUser(id: '@result1', name: '사용자1'),
    MockUser(id: '@result2', name: '사용자2'),
    MockUser(id: '@result3', name: '사용자3'),
    MockUser(id: '@result4', name: '사용자4'),
    MockUser(id: '@result5', name: '사용자5'),
    MockUser(id: '@result6', name: '사용자6'),
    MockUser(id: '@result7', name: '사용자7'),
    MockUser(id: '@result8', name: '사용자8'),
    MockUser(id: '@result9', name: '사용자9'),
    MockUser(id: '@result10', name: '사용자10'),
  ];

  final List<MockUser> friendsList = [MockUser(id: '@result5', name: '사용자5')];
  final List<MockUser> sentRequestList = [
    MockUser(id: '@recommend2', name: '사용자2'),
    MockUser(id: '@result4', name: '사용자4'),
  ];
  final List<MockUser> receivedRequestList = [
    MockUser(id: '@recommend5', name: '사용자5'),
    MockUser(id: '@result7', name: '사용자7'),
  ];

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('검색 결과 ${_resultList.length}', style: textTheme.labelLarge),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _resultList.length,
          itemBuilder: (context, index) {
            bool isFriend = friendsList.any(
              (user) => user.id == _resultList[index].id,
            );
            bool isReceived = receivedRequestList.any(
              (user) => user.id == _resultList[index].id,
            );
            bool isSent = sentRequestList.any(
              (user) => user.id == _resultList[index].id,
            );
            return UserCard(
              user: _resultList[index],
              onSearch: true,
              isFriend: isFriend,
              isRequested: isReceived,
              isSent: isSent,
            );
          },
        ),
      ],
    );
  }
}
