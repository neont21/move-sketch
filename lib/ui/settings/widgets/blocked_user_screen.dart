import 'package:flutter/material.dart';
import '../../../domain/models/mock_user.dart';
import '../../friends/widgets/user_card.dart';

List<MockUser> blockedList = [
  MockUser.byId('@blocked01'),
  MockUser.byId('@blocked02'),
];

class BlockedUserScreen extends StatelessWidget {
  const BlockedUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('차단한 사용자 관리')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: blockedList.length,
          itemBuilder: (context, index) {
            return UserCard(user: blockedList[index], onBlocked: true);
          },
        ),
      ),
    );
  }
}
