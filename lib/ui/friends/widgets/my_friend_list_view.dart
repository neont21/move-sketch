import 'package:flutter/material.dart';
import '../../../domain/models/social/user.dart';
import 'user_card.dart';

class MyFriendListView extends StatelessWidget {
  final List<UserSummary> friends;

  const MyFriendListView({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('내 친구 ${friends.length}', style: textTheme.labelLarge),
        if (friends.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            child: Center(
              child: Text(
                '아직 등록된 친구가 없습니다.\n상단 검색 버튼을 눌러 새로운 친구를 찾아보세요!',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return UserCard(user: friends[index], isFriend: true);
            },
          ),
      ],
    );
  }
}
