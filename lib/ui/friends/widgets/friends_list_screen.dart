import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import 'my_friend_list_view.dart';
import 'requested_friend_list_view.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구'),
        actions: [
          IconButton(
            onPressed: () {
              context.go(Routes.meFriendsSearch);
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [RequestedFriendListView(), MyFriendListView()],
          ),
        ),
      ),
    );
  }
}
