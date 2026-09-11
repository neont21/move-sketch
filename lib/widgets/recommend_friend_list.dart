import 'package:flutter/material.dart';
import '../models/mock_user.dart';
import '../widgets/user_card.dart';

class RecommendFriendList extends StatefulWidget {
  const RecommendFriendList({super.key});

  @override
  State<RecommendFriendList> createState() => _RequestedFriendListState();
}

class _RequestedFriendListState extends State<RecommendFriendList> {
  final List<MockUser> _recommendList = [
    MockUser(id: '@recommend1', name: '사용자1'),
    MockUser(id: '@recommend2', name: '사용자2'),
    MockUser(id: '@recommend3', name: '사용자3'),
    MockUser(id: '@recommend4', name: '사용자4'),
    MockUser(id: '@recommend5', name: '사용자5'),
    MockUser(id: '@recommend6', name: '사용자6'),
    MockUser(id: '@recommend7', name: '사용자7'),
    MockUser(id: '@recommend8', name: '사용자8'),
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
        Text(
          '알 수도 있는 사람 ${_recommendList.length}',
          style: textTheme.labelLarge,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _recommendList.length,
          itemBuilder: (context, index) {
            bool isFriend = friendsList.any(
              (user) => user.id == _recommendList[index].id,
            );
            bool isReceived = receivedRequestList.any(
              (user) => user.id == _recommendList[index].id,
            );
            bool isSent = sentRequestList.any(
              (user) => user.id == _recommendList[index].id,
            );
            return UserCard(
              user: _recommendList[index],
              onRecommend: true,
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
